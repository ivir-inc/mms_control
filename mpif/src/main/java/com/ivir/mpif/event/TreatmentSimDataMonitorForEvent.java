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

package com.ivir.mpif.event;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientService;
import com.ivir.mpif.simdata.*;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.Optional;

@Component
public class TreatmentSimDataMonitorForEvent implements ConcurrentDataStorageListener<Treatment> {
    private Logger logger = LoggerFactory.getLogger(TreatmentSimDataMonitorForEvent.class);

    @Autowired
    TreatmentSimDataService treatmentSimDataService;

    @Autowired
    EventSimDataService eventSimDataService;

    @Autowired
    PatientService patientService;

    @PostConstruct
    public void init(){
        treatmentSimDataService.addDataStorageListener(this);
    }

    //---------------------------------------------------------------------------------------------
    //                       ConcurrentSimDataListener
    //---------------------------------------------------------------------------------------------
    @Override
    public void entityAdded(Treatment newEntity) {
        PatientId patientId = newEntity.getPatientId();
        Optional<Patient> oPatient = patientService.getPatient(patientId);

        if(oPatient.isEmpty()){
            logger.warn("Treatment is not associated with a known patientId.  Event will not be created");
        }else{
            Event treatmentEvent = new Event();

            treatmentEvent.setSource("Simulation");
            treatmentEvent.setLocal(true);
            treatmentEvent.setType(EventTypeEnum.TREATMENT);
            treatmentEvent.setPatientId(newEntity.getPatientId().getIdAsString());

            if(newEntity.getTreatmentTime() != null) {
                treatmentEvent.setTime(newEntity.getTreatmentTime());
            }else {
                treatmentEvent.setTime(new Date().getTime());
            }

            if(newEntity.getClassType() == TreatmentClassType.PHYSICAL_TREATMENT) {
                String notes = TreatmentEventBuilder.physicalTreatmentClause(newEntity.getTreatment());
                treatmentEvent.setNotes(notes);

            }else {
                String notes = TreatmentEventBuilder.medicationTreatmentClause(newEntity.getMedication());
                treatmentEvent.setNotes(notes);
            }

            if(newEntity.getClassType() == TreatmentClassType.PHYSICAL_TREATMENT) {
                //Treatment applied with device at body location
                String description = null;
                description = setOrAppend(description, TreatmentEventBuilder.devicePhrase(newEntity.getDeviceUsed()));
                description = setOrAppend(description, TreatmentEventBuilder.locationPhrase(newEntity.getTreatmentLocation()));
                if(description != null) {
                    treatmentEvent.setDescription("Treatment applied " + description);
                }
            }else {
                String description = null;
                description = setOrAppend(description, TreatmentEventBuilder.routePhrase(newEntity.getAdministrationRoute()));
                description = setOrAppend(description, TreatmentEventBuilder.locationPhrase(newEntity.getTreatmentLocation()));
                description = setOrAppend(description, TreatmentEventBuilder.dosagePhrase(newEntity.getDosageValue(), newEntity.getDosageTimePeriod()));

                if(description != null) {
                    treatmentEvent.setDescription("Treatment administered " + description);
                }
            }
            eventSimDataService.add(treatmentEvent);
            logger.debug("Event for new treatment created " + treatmentEvent.toString());
        }

    }

    /**
     * adds the 2 strings unless one or the other is null
     * if appended, then a space is added
     */
    private String setOrAppend(String base, String toAdd) {
        if(toAdd == null) {
            return base;
        }

        if(base == null) {
            return toAdd;
        }

        return base + " " + toAdd;
    }

    @Override
    public void entityUpdated(Treatment entity) {
        //ignore updates, just use add
    }
}
