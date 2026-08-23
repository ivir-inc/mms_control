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

import java.util.List;

public class InjuryWs {
    private String instanceName;
    private String patientId;
    private String injuryId;
    private List<String> locations;
    private Long time;
    private String description;
    private String injuryType;
    private Integer severity;
    private Boolean isBurn;
    private Float burnSurfaceArea;
    private String burnDegree;
    private String burnType;
	public String getInstanceName() {
		return instanceName;
	}
	public void setInstanceName(String instanceName) {
		this.instanceName = instanceName;
	}
	public String getPatientId() {
		return patientId;
	}
	public void setPatientId(String patientId) {
		this.patientId = patientId;
	}
	public String getInjuryId() {
		return injuryId;
	}
	public void setInjuryId(String injuryId) {
		this.injuryId = injuryId;
	}
	public List<String> getLocations() {
		return locations;
	}
	public void setLocations(List<String> locations) {
		this.locations = locations;
	}
	public Long getTime() {
		return time;
	}
	public void setTime(Long time) {
		this.time = time;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getInjuryType() {
		return injuryType;
	}
	public void setInjuryType(String injuryType) {
		this.injuryType = injuryType;
	}
	public Integer getSeverity() {
		return severity;
	}
	public void setSeverity(Integer severity) {
		this.severity = severity;
	}
	public Boolean getIsBurn() {
		return isBurn;
	}
	public void setIsBurn(Boolean isBurn) {
		this.isBurn = isBurn;
	}
	public Float getBurnSurfaceArea() {
		return burnSurfaceArea;
	}
	public void setBurnSurfaceArea(Float burnSurfaceArea) {
		this.burnSurfaceArea = burnSurfaceArea;
	}
	public String getBurnDegree() {
		return burnDegree;
	}
	public void setBurnDegree(String burnDegree) {
		this.burnDegree = burnDegree;
	}
	public String getBurnType() {
		return burnType;
	}
	public void setBurnType(String burnType) {
		this.burnType = burnType;
	}
    
    
    
    
    
}
