/*
 * Copyright 2026 IVIR Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.ivir.mpif.federate;

import com.ivir.mpif.simdata.*;
import devstudio.generatedcode.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Set;

@Component
public class EventAdapter implements MmsFederateInitializationListener, HlaEventListener, ConcurrentDataStorageListener<Event> {
    private static final Logger logger = LoggerFactory.getLogger(EventAdapter.class);
    private HlaEventManager eventManager;

    @Autowired
    private EventSimDataService simDataService;

    private MmsFederate mmsFederate;
    //---------------------------------------------------------------------------------------------
    //                MmsFederateInitializationListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        this.eventManager = mmsFederate.getHlaWorld().getHlaEventManager();
        this.eventManager.addHlaEventDefaultInstanceListener(this);
        this.simDataService.addDataStorageListener(this);
    }

    //---------------------------------------------------------------------------------------------
    //               DataStorageListener Implementation
    //---------------------------------------------------------------------------------------------

    @Override
    public void entityAdded(Event newEntity) {
        if((!mmsFederate.isConnected() || !newEntity.isLocal())){
            return;
        }
        try{
            HlaEvent hlaEvent = eventManager.createLocalHlaEvent();
            updateAndSend(newEntity, hlaEvent.getHlaEventUpdater());
        }catch (Exception e){
            logger.error("Failed to add entity", e);
            throw new RuntimeException(e);
        }
    }

    @Override
    public void entityUpdated(Event entity) {
        if((!mmsFederate.isConnected() || !entity.isLocal())){
            return;
        }
        if(entity.getInstanceName() != null){
            entityAdded(entity);
        }else{
            HlaEvent hlaEvent = eventManager.getEventByHlaInstanceName(entity.getInstanceName());
            if(hlaEvent != null){
                updateAndSend(entity, hlaEvent.getHlaEventUpdater());
            }else{
                entityAdded(entity);
            }
        }
    }

    private void updateAndSend(Event event, HlaEventUpdater hlaEventUpdater){
        for(Event.Attributes attribute : event.getUpdatedAttributes()){
            switch (attribute){
                case INSTRUCTOR_ID -> hlaEventUpdater.setInstructorId(event.getInstructorId());
                case DESCRIPTION -> hlaEventUpdater.setDescription(event.getDescription());
                case LEARNER_ID -> hlaEventUpdater.setLearnerId(event.getLearnerId());
                case LEARNER_ACTION_ENUM -> hlaEventUpdater.setLearnerAction(devstudio.generatedcode.datatypes.LearnerActionEnum.valueOf(event.getLearnerAction().toString()));
                case NOTES -> hlaEventUpdater.setNotes(event.getNotes());
                case PATIENT_ID -> hlaEventUpdater.setPatientId(event.getPatientId());
                case SOURCE -> hlaEventUpdater.setSource(event.getSource());
                case SIM_TIME -> hlaEventUpdater.setSimTime(event.getSimTime());
                case TIME -> hlaEventUpdater.setTime(event.getTime());
                case TEAM_ID -> hlaEventUpdater.setTeamId(event.getTeamId());
                case TYPE -> hlaEventUpdater.setType(devstudio.generatedcode.datatypes.EventTypeEnum.valueOf(event.getType().toString()));
                case TRAINING_FACILITY_ID_STR -> hlaEventUpdater.setTrainingFacilityId(event.getTrainingFacilityId());
            }
        }
        try {
            hlaEventUpdater.sendUpdate();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    //---------------------------------------------------------------------------------------------
    //               HlaEventListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void attributesUpdated(HlaEvent hlaEvent, Set<HlaEventAttributes.Attribute> set, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if (hlaEvent.isLocal()) {
            //only handle remote objects
            return;
        }
        boolean newEntity = false;
        Event simEvent = simDataService.getByInstanceName(hlaEvent.getHlaInstanceName())
                .orElse(createNewSimEvent(hlaEvent.getHlaInstanceName()));
        for (HlaEventAttributes.Attribute attribute : set) {
            switch (attribute) {
                case DESCRIPTION -> simEvent.setDescription(hlaEvent.getDescription());
                case INSTRUCTOR_ID -> simEvent.setInstructorId(hlaEvent.getInstructorId());
                case LEARNER_ACTION ->
                        simEvent.setLearnerAction(LearnerActionEnum.valueOf(hlaEvent.getLearnerAction().toString()));
                case LEARNER_ID -> simEvent.setLearnerId(hlaEvent.getLearnerId());
                case NOTES -> simEvent.setNotes(hlaEvent.getNotes());
                case PATIENT_ID -> simEvent.setPatientId(hlaEvent.getPatientId());
                case SOURCE -> simEvent.setSource(hlaEvent.getSource());
                case SIM_TIME -> simEvent.setSimTime(hlaEvent.getSimTime());
                case TIME -> simEvent.setTime(hlaEvent.getTime());
                case TYPE -> simEvent.setType(EventTypeEnum.valueOf(hlaEvent.getType().toString()));
                case TEAM_ID -> simEvent.setTeamId(hlaEvent.getTeamId());
                case TRAINING_FACILITY_ID -> simEvent.setTrainingFacilityId(hlaEvent.getTrainingFacilityId());
            }
        }
        simDataService.put(simEvent);
    }

    private Event createNewSimEvent(String instanceName){
       Event event = new Event();
       event.setLocal(false);
       event.setInstanceName(instanceName);
       return event;
    }
}
