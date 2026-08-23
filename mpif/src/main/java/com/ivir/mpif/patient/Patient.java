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

package com.ivir.mpif.patient;

import com.ivir.mpif.common.PatientId;

import java.util.Objects;

public class Patient {
    private PatientId id;
    private PatientSource physiologySource = PatientSource.UNKNOWN;
    private Boolean sourceLocked = false;
    private Boolean visible = false;
    private Integer patientCaseNum = null;

    public PatientId getId() {
        return id;
    }

    public Patient setId(PatientId id) {
        this.id = id;
        return this;
    }

    public PatientSource getPhysiologySource() {
        return physiologySource;
    }

    public Patient setPhysiologySource(PatientSource physiologySource) {
        this.physiologySource = physiologySource;
        return this;
    }

    public Boolean getSourceLocked() {
        return sourceLocked;
    }

    public Patient setSourceLocked(Boolean sourceLocked) {
        this.sourceLocked = sourceLocked;
        return this;
    }

    public Boolean getVisible() {
        return visible;
    }

    public Patient setVisible(Boolean visible) {
        this.visible = visible;
        return this;
    }

    public Integer getPatientCaseNum() {
        return patientCaseNum;
    }

    public Patient setPatientCaseNum(Integer patientCaseNum) {
        this.patientCaseNum = patientCaseNum;
        return this;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Patient patient)) return false;
        return Objects.equals(id, patient.id) && physiologySource == patient.physiologySource && Objects.equals(sourceLocked, patient.sourceLocked) && Objects.equals(visible, patient.visible) && Objects.equals(patientCaseNum, patient.patientCaseNum);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, physiologySource, sourceLocked, visible, patientCaseNum);
    }

    @Override
    public String toString() {
        return "Patient{" +
                "id=" + id +
                ", physiologySource=" + physiologySource +
                ", sourceLocked=" + sourceLocked +
                ", visible=" + visible +
                ", patientCaseNum=" + patientCaseNum +
                '}';
    }
}
