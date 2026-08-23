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

import com.ivir.mpif.dataws.model.MagicTransferWS;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.MagicTransfer;
import com.ivir.mpif.simdata.MagicTransferSimDataService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

@Component
public class MagicTransferSimDataMonitorForDataWs implements DataWebSocketStatusListener, ConcurrentDataStorageListener<MagicTransfer> {
    @Autowired
    DataWebSocketHandler dataWebSocketHandler;
    @Autowired
    MagicTransferSimDataService magicTransferSimDataService;

    @PostConstruct
    public void init(){
        dataWebSocketHandler.addStatusListener(this);
        magicTransferSimDataService.addDataStorageListener(this);
    }

    @Override
    public void entityAdded(MagicTransfer newEntity) {
        MagicTransferWS magicTransferWS = toWebSocketEntity(newEntity);
        dataWebSocketHandler.sendToAll(new DataMessage().setDataType("MagicTransfer").setDataPayload(magicTransferWS));
    }

    @Override
    public void entityUpdated(MagicTransfer entity) {
        //ignore
    }

    @Override
    public void webSocketConnected(WebSocketSession session) {
        magicTransferSimDataService.getAll().forEach(magicTransfer -> {
            MagicTransferWS magicTransferWS = toWebSocketEntity(magicTransfer);
            dataWebSocketHandler.sendMessage(session, new DataMessage().setDataType("MagicTransfer").setDataPayload(magicTransferWS));
        });
    }

    public MagicTransferWS toWebSocketEntity(MagicTransfer magicTransfer) {
        MagicTransferWS magicTransferWS = new MagicTransferWS();
        magicTransferWS.setPatientId(magicTransfer.getPatientId());
        magicTransferWS.setFacilityId(magicTransfer.getFacilityId());
        magicTransferWS.setLocal(magicTransfer.isLocal());
        return magicTransferWS;
    }

}
