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

import java.io.Serializable;

public class MechanismOfInjury implements Comparable<MechanismOfInjury>, Serializable {
    private GunshotCaliber gunshotCaliber;
    private  GunshotAmmunitionType gunshotAmmunitionType;
    private  BladeType blade;
    private  BlastType blast;
    private  VehicleCrash vehicleCrash;
    private  FallType fall;
    private  CbrnType cbrn;
    private  ShrapnelType shrapnel;

    public GunshotCaliber getGunshotCaliber() {
        return gunshotCaliber;
    }

    public MechanismOfInjury setGunshotCaliber(GunshotCaliber gunshotCaliber) {
        this.gunshotCaliber = gunshotCaliber;
        return this;
    }

    public GunshotAmmunitionType getGunshotAmmunitionType() {
        return gunshotAmmunitionType;
    }

    public MechanismOfInjury setGunshotAmmunitionType(GunshotAmmunitionType gunshotAmmunitionType) {
        this.gunshotAmmunitionType = gunshotAmmunitionType;
        return this;
    }

    public BladeType getBlade() {
        return blade;
    }

    public MechanismOfInjury setBlade(BladeType blade) {
        this.blade = blade;
        return this;
    }

    public BlastType getBlast() {
        return blast;
    }

    public MechanismOfInjury setBlast(BlastType blast) {
        this.blast = blast;
        return this;
    }

    public VehicleCrash getVehicleCrash() {
        return vehicleCrash;
    }

    public MechanismOfInjury setVehicleCrash(VehicleCrash vehicleCrash) {
        this.vehicleCrash = vehicleCrash;
        return this;
    }

    public FallType getFall() {
        return fall;
    }

    public MechanismOfInjury setFall(FallType fall) {
        this.fall = fall;
        return this;
    }

    public CbrnType getCbrn() {
        return cbrn;
    }

    public MechanismOfInjury setCbrn(CbrnType cbrn) {
        this.cbrn = cbrn;
        return this;
    }

    public ShrapnelType getShrapnel() {
        return shrapnel;
    }

    public MechanismOfInjury setShrapnel(ShrapnelType shrapnel) {
        this.shrapnel = shrapnel;
        return this;
    }

    @Override
    public String toString() {
        return "MechanismOfInjury{" +
                "gunshotCaliber=" + gunshotCaliber +
                ", gunshotAmmunitionType=" + gunshotAmmunitionType +
                ", blade=" + blade +
                ", blast=" + blast +
                ", vehicleCrash=" + vehicleCrash +
                ", fall=" + fall +
                ", cbrn=" + cbrn +
                ", shrapnel=" + shrapnel +
                '}';
    }

    @Override
    public int compareTo(MechanismOfInjury other) {
        int result;

        if ((result = compareEnums(this.gunshotCaliber, other.getGunshotCaliber())) != 0) return result;
        if ((result = compareEnums(this.gunshotAmmunitionType, other.getGunshotAmmunitionType())) != 0) return result;
        if ((result = compareEnums(this.blade, other.getBlade())) != 0) return result;
        if ((result = compareEnums(this.blast, other.getBlast())) != 0) return result;
        if ((result = compareEnums(this.vehicleCrash, other.getVehicleCrash())) != 0) return result;
        if ((result = compareEnums(this.fall, other.getFall())) != 0) return result;
        if ((result = compareEnums(this.cbrn, other.getCbrn())) != 0) return result;
        return compareEnums(this.shrapnel, other.getShrapnel());
    }

    private <E extends Enum<E>> int compareEnums(E a, E b) {
        if (a == b) return 0;
        if (a == null) return -1;
        if (b == null) return 1;
        return a.compareTo(b);
    }
}
