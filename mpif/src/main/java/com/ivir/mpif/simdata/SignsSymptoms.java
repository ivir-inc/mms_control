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

public class SignsSymptoms implements Comparable<SignsSymptoms>, Serializable {
    @Serial
    private static final long serialVersionUID = -645548026931249099L;

    private String time = "";
    private String pulse = "";
    private int systolicBloodPressure = 0;
    private int diastolicBloodPressure = 0;
    private int respiratoryRate = 0;
    private int pulseOxO2Saturation = 0;
    private byte alertnessLevel = 0;
    private int painScale = 0;

    public String getTime() {
        return time;
    }

    public SignsSymptoms setTime(String time) {
        this.time = time;
        return this;
    }

    public String getPulse() {
        return pulse;
    }

    public SignsSymptoms setPulse(String pulse) {
        this.pulse = pulse;
        return this;
    }

    public int getSystolicBloodPressure() {
        return systolicBloodPressure;
    }

    public SignsSymptoms setSystolicBloodPressure(int systolicBloodPressure) {
        this.systolicBloodPressure = systolicBloodPressure;
        return this;
    }

    public int getDiastolicBloodPressure() {
        return diastolicBloodPressure;
    }

    public SignsSymptoms setDiastolicBloodPressure(int diastolicBloodPressure) {
        this.diastolicBloodPressure = diastolicBloodPressure;
        return this;
    }

    public int getRespiratoryRate() {
        return respiratoryRate;
    }

    public SignsSymptoms setRespiratoryRate(int respiratoryRate) {
        this.respiratoryRate = respiratoryRate;
        return this;
    }

    public int getPulseOxO2Saturation() {
        return pulseOxO2Saturation;
    }

    public SignsSymptoms setPulseOxO2Saturation(int pulseOxO2Saturation) {
        this.pulseOxO2Saturation = pulseOxO2Saturation;
        return this;
    }

    public byte getAlertnessLevel() {
        return alertnessLevel;
    }

    public SignsSymptoms setAlertnessLevel(byte alertnessLevel) {
        this.alertnessLevel = alertnessLevel;
        return this;
    }

    public int getPainScale() {
        return painScale;
    }

    public SignsSymptoms setPainScale(int painScale) {
        this.painScale = painScale;
        return this;
    }

    @Override
    public int compareTo(SignsSymptoms other) {
        int cmp;
        cmp = this.time.compareTo(other.time);
        if (cmp != 0) return cmp;
        cmp = this.pulse.compareTo(other.pulse);
        if (cmp != 0) return cmp;
        cmp = Integer.compare(this.systolicBloodPressure, other.systolicBloodPressure);
        if (cmp != 0) return cmp;
        cmp = Integer.compare(this.diastolicBloodPressure, other.diastolicBloodPressure);
        if (cmp != 0) return cmp;
        cmp = Integer.compare(this.respiratoryRate, other.respiratoryRate);
        if (cmp != 0) return cmp;
        cmp = Integer.compare(this.pulseOxO2Saturation, other.pulseOxO2Saturation);
        if (cmp != 0) return cmp;
        cmp = Byte.compare(this.alertnessLevel, other.alertnessLevel);
        if (cmp != 0) return cmp;
        return Integer.compare(this.painScale, other.painScale);
    }
}
