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

public enum LevelOfResponse {
    /** <code>alert</code> (with ordinal 0) */
    ALERT("alert", 0),
    /** <code>verbal</code> (with ordinal 1) */
    VERBAL("verbal", 1),
    /** <code>pain</code> (with ordinal 2) */
    PAIN("pain", 2),
    /** <code>unresponsive</code> (with ordinal 3) */
    UNRESPONSIVE("unresponsive", 3);

    /**
     * The name of the enum.
     */
    public final String name;
    /**
     * The ordinal of the enum.
     */
    public final long ordinal;

    private LevelOfResponse(String name, long ordinal) {
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
