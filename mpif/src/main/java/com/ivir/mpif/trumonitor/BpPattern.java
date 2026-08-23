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
package com.ivir.mpif.trumonitor;

/**
 *
 * @author blewa
 */
public enum BpPattern {
    NORMAL("Normal",0),
    UNDER_DAMPED("Under Damped",1),
    OVER_DAMPED("Over Damped",2),
    POOR_PERFUSION("Poor Perfusion",3);
  
    private String typeName;
    private int typeValue;
    
    private BpPattern(String name, int value){
        this.typeName = name;
        this.typeValue = value;
    }
    
    public String getTypeName(){
        return typeName;
    }
    
    public int getTypeValue(){
        return typeValue;
    }
}
