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

import java.io.Serializable;
import java.util.Objects;

public class BodyLocation implements Comparable<BodyLocation>, Serializable {
    public GeneralRegion generalRegion;
    public RegionTissueType regionTissueType;
    public InternalAnatomy internalAnatomy;
    public SagittalPlane sagittalPlane;
    public TransversePlane transversePlane;
    public CoronalPlane coronalPlane;
    public SkeletalSystem skeletalSystem;
    public DetailedAnatomy detailedAnatomy;
    public Integer fmaid;

    public BodyLocation() {
        this.generalRegion = GeneralRegion.NOT_APPLICABLE;
        this.regionTissueType = RegionTissueType.NOT_APPLICABLE;
        this.internalAnatomy = InternalAnatomy.NOT_APPLICABLE;
        this.sagittalPlane = SagittalPlane.NOT_APPLICABLE;
        this.transversePlane = TransversePlane.NOT_APPLICABLE;
        this.coronalPlane = CoronalPlane.NOT_APPLICABLE;
        this.skeletalSystem = SkeletalSystem.NOT_APPLICABLE;
        this.detailedAnatomy = DetailedAnatomy.NOT_APPLICABLE;
        this.fmaid = 0;
    }

    public GeneralRegion getGeneralRegion() {
        return generalRegion;
    }

    public BodyLocation setGeneralRegion(GeneralRegion generalRegion) {
        this.generalRegion = generalRegion;
        return this;
    }

    public RegionTissueType getRegionTissueType() {
        return regionTissueType;
    }

    public BodyLocation setRegionTissueType(RegionTissueType regionTissueType) {
        this.regionTissueType = regionTissueType;
        return this;
    }

    public InternalAnatomy getInternalAnatomy() {
        return internalAnatomy;
    }

    public BodyLocation setInternalAnatomy(InternalAnatomy internalAnatomy) {
        this.internalAnatomy = internalAnatomy;
        return this;
    }

    public SagittalPlane getSagittalPlane() {
        return sagittalPlane;
    }

    public BodyLocation setSagittalPlane(SagittalPlane sagittalPlane) {
        this.sagittalPlane = sagittalPlane;
        return this;
    }

    public TransversePlane getTransversePlane() {
        return transversePlane;
    }

    public BodyLocation setTransversePlane(TransversePlane transversePlane) {
        this.transversePlane = transversePlane;
        return this;
    }

    public CoronalPlane getCoronalPlane() {
        return coronalPlane;
    }

    public BodyLocation setCoronalPlane(CoronalPlane coronalPlane) {
        this.coronalPlane = coronalPlane;
        return this;
    }

    public SkeletalSystem getSkeletalSystem() {
        return skeletalSystem;
    }

    public BodyLocation setSkeletalSystem(SkeletalSystem skeletalSystem) {
        this.skeletalSystem = skeletalSystem;
        return this;
    }

    public DetailedAnatomy getDetailedAnatomy() {
        return detailedAnatomy;
    }

    public BodyLocation setDetailedAnatomy(DetailedAnatomy detailedAnatomy) {
        this.detailedAnatomy = detailedAnatomy;
        return this;
    }

    public Integer getFmaid() {
        return fmaid;
    }

    public BodyLocation setFmaid(Integer fmaid) {
        this.fmaid = fmaid;
        return this;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof BodyLocation that)) return false;
        return generalRegion == that.generalRegion && regionTissueType == that.regionTissueType && internalAnatomy == that.internalAnatomy && sagittalPlane == that.sagittalPlane && transversePlane == that.transversePlane && coronalPlane == that.coronalPlane && skeletalSystem == that.skeletalSystem && detailedAnatomy == that.detailedAnatomy && Objects.equals(fmaid, that.fmaid);
    }

    @Override
    public int hashCode() {
        return Objects.hash(generalRegion, regionTissueType, internalAnatomy, sagittalPlane, transversePlane, coronalPlane, skeletalSystem, detailedAnatomy, fmaid);
    }

    @Override
    public String toString() {
        return "BodyLocationRecord{" +
                "generalRegion=" + generalRegion +
                ", regionTissueType=" + regionTissueType +
                ", internalAnatomy=" + internalAnatomy +
                ", sagittalPlane=" + sagittalPlane +
                ", transversePlane=" + transversePlane +
                ", coronalPlane=" + coronalPlane +
                ", skeletalSystem=" + skeletalSystem +
                ", detailedAnatomy=" + detailedAnatomy +
                ", fmaid='" + fmaid + '\'' +
                '}';
    }

    @Override
    public int compareTo(BodyLocation o) {
        if(o == null){
            return -1;
        }
        int compareValue = 0;
        BodyLocation compRecord = (BodyLocation) o;
        compareValue += nullSafeCompare(this.generalRegion,compRecord.getGeneralRegion());
        compareValue += nullSafeCompare(this.regionTissueType,compRecord.getRegionTissueType());
        compareValue += nullSafeCompare(this.internalAnatomy,compRecord.getInternalAnatomy());
        compareValue += nullSafeCompare(this.sagittalPlane,compRecord.getSagittalPlane());
        compareValue += nullSafeCompare(this.transversePlane,compRecord.getTransversePlane());
        compareValue += nullSafeCompare(this.coronalPlane,compRecord.getCoronalPlane());
        compareValue += nullSafeCompare(this.skeletalSystem,compRecord.getSkeletalSystem());
        compareValue += nullSafeCompare(this.detailedAnatomy,compRecord.getDetailedAnatomy());
        compareValue += nullSafeCompare(this.fmaid,compRecord.getFmaid());
        return compareValue;
    }

    private int nullSafeCompare(Comparable thisVersion, Comparable newVersion){
        if(thisVersion == null){
            return 1;
        }
        if(newVersion == null){
            return -1;
        }
        return thisVersion.compareTo(newVersion);
    }
}


