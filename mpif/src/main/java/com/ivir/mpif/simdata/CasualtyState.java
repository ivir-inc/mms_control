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

public class CasualtyState extends ConcurrentSimData<CasualtyState.Attributes>{
    public enum Attributes{
        ID,
        LOCAL_BOOL,
        INSTANCE_NAME_STR,
        PATIENT_ID_STR,
        FACILITY_ID_STR,
        EVACUATION_PRIORITY_ENUM,
        TRIAGE_CLASSIFICATION_ENUM,
    }

    public CasualtyState(){
        super(Attributes.class, Attributes.ID, true);
    }

    public String getId(){
        return this.getIndex();
    }

    public Boolean isLocal(){
        return this.getValue(Attributes.LOCAL_BOOL, Boolean.class);
    }

    public CasualtyState setLocal(Boolean isLocal){
        this.setValue(Attributes.LOCAL_BOOL, isLocal);
        return this;
    }

    public String getFacilityId(){
        return this.getValue(Attributes.FACILITY_ID_STR, String.class);
    }

    public CasualtyState setFacilityId(String facilityId){
        this.setValue(Attributes.FACILITY_ID_STR, facilityId);
        return this;
    }

    public String getInstanceName(){
        return this.getValue(Attributes.INSTANCE_NAME_STR, String.class);
    }

    public CasualtyState setInstanceName(String name){
        this.setValue(Attributes.INSTANCE_NAME_STR, name);
        return this;
    }

    public String getPatientId(){
        return this.getValue(Attributes.PATIENT_ID_STR, String.class);
    }

    public CasualtyState setPatientId(String patientId){
        this.setValue(Attributes.PATIENT_ID_STR, patientId);
        return this;
    }

    public EvacuationPriority getEvacuationPriority(){
        return this.getValue(Attributes.EVACUATION_PRIORITY_ENUM, EvacuationPriority.class);
    }

    public CasualtyState setEvacuationPriority(EvacuationPriority evacuationPriority){
        this.setValue(Attributes.EVACUATION_PRIORITY_ENUM, evacuationPriority);
        return this;
    }

    public TriageClassification getTriageClassification(){
        return this.getValue(Attributes.TRIAGE_CLASSIFICATION_ENUM, TriageClassification.class);
    }

    public CasualtyState setTriageClassification(TriageClassification triageClassification){
        this.setValue(Attributes.TRIAGE_CLASSIFICATION_ENUM, triageClassification);
        return this;
    }

}
