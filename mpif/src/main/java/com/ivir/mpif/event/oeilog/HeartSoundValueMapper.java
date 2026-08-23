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
public class HeartSoundValueMapper implements ParamValueMapper{
    public enum HeartSound {
        NO_SOUND(0, "No Sound"),
        HEALTHY(1, "Healthy"),
        S3(2, "S3"),
        S4(3, "S4 "),
        S3_S4(4, "S3 & S4"),
        SYSTOLIC_EARLY(5, "Systolic Early"),
        SYSTOLIC_MID(6, "Systolic Mid"),
        SYSTOLIC_LATE(7, "Systolic Late"),
        SYSTOLIC_PAN(8, "Systolic Pan"),
        DIASTOLIC_LATE(9, "Diastolic Late");

        public final float value;
        public final String description;

        private HeartSound(float value, String description) {
            this.value = value;
            this.description = description;
        }
    }

    @Override
    public String getParamName() {
        return "Heart sound";
    }
   
    @Override
    public float oeiStringValueToFloat(String oeiValueStr) {
       return Float.parseFloat(oeiValueStr);
    }

    @Override
    public String floatToTextDescription(float value) {
        for(HeartSound sound : HeartSound.values()){
            if(sound.value == value){
                return sound.description;
            }
        }
        return null;
    }

    
    
}
