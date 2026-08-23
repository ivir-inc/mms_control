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

public enum RegionTissueType {
    NOT_APPLICABLE("notApplicable", 0L),
    SKIN("skin", 1L),
    MUSCULATURE("musculature", 2L),
    SKELETAL_STRUCTURE("skeletalStructure", 3L),
    NEURAL_NETWORK("neuralNetwork", 4L),
    VASCULATURE("vasculature", 5L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, RegionTissueType> nameMap = new HashMap<>();

    static{
        for(RegionTissueType value : RegionTissueType.values()){
            nameMap.put(value.getName(),value);
        }
    }

    private RegionTissueType(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static RegionTissueType getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }
}
