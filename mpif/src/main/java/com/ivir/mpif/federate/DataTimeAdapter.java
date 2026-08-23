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

package com.ivir.mpif.federate;

import com.ivir.mpif.simdata.ClockType;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.DateTime;
import com.ivir.mpif.simdata.DateTimeSimDataService;
import devstudio.generatedcode.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Optional;
import java.util.Set;

@Component
public class DataTimeAdapter implements MmsFederateInitializationListener, HlaDateTimeListener, ConcurrentDataStorageListener<DateTime> {
    private Logger logger = LoggerFactory.getLogger(this.getClass());
    private HlaDateTimeManager hlaDateTimeManager;
    private HlaDateTime hlaDateTime;
    private MmsFederate mmsFederate;

    @Autowired
    private DateTimeSimDataService dateTimeSimDataService;

    //******************************************************************************************************************
    //                         MmsFederateInitializationListener Implementation
    //******************************************************************************************************************
    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        this.hlaDateTimeManager = mmsFederate.getHlaWorld().getHlaDateTimeManager();
        this.hlaDateTimeManager.addHlaDateTimeDefaultInstanceListener(this);
        dateTimeSimDataService.addDataStorageListener(this);
    }

    //******************************************************************************************************************
    //                                HlaDateTimeListener Implementation
    //******************************************************************************************************************
    @Override
    public void attributesUpdated(HlaDateTime hlaDateTime, Set<HlaDateTimeAttributes.Attribute> attributes, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if (!hlaDateTime.isLocal()) {
            Optional<DateTime> optDateTime = dateTimeSimDataService.getDateTime(ClockType.FEDERATION);
            if (optDateTime.isEmpty()) {
                DateTime dateTime = new DateTime(ClockType.FEDERATION);
                dateTime.setLocal(false);
                updateDataService(dateTime, hlaDateTime, attributes);
            } else if (!optDateTime.get().getLocal()) {
                updateDataService(optDateTime.get(), hlaDateTime, attributes);
            } else {
                logger.warn("HLA Date Time update received, but MPIF claims ownership");
            }
        }
    }

    private void updateDataService(DateTime dateTime, HlaDateTime hlaDateTime, Set<HlaDateTimeAttributes.Attribute> attributes) {
        for (HlaDateTimeAttributes.Attribute attribute : attributes) {
            switch (attribute) {
                case CURRENT_DATE_TIME:
                    dateTime.setCurrentDateTime(hlaDateTime.getCurrentDateTime());
                    break;
                case SIMULATED_DATE_TIME:
                    dateTime.setSimulatedDateTime(hlaDateTime.getSimulatedDateTime());
                    break;
                case SIMULATION_ELAPSED_TIME:
                    dateTime.setSimulationElapsedTime(hlaDateTime.getSimulationElapsedTime());
                    break;
                case TIME_SCALE:
                    dateTime.setTimeScale(hlaDateTime.getTimeScale());
                    break;
            }
        }
        dateTimeSimDataService.put(dateTime);
    }

    //******************************************************************************************************************
    //                                ConcurrentDataStorageListener Implementation
    //******************************************************************************************************************
    @Override
    public void entityAdded(DateTime newEntity) {
        if (mmsFederate.isConnected()) {
            if ((newEntity.getClockType() == ClockType.FEDERATION) && newEntity.getLocal()) {
                try {
                    hlaDateTime = hlaDateTimeManager.createLocalHlaDateTime();
                    HlaDateTimeUpdater updater = hlaDateTime.getHlaDateTimeUpdater();
                    updateAndSend(newEntity, updater);
                } catch (Exception ex) {
                    logger.error("Could not publish DateTime", ex);
                }
            }
        }
    }

    @Override
    public void entityUpdated(DateTime entity) {
        if (mmsFederate.isConnected()) {
            if ((entity.getClockType() == ClockType.FEDERATION) && entity.getLocal()) {
                try {
                    if (hlaDateTime == null) {
                        hlaDateTime = hlaDateTimeManager.createLocalHlaDateTime();
                    }
                    HlaDateTimeUpdater updater = hlaDateTime.getHlaDateTimeUpdater();
                    updateAndSend(entity, updater);
                } catch (Exception e) {
                    logger.error("Could not update DateTime", e);
                }
            }
        }
    }

    private void updateAndSend(DateTime dateTime, HlaDateTimeUpdater dateTimeUpdater){
        for(DateTime.Attributes attribute : dateTime.getUpdatedAttributes()){
            switch(attribute){
                case CURRENT_DATE_TIME -> dateTimeUpdater.setCurrentDateTime(dateTime.getCurrentDateTime());
                case SIMULATED_DATE_TIME -> dateTimeUpdater.setSimulatedDateTime(dateTime.getSimulatedDateTime());
                case SIMULATION_ELAPSED_TIME -> dateTimeUpdater.setSimulationElapsedTime(dateTime.getSimulationElapsedTime());
                case TIME_SCALE -> dateTimeUpdater.setTimeScale(dateTime.getTimeScale());
            }
        }
        try {
            dateTimeUpdater.sendUpdate();
        }catch (Exception e){
            throw new RuntimeException(e);
        }
    }
}
