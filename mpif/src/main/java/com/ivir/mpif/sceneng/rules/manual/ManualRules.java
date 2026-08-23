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

import org.jeasy.rules.api.Rules;

public class ManualRules {
    public static Rules createRules(){
        Rules rules = new Rules();
        rules.register(new ManualDiastolicPressureRule());
        rules.register(new ManualEtCO2Rule());
        rules.register(new ManualHeartRateRule());
        rules.register(new ManualO2SaturationRule());
        rules.register(new ManualRespiratoryRateRule());
        rules.register(new ManualSystolicPressureRule());
        rules.register(new ManualTemperatureRule());
        return rules;
    }
}
