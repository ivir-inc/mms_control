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

package com.ivir.mpif.pcb;

import com.ivir.mpif.simdata.*;

public class PCTreatment {
    private String injuryName;
    private BodyLocation location;
    private TreatmentClassType treatmentType;
    private PhysicalTreatmentType physicalTreatment;
    private TreatmentDevice physicalDevice;
    private Medication medication;
    private MedicationAdministrationRoute medRoute;
    private Float medDosage;
    private Integer medDosageTimePeriod;

    public String getInjuryName() {
        return injuryName;
    }

    public PCTreatment setInjuryName(String injuryName) {
        this.injuryName = injuryName;
        return this;
    }

    public BodyLocation getLocation() {
        return location;
    }

    public PCTreatment setLocation(BodyLocation location) {
        this.location = location;
        return this;
    }

    public TreatmentClassType getTreatmentType() {
        return treatmentType;
    }

    public PCTreatment setTreatmentType(TreatmentClassType treatmentType) {
        this.treatmentType = treatmentType;
        return this;
    }

    public PhysicalTreatmentType getPhysicalTreatment() {
        return physicalTreatment;
    }

    public PCTreatment setPhysicalTreatment(PhysicalTreatmentType physicalTreatment) {
        this.physicalTreatment = physicalTreatment;
        return this;
    }

    public TreatmentDevice getPhysicalDevice() {
        return physicalDevice;
    }

    public PCTreatment setPhysicalDevice(TreatmentDevice physicalDevice) {
        this.physicalDevice = physicalDevice;
        return this;
    }

    public Medication getMedication() {
        return medication;
    }

    public PCTreatment setMedication(Medication medication) {
        this.medication = medication;
        return this;
    }

    public MedicationAdministrationRoute getMedRoute() {
        return medRoute;
    }

    public PCTreatment setMedRoute(MedicationAdministrationRoute medRoute) {
        this.medRoute = medRoute;
        return this;
    }

    public Float getMedDosage() {
        return medDosage;
    }

    public PCTreatment setMedDosage(Float medDosage) {
        this.medDosage = medDosage;
        return this;
    }

    public Integer getMedDosageTimePeriod() {
        return medDosageTimePeriod;
    }

    public PCTreatment setMedDosageTimePeriod(Integer medDosageTimePeriod) {
        this.medDosageTimePeriod = medDosageTimePeriod;
        return this;
    }

    @Override
    public String toString() {
        return "PatientCaseTreatmentEntity{" +
                "injuryName=" + injuryName +
                ", location=" + location +
                ", treatmentType=" + treatmentType +
                ", physicalTreatment=" + physicalTreatment +
                ", physicalDevice=" + physicalDevice +
                ", medication=" + medication +
                ", medRoute=" + medRoute +
                ", medDosage=" + medDosage +
                ", medDosageTimePeriod=" + medDosageTimePeriod +
                '}';
    }
}
