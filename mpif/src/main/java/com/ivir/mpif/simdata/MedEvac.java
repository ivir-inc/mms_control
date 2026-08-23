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

public class MedEvac extends ConcurrentSimData<MedEvac.Attributes>{
	private static final long serialVersionUID = 7113985914359281128L;

	public enum Attributes {
		PATIENT_ID_STR,
		FACILITY_ID_STR,
		TRANSPORT_TYPE_STR,
		VEHICLE_ID_STR,
		EVAC_STATE_ENU
    }//Attributes
    
	public MedEvac(){
        super(Attributes.class, Attributes.PATIENT_ID_STR);
    }	
	
    public String getPatientId() {
        return (String) this.getValue(Attributes.PATIENT_ID_STR);
    }

    public MedEvac setPatientId(String patientId) {
    	this.setValue(Attributes.PATIENT_ID_STR, patientId);
        return this;
    }	
	
    public String getFacilityId() {
    	return (String) this.getValue(Attributes.FACILITY_ID_STR);
    }
    
    public MedEvac setFacilityId(String facilityId) {
    	this.setValue(Attributes.FACILITY_ID_STR, facilityId);
    	return this;
    }
    
    public String getTransportType() {
    	return (String) this.getValue(Attributes.TRANSPORT_TYPE_STR);
    }
    
    public MedEvac setTransportType(String type) {
    	this.setValue(Attributes.TRANSPORT_TYPE_STR, type);
    	return this;
    }
    
    public String getVehicleId() {
    	return (String) this.getValue(Attributes.VEHICLE_ID_STR);
    }
    
    public MedEvac setVehicleId(String vehicleId) {
    	this.setValue(Attributes.VEHICLE_ID_STR, vehicleId);
    	return this;
    }
    
    public EvacStateEnum getEvacState() {
    	return (EvacStateEnum) this.getValue(Attributes.EVAC_STATE_ENU);
    }
    
    public MedEvac setEvacState(EvacStateEnum state) {
    	this.setValue(Attributes.EVAC_STATE_ENU, state);
    	return this;
    }
    
    @Override
    public String toString() {
    	return super.toString();
    }
}
