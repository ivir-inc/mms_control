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

public class TreatmentOther implements Comparable<TreatmentOther>, Serializable {
    @Serial
    private static final long serialVersionUID = -6277461512758442635L;

    private Boolean combatPill = false;
    private Boolean hypothermiaBlanket = false;
    private Boolean eyeShieldRight = false;
    private Boolean eyeShieldLeft = false;
    private Boolean splint = false;
    private String type = "";

    public Boolean getCombatPill() {
        return combatPill;
    }

    public TreatmentOther setCombatPill(Boolean combatPill) {
        this.combatPill = combatPill;
        return this;
    }

    public Boolean getHypothermiaBlanket() {
        return hypothermiaBlanket;
    }

    public TreatmentOther setHypothermiaBlanket(Boolean hypothermiaBlanket) {
        this.hypothermiaBlanket = hypothermiaBlanket;
        return this;
    }

    public Boolean getEyeShieldRight() {
        return eyeShieldRight;
    }

    public TreatmentOther setEyeShieldRight(Boolean eyeShieldRight) {
        this.eyeShieldRight = eyeShieldRight;
        return this;
    }

    public Boolean getEyeShieldLeft() {
        return eyeShieldLeft;
    }

    public TreatmentOther setEyeShieldLeft(Boolean eyeShieldLeft) {
        this.eyeShieldLeft = eyeShieldLeft;
        return this;
    }

    public Boolean getSplint() {
        return splint;
    }

    public TreatmentOther setSplint(Boolean splint) {
        this.splint = splint;
        return this;
    }

    public String getType() {
        return type;
    }

    public TreatmentOther setType(String type) {
        this.type = type;
        return this;
    }

    @Override
        public int compareTo(TreatmentOther o) {
            int result = Boolean.compare(this.combatPill, o.combatPill);
            if (result != 0) return result;
            result = Boolean.compare(this.hypothermiaBlanket, o.hypothermiaBlanket);
            if (result != 0) return result;
            result = Boolean.compare(this.eyeShieldRight, o.eyeShieldRight);
            if (result != 0) return result;
            result = Boolean.compare(this.eyeShieldLeft, o.eyeShieldLeft);
            if (result != 0) return result;
            result = Boolean.compare(this.splint, o.splint);
            if (result != 0) return result;
            return this.type.compareTo(o.type);
        }
}
