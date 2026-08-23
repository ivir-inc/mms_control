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

package com.ivir.mpif.pcb;

import com.ivir.mpif.simdata.BodyLocation;
import com.ivir.mpif.simdata.InjuryDescription;
import com.ivir.mpif.simdata.InjuryType;
import com.ivir.mpif.simdata.MechanismOfInjury;

public class PCInjury {
    private String name;
    private BodyLocation location;
    private InjuryType injuryType;
    private InjuryDescription description;
    private String detail;
    private Integer severity;
    private MechanismOfInjury mechanismOfInjury;
    private Float hemorrhageRate;
    private Float totalBodySurfaceArea;

    public BodyLocation getLocation() {
        return location;
    }

    public PCInjury setLocation(BodyLocation location) {
        this.location = location;
        return this;
    }

    public String getName() {
        return name;
    }

    public PCInjury setName(String name) {
        this.name = name;
        return this;
    }

    public InjuryType getInjuryType() {
        return injuryType;
    }

    public PCInjury setInjuryType(InjuryType injuryType) {
        this.injuryType = injuryType;
        return this;
    }

    public InjuryDescription getDescription() {
        return description;
    }

    public PCInjury setDescription(InjuryDescription description) {
        this.description = description;
        return this;
    }

    public String getDetail() {
        return detail;
    }

    public PCInjury setDetail(String detail) {
        this.detail = detail;
        return this;
    }

    public Integer getSeverity() {
        return severity;
    }

    public PCInjury setSeverity(Integer severity) {
        this.severity = severity;
        return this;
    }

    public MechanismOfInjury getMechanismOfInjury() {
        return mechanismOfInjury;
    }

    public PCInjury setMechanismOfInjury(MechanismOfInjury mechanismOfInjury) {
        this.mechanismOfInjury = mechanismOfInjury;
        return this;
    }

    public Float getHemorrhageRate() {
        return hemorrhageRate;
    }

    public PCInjury setHemorrhageRate(Float hemorrhageRate) {
        this.hemorrhageRate = hemorrhageRate;
        return this;
    }

    public Float getTotalBodySurfaceArea() {
        return totalBodySurfaceArea;
    }

    public PCInjury setTotalBodySurfaceArea(Float totalBodySurfaceArea) {
        this.totalBodySurfaceArea = totalBodySurfaceArea;
        return this;
    }
}
