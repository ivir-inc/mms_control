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
import com.ivir.mpif.treatment.TreatmentService;
import devstudio.generatedcode.*;
import devstudio.generatedcode.datatypes.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

import static com.ivir.mpif.simdata.BodyLocationConversionUtil.toBodyLocation;
import static com.ivir.mpif.simdata.BodyLocationConversionUtil.toBodyLocationRecord;

@Component
public class TreatmentAdapter implements MmsFederateInitializationListener, HlaMedicationTreatmentListener, HlaPhysicalTreatmentListener, ConcurrentDataStorageListener<Treatment> {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());
    private MmsFederate mmsFederate;

    @Autowired
    private TreatmentService treatmentService;

    public TreatmentAdapter() {
    }

    //---------------------------------------------------------------------------------------------
    //          MmsFederateInitializationListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        mmsFederate.getHlaWorld().getHlaPhysicalTreatmentManager()
                .addHlaPhysicalTreatmentDefaultInstanceListener(this);
        mmsFederate.getHlaWorld().getHlaMedicationTreatmentManager()
                .addHlaMedicationTreatmentDefaultInstanceListener(this);
        this.treatmentService.addTreatmentListener(this);
    }

    //---------------------------------------------------------------------------------------------
    //         HlaMedicationTreatmentListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void attributesUpdated(HlaMedicationTreatment hlaMedicationTreatment,
                                  Set<HlaMedicationTreatmentAttributes.Attribute> set, HlaTimeStamp hlaTimeStamp,
                                  HlaLogicalTime hlaLogicalTime) {
        if(!hlaMedicationTreatment.isLocal()){
            if(treatmentService.getTreatmentByInstanceName(hlaMedicationTreatment.getHlaInstanceName()) != null){
                logger.info("Treatment was already created with this instance id. Ignoring updates");
                return;
            }

            Treatment treatment = new Treatment().setLocal(false)
                    .setClassType(TreatmentClassType.MEDICATION_TREATMENT)
                    .setInstanceName(hlaMedicationTreatment.getHlaInstanceName());
            for (HlaMedicationTreatmentAttributes.Attribute attribute : set){
                switch (attribute){
                    case MEDICATION -> treatment.setMedication(Medication.valueOf(hlaMedicationTreatment.getMedication().toString()));
                    case ADMINISTRATION_ROUTE -> treatment.setAdministrationRoute(
                            MedicationAdministrationRoute.valueOf(hlaMedicationTreatment.getAdministrationRoute().toString()));
                    case DOSAGE_ACTIVE -> treatment.setTreatmentActive(hlaMedicationTreatment.getDosageActive());
                    case DOSAGE_TIME_PERIOD -> treatment.setDosageTimePeriod(hlaMedicationTreatment.getDosageTimePeriod());
                    case DOSAGE_VALUE -> treatment.setDosageValue(hlaMedicationTreatment.getDosageValue());
                    case INJURY_ID -> treatment.setInjuryId(hlaMedicationTreatment.getInjuryId());
                    case PATIENT_ID -> treatment.setPatientId(hlaMedicationTreatment.getPatientId());
                    case TREATMENT_ID -> treatment.setTreatmentId(hlaMedicationTreatment.getTreatmentId());
                    case TREATMENT_LOCATION -> treatment.setTreatmentLocation(toBodyLocation(hlaMedicationTreatment.getTreatmentLocation()));
                    case TREATMENT_TIME -> treatment.setTreatmentTime(hlaMedicationTreatment.getTreatmentTime());
                }
            }
            treatmentService.addTreatment(treatment);
        }
    }

    //---------------------------------------------------------------------------------------------
    //         HlaPhysicalTreatmentListener Implementation
    //---------------------------------------------------------------------------------------------
    @Override
    public void attributesUpdated(HlaPhysicalTreatment hlaPhysicalTreatment,
                                  Set<HlaPhysicalTreatmentAttributes.Attribute> set, HlaTimeStamp hlaTimeStamp,
                                  HlaLogicalTime hlaLogicalTime) {
        if(!hlaPhysicalTreatment.isLocal()){
            if(treatmentService.getTreatmentByInstanceName(hlaPhysicalTreatment.getHlaInstanceName()) != null){
                logger.info("Treatment was already created with this instance id. Ignoring updates");
                return;
            }
            Treatment treatment = new Treatment().setLocal(false)
                    .setClassType(TreatmentClassType.PHYSICAL_TREATMENT)
                    .setInstanceName(hlaPhysicalTreatment.getHlaInstanceName());

            for (HlaPhysicalTreatmentAttributes.Attribute attribute : set){
                switch (attribute) {
                    case DEVICE_USED -> treatment.setDeviceUsed(TreatmentDevice.valueOf(
                            hlaPhysicalTreatment.getDeviceUsed().toString()));
                    case INJURY_ID -> treatment.setInjuryId(hlaPhysicalTreatment.getInjuryId());
                    case PATIENT_ID -> treatment.setPatientId(hlaPhysicalTreatment.getPatientId());
                    case TREATMENT -> treatment.setTreatment(PhysicalTreatmentType.valueOf(
                            hlaPhysicalTreatment.getTreatment().toString()));
                    case TREATMENT_ID -> treatment.setTreatmentId(hlaPhysicalTreatment.getTreatmentId());
                    case TREATMENT_ACTIVE -> treatment.setTreatmentActive(hlaPhysicalTreatment.getTreatmentActive());
                    case TREATMENT_LOCATION -> treatment.setTreatmentLocation(toBodyLocation(hlaPhysicalTreatment.getTreatmentLocation()));
                    case TREATMENT_TIME -> treatment.setTreatmentTime(hlaPhysicalTreatment.getTreatmentTime());
                }
            }
            treatmentService.addTreatment(treatment);
        }
    }


    //---------------------------------------------------------------------------------------------
    //         DataStorageListener Implementation
    //---------------------------------------------------------------------------------------------


    @Override
    public void entityAdded(Treatment newEntity) {
        if(newEntity.isLocal()) {
            try {
                if (newEntity.getClassType() == TreatmentClassType.MEDICATION_TREATMENT) {
                    HlaMedicationTreatment hlaTreatment = mmsFederate.getHlaWorld().getHlaMedicationTreatmentManager()
                            .createLocalHlaMedicationTreatment();
                    HlaMedicationTreatmentUpdater hlaTreatmentUpdater = hlaTreatment.getHlaMedicationTreatmentUpdater();
                    if (newEntity.getMedication() != null) {
                        hlaTreatmentUpdater.setMedication(MedicationEnum.valueOf(newEntity.getMedication().toString()));
                    }
                    if (newEntity.getAdministrationRoute() != null) {
                        hlaTreatmentUpdater.setAdministrationRoute(MedicationAdministrationRouteEnum.valueOf(
                                newEntity.getAdministrationRoute().toString()));
                    }
                    if (newEntity.getTreatmentActive() != null) {
                        hlaTreatmentUpdater.setDosageActive(newEntity.getTreatmentActive());
                    }
                    if (newEntity.getDosageTimePeriod() != null) {
                        hlaTreatmentUpdater.setDosageTimePeriod(newEntity.getDosageTimePeriod());
                    }
                    if (newEntity.getDosageValue() != null) {
                        hlaTreatmentUpdater.setDosageValue(newEntity.getDosageValue());
                    }
                    if (newEntity.getInjuryId() != null) {
                        hlaTreatmentUpdater.setInjuryId(newEntity.getInjuryId());
                    }
                    if (newEntity.getPatientId() != null) {
                        hlaTreatmentUpdater.setPatientId(newEntity.getPatientId().getIdAsString());
                    }
                    if (newEntity.getTreatmentId() != null) {
                        hlaTreatmentUpdater.setTreatmentId(newEntity.getTreatmentId());
                    }
                    if (newEntity.getTreatmentLocation() != null) {
                        hlaTreatmentUpdater.setTreatmentLocation(toBodyLocationRecord(newEntity.getTreatmentLocation()));
                    }
                    if (newEntity.getTreatmentTime() != null) {
                        hlaTreatmentUpdater.setTreatmentTime(newEntity.getTreatmentTime());
                    }
                    logger.debug("Publishing Medication Treatment");
                    hlaTreatmentUpdater.sendUpdate();
                } else {
                    HlaPhysicalTreatment hlaTreatment = mmsFederate.getHlaWorld().getHlaPhysicalTreatmentManager()
                            .createLocalHlaPhysicalTreatment();
                    HlaPhysicalTreatmentUpdater hlaTreatmentUpdater = hlaTreatment.getHlaPhysicalTreatmentUpdater();
                    if (newEntity.getDeviceUsed() != null) {
                        hlaTreatmentUpdater.setDeviceUsed(TreatmentDeviceEnum.valueOf(newEntity.getDeviceUsed().toString()));
                    }
                    if (newEntity.getInjuryId() != null) {
                        hlaTreatmentUpdater.setInjuryId(newEntity.getInjuryId());
                    }
                    if (newEntity.getPatientId() != null) {
                        hlaTreatmentUpdater.setPatientId(newEntity.getPatientId().getIdAsString());
                    }
                    if (newEntity.getTreatment() != null) {
                        hlaTreatmentUpdater.setTreatment(PhysicalTreatmentTypeEnum.valueOf(newEntity.getTreatment().toString()));
                    }
                    if (newEntity.getTreatmentActive() != null) {
                        hlaTreatmentUpdater.setTreatmentActive(newEntity.getTreatmentActive());
                    }
                    if (newEntity.getTreatmentId() != null) {
                        hlaTreatmentUpdater.setTreatmentId(newEntity.getTreatmentId());
                    }
                    if (newEntity.getTreatmentLocation() != null) {
                        hlaTreatmentUpdater.setTreatmentLocation(toBodyLocationRecord(newEntity.getTreatmentLocation()));
                    }
                    if (newEntity.getTreatmentTime() != null) {
                        hlaTreatmentUpdater.setTreatmentTime(newEntity.getTreatmentTime());
                    }
                    logger.debug("Publishing Physical Treatment");
                    hlaTreatmentUpdater.sendUpdate();
                }
            } catch (Exception e) {
                logger.warn("Failed to publish new treatment: {}", e.getMessage());
            }
        }
    }

    @Override
    public void entityUpdated(Treatment entity) {

    }

    /**
     * convert "this enum" into "THIS_ENUM"
     * @param name
     * @return
     */
    private MedicationEnum toMedicationEnumFromName(String name){
        String enumName = Arrays.stream(name.strip().split(" ")).map(String::toUpperCase).collect(Collectors.joining("_"));
        return MedicationEnum.valueOf(enumName);
    }

}
