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

public class TreatmentCirculatoryDressing implements Comparable<TreatmentCirculatoryDressing>, Serializable {
    @Serial
    private static final long serialVersionUID = 3009830877281721091L;

    private Boolean hemostatic = false;
    private Boolean pressure = false;
    private Boolean other = false;
    private String otherType = "";

    public Boolean getHemostatic() {
        return hemostatic;
    }

    public TreatmentCirculatoryDressing setHemostatic(Boolean hemostatic) {
        this.hemostatic = hemostatic;
        return this;
    }

    public Boolean getPressure() {
        return pressure;
    }

    public TreatmentCirculatoryDressing setPressure(Boolean pressure) {
        this.pressure = pressure;
        return this;
    }

    public Boolean getOther() {
        return other;
    }

    public TreatmentCirculatoryDressing setOther(Boolean other) {
        this.other = other;
        return this;
    }

    public String getOtherType() {
        return otherType;
    }

    public TreatmentCirculatoryDressing setOtherType(String otherType) {
        this.otherType = otherType;
        return this;
    }

    @Override
        public int compareTo(TreatmentCirculatoryDressing o) {
            int cmp;
            cmp = Boolean.compare(this.hemostatic, o.hemostatic);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.pressure, o.pressure);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.other, o.other);
            if (cmp != 0) return cmp;
            cmp = this.otherType.compareTo(o.otherType);
            return cmp;
        }
}
