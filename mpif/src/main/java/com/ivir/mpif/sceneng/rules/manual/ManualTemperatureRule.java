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

package com.ivir.mpif.sceneng.rules.manual;

import com.ivir.mpif.sceneng.rules.ReservedFacts;

import static com.ivir.mpif.sceneng.rules.ReservedFacts.TEMPERATURE_FLT;

public class ManualTemperatureRule extends ManualRule<Float>{

    @Override
    public String getName() {
        return "manually update temperature";
    }

    @Override
    public String getDescription() {
        return "manually update temperature";
    }

    @Override
    protected String getControlFactKey() {
        return "temperature_control";
    }

    @Override
    protected ReservedFacts getVitalsReservedFact() {
        return TEMPERATURE_FLT;
    }

    @Override
    protected Float addIncrement(Float currentValue, float increment) {
        return currentValue + increment;
    }


}
