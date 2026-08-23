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

public class RestPCVitals {
    private Integer heartRate = null;
    private Integer systolicBp = null;
    private Integer diastolicBp = null;
    private Float spO2 = null;
    private Float respiratoryRate = null;
    private Float etco2 = null;
    private Float temp = null;

    public Integer getHeartRate() {
        return heartRate;
    }

    public RestPCVitals setHeartRate(Integer heartRate) {
        this.heartRate = heartRate;
        return this;
    }

    public Integer getSystolicBp() {
        return systolicBp;
    }

    public RestPCVitals setSystolicBp(Integer systolicBp) {
        this.systolicBp = systolicBp;
        return this;
    }

    public Integer getDiastolicBp() {
        return diastolicBp;
    }

    public RestPCVitals setDiastolicBp(Integer diastolicBp) {
        this.diastolicBp = diastolicBp;
        return this;
    }

    public Float getSpO2() {
        return spO2;
    }

    public RestPCVitals setSpO2(Float spO2) {
        this.spO2 = spO2;
        return this;
    }

    public Float getRespiratoryRate() {
        return respiratoryRate;
    }

    public RestPCVitals setRespiratoryRate(Float respiratoryRate) {
        this.respiratoryRate = respiratoryRate;
        return this;
    }

    public Float getEtco2() {
        return etco2;
    }

    public RestPCVitals setEtco2(Float etco2) {
        this.etco2 = etco2;
        return this;
    }

    public Float getTemp() {
        return temp;
    }

    public RestPCVitals setTemp(Float temp) {
        this.temp = temp;
        return this;
    }
}
