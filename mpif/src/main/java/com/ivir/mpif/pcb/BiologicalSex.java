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

package com.ivir.mpif.pcb;

import java.util.HashMap;
import java.util.Map;

public enum BiologicalSex {
    FEMALE("female", "Female"),
    MALE("male", "Male");

    private final String name;
    private final String displayName;

    private static final Map<String, BiologicalSex> nameMap = new HashMap<>();

    static {
        for (BiologicalSex value : BiologicalSex.values()) {
            nameMap.put(value.getName(), value);
        }
    }

    BiologicalSex(String name, String displayName) {
        this.name = name;
        this.displayName = displayName;
    }

    public String getName() {
        return name;
    }

    public String getDisplayName() {
        return displayName;
    }

    public static BiologicalSex getByName(String name) {
        if (name == null) {
            return null;
        }
        return nameMap.get(name);
    }
}
