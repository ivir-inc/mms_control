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

public class EventWs {
	private String id;
	private String instanceName;
	private Long time;
	private Long simTime;
	private String type;
	private String source;
	private String patientId;
	private String learnerId;
	private String instructorId;
	private String teamId;
	private String notes;
	private String description;
	private String facilityId;
	private String action;
	
	public String getId() {
		return id;
	}

	public EventWs setId(String id) {
		this.id = id;
		return this;
	}

	public String getInstanceName() {
		return instanceName;
	}

	public EventWs setInstanceName(String instanceName) {
		this.instanceName = instanceName;
		return this;
	}

	public Long getTime() {
		return time;
	}

	public EventWs setTime(Long time) {
		this.time = time;
		return this;
	}

	public Long getSimTime() {
		return simTime;
	}

	public EventWs setSimTime(Long simTime) {
		this.simTime = simTime;
		return this;
	}

	public String getType() {
		return type;
	}

	public EventWs setType(String type) {
		this.type = type;
		return this;
	}

	public String getSource() {
		return source;
	}

	public EventWs setSource(String source) {
		this.source = source;
		return this;
	}

	public String getPatientId() {
		return patientId;
	}

	public EventWs setPatientId(String patientId) {
		this.patientId = patientId;
		return this;
	}

	public String getLearnerId() {
		return learnerId;
	}

	public EventWs setLearnerId(String learnerId) {
		this.learnerId = learnerId;
		return this;
	}

	public String getInstructorId() {
		return instructorId;
	}

	public EventWs setInstructorId(String instructorId) {
		this.instructorId = instructorId;
		return this;
	}

	public String getTeamId() {
		return teamId;
	}

	public EventWs setTeamId(String teamId) {
		this.teamId = teamId;
		return this;
	}

	public String getNotes() {
		return notes;
	}

	public EventWs setNotes(String notes) {
		this.notes = notes;
		return this;
	}

	public String getDescription() {
		return description;
	}

	public EventWs setDescription(String description) {
		this.description = description;
		return this;
	}

	public String getFacilityId() {
		return facilityId;
	}
	
	public EventWs setFacilityId(String facilityId) {
		this.facilityId = facilityId;
		return this;
	}

	public String getAction() {
		return action;
	}

	public EventWs setAction(String action) {
		this.action = action;
		return this;
	}

	@Override
	public String toString() {
		return "EventWs{" +
				"id='" + id + '\'' +
				", instanceName='" + instanceName + '\'' +
				", time=" + time +
				", simTime=" + simTime +
				", type='" + type + '\'' +
				", source='" + source + '\'' +
				", patientId='" + patientId + '\'' +
				", learnerId='" + learnerId + '\'' +
				", instructorId='" + instructorId + '\'' +
				", teamId='" + teamId + '\'' +
				", notes='" + notes + '\'' +
				", description='" + description + '\'' +
				", facilityId='" + facilityId + '\'' +
				", action='" + action + '\'' +
				'}';
	}
}
