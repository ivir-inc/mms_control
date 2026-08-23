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
 * @author blewa
 */
public enum HeartSound {
    NO_SOUND(0,"No Sound"),
    HEALTHY(1,"Healthy"),
    S3(2,"S3"),
    S4(3,"S4 "),
    S3_S4(4,"S3 & S4"),
    SYSTOLIC_EARLY(5,"Systolic Early"),
    SYSTOLIC_MID(6,"Systolic Mid"),
    SYSTOLIC_LATE(7,"Systolic Late"),
    SYSTOLIC_PAN(8,"Systolic Pan"),
    DIASTOLIC_LATE(9,"Diastolic Late");
    
    private final float _value;
    private final String _description;
    
    private HeartSound(float value, String description){
        this._value = value;
        this._description = description;
    }
    
    public String getDescription(){
        return this._description;
    }
    
    public static HeartSound oeiValueToHeartStatus(float value){
        for(HeartSound status : HeartSound.values()){
            if(value == status._value){
                return status;
            }
        }
        return null;
    }
}
