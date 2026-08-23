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

public enum TreatmentDevice {
    NOT_APPLICABLE("notApplicable", 0L, "Not Applicable"),
    CERVICAL_COLLAR("cervicalCollar", 1L, "Cervical Collar"),
    EXTREMITY_TOURNIQUET("extremityTourniquet", 2L, "Extremity TQ"),
    JUNCTIONAL_TOURNIQUET("junctionalTourniquet", 3L, "Junctional TQ"),
    SPINE_BOARD("spineBoard", 4L, "Spine Board"),
    LITTER("litter", 5L, "Litter"),
    BANDAGE("bandage", 6L, "Bandage"),
    GAUZE("gauze", 7L, "Gauze"),
    VENTED_OCCLUSIVE_DRESSING("ventedOcclusiveDressing", 8L, "Vented Occlusive Dressing"),
    OCCLUSIVE_DRESSING("occlusiveDressing", 9L, "Occlusive Dressing"),
    MYLAR_BLANKET("mylarBlanket", 10L, "Mylar Blanket"),
    CHEST_TUBE("chestTube", 11L, "Chest Tube"),
    CHEST_NEEDLE_DECOMPRESSION("chestNeedleDecompression", 12L, "NCD"),
    FOLEY_CATHETER("foleyCatheter", 13L, "Foley Catheter"),
    OROPHARYNGEAL_AIRWAY("oropharyngealAirway", 14L, "OPA"),
    NASOPHARYNGEAL_AIRWAY("nasopharyngealAirway", 15L, "NPA"),
    ENDOTRACHEAL_TUBE("endotrachealTube", 16L, "ET-Tube"),
    LARYNGEAL_TUBE("laryngealTube", 17L, "LT-Tube"),
    SUPRAGLOTTIC_DEVICE("supraglotticDevice", 18L, "SGA"),
    LARYNGOSCOPE("laryngoscope", 19L, "Laryngoscope"),
    ENDOVASCULAR_BALLOON("endovascularBalloon", 20L, "Endovascular Balloon"),
    EYE_SHIELD("eyeShield", 21L, "Eye Shield" ),
    SPLINT("splint", 22L, "Splint"),
    OXYGEN_MASK("oxygenMask", 23L, "BVM"),
    ISOPROPYL_ALCOHOL_PAD("isopropylAlcoholPad", 24L, "Isopropyl Alcohol"),
    CRICOTHYROIDOTOMY_KIT("cricothyroidotomyKit", 25L, "Cric Kit");

	private String _name = null;
	private long _ordinal = 0;
    private String _displayName = null;

    private static HashMap<String, TreatmentDevice> nameMap = new HashMap<>();

    static{
        for(TreatmentDevice value : TreatmentDevice.values()){
            nameMap.put(value.getName(),value);
        }
    }

	private TreatmentDevice(String name, long ordinal, String displayName) {
		_name = name;
		_ordinal = ordinal;
        _displayName = displayName;
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

    public static TreatmentDevice getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }
		
}
