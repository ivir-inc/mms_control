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

package com.ivir.mpif.controller.model;

public class SendMedicationTreatment {
    private String medication = null;
    private String patientId = null;
    private String injuryId = null;
    private String administrationRoute = null;
    private Float dosageValue = null;
    private Integer dosageTimePeriod = null;
    private RestBodyLocation treatmentLocation = null;

    public String getMedication() {
        return medication;
    }

    public SendMedicationTreatment setMedication(String medication) {
        this.medication = medication;
        return this;
    }

    public String getPatientId() {
        return patientId;
    }

    public SendMedicationTreatment setPatientId(String patientId) {
        this.patientId = patientId;
        return this;
    }

    public String getInjuryId() {
        return injuryId;
    }

    public SendMedicationTreatment setInjuryId(String injuryId) {
        this.injuryId = injuryId;
        return this;
    }

    public String getAdministrationRoute() {
        return administrationRoute;
    }

    public SendMedicationTreatment setAdministrationRoute(String administrationRoute) {
        this.administrationRoute = administrationRoute;
        return this;
    }

    public Float getDosageValue() {
        return dosageValue;
    }

    public SendMedicationTreatment setDosageValue(Float dosageValue) {
        this.dosageValue = dosageValue;
        return this;
    }

    public Integer getDosageTimePeriod() {
        return dosageTimePeriod;
    }

    public SendMedicationTreatment setDosageTimePeriod(Integer dosageTimePeriod) {
        this.dosageTimePeriod = dosageTimePeriod;
        return this;
    }

    public RestBodyLocation getTreatmentLocation() {
        return treatmentLocation;
    }

    public SendMedicationTreatment setTreatmentLocation(RestBodyLocation treatmentLocation) {
        this.treatmentLocation = treatmentLocation;
        return this;
    }
}
