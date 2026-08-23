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

public enum SkeletalSystem {
    NOT_APPLICABLE("notApplicable", 0L),
    SKULL("skull", 1L),
    SPINE("spine", 2L),
    STERNUM("sternum", 3L),
    RIBS("ribs", 4L),
    CLAVICLE("clavicle", 5L),
    SCAPULA("scapula", 6L),
    HUMERUS("humerus", 7L),
    RADIUS("radius", 8L),
    ULNA("ulna", 9L),
    CARPALS("carpals", 10L),
    METACARPALS("metacarpals", 11L),
    PHALANGES_HAND("phalangesHand", 12L),
    PELVIS("pelvis", 13L),
    ILIUM("ilium", 14L),
    FEMUR("femur", 15L),
    PATELLA("patella", 16L),
    TIBIA("tibia", 17L),
    FIBULA("fibula", 18L),
    TARSALS("tarsals", 19L),
    METATARSALS("metatarsals", 20L),
    PHALANGES_FOOT("phalangesFoot", 21L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, SkeletalSystem> nameMap = new HashMap<>();

    static{
        for(SkeletalSystem value : SkeletalSystem.values()){
            nameMap.put(value.getName(),value);
        }
    }

    private SkeletalSystem(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static SkeletalSystem getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }
}
