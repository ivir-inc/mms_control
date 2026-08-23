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

public enum BlastType {
    NOT_APPLICABLE("notApplicable", 0L),
    UNKNOWN("unknown", 1L),
    IED_MOUNTED("IED_Mounted", 2L),
    IED_DISMOUNTED("IED_Dismounted", 3L),
    GRENADE("grenade", 4L),
    RPG("RPG", 5L),
    INDIRECT("indirect", 6L),
    HIGH_YIELD_EXPLOSIVE("highYieldExplosive", 7L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, BlastType> nameMap = new HashMap<>();

    static {
        for (BlastType value : BlastType.values()) {
            nameMap.put(value.getName(), value);
        }
    }

    BlastType(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static BlastType getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }
}
