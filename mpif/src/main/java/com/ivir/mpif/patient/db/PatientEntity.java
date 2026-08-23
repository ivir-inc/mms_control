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

package com.ivir.mpif.patient.db;

import com.ivir.mpif.patient.PatientSource;
import org.dizitart.no2.repository.annotations.Entity;
import org.dizitart.no2.repository.annotations.Id;

import java.util.Objects;

@Entity
public class PatientEntity {
    @Id
    private String id = "";
    private PatientSource physiologySource = PatientSource.UNKNOWN;
    private Boolean sourceLocked = false;
    private Boolean visible = false;
    private Integer patientCaseNum = null;

    public PatientEntity(String id, Boolean visible) {
        this.id = id;
        this.visible = visible;
    }

    public PatientEntity() {

    }

    public String getId() {
        return id;
    }

    public PatientEntity setId(String id) {
        this.id = id;
        return this;
    }

    public PatientSource getPhysiologySource() {
        return physiologySource;
    }

    public PatientEntity setPhysiologySource(PatientSource patientSource) {
        this.physiologySource = patientSource;
        return this;
    }

    public Boolean getVisible() {
        return visible;
    }

    public PatientEntity setVisible(Boolean visible) {
        this.visible = visible;
        return this;
    }

    public Boolean getSourceLocked() {
        return sourceLocked;
    }

    public PatientEntity setSourceLocked(Boolean sourceLocked) {
        this.sourceLocked = sourceLocked;
        return this;
    }

    public Integer getPatientCaseNum() {
        return patientCaseNum;
    }

    public PatientEntity setPatientCaseNum(Integer patientCaseNum) {
        this.patientCaseNum = patientCaseNum;
        return this;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof PatientEntity that)) return false;
        return Objects.equals(id, that.id) && physiologySource == that.physiologySource && Objects.equals(sourceLocked, that.sourceLocked) && Objects.equals(visible, that.visible) && Objects.equals(patientCaseNum, that.patientCaseNum);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, physiologySource, sourceLocked, visible, patientCaseNum);
    }

    @Override
    public String toString() {
        return "PatientEntity{" +
                "id='" + id + '\'' +
                ", physiologySource=" + physiologySource +
                ", sourceLocked=" + sourceLocked +
                ", visible=" + visible +
                ", patientCaseNum=" + patientCaseNum +
                '}';
    }
}