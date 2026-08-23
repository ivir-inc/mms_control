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


public class RestPCInjury {
    private String name;
    private RestBodyLocation location;
    private String injuryType;
    private String description;
    private String detail;
    private Integer severity;
    private RestMechanismOfInjury mechanismOfInjury;
    private Float hemorrhageRate;
    private Float totalBodySurfaceArea;

    public String getName() {
        return name;
    }

    public RestPCInjury setName(String name) {
        this.name = name;
        return this;
    }

    public RestBodyLocation getLocation() {
        return location;
    }

    public RestPCInjury setLocation(RestBodyLocation location) {
        this.location = location;
        return this;
    }

    public String getInjuryType() {
        return injuryType;
    }

    public RestPCInjury setInjuryType(String injuryType) {
        this.injuryType = injuryType;
        return this;
    }

    public String getDescription() {
        return description;
    }

    public RestPCInjury setDescription(String description) {
        this.description = description;
        return this;
    }

    public String getDetail() {
        return detail;
    }

    public RestPCInjury setDetail(String detail) {
        this.detail = detail;
        return this;
    }

    public Integer getSeverity() {
        return severity;
    }

    public RestPCInjury setSeverity(Integer severity) {
        this.severity = severity;
        return this;
    }

    public RestMechanismOfInjury getMechanismOfInjury() {
        return mechanismOfInjury;
    }

    public RestPCInjury setMechanismOfInjury(RestMechanismOfInjury mechanismOfInjury) {
        this.mechanismOfInjury = mechanismOfInjury;
        return this;
    }

    public Float getHemorrhageRate() {
        return hemorrhageRate;
    }

    public RestPCInjury setHemorrhageRate(Float hemorrhageRate) {
        this.hemorrhageRate = hemorrhageRate;
        return this;
    }

    public Float getTotalBodySurfaceArea() {
        return totalBodySurfaceArea;
    }

    public RestPCInjury setTotalBodySurfaceArea(Float totalBodySurfaceArea) {
        this.totalBodySurfaceArea = totalBodySurfaceArea;
        return this;
    }
}
