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

package com.ivir.mpif.simdata;

public class VitalSigns extends ConcurrentSimData<VitalSigns.Attributes>{

	private static final long serialVersionUID = -5461289520926221471L;

	public enum Attributes{
        INSTANCE_NAME,
        LOCAL,
        ID,//patient ID
        HEART_RATE,
        DIASTOLIC_BP,
        SYSTOLIC_BP,
        O2_SAT,
        TEMP_F,
        RESP_ETCO2,
        RESP_RATE,
        TIME_STAMP,
        OWNERSHIP_STATE_ENUM
    }

    public VitalSigns(){
        super(Attributes.class, Attributes.ID);
        setOwnershipState(OwnershipState.UNKNOWN);
    }

    public void setByAttribute(Attributes attribute, Comparable<?> value){
        this.setValue(attribute,value);
    }

    public Comparable<?> getByAttribute(Attributes attribute){
        return this.getValue(attribute);
    }
    
    public String getInstanceName() {
        return (String) this.getValue(Attributes.INSTANCE_NAME);
    }

    public VitalSigns setInstanceName(String instanceName) {
        this.setValue(Attributes.INSTANCE_NAME, instanceName);
        return this;
    }

    public boolean isLocal() {
        return (Boolean) this.getValue(Attributes.LOCAL);
    }

    public VitalSigns setLocal(boolean local) {
        this.setValue(Attributes.LOCAL, local);
        return this;
    }

    public String getId() {
        return (String) this.getValue(Attributes.ID);
    }

    public VitalSigns setId(String id) {
        this.setValue(Attributes.ID, id);
        return this;
    }

    public Integer getHeartRate() {
        return (Integer) this.getValue(Attributes.HEART_RATE);
    }

    public VitalSigns setHeartRate(Integer heartRate) {
        this.setValue(Attributes.HEART_RATE, heartRate);
        return this;
    }

    public Integer getDiastolicBloodPressure() {
        return (Integer) this.getValue(Attributes.DIASTOLIC_BP);
    }

    public VitalSigns setDiastolicBloodPressure(Integer diastolicBloodPressure) {
        this.setValue(Attributes.DIASTOLIC_BP, diastolicBloodPressure);
        return this;
    }

    public Integer getSystolicBloodPressure() {
        return (Integer) this.getValue(Attributes.SYSTOLIC_BP);
    }

    public VitalSigns setSystolicBloodPressure(Integer systolicBloodPressure) {
        this.setValue(Attributes.SYSTOLIC_BP, systolicBloodPressure);
        return this;
    }

    public Float getOxygenSaturation() {
        return (Float) this.getValue(Attributes.O2_SAT);
    }

    public VitalSigns setOxygenSaturation(Float oxygenSaturation) {
        this.setValue(Attributes.O2_SAT, oxygenSaturation);
        return this;
    }

    public Float getTemperatureFahrenheit() {
        return (Float) this.getValue(Attributes.TEMP_F);
    }

    public VitalSigns setTemperatureFahrenheit(Float temperatureFahrenheit) {
        this.setValue(Attributes.TEMP_F, temperatureFahrenheit);
        return this;
    }

    public Float getRespirationETco2() {
        return (Float) this.getValue(Attributes.RESP_ETCO2);
    }

    public VitalSigns setRespirationETco2(Float respirationETco2) {
        this.setValue(Attributes.RESP_ETCO2, respirationETco2);
        return this;
    }

    public Float getRespirationRate() {
        return (Float) this.getValue(Attributes.RESP_RATE);
    }

    public VitalSigns setRespirationRate(Float respirationRate) {
        this.setValue(Attributes.RESP_RATE, respirationRate);
        return this;
    }

    public Long getTimeStamp() {
        return (Long) this.getValue(Attributes.TIME_STAMP);
    }

    public VitalSigns setTimeStamp(Long timeStamp) {
        this.setValue(Attributes.TIME_STAMP, timeStamp);
        return this;
    }

    public OwnershipState getOwnershipState() {
        return (OwnershipState) this.getValue(Attributes.OWNERSHIP_STATE_ENUM);
    }

    public VitalSigns setOwnershipState(OwnershipState ownershipState) {
        this.setValue(Attributes.OWNERSHIP_STATE_ENUM, ownershipState);
        return this;
    }

}
