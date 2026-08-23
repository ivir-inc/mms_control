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

package com.ivir.mpif.clock;

import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.FederationControl;
import com.ivir.mpif.simdata.FederationControlSimDataService;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Set;

@Component
public class FederationControlSimDataMonitorForClock implements ConcurrentDataStorageListener<FederationControl> {
    private Logger logger = LoggerFactory.getLogger(this.getClass());
    private FederationControlSimDataService federationControlSimDataService;
    private ClockService clockService;

    public FederationControlSimDataMonitorForClock(FederationControlSimDataService federationControlSimDataService,
                                                   ClockService clockService){
        this.federationControlSimDataService = federationControlSimDataService;
        this.clockService = clockService;
    }

    @PostConstruct
    public void init(){
        this.federationControlSimDataService.addDataStorageListener(this);
    }


    @Override
    public void entityAdded(FederationControl newEntity) {
       switch(newEntity.getCommand()){
           case START -> clockService.startClock();
           case STOP -> clockService.stopClock();
           case PAUSE -> clockService.pauseClock();
           case RESUME -> clockService.startClock();
       }
    }

    @Override
    public void entityUpdated(FederationControl entity) {
        logger.trace("Update is not supported by this monitor.");
    }
}
