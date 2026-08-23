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

public class BodyFluids extends ConcurrentSimData<BodyFluids.Attributes> {
    public enum Attributes{
        AUTO_ID,
        BLOOD_LOSS_RATE_FLT,
        BLOOD_VOLUME_FLT,
        SWEAT_RATE_FLT,
        URINE_OUTPUT_RATE_FLT,
        GHOSTED_BOOL,
        PATIENT_ID_STR,
        INSTANCE_NAME_STR
    }

    public BodyFluids(){
        super(Attributes.class, Attributes.AUTO_ID, true);
    }

    public String getAutoId(){
        return (String)this.getValue(Attributes.AUTO_ID);
    }

    public BodyFluids setBloodLossRate(float bloodLoss){
        this.setValue(Attributes.BLOOD_LOSS_RATE_FLT, bloodLoss);
        return this;
    }

    public Float getBloodLossRate(){
        return (Float) this.getValue(Attributes.BLOOD_LOSS_RATE_FLT);
    }

    public BodyFluids setBloodVolume(float bloodVolume){
        this.setValue(Attributes.BLOOD_VOLUME_FLT, bloodVolume);
        return this;
    }

    public Float getBloodVolume(){
        return (Float) this.getValue(Attributes.BLOOD_VOLUME_FLT);
    }

    public BodyFluids setSweatRate(float sweatRate){
        this.setValue(Attributes.SWEAT_RATE_FLT, sweatRate);
        return this;
    }

    public Float getSweatRate() {
        return (Float) this.getValue(Attributes.SWEAT_RATE_FLT);
    }

    public BodyFluids setUrineOutputRate(float urineOutputRate){
        this.setValue(Attributes.URINE_OUTPUT_RATE_FLT, urineOutputRate);
        return this;
    }

    public Float getUrineOutputRate(){
        return (Float) this.getValue(Attributes.URINE_OUTPUT_RATE_FLT);
    }

    public Boolean getGhosted() {
        return (Boolean) this.getValue(Attributes.GHOSTED_BOOL);
    }

    public BodyFluids setGhosted(Boolean isGhosted) {
        this.setValue(Attributes.GHOSTED_BOOL, isGhosted);
        return this;
    }

    public String getPatientId(){
        return (String) this.getValue(Attributes.PATIENT_ID_STR);
    }

    public BodyFluids setPatientId(String patientId){
        this.setValue(Attributes.PATIENT_ID_STR, patientId);
        return this;
    }

    public String getInstanceName(){
        return (String) this.getValue(Attributes.INSTANCE_NAME_STR);
    }

    public BodyFluids setInstanceName(String instanceName){
        this.setValue(Attributes.INSTANCE_NAME_STR, instanceName);
        return this;
    }

}
