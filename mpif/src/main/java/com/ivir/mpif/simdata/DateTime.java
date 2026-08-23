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

public class DateTime extends ConcurrentSimData<DateTime.Attributes> {

    public enum Attributes{
        CLOCK_TYPE_ENUM,
        CURRENT_DATE_TIME,
        SIMULATED_DATE_TIME,
        SIMULATION_ELAPSED_TIME,
        TIME_SCALE,
        LOCAL
    }
    
    public DateTime(ClockType clockType) {
        super(Attributes.class, Attributes.CLOCK_TYPE_ENUM);
        this.setValue(Attributes.CLOCK_TYPE_ENUM, clockType);
    }

    public ClockType getClockType(){
        return (ClockType) this.getValue(Attributes.CLOCK_TYPE_ENUM);
    }

    public Long getCurrentDateTime() {
    	return (Long) this.getValue(Attributes.CURRENT_DATE_TIME);
    }
    
    public DateTime setCurrentDateTime(long currentDateTime) {
    	this.setValue(Attributes.CURRENT_DATE_TIME, currentDateTime);
    	return this;
    }
    
    public Long getSimulatedDateTime() {
    	return (Long) this.getValue(Attributes.SIMULATED_DATE_TIME);
    }
    
    public DateTime setSimulatedDateTime(long simDateTime) {
    	this.setValue(Attributes.SIMULATED_DATE_TIME, simDateTime);
    	return this;
    }   
    
    public Long getSimulationElapsedTime() {
    	return (Long) this.getValue(Attributes.SIMULATION_ELAPSED_TIME);
    }
    
    public DateTime setSimulationElapsedTime(long elapsedTime) {
    	this.setValue(Attributes.SIMULATION_ELAPSED_TIME, elapsedTime);
    	return this;
    }   
    
    public Integer getTimeScale() {
    	return (Integer) this.getValue(Attributes.TIME_SCALE);
    }
    
    public DateTime setTimeScale(int timeScale) {
    	this.setValue(Attributes.TIME_SCALE, timeScale);
    	return this;
    }
    
    public Boolean getLocal() {
    	return (Boolean) this.getValue(Attributes.LOCAL);
    }
    
    public DateTime setLocal(Boolean isLocal) {
    	this.setValue(Attributes.LOCAL, isLocal);
    	return this;
    }
}
