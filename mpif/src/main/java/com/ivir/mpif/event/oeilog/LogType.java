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
public enum LogType {
    OPEN_SIMULATION_MESSAGE(301,SimulationStateMessage.class),
    START_SIMULATION_MESSAGE(302,SimulationStateMessage.class),
    SIMULATION_PARAM_MESSAGE(509, SimulationParamMessage.class),
    VENTILATION_TREATMENT(111, VentilationTreatment.class),
    NCD_TREATMENT(105, NcdTreatment.class);
    
    private int _typeNum;
    private Class<?> _classType;
    
    private LogType(int num, Class<?> classType){
        _typeNum = num;
        _classType = classType;
    }
    
    public int getTypeNum(){
        return _typeNum;
    }
    
    public Class<?> getClassType(){
        return _classType;
    }
    
    public static LogType getByLogTypeNum(int num){
        for(LogType ltype : LogType.values()){
            if(ltype.getTypeNum() ==  num){
                return ltype;
            }
        }
        return null;
    }
}
