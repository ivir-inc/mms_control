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

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.ivir.mpif.event.oeilog;

/**
 *
 * @author lewanw
 */
public class EyeStatusValueMapper implements ParamValueMapper {

    public static enum EyeStatus {
        AUTO(0, "Auto"),
        OPEN(1, "Open"),
        CLOSED(2, "Closed");

        public final float value;
        public final String description;

        private EyeStatus(float value, String description) {
            this.value = value;
            this.description = description;
        }
    }

    private String name = null;

    public EyeStatusValueMapper(String paramName) {
        this.name = paramName;
    }

    @Override
    public String getParamName() {
        return this.name;
    }

    @Override
    public float oeiStringValueToFloat(String oeiValueStr) {
        return Float.parseFloat(oeiValueStr);
    }

    @Override
    public String floatToTextDescription(float value) {
        for (EyeStatus eyeStatus : EyeStatus.values()) {
            if (value == eyeStatus.value) {
                return eyeStatus.description;
            }
        }
        return null;
    }
}
