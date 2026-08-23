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

public class RestUiVitalsPatterns {
	private Integer ekg;
	private Integer bp;
	private Integer spo2;
	private Integer etco2;
	
	public Integer getEkg() {
		return ekg;
	}
	
	public void setEkg(Integer ekg) {
		this.ekg = ekg;
	}
	
	public Integer getBp() {
		return bp;
	}
	
	public void setBp(Integer bp) {
		this.bp = bp;
	}
	
	public Integer getSpo2() {
		return spo2;
	}
	
	public void setSpo2(Integer spo2) {
		this.spo2 = spo2;
	}
	
	public Integer getEtco2() {
		return etco2;
	}
	
	public void setEtco2(Integer etco2) {
		this.etco2 = etco2;
	}
	
	
}
