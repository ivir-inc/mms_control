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

public enum LevelOfConsciousness {
    /** <code>normal</code> (with ordinal 0) */
    NORMAL("normal", 0),
    /** <code>confused</code> (with ordinal 1) */
    CONFUSED("confused", 1),
    /** <code>impaired</code> (with ordinal 2) */
    IMPAIRED("impaired", 2),
    /** <code>comotose</code> (with ordinal 3) */
    COMOTOSE("comotose", 3),
    /** <code>convulsing</code> (with ordinal 4) */
    CONVULSING("convulsing", 4),
    /** <code>notBreathing</code> (with ordinal 5) */
    NOT_BREATHING("notBreathing", 5),
    /** <code>nearDeath</code> (with ordinal 6) */
    NEAR_DEATH("nearDeath", 6),
    /** <code>dead</code> (with ordinal 7) */
    DEAD("dead", 7);

    /**
     * The name of the enum.
     */
    public final String name;
    /**
     * The ordinal of the enum.
     */
    public final long ordinal;

    private LevelOfConsciousness(String name, long ordinal) {
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
