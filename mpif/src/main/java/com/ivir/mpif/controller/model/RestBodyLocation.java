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

public class RestBodyLocation {
    public String generalRegion;
    public String regionTissueType;
    public String internalAnatomy;
    public String sagittalPlane;
    public String transversePlane;
    public String coronalPlane;
    public String skeletalSystem;
    public String detailedAnatomy;
    public String fmaid;

    public String getGeneralRegion() {
        return generalRegion;
    }

    public RestBodyLocation setGeneralRegion(String generalRegion) {
        this.generalRegion = generalRegion;
        return this;
    }

    public String getRegionTissueType() {
        return regionTissueType;
    }

    public RestBodyLocation setRegionTissueType(String regionTissueType) {
        this.regionTissueType = regionTissueType;
        return this;
    }

    public String getInternalAnatomy() {
        return internalAnatomy;
    }

    public RestBodyLocation setInternalAnatomy(String internalAnatomy) {
        this.internalAnatomy = internalAnatomy;
        return this;
    }

    public String getSagittalPlane() {
        return sagittalPlane;
    }

    public RestBodyLocation setSagittalPlane(String sagittalPlane) {
        this.sagittalPlane = sagittalPlane;
        return this;
    }

    public String getTransversePlane() {
        return transversePlane;
    }

    public RestBodyLocation setTransversePlane(String transversePlane) {
        this.transversePlane = transversePlane;
        return this;
    }

    public String getCoronalPlane() {
        return coronalPlane;
    }

    public RestBodyLocation setCoronalPlane(String coronalPlane) {
        this.coronalPlane = coronalPlane;
        return this;
    }

    public String getSkeletalSystem() {
        return skeletalSystem;
    }

    public RestBodyLocation setSkeletalSystem(String skeletalSystem) {
        this.skeletalSystem = skeletalSystem;
        return this;
    }

    public String getDetailedAnatomy() {
        return detailedAnatomy;
    }

    public RestBodyLocation setDetailedAnatomy(String detailedAnatomy) {
        this.detailedAnatomy = detailedAnatomy;
        return this;
    }

    public String getFmaid() {
        return fmaid;
    }

    public RestBodyLocation setFmaid(String fmaid) {
        this.fmaid = fmaid;
        return this;
    }
}
