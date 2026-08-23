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

import com.ivir.mpif.sceneng.ScenarioEngineService;
import com.ivir.mpif.simdata.ClockType;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.DateTime;
import com.ivir.mpif.simdata.DateTimeSimDataService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Set;

@Component
public class DateTimeSimDataMonitorForScenarioEngine implements ConcurrentDataStorageListener<DateTime> {
    @Autowired
    DateTimeSimDataService dateTimeSimDataService;

    @Autowired
    ScenarioEngineService scenarioEngineService;

    //NOTE Disabling listeners for right now to turn off scenario engine noise
//    @PostConstruct
//    public void initialize(){
//        dateTimeSimDataService.addDataStorageListener(this);
//    }

    @Override
    public void entityAdded(DateTime newEntity) {
        if(scenarioEngineService.usingFederationTime()){
            if(newEntity.getClockType() == ClockType.FEDERATION){
                scenarioEngineService.engineTick(newEntity.getSimulationElapsedTime());
            }
        }else{
            if(newEntity.getClockType() == ClockType.INTERNAL){
                scenarioEngineService.engineTick(newEntity.getSimulationElapsedTime());
            }
        }
    }

    @Override
    public void entityUpdated(DateTime entity) {
        if(scenarioEngineService.usingFederationTime()){
            if(entity.getClockType() == ClockType.FEDERATION){
                scenarioEngineService.engineTick(entity.getSimulationElapsedTime());
            }
        }else{
            if(entity.getClockType() == ClockType.INTERNAL){
                scenarioEngineService.engineTick(entity.getSimulationElapsedTime());
            }
        }
    }
}
