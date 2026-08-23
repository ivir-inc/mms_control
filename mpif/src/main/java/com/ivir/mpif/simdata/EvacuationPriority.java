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

public enum EvacuationPriority {
    URGENT("urgent", 0L),
    URGENT_SURGICAL("urgentSurgical", 1L),
    PRIORITY("priority", 2L),
    ROUTINE("routine", 3L),
    CONVENIENCE("convenience", 4L),
    NOT_APPLICABLE("notApplicable", 5L);

    public final String name;
    public final long ordinal;

    private EvacuationPriority(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static EvacuationPriority find(long ordinal) {
        EvacuationPriority[] var2 = values();
        int var3 = var2.length;

        for(int var4 = 0; var4 < var3; ++var4) {
            EvacuationPriority value = var2[var4];
            if (value.getOrdinal() == ordinal) {
                return value;
            }
        }

        return null;
    }

    public static EvacuationPriority find(String name) {
        EvacuationPriority[] var1 = values();
        int var2 = var1.length;

        for(int var3 = 0; var3 < var2; ++var3) {
            EvacuationPriority value = var1[var3];
            if (value.getName().equals(name)) {
                return value;
            }
        }

        return null;
    }
}
