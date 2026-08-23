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

public class TreatmentCirculatoryTourniquet implements Comparable<TreatmentCirculatoryTourniquet> , Serializable{
    @Serial
    private static final long serialVersionUID = 6264758048414222816L;

    private Boolean extremity = false;
    private String extremityType = "";
    private Boolean junctional = false;
    private String junctionalType = "";
    private Boolean truncal = false;
    private String truncalType = "" ;

    public Boolean getExtremity() {
        return extremity;
    }

    public TreatmentCirculatoryTourniquet setExtremity(Boolean extremity) {
        this.extremity = extremity;
        return this;
    }

    public String getExtremityType() {
        return extremityType;
    }

    public TreatmentCirculatoryTourniquet setExtremityType(String extremityType) {
        this.extremityType = extremityType;
        return this;
    }

    public Boolean getJunctional() {
        return junctional;
    }

    public TreatmentCirculatoryTourniquet setJunctional(Boolean junctional) {
        this.junctional = junctional;
        return this;
    }

    public String getJunctionalType() {
        return junctionalType;
    }

    public TreatmentCirculatoryTourniquet setJunctionalType(String junctionalType) {
        this.junctionalType = junctionalType;
        return this;
    }

    public Boolean getTruncal() {
        return truncal;
    }

    public TreatmentCirculatoryTourniquet setTruncal(Boolean truncal) {
        this.truncal = truncal;
        return this;
    }

    public String getTruncalType() {
        return truncalType;
    }

    public TreatmentCirculatoryTourniquet setTruncalType(String truncalType) {
        this.truncalType = truncalType;
        return this;
    }

    @Override
        public int compareTo(TreatmentCirculatoryTourniquet other) {
            int cmp;
            cmp = Boolean.compare(this.extremity, other.extremity);
            if (cmp != 0) return cmp;
            cmp = this.extremityType.compareTo(other.extremityType);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.junctional, other.junctional);
            if (cmp != 0) return cmp;
            cmp = this.junctionalType.compareTo(other.junctionalType);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.truncal, other.truncal);
            if (cmp != 0) return cmp;
            return this.truncalType.compareTo(other.truncalType);
        }
}
