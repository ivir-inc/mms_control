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

public class VitalsPatterns {
	private EcgPattern ecgPattern = null;
	private BpPattern bpPattern = null;
	private Spo2Pattern spo2Pattern = null;
	private Etco2Pattern etco2Pattern = null;
	
	public EcgPattern getEcgPattern() {
		return ecgPattern;
	}
	
	public void setEcgPattern(EcgPattern ecgPattern) {
		this.ecgPattern = ecgPattern;
	}
	
	public BpPattern getBpPattern() {
		return bpPattern;
	}
	
	public void setBpPattern(BpPattern bpPattern) {
		this.bpPattern = bpPattern;
	}
	
	public Spo2Pattern getSpo2Pattern() {
		return spo2Pattern;
	}
	
	public void setSpo2Pattern(Spo2Pattern spo2Pattern) {
		this.spo2Pattern = spo2Pattern;
	}
	
	public Etco2Pattern getEtco2Pattern() {
		return etco2Pattern;
	}
	
	public void setEtco2Pattern(Etco2Pattern etco2Pattern) {
		this.etco2Pattern = etco2Pattern;
	}
	
	
}
