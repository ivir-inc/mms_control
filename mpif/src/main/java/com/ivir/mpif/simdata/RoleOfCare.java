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

public enum RoleOfCare {
    ROLE1("role1", 0L),
    ROLE2("role2", 1L),
    ROLE3("role3", 2L),
    ROLE4("role4", 3L),
    EN_ROUTE("enRoute", 4L);

    public final String name;
    public final long ordinal;

    private RoleOfCare(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static RoleOfCare find(long ordinal) {
        RoleOfCare[] var2 = values();
        int var3 = var2.length;

        for(int var4 = 0; var4 < var3; ++var4) {
            RoleOfCare value = var2[var4];
            if (value.getOrdinal() == ordinal) {
                return value;
            }
        }

        return null;
    }

    public static RoleOfCare find(String name) {
        RoleOfCare[] var1 = values();
        int var2 = var1.length;

        for(int var3 = 0; var3 < var2; ++var3) {
            RoleOfCare value = var1[var3];
            if (value.getName().equals(name)) {
                return value;
            }
        }

        return null;
    }
}
