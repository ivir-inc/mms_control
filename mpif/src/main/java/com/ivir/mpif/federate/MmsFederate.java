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

import com.ivir.mpif.common.GlobalVariables;
import com.ivir.mpif.mconfig.MpifConfigKey;
import com.ivir.mpif.mconfig.MpifConfigService;
import devstudio.generatedcode.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

@Component
public class MmsFederate {
    private Logger logger = LoggerFactory.getLogger(MmsFederate.class);
    @Autowired
    MpifConfigService mpifConfigService;

    @Autowired
    List<MmsFederateInitializationListener> initializationListeners;

    private HlaWorld hlaWorld = null;
    private boolean connected = false;
    private String federateName = "FEDERATE";
    private String rtiHost = null;
    private String federationName = "FEDERATION";
    private String instanceNamePrefix = null;
    private ArrayList<String> federateList = new ArrayList<String>();

    private Timer fedListTimer = null;

    private MmsFederate() {
    }

    public HlaWorld getHlaWorld() {
        return hlaWorld;
    }

    public void addInitializationListener(MmsFederateInitializationListener listener){
        this.initializationListeners.add(listener);
    }

    private void initializeFederate() {
        mpifConfigService.getProperty(MpifConfigKey.FEDERATE).ifPresent(this::setFederateName);
        mpifConfigService.getProperty(MpifConfigKey.FEDERATION).ifPresent(this::setFederationName);
        System.setProperty("devstudio.generatedcode.federateName",this.getFederateName());
        System.setProperty("devstudio.generatedcode.federationName",this.getFederationName());
        logger.info("Connecting to {} with federate name {}", getFederationName(), getFederateName());
        hlaWorld = HlaWorld.Factory.create();
        GlobalVariables.setFederateName(getFederateName());
        notifyInitializationListeners();
    }

    private void notifyInitializationListeners(){
        logger.info("initializing {} adapters", initializationListeners.size());
        initializationListeners.forEach(listener -> listener.initializing(this));
    }

    public void connect() {
        initializeFederate();
        try {
            HlaLogicalTime logicalTime = hlaWorld.connect();
            connected();
            logger.info("Federated");
        } catch (Exception e) {
            System.out.println("Failed to connect: " + e.getMessage());
            logger.error("Failed to connect to federation", e);
        }
    }

    /**
     * fired when connected to the federation
     */
    private void connected(){
        federateName = hlaWorld.getFederateId().getFederateName();
        startFedListTimer();
        setConnected(true);
    }

//    private void updateFederateDataFromSetting() {
//        HlaSettings settings = hlaWorld.getSettings();
//        rtiHost = settings.getCrcHost();
//        federationName = settings.getFederationName();
//        federateName = settings.getFederateName();
//
//        instanceNamePrefix = getFederateName();
//        instanceNamePrefix = instanceNamePrefix.replaceAll("\\s", "");
//        instanceNamePrefix = instanceNamePrefix + ".";
//    }

    public boolean isConnected() {
        return connected;
    }

    public void setConnected(boolean isConnected) {
        connected = isConnected;
    }

    public String getFederateName() {
        return federateName;
    }

    public void setFederateName(String federateName){
        this.federateName = federateName;
    }

    public String getFederationName() {
        return federationName;
    }

    public void setFederationName(String fedName) {
        this.federationName = fedName;
    }

    public String getInstanceNamePrefix() {
        return this.instanceNamePrefix;
    }

    public String getRtiHost() {
        return rtiHost;
    }

    private void startFedListTimer(){
        if(this.fedListTimer == null){
            this.fedListTimer = new Timer("Fed List Timer");
            this.fedListTimer.schedule(new TimerTask(){
               @Override
                public void run() {
                    federateListChanged();
                }
            },0,1000);
        }
    }

    private void stopFedListTimer(){
        if(fedListTimer != null) {
            fedListTimer.cancel();
            fedListTimer.purge();
            fedListTimer = null;
        }
    }
 
    public void federateListChanged(){
        try {
            this.federateList.clear();
            for (HlaHLAfederate federate : this.hlaWorld.getHlaHLAfederateManager().getAllHlaHLAfederates()) {
                if (federate.hasHLAfederateName()) {
                    this.federateList.add(federate.getHLAfederateName());
                }
            }
        }catch(Exception e){
            logger.warn("getting federate name failed, will try again",e);
        }
    }
    
    public ArrayList<String> getFederateList(){
        return this.federateList;
    }

    public void disconnect() {
        try {
            stopFedListTimer();
            hlaWorld.disconnect();
            setConnected(false);
            logger.info("Federate disconnected");
        } catch (Exception e) {
        	System.out.println("Could not disconnect: " + e.getMessage());
        	logger.error("Failed to disconnect from the federation", e);
        }
    }
}
