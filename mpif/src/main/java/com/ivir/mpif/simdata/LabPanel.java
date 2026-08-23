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

public class LabPanel extends ConcurrentSimData<LabPanel.Attributes>{

    public enum Attributes{
        AUTO_ID,
        LAB_TYPE_ENUM,
        LAB_ENTRIES_OBJ,
        TIME_LON,
        GHOSTED_BOOL,
        PATIENT_ID_STR,
        INSTANCE_NAME_STR
    }

    public LabPanel(){
        super(Attributes.class, Attributes.AUTO_ID, true);
    }

    public String getAutoId(){
        return (String)this.getValue(Attributes.AUTO_ID);
    }

    public LabTypeEnum getLabType(){
        return (LabTypeEnum) this.getValue(Attributes.LAB_TYPE_ENUM);
    }

    public LabPanel setLabType(LabTypeEnum type){
        this.setValue(Attributes.LAB_TYPE_ENUM, type);
        return this;
    }

    public LabEntries getLabEntries(){
        return (LabEntries) this.getValue(Attributes.LAB_ENTRIES_OBJ);
    }

    public LabPanel setLabEntries(LabEntries entries){
        this.setValue(Attributes.LAB_ENTRIES_OBJ, entries);
        return this;
    }

    public Long getTime(){
        return (Long) this.getValue(Attributes.TIME_LON);
    }

    public LabPanel setTime(Long time){
        this.setValue(Attributes.TIME_LON, time);
        return this;
    }


    public Boolean getGhosted() {
        return (Boolean) this.getValue(Attributes.GHOSTED_BOOL);
    }

    public LabPanel setGhosted(Boolean isGhosted) {
        this.setValue(Attributes.GHOSTED_BOOL, isGhosted);
        return this;
    }

    public String getPatientId(){
        return (String) this.getValue(Attributes.PATIENT_ID_STR);
    }

    public LabPanel setPatientId(String patientId){
        this.setValue(Attributes.PATIENT_ID_STR, patientId);
        return this;
    }

    public String getInstanceName(){
        return (String) this.getValue(Attributes.INSTANCE_NAME_STR);
    }

    public LabPanel setInstanceName(String instanceName){
        this.setValue(Attributes.INSTANCE_NAME_STR, instanceName);
        return this;
    }

}
