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

public class InstructorControl extends ConcurrentSimData<InstructorControl.Attributes> {
    private static final long serialVersionUID = -2860956934855176521L;

    public enum Attributes {
        AUTO_ID_LNG,
        FACILITY_ID_STR,
        COMMAND_ENUM,
        LOCAL_BOOL
    }

    public InstructorControl() {
        super(InstructorControl.Attributes.class, Attributes.AUTO_ID_LNG, true);
    }

    public Long getId() {
        return (Long) this.getValue(Attributes.AUTO_ID_LNG);
    }

    public String getFacilityId() {
        return (String) this.getValue(Attributes.FACILITY_ID_STR);
    }

    public InstructorControl setFacilityId(String facilityId) {
        this.setValue(Attributes.FACILITY_ID_STR, facilityId);
        return this;
    }

    public InstructorControlCmdEnum getCommand() {
        return (InstructorControlCmdEnum) this.getValue(Attributes.COMMAND_ENUM);
    }

    public InstructorControl setCommand(InstructorControlCmdEnum command) {
        this.setValue(Attributes.COMMAND_ENUM, command);
        return this;
    }

    public Boolean getLocal() {
        return (Boolean) this.getValue(Attributes.LOCAL_BOOL);
    }

    public InstructorControl setLocal(Boolean local) {
        this.setValue(Attributes.LOCAL_BOOL, local);
        return this;
    }

}
