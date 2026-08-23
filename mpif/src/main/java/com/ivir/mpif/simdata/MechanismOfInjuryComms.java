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

import org.springframework.stereotype.Component;

import java.io.Serial;
import java.io.Serializable;
import java.util.Objects;

public class MechanismOfInjuryComms implements Comparable<MechanismOfInjuryComms>, Serializable {
   @Serial
    private static final long serialVersionUID = -9101126397820146239L;

    private Boolean artillery = false;
    private Boolean blunt = false;
    private Boolean burn = false;
    private Boolean fall = false;
    private Boolean grenade = false;
    private Boolean gunShotWound = false;
    private Boolean improvisedExplosiveDevice = false;
    private Boolean landMine = false;
    private Boolean motorVehicleCollision = false;
    private Boolean rocketPropelledGrenade = false;
    private Boolean other = false;
    private String otherCause = "";

    public Boolean getArtillery() {
        return artillery;
    }

    public MechanismOfInjuryComms setArtillery(Boolean artillery) {
        this.artillery = artillery;
        return this;
    }

    public Boolean getBlunt() {
        return blunt;
    }

    public MechanismOfInjuryComms setBlunt(Boolean blunt) {
        this.blunt = blunt;
        return this;
    }

    public Boolean getBurn() {
        return burn;
    }

    public MechanismOfInjuryComms setBurn(Boolean burn) {
        this.burn = burn;
        return this;
    }

    public Boolean getFall() {
        return fall;
    }

    public MechanismOfInjuryComms setFall(Boolean fall) {
        this.fall = fall;
        return this;
    }

    public Boolean getGrenade() {
        return grenade;
    }

    public MechanismOfInjuryComms setGrenade(Boolean grenade) {
        this.grenade = grenade;
        return this;
    }

    public Boolean getGunShotWound() {
        return gunShotWound;
    }

    public MechanismOfInjuryComms setGunShotWound(Boolean gunShotWound) {
        this.gunShotWound = gunShotWound;
        return this;
    }

    public Boolean getImprovisedExplosiveDevice() {
        return improvisedExplosiveDevice;
    }

    public MechanismOfInjuryComms setImprovisedExplosiveDevice(Boolean improvisedExplosiveDevice) {
        this.improvisedExplosiveDevice = improvisedExplosiveDevice;
        return this;
    }

    public Boolean getLandMine() {
        return landMine;
    }

    public MechanismOfInjuryComms setLandMine(Boolean landMine) {
        this.landMine = landMine;
        return this;
    }

    public Boolean getMotorVehicleCollision() {
        return motorVehicleCollision;
    }

    public MechanismOfInjuryComms setMotorVehicleCollision(Boolean motorVehicleCollision) {
        this.motorVehicleCollision = motorVehicleCollision;
        return this;
    }

    public Boolean getRocketPropelledGrenade() {
        return rocketPropelledGrenade;
    }

    public MechanismOfInjuryComms setRocketPropelledGrenade(Boolean rocketPropelledGrenade) {
        this.rocketPropelledGrenade = rocketPropelledGrenade;
        return this;
    }

    public Boolean getOther() {
        return other;
    }

    public MechanismOfInjuryComms setOther(Boolean other) {
        this.other = other;
        return this;
    }

    public String getOtherCause() {
        return otherCause;
    }

    public MechanismOfInjuryComms setOtherCause(String otherCause) {
        this.otherCause = otherCause;
        return this;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof MechanismOfInjuryComms that)) return false;
        return Objects.equals(artillery, that.artillery) && Objects.equals(blunt, that.blunt) && Objects.equals(burn, that.burn) && Objects.equals(fall, that.fall) && Objects.equals(grenade, that.grenade) && Objects.equals(gunShotWound, that.gunShotWound) && Objects.equals(improvisedExplosiveDevice, that.improvisedExplosiveDevice) && Objects.equals(landMine, that.landMine) && Objects.equals(motorVehicleCollision, that.motorVehicleCollision) && Objects.equals(rocketPropelledGrenade, that.rocketPropelledGrenade) && Objects.equals(other, that.other) && Objects.equals(otherCause, that.otherCause);
    }

    @Override
    public int hashCode() {
        return Objects.hash(artillery, blunt, burn, fall, grenade, gunShotWound, improvisedExplosiveDevice, landMine, motorVehicleCollision, rocketPropelledGrenade, other, otherCause);
    }

    @Override
        public int compareTo(MechanismOfInjuryComms o) {
            int cmp;
            cmp = Boolean.compare(this.artillery, o.artillery);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.blunt, o.blunt);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.burn, o.burn);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.fall, o.fall);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.grenade, o.grenade);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.gunShotWound, o.gunShotWound);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.improvisedExplosiveDevice, o.improvisedExplosiveDevice);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.landMine, o.landMine);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.motorVehicleCollision, o.motorVehicleCollision);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.rocketPropelledGrenade, o.rocketPropelledGrenade);
            if (cmp != 0) return cmp;
            cmp = Boolean.compare(this.other, o.other);
            if (cmp != 0) return cmp;
            return this.otherCause.compareTo(o.otherCause);
        }
}
