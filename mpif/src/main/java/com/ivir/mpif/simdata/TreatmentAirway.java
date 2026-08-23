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

public class TreatmentAirway implements Comparable<TreatmentAirway>, Serializable {
    @Serial
    private static final long serialVersionUID = 5597305371465766118L;

    private Boolean intact = false;
    private Boolean nasopharyngealAirway = false;
    private Boolean cricothyroidotomy = false;
    private Boolean endotrachealTube = false;
    private Boolean supraglotticAirway = false;
    private String type = "";

    public Boolean getIntact() {
        return intact;
    }

    public TreatmentAirway setIntact(Boolean intact) {
        this.intact = intact;
        return this;
    }

    public Boolean getNasopharyngealAirway() {
        return nasopharyngealAirway;
    }

    public TreatmentAirway setNasopharyngealAirway(Boolean nasopharyngealAirway) {
        this.nasopharyngealAirway = nasopharyngealAirway;
        return this;
    }

    public Boolean getCricothyroidotomy() {
        return cricothyroidotomy;
    }

    public TreatmentAirway setCricothyroidotomy(Boolean cricothyroidotomy) {
        this.cricothyroidotomy = cricothyroidotomy;
        return this;
    }

    public Boolean getEndotrachealTube() {
        return endotrachealTube;
    }

    public TreatmentAirway setEndotrachealTube(Boolean endotrachealTube) {
        this.endotrachealTube = endotrachealTube;
        return this;
    }

    public Boolean getSupraglotticAirway() {
        return supraglotticAirway;
    }

    public TreatmentAirway setSupraglotticAirway(Boolean supraglotticAirway) {
        this.supraglotticAirway = supraglotticAirway;
        return this;
    }

    public String getType() {
        return type;
    }

    public TreatmentAirway setType(String type) {
        this.type = type;
        return this;
    }

    @Override
    public int compareTo(TreatmentAirway other) {
        int cmp;
        cmp = Boolean.compare(this.intact, other.intact);
        if (cmp != 0) return cmp;
        cmp = this.nasopharyngealAirway.compareTo(other.nasopharyngealAirway);
        if (cmp != 0) return cmp;
        cmp = Boolean.compare(this.cricothyroidotomy, other.cricothyroidotomy);
        if (cmp != 0) return cmp;
        cmp = this.endotrachealTube.compareTo(other.endotrachealTube);
        if (cmp != 0) return cmp;
        cmp = Boolean.compare(this.supraglotticAirway, other.supraglotticAirway);
        if (cmp != 0) return cmp;
        return this.type.compareTo(other.type);
    }

}
