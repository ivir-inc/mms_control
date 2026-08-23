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

package com.ivir.mpif.simdata;

import java.util.HashMap;

import static com.ivir.mpif.simdata.PhysicalTreatmentCategory.*;

public enum PhysicalTreatmentType {
    OPEN_NASAL_AIRWAY("openNasalAirway", 0L, "Open Nasal Airway", AIRWAY),
    OPEN_TRACHEAL_AIRWAY("openTrachealAirway", 1L, "Open Airway", AIRWAY),
    STOP_HEMORRHAGE("stopHemorrhage", 2L, "Stop Hemorrhage", MASSIVE_HEMORRHAGE),
    RELEASE_INTRAPLEURAL_PRESSURE("releaseIntrapleuralPressure", 3L, "Treat Pneumothorax", RESPIRATION),
    STABILIZE_ORTHOPEDIC_FRACTURE("stabilizeOrthopedicFracture", 4L, "Stabilize Fracture", GENERAL),
    IMMOBILIZE_SPINE("immobilizeSpine", 5L, "Immobilize Spine", GENERAL),
    CLEAN_WOUND("cleanWound", 6L, "Clean Wound", GENERAL),
    ELEVATE_HEAD("elevateHead", 7L, "Elevate Head", AIRWAY),
    SEAL_CHEST_WOUND("sealChestWound", 8L, "Seal Chest Wound", RESPIRATION),
    WARM_PATIENT("warmPatient", 9L, "Warm Patient", HYPOTHERMIA),
    CATHETERIZE("catheterize", 10L, "Catheterization", GENERAL),
    VENTILATION_MANUAL("ventilationManual", 11L, "Manual Ventilation", RESPIRATION),
    CHEST_COMPRESSION("chestCompression", 12L, "Chest Compressions", CIRCULATION),
    DEFIBRILLATE("defibrillate", 13L, "Defibrillate", CIRCULATION),
    VENTILATION_HYPER("ventilationHyper", 14L, "Hyperventilate", RESPIRATION),
    VENTILATION_PEEP5("ventilationPEEP5", 15L, "PEEP-5", RESPIRATION),
    VENTILATION_PEEP15("ventilationPEEP15", 16L, "PEEP-15", RESPIRATION),
    BANDAGE_BURN("bandageBurn", 17L, "Bandage Burn", GENERAL),
    RELEASE_COMPARTMENTAL_PRESSURE("releaseCompartmentalPressure", 18L, "Fasciotomy", GENERAL),
    RELEASE_SKIN_PRESSURE("releaseSkinPressure", 19L, "Release Skin Pressure", GENERAL),
    COVER_EYE("coverEye", 20L, "Cover Eye", GENERAL);

	private String _name = null;
	private long _ordinal = 0;
    private String _displayName = null;
    private PhysicalTreatmentCategory _category = null;
    private static HashMap<String, PhysicalTreatmentType> nameMap = new HashMap<>();

    static{
        for(PhysicalTreatmentType value : PhysicalTreatmentType.values()){
            nameMap.put(value.getName(),value);
        }
    }

	private PhysicalTreatmentType(String name, long ordinal, String displayName, PhysicalTreatmentCategory category) {
		_name = name;
		_ordinal = ordinal;
        _displayName = displayName;
        _category = category;
	}
	
	public String getName() {
		return _name; 
	}
	
	public long getOrdinal() {
		return _ordinal;
	}

    public String getDisplayName(){
        return _displayName;
    }

    public PhysicalTreatmentCategory getCategory(){
        return _category;
    }

    public static PhysicalTreatmentType getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }
	

}
