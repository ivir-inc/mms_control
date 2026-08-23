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

import com.ivir.mpif.dataws.model.FederationControlWs;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.FederationControl;
import com.ivir.mpif.simdata.FederationControlSimDataService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

@Component
public class FederationControlDataMonitorForDataWs implements DataWebSocketStatusListener, ConcurrentDataStorageListener<FederationControl> {
    @Autowired
    DataWebSocketHandler dataWebSocketHandler;
    @Autowired
    FederationControlSimDataService federationControlDataService;

    @PostConstruct
    public void init(){
        dataWebSocketHandler.addStatusListener(this);
        federationControlDataService.addDataStorageListener(this);
    }

    //*********************************************************************************************
    // ConcurrentDataStorageListener<FederationControl>
    //*********************************************************************************************

    @Override
    public void entityAdded(FederationControl newEntity) {
        sendFederationControl(newEntity);
    }

    @Override
    public void entityUpdated(FederationControl entity) {
        sendFederationControl(entity);
    }

    private void sendFederationControl(FederationControl federationControl){
        FederationControlWs federationControlWs = new FederationControlWs();
        for(FederationControl.Attributes attribute : federationControl.getUpdatedAttributes()){
            switch(attribute){
                case AUTO_ID_LONG -> federationControlWs.setId(federationControl.getId());
                case COMMAND_ENUM -> federationControlWs.setCommand(federationControl.getCommand().toString());
                case PARAMETER_STR -> federationControlWs.setParameter(federationControl.getParameter());
                case TIME_INST -> {
                    if(federationControl.getTime() != null){
                        federationControlWs.setTime(federationControl.getTime().toEpochMilli());
                    } else {
                        federationControlWs.setTime(null);
                    }
                }
                case LOCAL_BOOL -> federationControlWs.setLocal(federationControl.getLocal());
            }
        }
        if(!federationControl.getUpdatedAttributes().isEmpty()){
            dataWebSocketHandler.sendToAll(new DataMessage().setDataType("FederationControl").setDataPayload(federationControlWs));
        }
    }

    //*********************************************************************************************
    // DataWebSocketStatusListener
    //*********************************************************************************************
    @Override
    public void webSocketConnected(WebSocketSession session) {
        for(FederationControl federationControl : federationControlDataService.getAllOrderAdded()){
            FederationControlWs federationControlWs = new FederationControlWs()
                    .setId(federationControl.getId())
                    .setCommand(federationControl.getCommand().toString())
                    .setParameter(federationControl.getParameter())
                    .setLocal(federationControl.getLocal())
                    .setTime(federationControl.getTime() != null ? federationControl.getTime().toEpochMilli() : null);
            dataWebSocketHandler.sendMessage(session, new DataMessage().setDataType("FederationControl").setDataPayload(federationControlWs));
        }
    }


}
