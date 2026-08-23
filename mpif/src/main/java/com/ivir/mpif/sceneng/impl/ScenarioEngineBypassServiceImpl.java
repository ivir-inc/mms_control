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
import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientService;
import com.ivir.mpif.patient.PatientSource;
import com.ivir.mpif.sceneng.ScenarioEngineBypassService;
import com.ivir.mpif.simdata.OwnershipState;
import com.ivir.mpif.simdata.VitalSigns;
import com.ivir.mpif.simdata.VitalSignsSimDataService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class ScenarioEngineBypassServiceImpl implements ScenarioEngineBypassService {
    Logger logger = LoggerFactory.getLogger(ScenarioEngineBypassServiceImpl.class);

    @Autowired
    VitalSignsSimDataService vitalSignsSimDataService;

    @Autowired
    PatientService patientService;

    //NOTE:  this method does not used rate at this time.  It always makes the change immediately.
    @Override
    public void changeVitalsNow(String patientId, String vitalsType, Float targetVital, Float rate) {
        if(patientId == null || patientId.isEmpty()){
            throw new IllegalArgumentException("You must include patientId");
        }
        if(vitalsType == null || vitalsType.isEmpty()) {
            throw new IllegalArgumentException("You must include vitalsType");
        }
        if(targetVital == null) {
            throw new IllegalArgumentException("You must include target number");
        }

        VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(patientId);
        if(vitalSigns == null){
            Optional<Patient> patientOpt = patientService.getPatient(new PatientId(patientId));
            if(patientOpt.isEmpty()){
                throw new IllegalArgumentException("No such patient with that ID");
            }else{
                if(patientOpt.get().getPhysiologySource() == PatientSource.INTERNAL){
                    logger.debug("Creating new VitalSigns for patient {}", patientId);
                    VitalSigns newVitalSigns = new VitalSigns();
                    newVitalSigns.setId(patientId);
                    newVitalSigns.setLocal(true);
                    newVitalSigns.setOwnershipState(OwnershipState.CREATED);
                    updateVitalSigns(newVitalSigns, vitalsType, targetVital);
                    vitalSignsSimDataService.add(newVitalSigns);
                }else {
                    throw new IllegalArgumentException("Cannot change vitals for patient without ownership");
                }

            }
        }else{
            if(!vitalSigns.getOwnershipState().hasOwnership()){
                throw new IllegalArgumentException("Cannot change vitals for patient without ownership");
            }
            logger.debug("Changing vitals for patient {}", patientId);
            updateVitalSigns(vitalSigns, vitalsType, targetVital);
            vitalSignsSimDataService.put(vitalSigns);
        }
    }

    private void updateVitalSigns(VitalSigns vitalSigns, String vitalsType, Float targetVital){
        switch (vitalsType.toUpperCase()) {
            case "HR":
                vitalSigns.setHeartRate(targetVital.intValue());
                break;
            case "BP_SYSTOLIC":
                vitalSigns.setSystolicBloodPressure(targetVital.intValue());
                break;
            case "BP_DIASTOLIC":
                vitalSigns.setDiastolicBloodPressure(targetVital.intValue());
                break;
            case "RR":
                vitalSigns.setRespirationRate(targetVital.floatValue());
                break;
            case "SPO2":
                vitalSigns.setOxygenSaturation(targetVital.floatValue());
                break;
            case "ETCO2":
                vitalSigns.setRespirationETco2(targetVital.floatValue());
                break;
            case "TEMP":
                vitalSigns.setTemperatureFahrenheit(targetVital.floatValue());
                break;
            default:
                throw new IllegalArgumentException("Unknown vitalsType");
        }
    }
}
