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

public enum GunshotCaliber {
    NOT_APPLICABLE("notApplicable", 0L),
    UNKNOWN("unknown", 1L),
    CALIBER22LR("caliber22lr", 2L),
    CALIBER9MM("caliber9mm", 3L),
    CALIBER10MM("caliber10mm", 4L),
    CALIBER50BMG("caliber50bmg", 5L),
    CALIBER556X45("caliber556x45", 6L),
    CALIBER762X51("caliber762x51", 7L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, GunshotCaliber> nameMap = new HashMap<>();

    static{
        for(GunshotCaliber value : GunshotCaliber.values()){
            nameMap.put(value.getName(),value);
        }
    }

    GunshotCaliber(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public String getName(){
        return name;
    }

    public static GunshotCaliber getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }

}
