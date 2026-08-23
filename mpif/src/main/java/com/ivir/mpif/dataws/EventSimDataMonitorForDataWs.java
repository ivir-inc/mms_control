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

package com.ivir.mpif.dataws;

import com.ivir.mpif.dataws.model.EventWs;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.Event;
import com.ivir.mpif.simdata.EventSimDataService;
import jakarta.annotation.PostConstruct;
import org.slf4j.LoggerFactory;
import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import static com.ivir.mpif.common.Utilities.doIfNotNull;

@Component
public class EventSimDataMonitorForDataWs implements ConcurrentDataStorageListener<Event>, DataWebSocketStatusListener {
    public static Logger logger = LoggerFactory.getLogger(EventSimDataMonitorForDataWs.class);

    @Autowired
    DataWebSocketHandler dataWebSocketHandler;
    @Autowired
    EventSimDataService eventSimDataService;

    @PostConstruct
    public void initialize(){
        dataWebSocketHandler.addStatusListener(this);
        eventSimDataService.addDataStorageListener(this);
        logger.info("Event to WebSocket started");
    }

    //*********************************************************************************************
    //                               Storage Listener
    //*********************************************************************************************

    @Override
    public void entityAdded(Event newEntity) {
        EventWs eventWs = new EventWs();
        sendEvent(eventWs, newEntity);
    }

    @Override
    public void entityUpdated(Event entity) {
        EventWs eventWs = new EventWs();
        sendEvent(eventWs, entity);
    }

    private void sendEvent(EventWs eventWs, Event eventDs){
        for(Event.Attributes attribute : eventDs.getUpdatedAttributes()){
            switch (attribute){
                case DESCRIPTION -> eventWs.setDescription(eventDs.getDescription());
                case ID -> eventWs.setId(eventDs.getId());
                case INSTANCE_NAME -> eventWs.setInstanceName(eventDs.getInstanceName());
                case INSTRUCTOR_ID -> eventWs.setInstructorId(eventDs.getInstructorId());
                case LEARNER_ACTION_ENUM -> eventWs.setAction(eventDs.getLearnerAction().toString());
                case LEARNER_ID -> eventWs.setLearnerId(eventDs.getLearnerId());
                case TRAINING_FACILITY_ID_STR -> eventWs.setFacilityId(eventDs.getTrainingFacilityId());
                case NOTES -> eventWs.setNotes(eventDs.getNotes());
                case PATIENT_ID -> eventWs.setPatientId(eventDs.getPatientId());
                case SIM_TIME -> eventWs.setSimTime(eventDs.getSimTime());
                case SOURCE -> eventWs.setSource(eventDs.getSource());
                case TIME -> eventWs.setTime(eventDs.getTime());
                case TYPE -> eventWs.setType(eventDs.getType().toString());
                case TEAM_ID -> eventWs.setTeamId(eventDs.getTeamId());
            }
        }
        if(eventDs.getUpdatedAttributes().size() > 0) {
            logger.debug("Sending event {}", eventWs);
            dataWebSocketHandler.sendToAll(new DataMessage().setDataType("Event").setDataPayload(eventWs));
        }
    }

    //*********************************************************************************************
    //                               DateWebSocketStatusListener Listener
    //*********************************************************************************************
    @Override
    public void webSocketConnected(WebSocketSession session) {
        for(Event event : eventSimDataService.getAllOrderAdded()){
            EventWs eventWs = new EventWs();
            doIfNotNull(event.getDescription(),eventWs::setDescription);
            doIfNotNull(event.getId(),eventWs::setId);
            doIfNotNull(event.getInstanceName(),eventWs::setInstanceName);
            doIfNotNull(event.getInstructorId(),eventWs::setInstructorId);
            doIfNotNull(event.getLearnerAction(),(action)->eventWs.setAction(action.toString()));
            doIfNotNull(event.getLearnerId(),eventWs::setLearnerId);
            doIfNotNull(event.getTrainingFacilityId(),eventWs::setFacilityId);
            doIfNotNull(event.getNotes(),eventWs::setNotes);
            doIfNotNull(event.getPatientId(),eventWs::setPatientId);
            doIfNotNull(event.getSimTime(), eventWs::setSimTime);
            doIfNotNull(event.getSource(), eventWs::setSource);
            doIfNotNull(event.getTime(), eventWs::setTime);
            doIfNotNull(event.getType(), (type)->eventWs.setType(type.toString()));
            doIfNotNull(event.getTeamId(), eventWs::setTeamId);

            dataWebSocketHandler.sendMessage(session, new DataMessage().setDataType("Event").setDataPayload(eventWs));
        }
    }

}
