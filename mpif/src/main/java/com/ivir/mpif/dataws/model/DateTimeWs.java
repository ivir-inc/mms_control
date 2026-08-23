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

public class DateTimeWs {
	private Integer rate;
	private Long elapsedTimeMs;
	private Long simTimeMs;
	private Long wallClockMs;
	
	public Integer getRate() {
		return rate;
	}
	
	public void setRate(Integer rate) {
		this.rate = rate;
	}
	
	public Long getElapsedTimeMs() {
		return elapsedTimeMs;
	}
	
	public void setElapsedTimeMs(Long elapsedTimeMs) {
		this.elapsedTimeMs = elapsedTimeMs;
	}
	
	public Long getSimTimeMs() {
		return simTimeMs;
	}
	
	public void setSimTimeMs(Long simTimeMs) {
		this.simTimeMs = simTimeMs;
	}
	
	public Long getWallClockMs() {
		return wallClockMs;
	}
	
	public void setWallClockMs(Long wallClockMs) {
		this.wallClockMs = wallClockMs;
	}

	
}
