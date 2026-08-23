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

public class RestPCMedication {
    private String injuryName;
    private RestBodyLocation location;
    private String medication;
    private String medRoute;
    private Float medDosage;
    private Integer medDosageTimePeriod;

    public String getInjuryName() {
        return injuryName;
    }

    public RestPCMedication setInjuryName(String injuryName) {
        this.injuryName = injuryName;
        return this;
    }

    public RestBodyLocation getLocation() {
        return location;
    }

    public RestPCMedication setLocation(RestBodyLocation location) {
        this.location = location;
        return this;
    }

    public String getMedication() {
        return medication;
    }

    public RestPCMedication setMedication(String medication) {
        this.medication = medication;
        return this;
    }

    public String getMedRoute() {
        return medRoute;
    }

    public RestPCMedication setMedRoute(String medRoute) {
        this.medRoute = medRoute;
        return this;
    }

    public Float getMedDosage() {
        return medDosage;
    }

    public RestPCMedication setMedDosage(Float medDosage) {
        this.medDosage = medDosage;
        return this;
    }

    public Integer getMedDosageTimePeriod() {
        return medDosageTimePeriod;
    }

    public RestPCMedication setMedDosageTimePeriod(Integer medDosageTimePeriod) {
        this.medDosageTimePeriod = medDosageTimePeriod;
        return this;
    }
}
