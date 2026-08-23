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

package com.ivir.mpif.facility.db;

import com.ivir.mpif.simdata.FacilityType;
import com.ivir.mpif.simdata.PhysicalLocation;
import com.ivir.mpif.simdata.RoleOfCare;
import org.dizitart.no2.repository.annotations.Entity;
import org.dizitart.no2.repository.annotations.Id;

@Entity
public class FacilityRecord {
    @Id
    private String facilityId;
    private String instanceName;
    private PhysicalLocation location;
    private RoleOfCare roleOfCare;
    private FacilityType facilityType;
    private Integer patientCapacity;
    private Boolean active;
    private Boolean controlledLocal;

    public String getFacilityId() {
        return facilityId;
    }

    public FacilityRecord setFacilityId(String facilityId) {
        this.facilityId = facilityId;
        return this;
    }

    public String getInstanceName() {
        return instanceName;
    }

    public FacilityRecord setInstanceName(String instanceName) {
        this.instanceName = instanceName;
        return this;
    }

    public PhysicalLocation getLocation() {
        return location;
    }

    public FacilityRecord setLocation(PhysicalLocation location) {
        this.location = location;
        return this;
    }

    public RoleOfCare getRoleOfCare() {
        return roleOfCare;
    }

    public FacilityRecord setRoleOfCare(RoleOfCare roleOfCare) {
        this.roleOfCare = roleOfCare;
        return this;
    }

    public FacilityType getFacilityType() {
        return facilityType;
    }

    public FacilityRecord setFacilityType(FacilityType facilityType) {
        this.facilityType = facilityType;
        return this;
    }

    public Integer getPatientCapacity() {
        return patientCapacity;
    }

    public FacilityRecord setPatientCapacity(Integer patientCapacity) {
        this.patientCapacity = patientCapacity;
        return this;
    }

    public Boolean getActive() {
        return active;
    }

    public FacilityRecord setActive(Boolean active) {
        this.active = active;
        return this;
    }

    public Boolean getControlledLocal() {
        return controlledLocal;
    }

    public FacilityRecord setControlledLocal(Boolean controlledLocal) {
        this.controlledLocal = controlledLocal;
        return this;
    }

    @Override
    public String toString() {
        return "FacilityRecord{" +
                "facilityId='" + facilityId + '\'' +
                ", instanceName='" + instanceName + '\'' +
                ", location=" + location +
                ", roleOfCare=" + roleOfCare +
                ", facilityType=" + facilityType +
                ", patientCapacity=" + patientCapacity +
                ", active=" + active +
                ", controlledLocal=" + controlledLocal +
                '}';
    }
}
