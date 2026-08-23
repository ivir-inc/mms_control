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

public enum InjuryDescription {
    NOT_APPLICABLE("notApplicable", 0L),
    AMPUTATION("amputation", 1L),
    LACERATION("laceration", 2L),
    PUNCTURE("puncture", 3L),
    PENETRATING("penetrating", 4L),
    BLUNT("blunt", 5L),
    SPRAIN("sprain", 6L),
    CRUSH("crush", 7L),
    DISLOCATION("dislocation", 8L),
    EXPOSURE("exposure", 9L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, InjuryDescription> nameMap = new HashMap<>();

    static{
        for(InjuryDescription value : InjuryDescription.values()){
            nameMap.put(value.getName(),value);
        }
    }

    private InjuryDescription(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static InjuryDescription getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }

}
