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

public enum DetailedAnatomy {
    NOT_APPLICABLE("notApplicable", 0L),
    INFRAMAMMARY_PART_OF_CHEST("inframammaryPartOfChest", 1L),
    SPACE_OF_FIRST_INTERCOSTAL_COMPARTMENT("spaceOfFirstIntercostalCompartment", 2L),
    SPACE_OF_SECOND_INTERCOSTAL_COMPARTMENT("spaceOfSecondIntercostalCompartment", 3L),
    SPACE_OF_THIRD_INTERCOSTAL_COMPARTMENT("spaceOfThirdIntercostalCompartment", 4L),
    SPACE_OF_FOURTH_INTERCOSTAL_COMPARTMENT("spaceOfFourthIntercostalCompartment", 5L),
    SPACE_OF_FIFTH_INTERCOSTAL_COMPARTMENT("spaceOfFifthIntercostalCompartment", 6L),
    SPACE_OF_SIXTH_INTERCOSTAL_COMPARTMENT("spaceOfSixthIntercostalCompartment", 7L),
    SPACE_OF_SEVENTH_INTERCOSTAL_COMPARTMENT("spaceOfSeventhIntercostalCompartment", 8L),
    SPACE_OF_EIGHTH_INTERCOSTAL_COMPARTMENT("spaceOfEighthIntercostalCompartment", 9L),
    SPACE_OF_NINTH_INTERCOSTAL_COMPARTMENT("spaceOfNinthIntercostalCompartment", 10L),
    SPACE_OF_TENTH_INTERCOSTAL_COMPARTMENT("spaceOfTenthIntercostalCompartment", 11L),
    SPACE_OF_ELEVENTH_INTERCOSTAL_COMPARTMENT("spaceOfEleventhIntercostalCompartment", 12L);

    public final String name;
    public final long ordinal;

    private static HashMap<String, DetailedAnatomy> nameMap = new HashMap<>();

    static {
        for (DetailedAnatomy value : DetailedAnatomy.values()) {
            nameMap.put(value.getName(), value);
        }
    }

    private DetailedAnatomy(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return this.ordinal;
    }

    public String getName() {
        return this.name;
    }

    public static DetailedAnatomy getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }
}
