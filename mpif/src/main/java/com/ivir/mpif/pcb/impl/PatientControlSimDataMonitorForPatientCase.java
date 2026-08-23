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

package com.ivir.mpif.pcb.impl;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.injury.InjuryService;
import com.ivir.mpif.pcb.PCInjury;
import com.ivir.mpif.pcb.PCVitals;
import com.ivir.mpif.pcb.PatientCaseService;
import com.ivir.mpif.simdata.*;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.function.Consumer;

@Component
public class PatientControlSimDataMonitorForPatientCase implements ConcurrentDataStorageListener<PatientControl> {
    Logger logger = LoggerFactory.getLogger(PatientControlSimDataMonitorForPatientCase.class);

    @Autowired
    InjuryService injuryService;

    @Autowired
    VitalSignsSimDataService vitalSignsSimDataService;

    @Autowired
    PatientCaseService patientCaseService;

    @Autowired
    PatientControlSimDataService patientControlSimDataService;

    @PostConstruct
    public void initialize(){
        patientControlSimDataService.addDataStorageListener(this);
    }

    @Override
    public void entityAdded(PatientControl newEntity) {
        PatientId patientId = newEntity.getPatient();
        if(newEntity.getCommand() == PatientControlCommandEnum.START){
            //send initial stuff
            patientCaseService.getPatientAssignment(patientId).ifPresent((patientCase)->{
                if(patientCase.getVitals() != null){
                    sendVitalSigns(patientCase.getVitals(), patientId);
                }
                patientCase.getInjuries().forEach((injury -> sendInjury(injury,patientId)));
            });
        }
    }

    private void sendInjury(PCInjury pcInjury, PatientId patientId){
        Injury injury = new Injury();
        injury.setDetail(pcInjury.getDetail());
        injury.setDescription(pcInjury.getDescription());
        injury.setHemorrhageRate(pcInjury.getHemorrhageRate());
        injury.setInjuryType(pcInjury.getInjuryType());
        injury.setLocation(pcInjury.getLocation());
        injury.setLocal(true);
        injury.setName(pcInjury.getName());
        injury.setPatientId(patientId.getIdAsString());
        injury.setMechanismOfInjury(pcInjury.getMechanismOfInjury());
        injury.setSeverity(pcInjury.getSeverity());
        injury.setTotalBodySurfaceArea(pcInjury.getTotalBodySurfaceArea());
        injuryService.apply(injury);
    }

    private void sendVitalSigns(PCVitals pcVitals, PatientId patientId){
        VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(patientId.getIdAsString());
        if(vitalSigns == null){
            vitalSigns = new VitalSigns()
                    .setLocal(true)
                    .setOwnershipState(OwnershipState.CREATED)
                    .setId(patientId.getIdAsString());
        }
        if(vitalSigns.isLocal()){
            ifNotNull(pcVitals.getDiastolicBp(),vitalSigns::setDiastolicBloodPressure);
            ifNotNull(pcVitals.getEtco2(),vitalSigns::setRespirationETco2);
            ifNotNull(pcVitals.getHeartRate(),vitalSigns::setHeartRate);
            ifNotNull(pcVitals.getRespiratoryRate(),vitalSigns::setRespirationRate);
            ifNotNull(pcVitals.getSpO2(),vitalSigns::setOxygenSaturation);
            ifNotNull(pcVitals.getSystolicBp(),vitalSigns::setSystolicBloodPressure);
            ifNotNull(pcVitals.getTemp(),vitalSigns::setTemperatureFahrenheit);
            vitalSignsSimDataService.put(vitalSigns);
        }
    }

    private <T> void ifNotNull(T value, Consumer<T> setCall){
        if(value != null){
            setCall.accept(value);
        }
    }

    @Override
    public void entityUpdated(PatientControl entity) {
        logger.warn("entityUpdated was not expected to be called for this listener.");
    }
}
