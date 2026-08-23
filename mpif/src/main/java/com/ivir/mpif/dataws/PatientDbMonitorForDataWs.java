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

import com.ivir.mpif.dataws.model.PatientDeletedWs;
import com.ivir.mpif.dataws.model.PatientWs;
import com.ivir.mpif.patient.db.PatientEntity;
import com.ivir.mpif.patient.db.PatientRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class PatientDbMonitorForDataWs{
    @Autowired
    DataWebSocketHandler dataWebSocketHandler;

    @Autowired
    PatientRepository patientRepository;

    @PostConstruct
    public void init(){
        patientRepository.addListener(this::newPatient,this::ignore,this::deletedPatient);
    }

    private void newPatient(PatientEntity patientEntity){
        PatientWs patientWs = new PatientWs();
        patientWs.setPatientCaseNum(patientEntity.getPatientCaseNum());
        patientWs.setId(patientEntity.getId());
        patientWs.setVisible(patientEntity.getVisible());
        patientWs.setSourceLocked(patientEntity.getSourceLocked());
        patientWs.setPhysiologySource(patientEntity.getPhysiologySource());
        dataWebSocketHandler.sendToAll(new DataMessage().setDataType("Patient").setDataPayload(patientWs));
    }

    private void deletedPatient(PatientEntity patientEntity){
        PatientDeletedWs patientDeletedWs = new PatientDeletedWs();
        patientDeletedWs.setPatientId(patientEntity.getId());
        dataWebSocketHandler.sendToAll(new DataMessage().setDataType("PatientDeleted").setDataPayload(patientDeletedWs));
    }

    private void ignore(PatientEntity patientEntity){
        //intentionally ignoring callback
    }
}
