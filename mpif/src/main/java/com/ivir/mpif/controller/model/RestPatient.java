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

import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientSource;

public class RestPatient {
    private String id;
    private String name;
    private PatientSource physiologySource = PatientSource.UNKNOWN;
    private Boolean sourceLocked;
    Boolean monitorPatient = false;
    private Integer patientCaseNum = null;

    public RestPatient(){

    }

    public RestPatient(Patient patient){
        id = patient.getId().getIdAsString();
        physiologySource = patient.getPhysiologySource();
        monitorPatient = patient.getVisible();
        patientCaseNum = patient.getPatientCaseNum();
    }

    public String getId() {
        return id;
    }

    public RestPatient setId(String id) {
        this.id = id;
        return this;
    }

    public String getName() {
        return name;
    }

    public RestPatient setName(String name) {
        this.name = name;
        return this;
    }

    public PatientSource getPhysiologySource() {
        return physiologySource;
    }

    public RestPatient setPhysiologySource(PatientSource physiologySource) {
        this.physiologySource = physiologySource;
        return this;
    }

    public Boolean getSourceLocked() {
        return sourceLocked;
    }

    public RestPatient setSourceLocked(Boolean sourceLocked) {
        this.sourceLocked = sourceLocked;
        return this;
    }

    public Boolean getMonitorPatient() {
        return monitorPatient;
    }

    public RestPatient setMonitorPatient(Boolean monitorPatient) {
        this.monitorPatient = monitorPatient;
        return this;
    }

    public Integer getPatientCaseNum() {
        return patientCaseNum;
    }

    public RestPatient setPatientCaseNum(Integer patientCaseNum) {
        this.patientCaseNum = patientCaseNum;
        return this;
    }
}
