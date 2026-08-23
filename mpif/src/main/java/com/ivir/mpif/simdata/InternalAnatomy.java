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

public enum InternalAnatomy {
    NOT_APPLICABLE("notApplicable", 0L),
    BRAIN("brain", 1L),
    EYES("eyes", 2L),
    HEART("heart", 3L),
    LUNG("lung", 4L),
    PLEURAL_CAVITY("pleuralCavity", 5L),
    REPRODUCTIVE_ORGAN_MALE("reproductiveOrganMale", 6L),
    REPRODUCTIVE_ORGAN_FEMALE("reproductiveOrganFemale", 7L),
    STOMACH("stomach", 8L),
    ABDOMINAL_CAVITY("abdominalCavity", 9L),
    SMALL_INTESTINE("smallIntestine", 10L),
    LARGE_INTESTINE("largeIntestine", 11L),
    LIVER("liver", 12L),
    SPLEEN("spleen", 13L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, InternalAnatomy> nameMap = new HashMap<>();

    static{
        for(InternalAnatomy value : InternalAnatomy.values()){
            nameMap.put(value.getName(),value);
        }
    }

    private InternalAnatomy(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static InternalAnatomy getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }

}
