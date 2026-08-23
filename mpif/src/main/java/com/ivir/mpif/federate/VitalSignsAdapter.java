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

import com.ivir.mpif.simdata.*;
import devstudio.generatedcode.HlaLogicalTime;
import devstudio.generatedcode.HlaTimeStamp;
import devstudio.generatedcode.HlaVitalSigns;
import devstudio.generatedcode.HlaVitalSignsAttributes;
import devstudio.generatedcode.HlaVitalSignsListener;
import devstudio.generatedcode.HlaVitalSignsManager;
import devstudio.generatedcode.HlaVitalSignsUpdater;
import devstudio.generatedcode.exceptions.HlaAttributeNotOwnedException;
import devstudio.generatedcode.exceptions.HlaIllegalInstanceNameException;
import devstudio.generatedcode.exceptions.HlaInstanceNameInUseException;
import devstudio.generatedcode.exceptions.HlaInternalException;
import devstudio.generatedcode.exceptions.HlaNotConnectedException;
import devstudio.generatedcode.exceptions.HlaObjectInstanceIsRemovedException;
import devstudio.generatedcode.exceptions.HlaRestoreInProgressException;
import devstudio.generatedcode.exceptions.HlaRtiException;
import devstudio.generatedcode.exceptions.HlaSaveInProgressException;
import devstudio.generatedcode.exceptions.HlaUpdaterReusedException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class VitalSignsAdapter implements MmsFederateInitializationListener, HlaVitalSignsListener, ConcurrentDataStorageListener<VitalSigns>, ConcurrentEventListener<VitalSigns> {
    static final Logger logger = LoggerFactory.getLogger(VitalSignsAdapter.class);
    private HlaVitalSignsManager hlaVitalSignsManager;
    private MmsFederate mmsFederate;

    @Autowired
    VitalSignsSimDataService vitalSignsSimDataService;

    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        this.hlaVitalSignsManager = mmsFederate.getHlaWorld().getHlaVitalSignsManager();
        this.hlaVitalSignsManager.addHlaVitalSignsDefaultInstanceListener(this);
        this.hlaVitalSignsManager.setHlaVitalSignsDefaultOwnershipListener(new VitalSignsOwnershipListener(vitalSignsSimDataService));
        vitalSignsSimDataService.addDataStorageListener(this);
        vitalSignsSimDataService.addEventListener(this);
    }

    private String acquireOwnershipByPatientIdOrReturnErrorMessage(VitalSigns vitalSigns){
        if(vitalSigns.getOwnershipState().hasOwnership()){
            logger.warn("Requesting acquire ownership of VitalSigns with patient ID {} but already have ownership, skipping acquire request", vitalSigns.getId());
            return "Already have ownership of this VitalSigns, skipping acquire request";
        }

        HlaVitalSigns hlaVitalSigns = hlaVitalSignsManager.getVitalSignsByHlaInstanceName(vitalSigns.getInstanceName());
        if(hlaVitalSigns == null){
            logger.warn("VitalSigns with patient ID {} is not found on the federation, cannot acquire ownership", vitalSigns.getId());
            return "VitalSigns with patient ID " + vitalSigns.getId() + " is not found on the federation";
        }

        try {
            hlaVitalSigns.acquireOwnership(getOwnershipSet());
            vitalSigns.setOwnershipState(OwnershipState.ACQUIRING_OWNERSHIP);
            vitalSignsSimDataService.put(vitalSigns);
            return null;
        } catch (Exception e) {
            logger.error("Exception attempting to acquire ownership", e);
            return "Exception attempting to acquire ownership: " + e.getMessage();
        }
    }

    private Set<HlaVitalSignsAttributes.Attribute> getOwnershipSet(){
        return Arrays.stream(HlaVitalSignsAttributes.Attribute.values())
                .filter((att)->!att.equals(HlaVitalSignsAttributes.Attribute.HLA_PRIVILEGE_TO_DELETE_OBJECT))
                .collect(Collectors.toSet());
    }

    //-----------------------------------------------------------------------------------------------------------------
    //                                  HlaVitalSignsListener Implementation
    //-----------------------------------------------------------------------------------------------------------------

    @Override
    public void attributesUpdated(HlaVitalSigns hlaVitalSigns, Set<HlaVitalSignsAttributes.Attribute> attributes, HlaTimeStamp timeStamp, HlaLogicalTime logicalTime) {
        boolean newEntity = false;
        logger.info("Received update for VitalSigns");
        if (!hlaVitalSigns.hasPatientId()) {
            logger.info("HlaVitalSigns did not have a patient id, skipping");
            return;
        }

        VitalSigns vitalSigns = vitalSignsSimDataService.get(hlaVitalSigns.getPatientId());
        if((vitalSigns != null) && vitalSigns.getOwnershipState().hasOwnership()){
            //we own this entity, ignore updates
            return;
        }
        if((vitalSigns == null) && hlaVitalSigns.isLocal()){
            //we created this entity, ignore updates
            return;
        }

        if (vitalSigns == null) {
            vitalSigns = new VitalSigns();
            vitalSigns.setId(hlaVitalSigns.getPatientId());
            vitalSigns.setLocal(false);
            vitalSigns.setOwnershipState(OwnershipState.DISCOVERED);
            newEntity = true;
        }
        if (vitalSigns.getInstanceName() == null) {
            vitalSigns.setInstanceName(hlaVitalSigns.getHlaInstanceName());
        }
        for (HlaVitalSignsAttributes.Attribute attribute : attributes) {
            switch (attribute) {
                case PATIENT_ID:
                    vitalSigns.setId(hlaVitalSigns.getPatientId());
                    break;
                case HEART_RATE:
                    vitalSigns.setHeartRate(hlaVitalSigns.getHeartRate());
                    break;
                case DIASTOLIC_BLOOD_PRESSURE:
                    vitalSigns.setDiastolicBloodPressure(hlaVitalSigns.getDiastolicBloodPressure());
                    break;
                case SYSTOLIC_BLOOD_PRESSURE:
                    vitalSigns.setSystolicBloodPressure(hlaVitalSigns.getSystolicBloodPressure());
                    break;
                case PERIPHERAL_OXYGEN_SATURATION:
                    vitalSigns.setOxygenSaturation(hlaVitalSigns.getPeripheralOxygenSaturation());
                    break;
                case TEMPERATURE_FAHRENHEIT:
                    vitalSigns.setTemperatureFahrenheit(hlaVitalSigns.getTemperatureFahrenheit());
                    break;
                case RESPIRATION_END_TIDAL_CARBON_DIOXIDE:
                    vitalSigns.setRespirationETco2(hlaVitalSigns.getRespirationEndTidalCarbonDioxide());
                    break;
                case RESPIRATION_RATE:
                    vitalSigns.setRespirationRate(hlaVitalSigns.getRespirationRate());
                    break;
            }
            vitalSigns.setTimeStamp(timeStamp.getValue());
        }
        if (newEntity) {
            vitalSignsSimDataService.addVitalSigns(vitalSigns);
        } else {
            vitalSignsSimDataService.put(vitalSigns);
        }
    }

    //-----------------------------------------------------------------------------------------------------------------
    //                           SimData Listener Implementation
    //-----------------------------------------------------------------------------------------------------------------
    @Override
    public void entityAdded(VitalSigns newEntity) {
        if(newEntity.getOwnershipState().hasOwnership()){
            if(!mmsFederate.isConnected()){
                return;
            }
            try {
                //publish vitalSigns
                HlaVitalSigns hlaVitalSigns = null;
                if(newEntity.getInstanceName() != null){
                    hlaVitalSigns = hlaVitalSignsManager.createLocalHlaVitalSigns(newEntity.getInstanceName());
                }else{
                    hlaVitalSigns = hlaVitalSignsManager.createLocalHlaVitalSigns();
                    newEntity.setInstanceName(hlaVitalSigns.getHlaInstanceName());
                }
                ArrayList<VitalSigns.Attributes> attributesIncluded = buildAttributesOfPresentValues(newEntity);

                newEntity.setOwnershipState(OwnershipState.CREATED);
                vitalSignsSimDataService.putVitalSignsDoNotFireListeners(newEntity);
                sendVitalSigns(hlaVitalSigns, newEntity);
            } catch (HlaInternalException | HlaRtiException | HlaSaveInProgressException
                     | HlaRestoreInProgressException | HlaIllegalInstanceNameException
                     | HlaInstanceNameInUseException | HlaUpdaterReusedException
                     | HlaObjectInstanceIsRemovedException | HlaNotConnectedException ex ) {
                logger.error("Could not create", ex);
            }

        }//not ghosted (local)
    }

    private ArrayList<VitalSigns.Attributes> buildAttributesOfPresentValues(VitalSigns entity){
        ArrayList<VitalSigns.Attributes> attributesIncluded = new ArrayList<>();
        if(entity.getDiastolicBloodPressure() != null){
            attributesIncluded.add(VitalSigns.Attributes.DIASTOLIC_BP);
        }
        if(entity.getHeartRate() != null){
            attributesIncluded.add(VitalSigns.Attributes.HEART_RATE);
        }
        if(entity.getId() != null){
            attributesIncluded.add(VitalSigns.Attributes.ID);
        }
        if(entity.getOxygenSaturation() != null){
            attributesIncluded.add(VitalSigns.Attributes.O2_SAT);
        }
        if(entity.getRespirationETco2() != null){
            attributesIncluded.add(VitalSigns.Attributes.RESP_ETCO2);
        }
        if(entity.getRespirationRate() != null){
            attributesIncluded.add(VitalSigns.Attributes.RESP_RATE);
        }
        if(entity.getSystolicBloodPressure() != null){
            attributesIncluded.add(VitalSigns.Attributes.SYSTOLIC_BP);
        }
        if(entity.getTemperatureFahrenheit() != null){
            attributesIncluded.add(VitalSigns.Attributes.TEMP_F);
        }
        return attributesIncluded;
    }

    @Override
    public synchronized void entityUpdated(VitalSigns entity) {
        if(!mmsFederate.isConnected()){
            return;
        }
        if(!entity.getOwnershipState().hasOwnership()) {
            return;
        }

        if(entity.getInstanceName() == null){
            entityAdded(entity);
            return;
        }

        HlaVitalSigns hlaVitalSigns = hlaVitalSignsManager.getVitalSignsByHlaInstanceName(entity.getInstanceName());
        if(hlaVitalSigns == null) {
            entityAdded(entity);
        }else{
            sendVitalSigns(hlaVitalSigns, entity);
        }

    }

    private synchronized void sendVitalSigns(HlaVitalSigns hlaVitalSigns, VitalSigns vitalSigns){
        boolean updated = false;
        HlaVitalSignsUpdater  hlaVitalSignsUpdater = hlaVitalSigns.getHlaVitalSignsUpdater();

        for(VitalSigns.Attributes attribute : vitalSigns.getUpdatedAttributes()){
            switch(attribute){
                case DIASTOLIC_BP: hlaVitalSignsUpdater.setDiastolicBloodPressure(vitalSigns.getDiastolicBloodPressure());
                    updated = true;
                    break;
                case HEART_RATE: hlaVitalSignsUpdater.setHeartRate(vitalSigns.getHeartRate());
                    updated = true;
                    break;
                case ID: hlaVitalSignsUpdater.setPatientId(vitalSigns.getId());
                    updated = true;
                    break;
                case O2_SAT: hlaVitalSignsUpdater.setPeripheralOxygenSaturation(vitalSigns.getOxygenSaturation());
                    updated = true;
                    break;
                case RESP_ETCO2: hlaVitalSignsUpdater.setRespirationEndTidalCarbonDioxide(vitalSigns.getRespirationETco2());
                    updated = true;
                    break;
                case RESP_RATE: hlaVitalSignsUpdater.setRespirationRate(vitalSigns.getRespirationRate());
                    updated = true;
                    break;
                case SYSTOLIC_BP: hlaVitalSignsUpdater.setSystolicBloodPressure(vitalSigns.getSystolicBloodPressure());
                    updated = true;
                    break;
                case TEMP_F: hlaVitalSignsUpdater.setTemperatureFahrenheit(vitalSigns.getTemperatureFahrenheit());
                    updated = true;
                    break;
                default: break;
            }
        }

        if(updated) {
            try {
                hlaVitalSignsUpdater.sendUpdate();
            } catch (HlaNotConnectedException | HlaAttributeNotOwnedException
                     | HlaUpdaterReusedException | HlaInternalException
                     | HlaRtiException | HlaObjectInstanceIsRemovedException
                     | HlaSaveInProgressException | HlaRestoreInProgressException ex) {
                logger.error("Could not update VitalSigns",ex);
            }
        }
    }


    @Override
    public List<String> getInterestedEvents() {
       return List.of(VitalSignsSimDataService.EVENT_ACQUIRE_OWNERSHIP_REQUESTED);
    }

    @Override
    public void eventOccurred(VitalSigns entity, String event) {
        if(event.equalsIgnoreCase(VitalSignsSimDataService.EVENT_ACQUIRE_OWNERSHIP_REQUESTED)){
            acquireOwnershipByPatientIdOrReturnErrorMessage(entity);
        }
    }
}
