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

public class TreatmentBreathing implements Comparable<TreatmentBreathing>, Serializable {
    @Serial
    private static final long serialVersionUID = -1232758762814964951L;

    private Boolean oxygenAdministered = false;
    private Boolean needleDecompression = false;
    private Boolean chestTube = false;
    private Boolean chestSeal = false;
    private String type = "";

    public Boolean getOxygenAdministered() {
        return oxygenAdministered;
    }

    public TreatmentBreathing setOxygenAdministered(Boolean oxygenAdministered) {
        this.oxygenAdministered = oxygenAdministered;
        return this;
    }

    public Boolean getNeedleDecompression() {
        return needleDecompression;
    }

    public TreatmentBreathing setNeedleDecompression(Boolean needleDecompression) {
        this.needleDecompression = needleDecompression;
        return this;
    }

    public Boolean getChestTube() {
        return chestTube;
    }

    public TreatmentBreathing setChestTube(Boolean chestTube) {
        this.chestTube = chestTube;
        return this;
    }

    public Boolean getChestSeal() {
        return chestSeal;
    }

    public TreatmentBreathing setChestSeal(Boolean chestSeal) {
        this.chestSeal = chestSeal;
        return this;
    }

    public String getType() {
        return type;
    }

    public TreatmentBreathing setType(String type) {
        this.type = type;
        return this;
    }

    @Override
    public int compareTo(TreatmentBreathing other) {
            int cmp;
            cmp = Boolean.compare(this.oxygenAdministered, other.oxygenAdministered);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.needleDecompression, other.needleDecompression);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.chestTube, other.chestTube);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.chestSeal, other.chestSeal);
            if (cmp != 0) return cmp;
            return this.type.compareTo(other.type);
        }

}
