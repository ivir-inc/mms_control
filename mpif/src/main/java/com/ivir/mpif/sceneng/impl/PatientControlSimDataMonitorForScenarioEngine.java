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
import com.ivir.mpif.sceneng.ScenarioEngineService;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.PatientControl;
import com.ivir.mpif.simdata.PatientControlSimDataService;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Set;

@Component
public class PatientControlSimDataMonitorForScenarioEngine implements ConcurrentDataStorageListener<PatientControl> {
    Logger logger = LoggerFactory.getLogger(this.getClass());
    @Autowired
    PatientControlSimDataService patientControlSimDataService;

    @Autowired
    ScenarioEngineService scenarioEngineService;

    //NOTE Disabling listeners for right now to turn off scenario engine noise
//    @PostConstruct
//    public void initialize(){
//        patientControlSimDataService.addDataStorageListener(this);
//    }
//
    @Override
    public void entityAdded(PatientControl newEntity) {
        PatientId patientId = newEntity.getPatient();
        if(scenarioEngineService.hasPatient(patientId)) {
            switch (newEntity.getCommand()) {
                case START -> scenarioEngineService.startScenario(patientId);
                case RESUME -> scenarioEngineService.resumeScenario(patientId);
                case STOP, PAUSE -> scenarioEngineService.stopScenario(patientId);
            }
        }else{
            logger.debug("Patient {} is not register with the scenario engine. Ignoring", patientId);
        }
    }

    @Override
    public void entityUpdated(PatientControl entity) {
        logger.warn("entityUpdated was not expected to be called for this listener.");
    }
}
