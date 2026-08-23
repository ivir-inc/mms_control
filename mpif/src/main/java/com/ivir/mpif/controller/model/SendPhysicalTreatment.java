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

public class SendPhysicalTreatment {
    private String patientId;
    private String injuryId;
    private String treatment;
    private String deviceUsed;
    private RestBodyLocation treatmentLocation;

    public String getPatientId() {
        return patientId;
    }

    public SendPhysicalTreatment setPatientId(String patientId) {
        this.patientId = patientId;
        return this;
    }

    public String getInjuryId() {
        return injuryId;
    }

    public SendPhysicalTreatment setInjuryId(String injuryId) {
        this.injuryId = injuryId;
        return this;
    }

    public String getTreatment() {
        return treatment;
    }

    public SendPhysicalTreatment setTreatment(String treatment) {
        this.treatment = treatment;
        return this;
    }

    public String getDeviceUsed() {
        return deviceUsed;
    }

    public SendPhysicalTreatment setDeviceUsed(String deviceUsed) {
        this.deviceUsed = deviceUsed;
        return this;
    }

    public RestBodyLocation getTreatmentLocation() {
        return treatmentLocation;
    }

    public SendPhysicalTreatment setTreatmentLocation(RestBodyLocation treatmentLocation) {
        this.treatmentLocation = treatmentLocation;
        return this;
    }
}
