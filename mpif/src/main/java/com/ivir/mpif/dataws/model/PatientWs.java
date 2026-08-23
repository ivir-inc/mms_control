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

import com.ivir.mpif.patient.PatientSource;

public class PatientWs {
    private String id = null;
    private PatientSource physiologySource = null;
    private Boolean sourceLocked = null;
    private Boolean visible = null;
    private Integer patientCaseNum = null;

    public String getId() {
        return id;
    }

    public PatientWs setId(String id) {
        this.id = id;
        return this;
    }

    public PatientSource getPhysiologySource() {
        return physiologySource;
    }

    public PatientWs setPhysiologySource(PatientSource physiologySource) {
        this.physiologySource = physiologySource;
        return this;
    }

    public Boolean getSourceLocked() {
        return sourceLocked;
    }

    public PatientWs setSourceLocked(Boolean sourceLocked) {
        this.sourceLocked = sourceLocked;
        return this;
    }

    public Boolean getVisible() {
        return visible;
    }

    public PatientWs setVisible(Boolean visible) {
        this.visible = visible;
        return this;
    }

    public Integer getPatientCaseNum() {
        return patientCaseNum;
    }

    public PatientWs setPatientCaseNum(Integer patientCaseNum) {
        this.patientCaseNum = patientCaseNum;
        return this;
    }
}
