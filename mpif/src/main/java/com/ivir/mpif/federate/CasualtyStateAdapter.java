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
import devstudio.generatedcode.datatypes.EvacuationPriorityEnum;
import devstudio.generatedcode.datatypes.TriageEnum;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Set;

@Component
public class CasualtyStateAdapter implements MmsFederateInitializationListener, HlaCasualtyStateListener, ConcurrentDataStorageListener<CasualtyState> {
    @Autowired
    private CasualtyStateSimDataService casualtyStateSimDataService;
    private static final Logger logger = LoggerFactory.getLogger(CasualtyStateAdapter.class);
    private MmsFederate mmsFederate;

    //---------------------------------------------------------------------------------------------
    //          MmsFederateInitializationListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        mmsFederate.getHlaWorld().getHlaCasualtyStateManager().addHlaCasualtyStateDefaultInstanceListener(this);
        casualtyStateSimDataService.addDataStorageListener(this);
        logger.info("CasualtyStateAdapter ready");
    }

    //---------------------------------------------------------------------------------------------
    //          HlaCasualtyStateListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void attributesUpdated(HlaCasualtyState hlaCasualtyState, Set<HlaCasualtyStateAttributes.Attribute> updateSet, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if (!hlaCasualtyState.isLocal()) {
            CasualtyState casualtyState = casualtyStateSimDataService.getByInstanceName(hlaCasualtyState.getHlaInstanceName());
            if (casualtyState == null) {
                casualtyState = new CasualtyState()
                        .setInstanceName(hlaCasualtyState.getHlaInstanceName())
                        .setLocal(false);
            }
            for (HlaCasualtyStateAttributes.Attribute attribute : updateSet) {
                switch (attribute) {
                    case FACILITY_ID -> casualtyState.setFacilityId(hlaCasualtyState.getFacilityId());
                    case PATIENT_ID -> casualtyState.setPatientId(hlaCasualtyState.getPatientId());
                    case EVACUATION_PRIORITY ->
                            casualtyState.setEvacuationPriority(EvacuationPriority.valueOf(hlaCasualtyState.getEvacuationPriority().toString()));
                    case TRIAGE_CLASSIFICATION ->
                            casualtyState.setTriageClassification(TriageClassification.valueOf(hlaCasualtyState.getTriageClassification().toString()));
                }
            }
            casualtyStateSimDataService.put(casualtyState);
        }
    }

    //---------------------------------------------------------------------------------------------
    //          ConcurrentDataStorageListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void entityAdded(CasualtyState newEntity) {
        if(newEntity.isLocal()){
            try{
                HlaCasualtyState hlaCasualtyState = mmsFederate.getHlaWorld().getHlaCasualtyStateManager().createLocalHlaCasualtyState();
                HlaCasualtyStateUpdater hlaCasualtyStateUpdater = hlaCasualtyState.getHlaCasualtyStateUpdater();
                updateHlaCasualtyState(newEntity, hlaCasualtyStateUpdater);
                hlaCasualtyStateUpdater.sendUpdate();
                newEntity.setInstanceName(hlaCasualtyState.getHlaInstanceName());
                casualtyStateSimDataService.put(newEntity, true);
            }catch (Exception e) {
                logger.error("Error adding local CasualtyState entity: {}", newEntity.getInstanceName(), e);
            }
        }
    }

    @Override
    public void entityUpdated(CasualtyState entity) {
        if (entity.isLocal()) {
            try {
                HlaCasualtyState hlaCasualtyState = mmsFederate.getHlaWorld().getHlaCasualtyStateManager().getCasualtyStateByHlaInstanceName(entity.getInstanceName());
                HlaCasualtyStateUpdater hlaCasualtyStateUpdater = hlaCasualtyState.getHlaCasualtyStateUpdater();
                updateHlaCasualtyState(entity, hlaCasualtyStateUpdater);
                hlaCasualtyStateUpdater.sendUpdate();
            } catch (Exception e) {
                logger.error("Failed to update casualtyState on federation", e);
            }
        }
    }

    private void updateHlaCasualtyState(CasualtyState casualtyState, HlaCasualtyStateUpdater hlaCasualtyStateUpdater) {
        casualtyState.getUpdatedAttributes().forEach(attribute -> {
            switch (attribute) {
                case FACILITY_ID_STR -> hlaCasualtyStateUpdater.setFacilityId(casualtyState.getFacilityId());
                case PATIENT_ID_STR -> hlaCasualtyStateUpdater.setPatientId(casualtyState.getPatientId());
                case EVACUATION_PRIORITY_ENUM -> hlaCasualtyStateUpdater.setEvacuationPriority(EvacuationPriorityEnum.valueOf(casualtyState.getEvacuationPriority().toString()));
                case TRIAGE_CLASSIFICATION_ENUM -> hlaCasualtyStateUpdater.setTriageClassification(TriageEnum.valueOf(casualtyState.getTriageClassification().toString()));
            }
        });
    }


}
