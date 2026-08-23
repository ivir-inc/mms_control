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
public enum EcgPattern {
    NORMAL_SINUS("Normal Sinus",0),
    VENTRICULAR_FIBRILATION_COARSE("Ventricular Fibrilation (Coarse)",1),
    VENTRICULAR_FIBRILATION_VERY_COARSE("Ventricular Fibrilation (Very Coarse)",2),
    VENTRICULAR_FIBRILATION_FINE("Ventricular Fibrilation (Fine)",3),
    VENTRICULAR_TACHYCARDIA_1("Ventricular Tachycardia 1",4),
    VENTRICULAR_TACHYCARDIA_2("Ventricular Tachycardia 2",5),
    VENTRICULAR_TACHYCARDIA_3("Ventricular Tachycardia 3",6),
    PULSELESS_VENTRICULAR_TACHYCARDIA_1("Pulseless Ventricular Tachycardia 1",7),
    PULSELESS_VENTRICULAR_TACHYCARDIA_2("Pulseless Ventricular Tachycardia 2",8),
    PULSELESS_VENTRICULAR_TACHYCARDIA_3("Pulseless Ventricular Tachycardia 3",9),
    ASYSTOLE("Asystole",10),
    VENTRICULAR_STANDSTILL_P_WAVE_ASYSTOLE("Ventricular Standstill/p-Wave Asystole",11),
    FIRST_DEGREE_BLOCK("1st Degree Block",12),
    SECOND_DEGREE_BLOCK_MOBITZ_1_WENKEBACH("2nd Degree Block - Mobitz 1 (Wenkebach)",13),
    SECOND_DEGREE_BLOCK_MOBITZ_2("2nd Degree Block - Mobitz 2",14),
    SECOND_DEGREE_BLOCK_2_1("2nd Degree Block (2:1)",15),
    SECOND_DEGREE_BLOCK_3_1("2nd Degree Block (3:1)",16),
    AF_ATRIAL_FIBRILLATION("AF (Atrial Fibrillation)",17),
    AF_DIGOXIN_EFFECT("AF - Digoxin Effect",18),
    ELECTRICAL_ALTERNANS("Electrical Alternans",19),
    BIGEMINY("Bigeminy",20),
    COMPLETE_HEART_BLOCK("Complete Heart Block",21),
    ATRIAL_FLUTTER("Atrial Flutter",22),
    ATRIAL_FLUTTER_2_1_CONDUCTION("Atrial Flutter (2:1 Conduction)",23),
    ATRIAL_FLUTTER_3_1_CONDUCTION("Atrial Flutter (3:1 Conduction)",24),
    ATRIAL_FLUTTER_4_1_CONDUCTION("Atrial Flutter (4:1 Conduction)",25),
    FLUTTER_PAUSE("Flutter Pause",26),
    MILD_HYPERKALAEMIA("Mild Hyperkalaemia",27),
    JUNCTIONAL_ESCAPE("Junctional Escape",28),
    LEAD_DISCONNECT("Lead Disconnect",29),
    LONG_QT("Long QT",30),
    MULTIPLE_VENTRICULAR_ECTOPICS("Multiple Ventricular Ectopics",31),
    PACEMAKER_WITH_CAPTURE("Pacemaker With Capture",32),
    PACEMAKER_WITHOUT_CAPTURE("Pacemaker Without Capture",33),
    DUAL_CHAMBER_PACEMAKER("Dual Chamber Pacemaker",34),
    PRE_EXCITED_AF("Pre-Excited AF",35),
    SEVERE_HYPERKALAEMIA("Severe Hyperkalaemia",36),
    ST_DEPRESSION("ST Depression",37),
    ST_ELEVATION("ST Elevation",38),
    SVT_SUPRA_VENTRICULAR_TACHYCARDIA("SVT (Supra Ventricular Tachycardia)",39),
    TORSADES_DE_POINTES("Torsades De Pointes",40),
    WPW_WOLF_PARKINSON_WHITE("WPW (Wolf Parkinson White)",41);
    
    private String typeName;
    private int typeValue;
    
    private EcgPattern(String name, int value){
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
