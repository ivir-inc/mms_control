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

import java.util.HashMap;

public enum GeneralRegion {
    NOT_APPLICABLE("notApplicable", 0L),
    HEAD("head", 1L),
    FACE("face", 2L),
    NECK("neck", 3L),
    THORAX("thorax", 4L),
    ABDOMEN("abdomen", 5L),
    PELVIS("pelvis", 6L),
    GENITALIA_MALE("genitaliaMale", 7L),
    GENITALIA_FEMALE("genitaliaFemale", 8L),
    SHOULDER("shoulder", 9L),
    UPPER_ARM("upperArm", 10L),
    ELBOW("elbow", 11L),
    FOREARM("forearm", 12L),
    WRIST("wrist", 13L),
    HAND("hand", 14L),
    FINGERS("fingers", 15L),
    HIP("hip", 16L),
    THIGH("thigh", 17L),
    KNEE("knee", 18L),
    LOWER_LEG("lowerLeg", 19L),
    ANKLE("ankle", 20L),
    FOOT("foot", 21L),
    TOES("toes", 22L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, GeneralRegion> nameMap = new HashMap<>();

    static{
        for(GeneralRegion value : GeneralRegion.values()){
            nameMap.put(value.getName(),value);
        }
    }

    private GeneralRegion(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static GeneralRegion getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }

}
