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

import java.time.Instant;

public class FederationControl extends ConcurrentSimData<FederationControl.Attributes>{

	private static final long serialVersionUID = 8626156166373014751L;

    public enum Attributes{
        AUTO_ID_LONG,
        COMMAND_ENUM,
        PARAMETER_STR,
        TIME_INST,
        LOCAL_BOOL
    }

    public FederationControl(){
        super(FederationControl.Attributes.class, Attributes.AUTO_ID_LONG, true);
    }
    
    public Long getId() {
    	return this.getValue(Attributes.AUTO_ID_LONG, Long.class);
    }
    
    public FederationCommandEnum getCommand() {
    	return (FederationCommandEnum) this.getValue(Attributes.COMMAND_ENUM);
    }
    
    public FederationControl setCommand(FederationCommandEnum command) {
    	this.setValue(Attributes.COMMAND_ENUM, command);
    	return this;
    }
    
    public String getParameter() {
    	return (String) this.getValue(Attributes.PARAMETER_STR);
    }
    
    public FederationControl setParameter(String parameter) {
    	this.setValue(Attributes.PARAMETER_STR, parameter);
    	return this;
    }
    
    public Instant getTime() {
    	return (Instant) this.getValue(Attributes.TIME_INST);
    }
    
    public FederationControl setTime(Instant time) {
    	this.setValue(Attributes.TIME_INST, time);
    	return this;
    }
    
    public Boolean getLocal() {
    	return (Boolean) this.getValue(Attributes.LOCAL_BOOL);
    }
    
    public FederationControl setLocal(Boolean local) {
    	this.setValue(Attributes.LOCAL_BOOL, local);
    	return this;
    }
}
