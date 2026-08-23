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

public class Facility extends ConcurrentSimData<Facility.Attributes>{
    public enum Attributes{
        ID,
        LOCAL_BOOL,
        FACILITY_ID_STR,
        INSTANCE_NAME_STR,
        LOCATION_OBJ,
        ROLE_OF_CARE_ENUM,
        FACILITY_TYPE_ENUM,
        PATIENT_CAPACITY_INT
    }

    public Facility(){
        super(Attributes.class, Attributes.ID, true);
    }

    public String getId(){
        return this.getIndex();
    }

    public Boolean isLocal(){
        return this.getValue(Attributes.LOCAL_BOOL, Boolean.class);
    }

    public Facility setLocal(Boolean isLocal){
        this.setValue(Attributes.LOCAL_BOOL, isLocal);
        return this;
    }

    public String getFacilityId(){
        return this.getValue(Attributes.FACILITY_ID_STR, String.class);
    }

    public Facility setFacilityId(String facilityId){
        this.setValue(Attributes.FACILITY_ID_STR, facilityId);
        return this;
    }

    public String getInstanceName(){
        return this.getValue(Attributes.INSTANCE_NAME_STR, String.class);
    }

    public Facility setInstanceName(String name){
        this.setValue(Attributes.INSTANCE_NAME_STR, name);
        return this;
    }

    public PhysicalLocation getLocation(){
        return this.getValue(Attributes.LOCATION_OBJ, PhysicalLocation.class);
    }

    public Facility setLocation(PhysicalLocation location){
        this.setValue(Attributes.LOCATION_OBJ, location);
        return this;
    }

    public RoleOfCare getRoleOfCare(){
        return this.getValue(Attributes.ROLE_OF_CARE_ENUM, RoleOfCare.class);
    }

    public Facility setRoleOfCare(RoleOfCare value){
        this.setValue(Attributes.ROLE_OF_CARE_ENUM, value);
        return this;
    }

    public FacilityType getFacilityType(){
        return this.getValue(Attributes.FACILITY_TYPE_ENUM, FacilityType.class);
    }

    public Facility setFacilityType(FacilityType value){
        this.setValue(Attributes.FACILITY_TYPE_ENUM, value);
        return this;
    }

    public Integer getPatientCapacity(){
        return this.getValue(Attributes.PATIENT_CAPACITY_INT, Integer.class);
    }

    public Facility setPatientCapacity(Integer capacity){
        this.setValue(Attributes.PATIENT_CAPACITY_INT, capacity);
        return this;
    }

}
