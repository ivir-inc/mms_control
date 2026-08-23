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

package com.ivir.mpif.sceneng.rules.model;

public class ManualControl<T> {
    private T ceiling;
    private T floor;
    private Float rate;
    private T instantaneousValue;

    public static <R> ManualControl<R> gradualUpdate(Float rate, R floor, R ceiling){
        ManualControl<R> newControl = new ManualControl<>();
        newControl.setRate(rate);
        newControl.setFloor(floor);
        newControl.setCeiling(ceiling);
        return newControl;
    }

    public static <R> ManualControl<R> instantaneousUpdate(R newValue){
        ManualControl<R> newControl = new ManualControl<>();
        newControl.setInstantaneousValue(newValue);
        return newControl;
    }

    public T getCeiling() {
        return ceiling;
    }

    public void setCeiling(T ceiling) {
        this.ceiling = ceiling;
    }

    public T getFloor() {
        return floor;
    }

    public void setFloor(T floor) {
        this.floor = floor;
    }

    public Float getRate() {
        return rate;
    }

    public void setRate(Float rate) {
        this.rate = rate;
    }

    public T getInstantaneousValue() {
        return instantaneousValue;
    }

    public void setInstantaneousValue(T instantaneousValue) {
        this.instantaneousValue = instantaneousValue;
    }

    public boolean isValid(){
        if(this.instantaneousValue != null){
            return rate == null;
        }
        return rate != null;
    }

    public boolean isInstantaneousChange(){
        return this.instantaneousValue != null;
    }
}
