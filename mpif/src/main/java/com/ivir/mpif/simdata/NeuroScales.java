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

public class NeuroScales extends ConcurrentSimData<NeuroScales.Attributes>{
    public enum Attributes{
        AUTO_ID,
        GCS_EYES_INT,
        GCS_VERBAL_INT,
        GCS_MOTOR_INT,
        LEVEL_OF_RESPONSE_ENUM,
        LEVEL_OF_CONSCIOUSNESS_ENUM,
        GHOSTED_BOOL,
        PATIENT_ID_STR,
        INSTANCE_NAME_STR
    }

    public NeuroScales(){
        super(Attributes.class, Attributes.AUTO_ID, true);
    }

    public String getAutoId(){
        return (String)this.getValue(Attributes.AUTO_ID);
    }

    public Integer getGcsEyes(){
        return (Integer)this.getValue(Attributes.GCS_EYES_INT);
    }

    public NeuroScales setGcsEyes(Integer eyesVal){
        this.setValue(Attributes.GCS_EYES_INT, eyesVal);
        return this;
    }

    public Integer getGcsVerbal(){
        return (Integer)this.getValue(Attributes.GCS_VERBAL_INT);
    }

    public NeuroScales setGcsVerbal(Integer value){
        this.setValue(Attributes.GCS_VERBAL_INT, value);
        return this;
    }

    public Integer getGcsMotor(){
        return (Integer)this.getValue(Attributes.GCS_MOTOR_INT);
    }

    public NeuroScales setGcsMotor(Integer value){
        this.setValue(Attributes.GCS_MOTOR_INT, value);
        return this;
    }

    public LevelOfResponse getLevelOfResponse(){
        return (LevelOfResponse)this.getValue(Attributes.LEVEL_OF_RESPONSE_ENUM);
    }

    public NeuroScales setLevelOfResponse(LevelOfResponse value){
        this.setValue(Attributes.LEVEL_OF_RESPONSE_ENUM, value);
        return this;
    }

    public LevelOfConsciousness getLevelOfConsciousness(){
        return (LevelOfConsciousness)this.getValue(Attributes.LEVEL_OF_CONSCIOUSNESS_ENUM);
    }

    public NeuroScales setLevelOfConsciousness(LevelOfConsciousness value){
        this.setValue(Attributes.LEVEL_OF_CONSCIOUSNESS_ENUM, value);
        return this;
    }

    public Boolean getGhosted() {
        return (Boolean) this.getValue(Attributes.GHOSTED_BOOL);
    }

    public NeuroScales setGhosted(Boolean isGhosted) {
        this.setValue(Attributes.GHOSTED_BOOL, isGhosted);
        return this;
    }

    public String getPatientId(){
        return (String) this.getValue(Attributes.PATIENT_ID_STR);
    }

    public NeuroScales setPatientId(String patientId){
        this.setValue(Attributes.PATIENT_ID_STR, patientId);
        return this;
    }

    public String getInstanceName(){
        return (String) this.getValue(Attributes.INSTANCE_NAME_STR);
    }

    public NeuroScales setInstanceName(String instanceName){
        this.setValue(Attributes.INSTANCE_NAME_STR, instanceName);
        return this;
    }

}
