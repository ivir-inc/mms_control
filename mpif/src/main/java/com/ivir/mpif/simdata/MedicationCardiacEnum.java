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

public enum MedicationCardiacEnum {
    /** <code>positiveInotropic</code> (with ordinal 0) */
    POSITIVE_INOTROPIC("positiveInotropic", 0),
    /** <code>negativeInotropic</code> (with ordinal 1) */
    NEGATIVE_INOTROPIC("negativeInotropic", 1),
    /** <code>chronotropic</code> (with ordinal 2) */
    CHRONOTROPIC("chronotropic", 2),
    /** <code>dromotropic</code> (with ordinal 3) */
    DROMOTROPIC("dromotropic", 3),
    /** <code>bathmotropic</code> (with ordinal 4) */
    BATHMOTROPIC("bathmotropic", 4);

    /**
     * The name of the enum.
     */
    public final String name;
    /**
     * The ordinal of the enum.
     */
    public final long ordinal;

    private MedicationCardiacEnum(String name, long ordinal) {
        this.name = name;
        this.ordinal = ordinal;
    }

    public long getOrdinal() {
        return ordinal;
    }

    public String getName() {
        return name;
    }
}
