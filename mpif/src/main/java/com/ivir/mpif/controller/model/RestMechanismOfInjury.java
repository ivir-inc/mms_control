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

package com.ivir.mpif.controller.model;


public class RestMechanismOfInjury {
    private String gunshotCaliber;
    private String gunshotAmmunitionType;
    private String blade;
    private String blast;
    private String vehicleCrash;
    private String fall;
    private String cbrn;
    private String shrapnel;

    public String getGunshotCaliber() {
        return gunshotCaliber;
    }

    public RestMechanismOfInjury setGunshotCaliber(String gunshotCaliber) {
        this.gunshotCaliber = gunshotCaliber;
        return this;
    }

    public String getGunshotAmmunitionType() {
        return gunshotAmmunitionType;
    }

    public RestMechanismOfInjury setGunshotAmmunitionType(String gunshotAmmunitionType) {
        this.gunshotAmmunitionType = gunshotAmmunitionType;
        return this;
    }

    public String getBlade() {
        return blade;
    }

    public RestMechanismOfInjury setBlade(String blade) {
        this.blade = blade;
        return this;
    }

    public String getBlast() {
        return blast;
    }

    public RestMechanismOfInjury setBlast(String blast) {
        this.blast = blast;
        return this;
    }

    public String getVehicleCrash() {
        return vehicleCrash;
    }

    public RestMechanismOfInjury setVehicleCrash(String vehicleCrash) {
        this.vehicleCrash = vehicleCrash;
        return this;
    }

    public String getFall() {
        return fall;
    }

    public RestMechanismOfInjury setFall(String fall) {
        this.fall = fall;
        return this;
    }

    public String getCbrn() {
        return cbrn;
    }

    public RestMechanismOfInjury setCbrn(String cbrn) {
        this.cbrn = cbrn;
        return this;
    }

    public String getShrapnel() {
        return shrapnel;
    }

    public RestMechanismOfInjury setShrapnel(String shrapnel) {
        this.shrapnel = shrapnel;
        return this;
    }
}
