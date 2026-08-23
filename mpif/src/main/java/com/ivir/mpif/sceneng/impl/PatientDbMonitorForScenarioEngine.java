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

package com.ivir.mpif.sceneng.impl;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.patient.db.PatientEntity;
import com.ivir.mpif.patient.db.PatientRepository;
import com.ivir.mpif.patient.PatientSource;
import com.ivir.mpif.sceneng.ScenarioEngineService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class PatientDbMonitorForScenarioEngine {
    @Autowired
    PatientRepository patientRepository;

    @Autowired
    ScenarioEngineService scenarioEngineService;

    //NOTE Disabling listeners for right now to turn off scenario engine noise
//    @PostConstruct
//    public void initialize(){
//        patientRepository.addListener(this::patientChanged, this::patientChanged, this::patientChanged);
//        patientRepository.getAll().forEach(this::patientChanged);
//    }

    private void patientChanged(PatientEntity patientEntity){
        PatientId patientId = new PatientId(patientEntity.getId());
        if(patientEntity.getPhysiologySource() == PatientSource.INTERNAL){
           if(!scenarioEngineService.hasPatient(patientId)){
              scenarioEngineService.registerPatient(patientId);
           }
        }else{
            if(scenarioEngineService.hasPatient(patientId)){
                scenarioEngineService.unregisterPatient(patientId);
            }
        }
    }
}
