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

import com.ivir.mpif.dataws.model.TcccReceivedWs;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.TcccSimDataService;
import com.ivir.mpif.simdata.Tccc;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

@Component
public class TcccSimDataMonitorForDataWs implements ConcurrentDataStorageListener<Tccc>, DataWebSocketStatusListener {

    @Autowired
    DataWebSocketHandler dataWebSocketHandler;
    @Autowired
    TcccSimDataService tcccSimDataService;

    @PostConstruct
    public void initialize(){
        dataWebSocketHandler.addStatusListener(this);
        tcccSimDataService.addDataStorageListener(this);
    }


    @Override
    public void webSocketConnected(WebSocketSession session) {
        for (Tccc tccc : tcccSimDataService.getAll()){
            if(tccc.getPatientId() == null) continue;
            TcccReceivedWs tcccReceivedWs = new TcccReceivedWs();
            tcccReceivedWs.setPatientId(tccc.getPatientId());
            dataWebSocketHandler.sendMessage(session, new DataMessage().setDataType("TcccReceived").setDataPayload(tcccReceivedWs));
        }
    }

    @Override
    public void entityAdded(Tccc newEntity) {
        if(newEntity.getPatientId() == null) return;
        TcccReceivedWs tcccReceivedWs = new TcccReceivedWs();
        tcccReceivedWs.setPatientId(newEntity.getPatientId());
        dataWebSocketHandler.sendToAll(new DataMessage().setDataType("TcccReceived").setDataPayload(tcccReceivedWs));
    }

    @Override
    public void entityUpdated(Tccc entity) {
        if(entity.getPatientId() == null) return;
        TcccReceivedWs tcccReceivedWs = new TcccReceivedWs();
        tcccReceivedWs.setPatientId(entity.getPatientId());
        dataWebSocketHandler.sendToAll(new DataMessage().setDataType("TcccReceived").setDataPayload(tcccReceivedWs));
    }


}
