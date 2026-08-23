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
public class CardioRhythmValueMapper implements ParamValueMapper {
    
    public static enum CardioRhythm {
        SINUS_BRADYCARDIA("Sinus Bradycardia", "Sinus Bradycardia", 0),
        SINUS_TACHYCARDIA("Sinus Tachycardia", "Sinus Tachycardia", 1),
        FIRST_DEGREE_AV_BLOCK("1st Degree AV Block", "1st Degree AV Block", 2),
        JUNCTIONAL_RHYTHM("Junctional Rhythm", "Junctional Rhythm", 3),
        ACCEL_JUNCTIONAL_RHYTHM("Accel. Junctional Rhythm", "Accel. Junctional Rhythm", 4),
        IDIOVENTRICULAR_RHYTHM("Idioventricular Rhythm", "Idioventricular Rhythm", 5),
        ACCEL_IDIOVENT_RHYTHM("Accel. Idiovent. Rhythm", "Accel. Idiovent. Rhythm", 6),
        SUPRAVENTRICULAR_TACHYCARDIA("Supraventricular Tachycardia", "Supraventricular Tachycardia", 7),
        MONOMORPHIC_VT("Monomorphic VT", "Monomorphic VT", 8),
        SINUS_RHYTHM("Sinus Rhythm", "Sinus Rhythm", 9);

        public final String stringValue;
        public final float floatValue;
        public final String description;

        private CardioRhythm(String sValue, String description, float fValue) {
            this.stringValue = sValue;
            this.description = description;
            this.floatValue = fValue;
        }
    }

    @Override
    public String getParamName() {
        return "Cardio rhythm";
    }

    @Override
    public float oeiStringValueToFloat(String oeiValueStr) {
        return getEnumByString(oeiValueStr).floatValue;
    }

    @Override
    public String floatToTextDescription(float value) {
        return getEnumByFloat(value).stringValue;
    }
    
    private CardioRhythm getEnumByFloat(float value){
        for(CardioRhythm rhythm : CardioRhythm.values()){
            if(rhythm.floatValue == value){
                return rhythm;
            }
        }
        return null;
    }
    
    private CardioRhythm getEnumByString(String value){
        for(CardioRhythm rhythm : CardioRhythm.values()){
            if(rhythm.stringValue.equalsIgnoreCase(value)){
                return rhythm;
            }
        }
        return null;
    }
    

}
