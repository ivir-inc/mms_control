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

package com.ivir.mpif.controller.model;

import java.util.Optional;

public enum VitalsChangeEnum {
	RR("rr", "respiratory_rate_control"),
	HR("hr", "heart_rate_control"),
	BP_SYSTOLIC("bp_systolic", "systolic_pressure_control"),
	BP_DIASTOLIC("bp_diastolic", "diastolic_pressure_control"),
	TEMP("temp", "temperature_control"),
	SPO2("spo2", "o2_saturation_control"),
	ETCO2("etco2", "etco2_control");

	VitalsChangeEnum(String restName, String controlFact) {
		this.restName = restName;
		this.controlFact = controlFact;
	}
	
	private String restName;
	private String controlFact;

	public String getRestName() {
		return this.restName;
	}

	public String getControlFact(){
		return this.controlFact;
	}
	
	public static Optional<VitalsChangeEnum> getVCEnumByRestName(String restName) {
		for(VitalsChangeEnum changeEnum : VitalsChangeEnum.values()) {
			if(restName.equalsIgnoreCase(changeEnum.getRestName())) {
				return Optional.of(changeEnum);
			}
		}
		return Optional.empty();
	}
		
}
