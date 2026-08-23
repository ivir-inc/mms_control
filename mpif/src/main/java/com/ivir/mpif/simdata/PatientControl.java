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

import com.ivir.mpif.common.PatientId;

public class PatientControl extends ConcurrentSimData<PatientControl.Attributes> {
    private static final long serialVersionUID = -2860956934855176521L;

    public enum Attributes {
        AUTO_ID_LONG,
        PATIENT_ID_OBJ,
        COMMAND_ENUM,
        SIMULATION_ELAPSED_TIME_LONG,
        LOCAL_BOOL
    }

    public PatientControl() {
        super(PatientControl.Attributes.class, PatientControl.Attributes.AUTO_ID_LONG, true);
    }

    public Long getId() {
        return (Long) this.getValue(Attributes.AUTO_ID_LONG);
    }

    public PatientId getPatient() {
        return (PatientId) this.getValue(Attributes.PATIENT_ID_OBJ);
    }

    public PatientControl setPatientId(PatientId patientId) {
        this.setValue(Attributes.PATIENT_ID_OBJ, patientId);
        return this;
    }

    public PatientControl setPatientId(String patientId) {
        return setPatientId(new PatientId(patientId));
    }

    public PatientControlCommandEnum getCommand() {
        return (PatientControlCommandEnum) this.getValue(Attributes.COMMAND_ENUM);
    }

    public PatientControl setCommand(PatientControlCommandEnum command) {
        this.setValue(Attributes.COMMAND_ENUM, command);
        return this;
    }

    public Long getSimulationElapsedTime() {
        return (Long) this.getValue(Attributes.SIMULATION_ELAPSED_TIME_LONG);
    }

    public PatientControl setSimulationElapsedTime(Long timeMs) {
        this.setValue(Attributes.SIMULATION_ELAPSED_TIME_LONG, timeMs);
        return this;
    }

    public Boolean isLocal() {
        return (Boolean) this.getValue(Attributes.LOCAL_BOOL);
    }

    public PatientControl setLocal(Boolean ghosted) {
        this.setValue(Attributes.LOCAL_BOOL, ghosted);
        return this;
    }

}
