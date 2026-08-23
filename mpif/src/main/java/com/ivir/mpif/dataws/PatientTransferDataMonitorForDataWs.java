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

import com.ivir.mpif.dataws.model.PatientTransferWs;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.PatientTransfer;
import com.ivir.mpif.simdata.PatientTransferSimDataService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class PatientTransferDataMonitorForDataWs implements ConcurrentDataStorageListener<PatientTransfer> {
    @Autowired
    DataWebSocketHandler dataWebSocketHandler;
    @Autowired
    PatientTransferSimDataService patientTransferSimDataService;

    @PostConstruct
    public void initialize() {
        patientTransferSimDataService.addDataStorageListener(this);
    }

    //*********************************************************************************************
    //                               Storage Listener
    //*********************************************************************************************
    @Override
    public void entityAdded(PatientTransfer newEntity) {
        PatientTransferWs patientTransferWs = new PatientTransferWs();
        sendPatientTransfer(patientTransferWs, newEntity);
    }

    @Override
    public void entityUpdated(PatientTransfer entity) {
        PatientTransferWs patientTransferWs = new PatientTransferWs();
        sendPatientTransfer(patientTransferWs, entity);
    }

    private void sendPatientTransfer(PatientTransferWs patientTransferWs, PatientTransfer patientTransferDs) {
        patientTransferWs.setPatientId(patientTransferDs.getPatientId());
        for (PatientTransfer.Attributes attribute : patientTransferDs.getUpdatedAttributes()) {
            switch (attribute) {
                case TRANSFER_STATE_ENUM -> patientTransferWs.setTransferState(patientTransferDs.getTransferState().toString());
                case ORIGIN_FACILITY_ID_STR -> patientTransferWs.setOriginFacilityId(patientTransferDs.getOriginFacilityId());
                case DESTINATION_FACILITY_ID_STR -> patientTransferWs.setDestinationFacilityId(patientTransferDs.getDestinationFacilityId());
            }
        }
        if(patientTransferDs.getUpdatedAttributes().size() > 0){
            dataWebSocketHandler.sendToAll(new DataMessage().setDataType("PatientTransfer")
                    .setDataPayload(patientTransferWs));
        }

    }

}
