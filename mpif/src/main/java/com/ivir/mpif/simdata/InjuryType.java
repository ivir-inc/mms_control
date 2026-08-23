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

public enum InjuryType {
    NOT_APPLICABLE("notApplicable", 0L, "Not Applicable"),
    HEMORRHAGE("hemorrhage", 1L, "Hemorrhage"),
    AIRWAY_OBSTRUCTION("airwayObstruction", 2L, "Airway Obstruction"),
    FRACTURE("fracture", 3L, "Fracture"),
    TRAUMATIC_BRAIN_INJURY("traumaticBrainInjury", 4L, "TBI"),
    PNEUMOTHORAX("pneumothorax", 5L, "Pneumothorax"),
    TENSION_PNEUMOTHORAX("tensionPneumothorax", 6L, "Tension Pneumothorax"),
    HEMOTHORAX("hemothorax", 7L, "Hemothorax"),
    BURN("burn", 8L, "Burn"),
    COMPARTMENTAL_PRESSURE("compartmentalPressure", 9L, "Compartmental Pressure");
    /**
     * The name of the enum.
     */
    public final String name;
    /**
     * The ordinal of the enum.
     */
    public final long ordinal;
    private final String displayName;

    private static HashMap<String, InjuryType> nameMap = new HashMap<>();

    static{
        for(InjuryType value : InjuryType.values()){
            nameMap.put(value.getName(),value);
        }
    }

    private InjuryType(String name, long ordinal, String displayName) {
        this.name = name;
        this.ordinal = ordinal;
        this.displayName = displayName;
    }

    public long getOrdinal() {
        return ordinal;
    }

    public String getName() {
        return name;
    }

    public String getDisplayName(){
        return this.displayName;
    }

    /**
     * Find the enum with the specified ordinal.
     *
     * @param ordinal ordinal of the enum to find
     *
     * @return the enum with the specified <code>ordinal</code>, or <code>null</code> if not found
     */
    public static InjuryType find(long ordinal) {
        for (InjuryType value : values()) {
            if (value.getOrdinal() == ordinal) {
                return value;
            }
        }
        return null;
    }

    /**
     * Find the enum with the specified name.
     *
     * @param name name of the enum to find
     *
     * @return the enum with the specified <code>name</code>, or <code>null</code> if not found
     */
    public static InjuryType find(String name) {
        for (InjuryType value : values()) {
            if (value.getName().equals(name)) {
                return value;
            }
        }
        return null;
    }

    public static InjuryType getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }
}
