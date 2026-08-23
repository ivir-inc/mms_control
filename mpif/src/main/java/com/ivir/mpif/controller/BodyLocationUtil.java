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

package com.ivir.mpif.controller;

import com.ivir.mpif.controller.model.RestBodyLocation;
import com.ivir.mpif.simdata.*;
import jdk.jshell.spi.ExecutionControlProvider;

public class BodyLocationUtil {

    public static BodyLocation fromRest(RestBodyLocation restLocation){
        if(restLocation == null){
            return null;
        }
        BodyLocation bodyLocation = new BodyLocation();
        try {
            bodyLocation.setFmaid(Integer.parseInt(restLocation.getFmaid()));
        }catch (Exception e){
            bodyLocation.setFmaid(0);
        }
        bodyLocation.setCoronalPlane(CoronalPlane.getByName(restLocation.getCoronalPlane()));
        bodyLocation.setDetailedAnatomy(DetailedAnatomy.getByName(restLocation.getDetailedAnatomy()));
        bodyLocation.setGeneralRegion(GeneralRegion.getByName(restLocation.getGeneralRegion()));
        bodyLocation.setInternalAnatomy(InternalAnatomy.getByName(restLocation.getInternalAnatomy()));
        bodyLocation.setRegionTissueType(RegionTissueType.getByName(restLocation.getRegionTissueType()));
        bodyLocation.setSagittalPlane(SagittalPlane.getByName(restLocation.getSagittalPlane()));
        bodyLocation.setSkeletalSystem(SkeletalSystem.getByName(restLocation.getSkeletalSystem()));
        bodyLocation.setTransversePlane(TransversePlane.getByName(restLocation.getTransversePlane()));
        return bodyLocation;
    }

    public static RestBodyLocation toRest(BodyLocation location){
        if(location == null){
            return null;
        }
        RestBodyLocation restLocation = new RestBodyLocation();
        if(location.getCoronalPlane() != null) {
            restLocation.setCoronalPlane(location.getCoronalPlane().getName());
        }
        if(location.getDetailedAnatomy() != null){
            restLocation.setDetailedAnatomy(location.getDetailedAnatomy().getName());
        }
        restLocation.setFmaid(String.valueOf(location.getFmaid()));
        if(location.getGeneralRegion() != null){
            restLocation.setGeneralRegion(location.getGeneralRegion().getName());
        }
        if(location.getInternalAnatomy() != null){
            restLocation.setInternalAnatomy(location.getInternalAnatomy().getName());
        }
        if(location.getRegionTissueType() != null){
            restLocation.setRegionTissueType(location.getRegionTissueType().getName());
        }
        if(location.getSagittalPlane() != null){
            restLocation.setSagittalPlane(location.getSagittalPlane().getName());
        }
        if(location.getSkeletalSystem() != null){
            restLocation.setSkeletalSystem(location.getSkeletalSystem().getName());
        }
        if(location.getTransversePlane() != null){
            restLocation.setTransversePlane(location.getTransversePlane().getName());
        }
        return restLocation;
    }


}
