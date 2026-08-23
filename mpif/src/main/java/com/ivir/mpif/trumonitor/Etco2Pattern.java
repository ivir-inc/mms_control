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
public enum Etco2Pattern {
    NORMAL("Normal",0),
    OESOPHAGEAL_INTUBATION("Oesophageal Intubation",1),
    RIGHT_MAIN_BRONCHUS_INTUBATION("Right Main Bronchus Intubation",2),
    SPONTANEOUS_VENTILATION("Spontaneous Ventilation",3),
    INTERMITTENT_MECHANICAL_VENTILATION("Intermittent Mechanical Ventilation",4),
    OBSTRUCTIVE_PATTERN_1("Obstructive Pattern 1",5),
    OBSTRUCTIVE_PATTERN_2("Obstructive Pattern 2",6),
    EMPHYSEMA("Emphysema",7),
    SUBSIDING_RELAXANT("Subsiding Relaxant",8),
    REBREATHING("Rebreathing",9),
    SATURATED_SODA_LIME("Saturated Soda Lime",10),
    CARDIAC_OSCILLATIONS("Cardiac Oscillations",11),
    MECHANICAL_AIRWAY_OBSTRUCTION("Mechanical Airway Obstruction",12),
    PIGTAIL("Pigtail",13);

    private String typeName;
    private int typeValue;
    
    private Etco2Pattern(String name, int value){
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
