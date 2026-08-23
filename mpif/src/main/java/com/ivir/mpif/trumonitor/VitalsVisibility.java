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

package com.ivir.mpif.trumonitor;

public class VitalsVisibility {
	private Boolean ekg = null;
	private Boolean bp = null;
	private Boolean spo2 = null;
	private Boolean etco2 = null;
	private Boolean rr = null;
	private Boolean temp = null;

	public Boolean getEkg() {
		return ekg;
	}
	
	public void setEkg(Boolean ekg) {
		this.ekg = ekg;
	}
	
	public Boolean getBp() {
		return bp;
	}
	
	public void setBp(Boolean bp) {
		this.bp = bp;
	}
	
	public Boolean getSpo2() {
		return spo2;
	}
	
	public void setSpo2(Boolean spo2) {
		this.spo2 = spo2;
	}
	
	public Boolean getEtco2() {
		return etco2;
	}
	
	public void setEtco2(Boolean etco2) {
		this.etco2 = etco2;
	}
	
	public Boolean getRr() {
		return rr;
	}

	public void setRr(Boolean rr) {
		this.rr = rr;
	}
	
	public Boolean getTemp() {
		return temp;
	}
	
	public void setTemp(Boolean temp) {
		this.temp = temp;
	}
	
	
}
