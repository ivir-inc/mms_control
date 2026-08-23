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

import java.util.ArrayList;
import java.util.HashMap;

public class PatientCaseMetadata {
    ArrayList<HashMap<String,Object>> physicalTreatmentType = new ArrayList<>();
    ArrayList<HashMap<String,Object>> treatmentDevice = new ArrayList<>();
    ArrayList<HashMap<String,Object>> medication = new ArrayList<>();
    ArrayList<HashMap<String,Object>> administrationRoute = new ArrayList<>();
    ArrayList<HashMap<String,Object>> detailedAnatomy = new ArrayList<>();
    ArrayList<HashMap<String,Object>> skeletalSystem = new ArrayList<>();
    ArrayList<HashMap<String,Object>> coronalPlane = new ArrayList<>();
    ArrayList<HashMap<String,Object>> transversePlane = new ArrayList<>();
    ArrayList<HashMap<String,Object>> sagittalPlane = new ArrayList<>();
    ArrayList<HashMap<String,Object>> internalAnatomy = new ArrayList<>();
    ArrayList<HashMap<String,Object>> regionTissueType = new ArrayList<>();
    ArrayList<HashMap<String,Object>> generalRegion = new ArrayList<>();
    ArrayList<HashMap<String,Object>> deviceMap = new ArrayList<>();


    public ArrayList<HashMap<String, Object>> getPhysicalTreatmentType() {
        return physicalTreatmentType;
    }

    public PatientCaseMetadata setPhysicalTreatmentType(ArrayList<HashMap<String, Object>> physicalTreatmentType) {
        this.physicalTreatmentType = physicalTreatmentType;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getTreatmentDevice() {
        return treatmentDevice;
    }

    public PatientCaseMetadata setTreatmentDevice(ArrayList<HashMap<String, Object>> treatmentDevice) {
        this.treatmentDevice = treatmentDevice;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getMedication() {
        return medication;
    }

    public PatientCaseMetadata setMedication(ArrayList<HashMap<String, Object>> medication) {
        this.medication = medication;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getAdministrationRoute() {
        return administrationRoute;
    }

    public PatientCaseMetadata setAdministrationRoute(ArrayList<HashMap<String, Object>> administrationRoute) {
        this.administrationRoute = administrationRoute;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getDetailedAnatomy() {
        return detailedAnatomy;
    }

    public PatientCaseMetadata setDetailedAnatomy(ArrayList<HashMap<String, Object>> detailedAnatomy) {
        this.detailedAnatomy = detailedAnatomy;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getSkeletalSystem() {
        return skeletalSystem;
    }

    public PatientCaseMetadata setSkeletalSystem(ArrayList<HashMap<String, Object>> skeletalSystem) {
        this.skeletalSystem = skeletalSystem;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getCoronalPlane() {
        return coronalPlane;
    }

    public PatientCaseMetadata setCoronalPlane(ArrayList<HashMap<String, Object>> coronalPlane) {
        this.coronalPlane = coronalPlane;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getTransversePlane() {
        return transversePlane;
    }

    public PatientCaseMetadata setTransversePlane(ArrayList<HashMap<String, Object>> transversePlane) {
        this.transversePlane = transversePlane;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getSagittalPlane() {
        return sagittalPlane;
    }

    public PatientCaseMetadata setSagittalPlane(ArrayList<HashMap<String, Object>> sagittalPlane) {
        this.sagittalPlane = sagittalPlane;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getInternalAnatomy() {
        return internalAnatomy;
    }

    public PatientCaseMetadata setInternalAnatomy(ArrayList<HashMap<String, Object>> internalAnatomy) {
        this.internalAnatomy = internalAnatomy;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getRegionTissueType() {
        return regionTissueType;
    }

    public PatientCaseMetadata setRegionTissueType(ArrayList<HashMap<String, Object>> regionTissueType) {
        this.regionTissueType = regionTissueType;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getGeneralRegion() {
        return generalRegion;
    }

    public PatientCaseMetadata setGeneralRegion(ArrayList<HashMap<String, Object>> generalRegion) {
        this.generalRegion = generalRegion;
        return this;
    }

    public ArrayList<HashMap<String, Object>> getDeviceMap() {
        return deviceMap;
    }

    public PatientCaseMetadata setDeviceMap(ArrayList<HashMap<String, Object>> deviceMap) {
        this.deviceMap = deviceMap;
        return this;
    }
}
