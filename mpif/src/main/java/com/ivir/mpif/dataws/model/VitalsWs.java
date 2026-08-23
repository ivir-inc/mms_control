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

package com.ivir.mpif.dataws.model;

import com.ivir.mpif.simdata.OwnershipState;

public class VitalsWs {
    
    private String patientId = null;
    private Integer heartRate = null;
    private Integer systolicBp = null;
    private Integer diastolicBp = null;
    private Float spO2 = null;
    private Float respiratoryRate = null;
    private Float etco2 = null;
    private Float temp = null;
    private OwnershipState ownershipState = OwnershipState.UNKNOWN;
    
    public VitalsWs() {
        
    }
    
    public VitalsWs(VitalsWs orgVitals) {
        this.patientId = orgVitals.getPatientId();
        this.heartRate = orgVitals.getHeartRate();
        this.diastolicBp = orgVitals.getDiastolicBp();
        this.etco2 = orgVitals.getEtco2();
        this.respiratoryRate = orgVitals.getRespiratoryRate();
        this.spO2 = orgVitals.getSpO2();
        this.systolicBp = orgVitals.getSystolicBp();
        this.temp = orgVitals.getTemp();
        this.ownershipState = orgVitals.getOwnershipState();
    }
    
    public String getPatientId(){
        return this.patientId;
    }

    public void setPatientId(String id){
        this.patientId = id;
    }

    public Integer getHeartRate() {
        return heartRate;
    }
    
    public void setHeartRate(Integer heartRate) {
        this.heartRate = heartRate;
    }
    
    public Integer getSystolicBp() {
        return systolicBp;
    }
    
    public void setSystolicBp(Integer systolicBp) {
        this.systolicBp = systolicBp;
    }
    
    public Integer getDiastolicBp() {
        return diastolicBp;
    }
    
    public void setDiastolicBp(Integer diastolicBp) {
        this.diastolicBp = diastolicBp;
    }
    
    public Float getSpO2() {
        return spO2;
    }
    
    public void setSpO2(Float spO2) {
        this.spO2 = spO2;
    }
    
    public Float getRespiratoryRate() {
        return respiratoryRate;
    }
    
    public void setRespiratoryRate(Float respiratoryRate) {
        this.respiratoryRate = respiratoryRate;
    }
    
    public Float getEtco2() {
        return etco2;
    }
    
    public void setEtco2(Float etco2) {
        this.etco2 = etco2;
    }
    
    public Float getTemp() {
        return temp;
    }
    
    public void setTemp(Float temp) {
        this.temp = temp;
    }

    public OwnershipState getOwnershipState() {
        return ownershipState;
    }

    public void setOwnershipState(OwnershipState ownershipState) {
        this.ownershipState = ownershipState;
    }

}
