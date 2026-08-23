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

package com.ivir.mpif.sceneng.rules;

import org.jeasy.rules.api.Facts;

public enum ReservedFacts {
    CLOCK_CHANGE_LONG("clock_change_long"),
    DIASTOLIC_PRESSURE_INT("diastolic_pressure_int"),
    ETCO2_FLT("etco2_flt"),
    HEART_RATE_INT("heart_rate_int"),
    O2_SATURATION_FLT("os_saturation_flt"),
    RESPIRATORY_RATE_FLT("respiratory_rate_flt"),
    SYSTOLIC_PRESSURE_INT("systolic_pressure_int"),
    TEMPERATURE_FLT("temperature_flt");

    private String factId;
    private ReservedFacts(String factId){
        this.factId = factId;
    }
    public String getFactId(){
        return this.factId;
    }

    public <T> T getFact(Facts facts){
        return facts.get(factId);
    }

    public <T> void setFact(Facts facts, T value){
        facts.put(factId, value);
    }
}
