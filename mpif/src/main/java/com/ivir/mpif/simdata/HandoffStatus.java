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

public class HandoffStatus extends ConcurrentSimData<HandoffStatus.Attributes>{
	private static final long serialVersionUID = -2860956934855176521L;

    public enum Attributes{
        AUTO_ID_LNG,
        FACILITY_ID_STR,
        PATIENT_ID_STR,
        GHOSTED_BOL,
        HANDOFF_STATUS_ENUM
    }

    public HandoffStatus(){
        super(Attributes.class, Attributes.AUTO_ID_LNG, true);
    }
    
    public Long getId() {
    	return (Long) this.getValue(Attributes.AUTO_ID_LNG);
    }
    
    public String getFacilityId() {
    	return (String) this.getValue(Attributes.FACILITY_ID_STR);
    }
    
    public HandoffStatus setFacilityId(String facilityId) {
    	this.setValue(Attributes.FACILITY_ID_STR, facilityId);
    	return this;
    }
    
    public String getPatientId() {
    	return (String) this.getValue(Attributes.PATIENT_ID_STR);
    }
    
    public HandoffStatus setPatientId(String id) {
    	this.setValue(Attributes.PATIENT_ID_STR, id);
    	return this;
    }
    
    public Boolean getGhosted() {
    	return (Boolean) this.getValue(Attributes.GHOSTED_BOL);
    }
    
    public HandoffStatus setGhosted(Boolean ghosted) {
    	this.setValue(Attributes.GHOSTED_BOL, ghosted);
    	return this;
    }

    public HandoffStatusEnum getStatus() {
    	return (HandoffStatusEnum) this.getValue(Attributes.HANDOFF_STATUS_ENUM);
    }
    
    public HandoffStatus setStatus(HandoffStatusEnum status) {
    	this.setValue(Attributes.HANDOFF_STATUS_ENUM, status);
    	return this;
    }
    
 }
