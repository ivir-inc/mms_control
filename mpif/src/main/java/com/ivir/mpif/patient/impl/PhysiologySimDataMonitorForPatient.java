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

package com.ivir.mpif.patient.impl;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientSource;
import com.ivir.mpif.patient.PatientService;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.OwnershipState;
import com.ivir.mpif.simdata.VitalSigns;
import com.ivir.mpif.simdata.VitalSignsSimDataService;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class PhysiologySimDataMonitorForPatient implements ConcurrentDataStorageListener<VitalSigns> {
    @Autowired
    VitalSignsSimDataService physiologySimDataService;
    @Autowired
    PatientService patientService;

    @PostConstruct
    public void init(){
        physiologySimDataService.addDataStorageListener(this);
    }

    @Override
    public void entityAdded(VitalSigns newEntity) {
        PatientSource patientSource = newEntity.getOwnershipState().hasOwnership() ? PatientSource.INTERNAL : PatientSource.EXTERNAL;
        if(newEntity.getOwnershipState() == OwnershipState.UNKNOWN){
            patientSource = newEntity.isLocal() ? PatientSource.INTERNAL : PatientSource.EXTERNAL;
        }

        Optional<Patient> patientOpt = patientService.getPatient(new PatientId(newEntity.getId()));
        if(patientOpt.isPresent()){
            Patient patient = patientOpt.get();
            if(patient.getPhysiologySource() != patientSource){
                patientService.updatePatient(patient.getId().getIdAsString(), patient.getVisible(), patientSource, patient.getSourceLocked(), patient.getPatientCaseNum());
            }
        }else{
            patientService.addPatient(newEntity.getId(), true, patientSource, true);
        }
    }

    @Override
    public void entityUpdated(VitalSigns entity) {
        entityAdded(entity);
    }
}
