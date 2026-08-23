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

import com.ivir.mpif.simdata.CasualtyState;
import com.ivir.mpif.simdata.CasualtyStateSimDataService;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.dataws.model.CasualtyStateWs;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import static com.ivir.mpif.common.Utilities.doIfNotNull;

@Component
public class CasualtyStateDataMonitorForDataWs  implements ConcurrentDataStorageListener<CasualtyState>, DataWebSocketStatusListener {
    @Autowired
    DataWebSocketHandler dataWebSocketHandler;
    @Autowired
    CasualtyStateSimDataService casualtyStateSimDataService;

    @PostConstruct
    public void initialize(){
        dataWebSocketHandler.addStatusListener(this);
        casualtyStateSimDataService.addDataStorageListener(this);
    }

    //*********************************************************************************************
    //                               Storage Listener
    //*********************************************************************************************
    @Override
    public void entityAdded(CasualtyState newEntity) {
        sendCasualtyState(newEntity);
    }

    @Override
    public void entityUpdated(CasualtyState entity) {
        sendCasualtyState(entity);
    }

    private void sendCasualtyState(CasualtyState entity){
        CasualtyStateWs casualtyStateWs = new CasualtyStateWs();
        casualtyStateWs.setPatientId(entity.getPatientId());
        casualtyStateWs.setId(entity.getId());
        for(CasualtyState.Attributes attribute : entity.getUpdatedAttributes()){
            switch (attribute){
                case EVACUATION_PRIORITY_ENUM -> casualtyStateWs.setEvacuationPriority(entity.getEvacuationPriority().toString());
                case FACILITY_ID_STR -> casualtyStateWs.setFacilityId(entity.getFacilityId());
                case INSTANCE_NAME_STR -> casualtyStateWs.setInstanceName(entity.getInstanceName());
                case LOCAL_BOOL -> casualtyStateWs.setLocal(entity.isLocal());
                case TRIAGE_CLASSIFICATION_ENUM -> casualtyStateWs.setTriageClassification(entity.getTriageClassification().toString());
            }
        }
        if(entity.getUpdatedAttributes().size() > 0) {
            dataWebSocketHandler.sendToAll(new DataMessage().setDataType("CasualtyState").setDataPayload(casualtyStateWs));
        }
    }

    //*********************************************************************************************
    //                               WebSocket Status Listener
    //*********************************************************************************************
    @Override
    public void webSocketConnected(WebSocketSession session) {
        for(CasualtyState casualtyState : casualtyStateSimDataService.getAll()) {
            CasualtyStateWs casualtyStateWs = new CasualtyStateWs();
            doIfNotNull(casualtyState.getEvacuationPriority(), p -> casualtyStateWs.setEvacuationPriority(p.toString()));
            doIfNotNull(casualtyState.getFacilityId(), casualtyStateWs::setFacilityId);
            doIfNotNull(casualtyState.getInstanceName(), casualtyStateWs::setInstanceName);
            doIfNotNull(casualtyState.isLocal(), casualtyStateWs::setLocal);
            doIfNotNull(casualtyState.getPatientId(), casualtyStateWs::setPatientId);
            doIfNotNull(casualtyState.getTriageClassification(), t -> casualtyStateWs.setTriageClassification(t.toString()));
            doIfNotNull(casualtyState.getId(), casualtyStateWs::setId);

            dataWebSocketHandler.sendMessage(session, new DataMessage().setDataType("CasualtyState").setDataPayload(casualtyStateWs));
        }
    }
}
