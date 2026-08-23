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

import com.ivir.mpif.MathUtils;
import com.ivir.mpif.dataws.model.VitalsWs;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.VitalSigns;
import com.ivir.mpif.simdata.VitalSignsSimDataService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.util.concurrent.ConcurrentHashMap;

import static com.ivir.mpif.common.Utilities.doIfNotNull;

@Component
public class PhysiologySimDataMonitorForDataWs implements ConcurrentDataStorageListener<VitalSigns>, DataWebSocketStatusListener {
    private ConcurrentHashMap<String, VitalsWs> patientIdToVitalsMap = new ConcurrentHashMap<>();
    @Autowired
    VitalSignsSimDataService physiologySimDataService;
    @Autowired
    DataWebSocketHandler dataWebSocketHandler;

    @PostConstruct
    public void init(){
        dataWebSocketHandler.addStatusListener(this);
        physiologySimDataService.addDataStorageListener(this);
    }

    @Override
    public void entityAdded(VitalSigns newEntity) {

        VitalsWs vitalsWs = new VitalsWs();
        vitalsWs.setPatientId(newEntity.getId());
        this.patientIdToVitalsMap.put(vitalsWs.getPatientId(), vitalsWs);

        sendPhysiology(vitalsWs, newEntity);

    }

    @Override
    public void entityUpdated(VitalSigns entity) {
        VitalsWs vitalsWs = this.patientIdToVitalsMap.get(entity.getId());

        sendPhysiology(vitalsWs, entity);
    }

    private void sendPhysiology(VitalsWs vitals, VitalSigns physiology){
        boolean updated = false;
        for(VitalSigns.Attributes attribute : physiology.getUpdatedAttributes()){
            switch(attribute){
                case HEART_RATE:
                    vitals.setHeartRate(Math.round(physiology.getHeartRate()));
                    updated = true;
                    break;
                case DIASTOLIC_BP:
                    vitals.setDiastolicBp(Math.round(physiology.getDiastolicBloodPressure()));
                    updated = true;
                    break;
                case O2_SAT:
                    vitals.setSpO2(physiology.getOxygenSaturation());
                    updated = true;
                    break;
                case RESP_RATE:
                    vitals.setRespiratoryRate(physiology.getRespirationRate());
                    updated = true;
                    break;
                case RESP_ETCO2:
                    vitals.setEtco2(physiology.getRespirationETco2());
                    updated = true;
                    break;
                case SYSTOLIC_BP:
                    vitals.setSystolicBp(Math.round(physiology.getSystolicBloodPressure()));
                    updated = true;
                    break;
                case TEMP_F:
                    vitals.setTemp(MathUtils.roundToNearestTenth(physiology.getTemperatureFahrenheit()).floatValue());
                    updated = true;
                    break;
                case OWNERSHIP_STATE_ENUM:
                    vitals.setOwnershipState(physiology.getOwnershipState());
                    updated = true;
                    break;
                default:
                    break;
            }
        }

        if(updated ) {
            dataWebSocketHandler.sendToAll(new DataMessage().setDataType("Vitals").setDataPayload(vitals));
        }
    }

    @Override
    public void webSocketConnected(WebSocketSession session) {
        physiologySimDataService.getAll().forEach((vitals)->{
            VitalsWs vitalsWs = new VitalsWs();
            vitalsWs.setPatientId(vitals.getId());
            doIfNotNull(vitals.getDiastolicBloodPressure(), (value)->vitalsWs.setDiastolicBp(Math.round(value)));
            doIfNotNull(vitals.getHeartRate(), (value)->vitalsWs.setHeartRate(Math.round(value)));
            doIfNotNull(vitals.getOxygenSaturation(), (value)->vitalsWs.setSpO2(value));
            doIfNotNull(vitals.getRespirationRate(), (value)->vitalsWs.setRespiratoryRate(value));
            doIfNotNull(vitals.getRespirationETco2(), (value)->vitalsWs.setEtco2(value));
            doIfNotNull(vitals.getSystolicBloodPressure(), (value)->vitalsWs.setSystolicBp(Math.round(value)));
            doIfNotNull(vitals.getTemperatureFahrenheit(), (value)->vitalsWs.setTemp(MathUtils.roundToNearestTenth(value).floatValue()));
            doIfNotNull(vitals.getOwnershipState(), (value)->vitalsWs.setOwnershipState(value));

            dataWebSocketHandler.sendMessage(session,new DataMessage().setDataType("Vitals").setDataPayload(vitalsWs));
        });
    }
}
