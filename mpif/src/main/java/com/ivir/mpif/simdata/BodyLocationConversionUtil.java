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

import devstudio.generatedcode.datatypes.*;

public class BodyLocationConversionUtil {
    public static BodyLocation toBodyLocation(BodyLocationRecord record){
        if(record == null){
            return null;
        }
        BodyLocation bodyLocation = new BodyLocation();
        bodyLocation.setFmaid(record.getFmaid());
        bodyLocation.setCoronalPlane(CoronalPlane.valueOf(record.getCoronalPlane().toString()));
        bodyLocation.setDetailedAnatomy(DetailedAnatomy.valueOf(record.getDetailedAnatomy().toString()));
        bodyLocation.setGeneralRegion(GeneralRegion.valueOf(record.getGeneralRegion().toString()));
        bodyLocation.setInternalAnatomy(InternalAnatomy.valueOf(record.getInternalAnatomy().toString()));
        bodyLocation.setRegionTissueType(RegionTissueType.valueOf(record.getRegionTissueType().toString()));
        bodyLocation.setSagittalPlane(SagittalPlane.valueOf(record.getSagittalPlane().toString()));
        bodyLocation.setSkeletalSystem(SkeletalSystem.valueOf(record.getSkeletalSystem().toString()));
        bodyLocation.setTransversePlane(TransversePlane.valueOf(record.getTransversePlane().toString()));
        return bodyLocation;
    }

    public static BodyLocationRecord toBodyLocationRecord(BodyLocation bodyLocation){
        if(bodyLocation == null){
            return null;
        }
        return BodyLocationRecord.create(
                GeneralRegionEnum.valueOf(bodyLocation.getGeneralRegion().toString()),
                RegionTissueTypeEnum.valueOf(bodyLocation.getRegionTissueType().toString()),
                InternalAnatomyEnum.valueOf(bodyLocation.getInternalAnatomy().toString()),
                SagittalPlaneEnum.valueOf(bodyLocation.getSagittalPlane().toString()),
                TransversePlaneEnum.valueOf(bodyLocation.getTransversePlane().toString()),
                CoronalPlaneEnum.valueOf(bodyLocation.getCoronalPlane().toString()),
                SkeletalSystemEnum.valueOf(bodyLocation.getSkeletalSystem().toString()),
                DetailedAnatomyEnum.valueOf(bodyLocation.getDetailedAnatomy().toString()),
                bodyLocation.getFmaid());
    }
}
