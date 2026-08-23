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

import java.io.Serial;
import java.io.Serializable;

public class InjuryLocation implements Comparable<InjuryLocation>, Serializable {
    @Serial
    private static final long serialVersionUID = -4504450291182923249L;

    public String injuryType = "";
    public ComparableList<BodyLocationCoarse> injuryLocation = new ComparableList<>();

    public String getInjuryType() {
        return injuryType;
    }

    public InjuryLocation setInjuryType(String injuryType) {
        this.injuryType = injuryType;
        return this;
    }

    public ComparableList<BodyLocationCoarse> getInjuryLocation() {
        return injuryLocation;
    }

    public InjuryLocation setInjuryLocation(ComparableList<BodyLocationCoarse> injuryLocation) {
        this.injuryLocation = injuryLocation;
        return this;
    }

    @Override
        public int compareTo(InjuryLocation other) {
            if (other == null) return 1;
            int typeCompare = this.injuryType.compareTo(other.injuryType);
            if (typeCompare != 0) return typeCompare;
            int comp = this.injuryLocation.compareTo(other.injuryLocation);
            return comp;
        }
}
