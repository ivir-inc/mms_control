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

import devstudio.generatedcode.datatypes.FacilityTypeEnum;

public enum FacilityType {
    FIXED("fixed", 0L),
    GROUND("ground", 1L),
    AIR("air", 2L);

    public final String name;
    public final long ordinal;

    private FacilityType(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static FacilityType find(long ordinal) {
        FacilityType[] var2 = values();
        int var3 = var2.length;

        for(int var4 = 0; var4 < var3; ++var4) {
            FacilityType value = var2[var4];
            if (value.getOrdinal() == ordinal) {
                return value;
            }
        }

        return null;
    }

    public static FacilityType find(String name) {
        FacilityType[] var1 = values();
        int var2 = var1.length;

        for(int var3 = 0; var3 < var2; ++var3) {
            FacilityType value = var1[var3];
            if (value.getName().equals(name)) {
                return value;
            }
        }

        return null;
    }
}
