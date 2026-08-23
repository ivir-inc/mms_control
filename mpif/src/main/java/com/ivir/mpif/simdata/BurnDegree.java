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

public enum BurnDegree {
    /** <code>notApplicable</code> (with ordinal 0) */
    NOT_APPLICABLE("notApplicable", 0),
    /** <code>firstDegree</code> (with ordinal 1) */
    FIRST_DEGREE("firstDegree", 1),
    /** <code>secondDegree</code> (with ordinal 2) */
    SECOND_DEGREE("secondDegree", 2),
    /** <code>thirdDegree</code> (with ordinal 3) */
    THIRD_DEGREE("thirdDegree", 3);

    /**
     * The name of the enum.
     */
    public final String name;
    /**
     * The ordinal of the enum.
     */
    public final long ordinal;

    private BurnDegree(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return ordinal;
    }

    public String getName() {
        return name;
    }

    /**
     * Find the enum with the specified ordinal.
     *
     * @param ordinal ordinal of the enum to find
     *
     * @return the enum with the specified <code>ordinal</code>, or <code>null</code> if not found
     */
    public static BurnDegree find(long ordinal) {
        for (BurnDegree value : values()) {
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
    public static BurnDegree find(String name) {
        for (BurnDegree value : values()) {
            if (value.getName().equals(name)) {
                return value;
            }
        }
        return null;
    }
}
