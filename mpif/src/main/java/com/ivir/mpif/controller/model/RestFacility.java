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

import com.ivir.mpif.simdata.FacilityType;
import com.ivir.mpif.simdata.PhysicalLocation;
import com.ivir.mpif.simdata.RoleOfCare;

public class RestFacility {
    private String id;
    private Boolean local;
    private String facilityId;
    private String instanceName;
    private PhysicalLocation location;
    private RoleOfCare roleOfCare;
    private FacilityType facilityType;
    private Integer patientCapacity;
    private Boolean active;
    private Boolean controlledLocal;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Boolean isLocal() {
        return local;
    }

    public void setLocal(Boolean local) {
        this.local = local;
    }

    public String getFacilityId() {
        return facilityId;
    }

    public void setFacilityId(String facilityId) {
        this.facilityId = facilityId;
    }

    public String getInstanceName() {
        return instanceName;
    }

    public void setInstanceName(String instanceName) {
        this.instanceName = instanceName;
    }

    public PhysicalLocation getLocation() {
        return location;
    }

    public void setLocation(PhysicalLocation location) {
        this.location = location;
    }

    public RoleOfCare getRoleOfCare() {
        return roleOfCare;
    }

    public void setRoleOfCare(RoleOfCare roleOfCare) {
        this.roleOfCare = roleOfCare;
    }

    public FacilityType getFacilityType() {
        return facilityType;
    }

    public void setFacilityType(FacilityType facilityType) {
        this.facilityType = facilityType;
    }

    public Integer getPatientCapacity() {
        return patientCapacity;
    }

    public void setPatientCapacity(Integer patientCapacity) {
        this.patientCapacity = patientCapacity;
    }

    public Boolean isActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public Boolean getControlledLocal() {
        return controlledLocal;
    }

    public void setControlledLocal(Boolean controlledLocal) {
        this.controlledLocal = controlledLocal;
    }

    @Override
    public String toString() {
        return "RestFacility{" +
                "id='" + id + '\'' +
                ", local=" + local +
                ", facilityId='" + facilityId + '\'' +
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
