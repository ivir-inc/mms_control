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

import com.ivir.mpif.simdata.EvacStateEnum;

public class MedEvacWs {
	private String patientId;
	private String transportType;
	private String siteName;
	private String vehicleId;
	private EvacStateEnum evacState;
	
	public String getPatientId() {
		return patientId;
	}
	
	public MedEvacWs setPatientId(String patientId) {
		this.patientId = patientId;
		return this;
	}
	
	public String getTransportType() {
		return transportType;
	}
	
	public MedEvacWs setTransportType(String transportType) {
		this.transportType = transportType;
		return this;
	}
	
	public String getSiteName() {
		return siteName;
	}
	
	public MedEvacWs setSiteName(String siteName) {
		this.siteName = siteName;
		return this;
	}
	
	public String getVehicleId() {
		return vehicleId;
	}
	
	public MedEvacWs setVehicleId(String vehicleId) {
		this.vehicleId = vehicleId;
		return this;
	}
	
	public EvacStateEnum getEvacState() {
		return evacState;
	}
	
	public MedEvacWs setEvacState(EvacStateEnum evacState) {
		this.evacState = evacState;
		return this;
	}
	
	
}
