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
public enum ParamType {
    VITALS_BP_DIASTOLIC("BPDiastolic",ParamCategory.VITALS, new FloatValueMapper("Diastolic Blood Pressure")),
    VITALS_BP_SYSTOLIC("BPSystolic",ParamCategory.VITALS, new FloatValueMapper("Systolic Blood Pressure")),
    VITALS_HR("HR",ParamCategory.VITALS, new FloatValueMapper("Heart Rate")),
    VITALS_RR("RR",ParamCategory.VITALS, new FloatValueMapper("Respiratory Rate")),
    VITALS_SPO2("SpO2",ParamCategory.VITALS, new FloatValueMapper("SpO2")),
    VITALS_TEMP("Temperature",ParamCategory.VITALS, new FloatValueMapper("Temperature")),
    AIRWAY_SOUND("AirwaySoundCondition",ParamCategory.SOUNDS, new AirwaySoundValueMapper()),
    BLEEDING_0("Bleeding_0", ParamCategory.BLEEDING_SITES, new OnOffValueMapper("First bleeding position")),
    BLEEDING_1("Bleeding_1", ParamCategory.BLEEDING_SITES, new OnOffValueMapper("Second bleeding position")),
    BLEEDING_2("Bleeding_2", ParamCategory.BLEEDING_SITES, new OnOffValueMapper("Third bleeding position")),
    BLEEDING_3("Bleeding_3", ParamCategory.BLEEDING_SITES, new OnOffValueMapper("Fourth bleeding position")),
    CARDIO_RHYTHM("CardioRhythm", ParamCategory.RHYTHM, new CardioRhythmValueMapper()),
    EYE_LEFT("EyeLeft", ParamCategory.MECHANICAL, new EyeStatusValueMapper("Left Eye")),
    EYE_RIGHT("EyeRight", ParamCategory.MECHANICAL, new EyeStatusValueMapper("Right Eye")),
    HEART_SOUND("HeartSoundCondition", ParamCategory.SOUNDS, new HeartSoundValueMapper()),
    LUNG_SOUND_RIGHT("LungSoundCondition_R", ParamCategory.SOUNDS, new LungSoundValueMapper("Right lung sound")),
    LUNG_SOUND_LEFT("LungSoundCondition_L", ParamCategory.SOUNDS, new LungSoundValueMapper("Left lung sound")),
    PULSE_CAROTID_RIGHT("Pulse_Carotid_R", ParamCategory.PULSE, new OnOffValueMapper("Right Carotid pulse")),
    PULSE_BRACHIAL_RIGHT("Pulse_Brachial_R", ParamCategory.PULSE, new OnOffValueMapper("Right Brachial pulse")),
    PULSE_RADIAL_RIGHT("Pulse_Radial_R", ParamCategory.PULSE, new OnOffValueMapper("Right Radial pulse")),
    PULSE_FEMORAL_RIGHT("Pulse_Femoral_R", ParamCategory.PULSE, new OnOffValueMapper("Right Femorial pulse")),
    PULSE_POPLITEAL_RIGHT("Pulse_Popliteal_R", ParamCategory.PULSE, new OnOffValueMapper("Right Popliteal pulse")),
    PULSE_POSTERIOR_RIGHT("Pulse_PosteriorP_R", ParamCategory.PULSE, new OnOffValueMapper("Right Posterior pulse")),
    PULSE_DORSALIS_RIGHT("Pulse_DorsalisP_R", ParamCategory.PULSE, new OnOffValueMapper("Right Dorsalis pulse")),
    PULSE_CAROTID_LEFT("Pulse_Carotid_L", ParamCategory.PULSE, new OnOffValueMapper("Left Carotid pulse")),
    PULSE_BRACHIAL_LEFT("Pulse_Brachial_L", ParamCategory.PULSE, new OnOffValueMapper("Left Brachial pulse")),
    PULSE_RADIAL_LEFT("Pulse_Radial_L", ParamCategory.PULSE, new OnOffValueMapper("Left Radial pulse")),
    PULSE_FEMORAL_LEFT("Pulse_Femoral_L", ParamCategory.PULSE, new OnOffValueMapper("Left Femorial pulse")),
    PULSE_POPLITEAL_LEFT("Pulse_Popliteal_L", ParamCategory.PULSE, new OnOffValueMapper("Left Popliteal pulse")),
    PULSE_POSTERIOR_LEFT("Pulse_PosteriorP_L", ParamCategory.PULSE, new OnOffValueMapper("Left Posterior pulse")),
    PULSE_DORSALIS_LEFT("Pulse_DorsalisP_L", ParamCategory.PULSE, new OnOffValueMapper("Left Dorsalis pulse")),
    PULSE_ALL("Pulse_All", ParamCategory.PULSE, new OnOffValueMapper("All pulses")),
    TONGUE_SWOLLEN("TongueSwollen", ParamCategory.MECHANICAL, new OnOffValueMapper("Swollen Toungue")),
    TENSION_PNEUMO_RIGHT("RightTensionPneumo", ParamCategory.MECHANICAL, new OnOffValueMapper("Right Tension Pneumothorax")),
    TENSION_PNEUMO_LEFT("LeftTensionPneumo", ParamCategory.MECHANICAL, new OnOffValueMapper("Left Tension Pneumothorax"));   
            
    private final String _oeiLogName;
    private final ParamCategory _category;
    private final ParamValueMapper _mapper;
        
   private ParamType(String oeiLogName, ParamCategory category, ParamValueMapper mapper){
       this._oeiLogName = oeiLogName;
       this._category = category;
       this._mapper = mapper;
   }
   
   
   public ParamCategory getCategory(){
       return this._category;
   }
   
   public ParamValueMapper getParamValueMapper(){
       return this._mapper;
   }
   
   public static ParamType oeiNameToParamType(String oeiName){
       for(ParamType pType : ParamType.values()){
           if(pType._oeiLogName.equalsIgnoreCase(oeiName)){
               return pType;
           }
       }
       return null;
   }
   
}
