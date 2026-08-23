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

package com.ivir.mpif.mconfig;

public enum MpifConfigKey {
    FACILITY_ID("facility_id"),
    FEDERATE("federate"),
    FEDERATION("federation"),
    OWNS_FEDERATION_STATE("owns_federation_state"),
    OWNS_FEDERATION_TIME("owns_federation_time"),
    PATIENTS_SHOW_EXTERNAL("patients_show_external"),
    SCENARIO_FOLDER("scenario_folder"),
    SCENARIO_ENGINE_CLOCK_MODE("scenario_engine_clock_mode"),
    ENDPOINT_MASK("endpoint_mask");

    private String keyStr;

    private MpifConfigKey(String key){
        this.keyStr = key;
    }

    public String getKeyStr(){
        return this.keyStr;
    }
}
