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

public enum BladeType {
    NOT_APPLICABLE("notApplicable", 0L),
    UNKNOWN("unknown", 1L),
    SERRATED_SHORT("serrated_Short", 2L),
    SERRATED_MEDIUM("serrated_Medium", 3L),
    SERRATED_LONG("serrated_Long", 4L),
    SMOOTH_SHORT("smooth_Short", 5L),
    SMOOTH_MEDIUM("smooth_Medium", 6L),
    SMOOTH_LONG("smooth_Long", 7L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, BladeType> nameMap = new HashMap<>();

    static{
        for(BladeType value : BladeType.values()){
            nameMap.put(value.getName(),value);
        }
    }

    BladeType(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public String getName(){
        return this.name;
    }

    public static BladeType getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }
}
