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

import com.ivir.mpif.simdata.BodyLocation;
import com.ivir.mpif.simdata.InjuryDescription;
import com.ivir.mpif.simdata.InjuryType;
import com.ivir.mpif.simdata.MechanismOfInjury;

public class RestInjury {
    String patientId;
    String injuryId;
    String injuryName;
    Long time;
    BodyLocation bodyLocation;
    InjuryType injuryType;
    InjuryDescription description;
    String detail;
    Integer severity;
    MechanismOfInjury mechanismOfInjury;
    Float hemorrhageRate;
    Float totalBodySurfaceArea;

    public String getPatientId() {
        return patientId;
    }

    public RestInjury setPatientId(String patientId) {
        this.patientId = patientId;
        return this;
    }

    public String getInjuryId() {
        return injuryId;
    }

    public RestInjury setInjuryId(String injuryId) {
        this.injuryId = injuryId;
        return this;
    }

    public String getInjuryName() {
        return injuryName;
    }

    public RestInjury setInjuryName(String injuryName) {
        this.injuryName = injuryName;
        return this;
    }

    public Long getTime() {
        return time;
    }

    public RestInjury setTime(Long time) {
        this.time = time;
        return this;
    }

    public BodyLocation getBodyLocation() {
        return bodyLocation;
    }

    public RestInjury setBodyLocation(BodyLocation bodyLocation) {
        this.bodyLocation = bodyLocation;
        return this;
    }

    public InjuryType getInjuryType() {
        return injuryType;
    }

    public RestInjury setInjuryType(InjuryType injuryType) {
        this.injuryType = injuryType;
        return this;
    }

    public InjuryDescription getDescription() {
        return description;
    }

    public RestInjury setDescription(InjuryDescription description) {
        this.description = description;
        return this;
    }

    public String getDetail() {
        return detail;
    }

    public RestInjury setDetail(String detail) {
        this.detail = detail;
        return this;
    }

    public Integer getSeverity() {
        return severity;
    }

    public RestInjury setSeverity(Integer severity) {
        this.severity = severity;
        return this;
    }

    public MechanismOfInjury getMechanismOfInjury() {
        return mechanismOfInjury;
    }

    public RestInjury setMechanismOfInjury(MechanismOfInjury mechanismOfInjury) {
        this.mechanismOfInjury = mechanismOfInjury;
        return this;
    }

    public Float getHemorrhageRate() {
        return hemorrhageRate;
    }

    public RestInjury setHemorrhageRate(Float hemorrhageRate) {
        this.hemorrhageRate = hemorrhageRate;
        return this;
    }

    public Float getTotalBodySurfaceArea() {
        return totalBodySurfaceArea;
    }

    public RestInjury setTotalBodySurfaceArea(Float totalBodySurfaceArea) {
        this.totalBodySurfaceArea = totalBodySurfaceArea;
        return this;
    }
}
