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
public class LungSoundValueMapper implements ParamValueMapper{

    public static enum LungSound {
        NO_SOUND(0, "No Sound"),
        HEALTHY(1, "Healthy"),
        WHEEZE(2, "Wheeze"),
        RHONCHI(3, "Rhonchi"),
        PLEURAL_RUB(4, "Pleural Rub"),
        CRACKLES(5, "Crackles");

        public final float value;
        public final String description;

        private LungSound(float value, String description) {
            this.value = value;
            this.description = description;
        }
    }
    
    private String name = null;
    
    public LungSoundValueMapper(String paramName){
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
        for(LungSound sound : LungSound.values()){
            if(sound.value == value){
                return sound.description;
            }
        }
        return null;
    }
    
}
