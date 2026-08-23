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

import java.util.Arrays;
import java.util.HashMap;

public enum MedicationAdministrationRoute {
    UNKNOWN("unknown", 0, "Unk", ""),
    INTRAVENOUS_DRIP("intravenousDrip", 1, "IV", "IV Drip"),
    INTRAVENOUS_BOLUS("intravenousBolus", 2, "IVB", "IV Bolus"),
    INTRAMUSCULAR("intramuscular", 3, "IM", "IM"),
    INTRAOSSEOUS_DRIP("intraosseousDrip", 4, "IO", "IO Drip"),
    INTRAOSSEOUS_BOLUS("intraosseousBolus", 5, "IOB", "IO Bolus"),
    ORAL("oral", 6, "PO", "Oral"),
    RECTAL("rectal", 7 , "PR", "Rectal"),
    SUBLINGUAL("sublingual", 8, "SL", "Sublingual"),
    BUCCAL("buccal", 9, "TM", "Buccal"),
    INTRADERMAL("intradermal", 10, "ID", "ID");

	private String _name = null;
	private int _ordinal = 0;
	private String _abbreviation;
	private String _displayName;

	private static HashMap<String, MedicationAdministrationRoute> nameMap = new HashMap<>();

	static{
		for(MedicationAdministrationRoute value : MedicationAdministrationRoute.values()){
			nameMap.put(value.getName(),value);
		}
	}

	private MedicationAdministrationRoute(String name, int ordinal, String abbreviation, String displayName) {
		_name = name;
		_ordinal = ordinal;
		_abbreviation = abbreviation;
		_displayName = displayName;
	}
	
	public String getName() {
		return _name;
	}

	public String getAbbreviation(){
		return _abbreviation;
	}
	
	public int getOrdinal() {
		return _ordinal;
	}

	public String getDisplayName(){
		return _displayName;
	}

	public static MedicationAdministrationRoute getByEnum(String enumString){
		try {
			return MedicationAdministrationRoute.valueOf(enumString);
		}catch(Exception e){
			return null;
		}
	}

	public static MedicationAdministrationRoute getByAbbreviation(String abvr){
		return Arrays.stream(MedicationAdministrationRoute.values()).filter((enumItem)->enumItem.getAbbreviation().equalsIgnoreCase(abvr)).findFirst().orElse(null);
	}

	public static MedicationAdministrationRoute getByName(String name){
		if(name == null){
			return null;
		}
		return nameMap.get(name);
	}

}
