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

import com.ivir.mpif.mconfig.MpifConfigKey;
import com.ivir.mpif.mconfig.MpifConfigService;
import com.ivir.mpif.simdata.ClockType;
import com.ivir.mpif.simdata.DateTime;
import com.ivir.mpif.simdata.DateTimeSimDataService;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Optional;
import java.util.Timer;
import java.util.TimerTask;

@Service
public class ClockService {
    private Logger logger = LoggerFactory.getLogger(this.getClass());

    private boolean ownsFederationTime = false;
    private long startTimeMs = 0;
    private long elapsedTimeMs = 0;
    private long lastUpdateTimeMs = 0;
    private long simTimeMs = 0; //Simulation absolute time
    private int runRate = 1;
    private int updateRate = 1;
    private Timer updateTimer;
    private ClockState clockState = ClockState.STOPPED;

    @Autowired
    private DateTimeSimDataService dateTimeSimDataService;
    @Autowired
    private MpifConfigService mpifConfigService;

    @PostConstruct
    public void init(){
       ownsFederationTime = mpifConfigService.getPropertyAsBoolean(MpifConfigKey.OWNS_FEDERATION_TIME).orElse(false);
    }

    public ClockState getClockState(){
        return this.clockState;
    }

    public boolean getOwnsFederationTime(){
        return this.ownsFederationTime;
    }

    public void startClock(){
        if(clockState == ClockState.RUNNING){
            logger.debug("startClock called, but clock is already running");
            return;
        }
        if(clockState == ClockState.STOPPED){
            elapsedTimeMs = 0;
            startTimeMs = new Date().getTime();
            simTimeMs = startTimeMs;
            lastUpdateTimeMs = startTimeMs;
        }else if(clockState == ClockState.PAUSED){
            lastUpdateTimeMs = new Date().getTime();
        }

        updateTimer = new Timer("Update Timer");
        updateTimer.scheduleAtFixedRate(new UpdateTimerTask(), updateRate * 1000, updateRate * 1000);
        clockState = ClockState.RUNNING;
        logger.debug("Clock started");
    }
    
    public void stopClock(){
        if(updateTimer == null){
            logger.debug("Clock stop requested, but timer is already stopped");
            return;
        }
        updateTimer.cancel();
        updateTimer.purge();
        updateTimer = null;
        clockState = ClockState.STOPPED;
    }
    
    public void pauseClock(){
        if(updateTimer == null){
            logger.debug("Clock pause requested, but timer is already stopped");
            return;
        }
        updateTimer.cancel();
        updateTimer.purge();
        updateTimer = null;
        clockState = ClockState.PAUSED;
    }

    private void publishDateTime(){
        if(ownsFederationTime){
            DateTime fedDateTime = dateTimeSimDataService.getDateTime(ClockType.FEDERATION).orElse(
                    new DateTime(ClockType.FEDERATION).setTimeScale(runRate).setLocal(true));
            fedDateTime.setCurrentDateTime(new Date().getTime());
            fedDateTime.setSimulatedDateTime(simTimeMs);
            fedDateTime.setSimulationElapsedTime(elapsedTimeMs);
            dateTimeSimDataService.put(fedDateTime);
        }
        DateTime internalDateTime = dateTimeSimDataService.getDateTime(ClockType.INTERNAL).orElse(
                new DateTime(ClockType.INTERNAL).setTimeScale(runRate).setLocal(true));
        internalDateTime.setCurrentDateTime(new Date().getTime());
        internalDateTime.setSimulatedDateTime(simTimeMs);
        internalDateTime.setSimulationElapsedTime(elapsedTimeMs);
        dateTimeSimDataService.put(internalDateTime);
    }
    
    private void updateTime(){
        long nowTime = new Date().getTime();
        long deltaTimeMs = (nowTime - lastUpdateTimeMs) * runRate;
        elapsedTimeMs += deltaTimeMs;
        simTimeMs += deltaTimeMs;
        lastUpdateTimeMs = nowTime;        
        publishDateTime();
    }
    
    private class UpdateTimerTask extends TimerTask{

        @Override
        public void run() {
            updateTime();
        }
    
    }

}
