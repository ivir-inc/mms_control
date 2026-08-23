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

package com.ivir.mpif.event;

import com.ivir.mpif.simdata.*;

import java.util.ArrayList;
import java.util.Arrays;

public class TreatmentEventBuilder {
	
	public static String physicalTreatmentClause(PhysicalTreatmentType type) {
		switch(type) {
			case BANDAGE_BURN : return "Burn bandaged";
			case CATHETERIZE : return "Catheterized";
			case CHEST_COMPRESSION : return "Chest compression applied";
			case CLEAN_WOUND : return "Wound cleaned";
			case COVER_EYE : return "Eye covered";
			case DEFIBRILLATE : return "Defibrillation applied";
			case ELEVATE_HEAD : return "Head elevated";
			case IMMOBILIZE_SPINE : return "Spine immobilized";
			case OPEN_NASAL_AIRWAY : return "Nasal airway opened";
			case OPEN_TRACHEAL_AIRWAY : return "Tracheal airway opened";
			case RELEASE_COMPARTMENTAL_PRESSURE : return "Compartmental pressure released";
			case RELEASE_INTRAPLEURAL_PRESSURE : return "Intrapleural pressure released"; 
			case RELEASE_SKIN_PRESSURE : return "Skin pressure released";
			case SEAL_CHEST_WOUND : return "Chest seal applied";
			case STABILIZE_ORTHOPEDIC_FRACTURE : return "Fracture stabilized";
			case STOP_HEMORRHAGE : return "Hemorrhage stopped";
			case VENTILATION_HYPER : return "Hyperventilation administered";
			case VENTILATION_MANUAL : return "Manual ventilation administered";
			case VENTILATION_PEEP15 : return "PEEP15 ventilation administered";
			case VENTILATION_PEEP5 : return "PEEP5 ventilation administered";
			case WARM_PATIENT : return "Patient warmed";
		}
		return "";
	}
	
	public static String medicationTreatmentClause(Medication medication) {
		String medicationStr = "";

		return medication.getDisplayName() + " administered";
	}

	public static String locationPhrase(BodyLocation location) {
		if(location== null) return null;
		String startStr = "on the";
		String orientationStr = orientationPhrase(location);
		String bodyPartStr = bodyPartPhrase(location);
		if(orientationStr.isEmpty() && bodyPartStr.isEmpty()){
			return "";
		}
		if(!orientationStr.isEmpty()){
			startStr += " " + orientationStr;
		}
		if(!bodyPartStr.isEmpty()){
			startStr += " " + bodyPartStr;
		}
		return startStr;
	}

	private static String bodyPartPhrase(BodyLocation locationRecord){
		// if more the one body location record is set, then used the most specific enum

		if(locationRecord.getDetailedAnatomy() != DetailedAnatomy.NOT_APPLICABLE){
			return toPrepositionalPhraseCase(locationRecord.getDetailedAnatomy().toString());
		}
		if(locationRecord.getSkeletalSystem() != SkeletalSystem.NOT_APPLICABLE){
			return toPrepositionalPhraseCase(locationRecord.getSkeletalSystem().toString());
		}
		if(locationRecord.getInternalAnatomy() != InternalAnatomy.NOT_APPLICABLE){
			return toPrepositionalPhraseCase(locationRecord.getInternalAnatomy().toString());
		}
		//there are special rules for region tissue type and general region.
		//if both are present then combine them.  If not then just used the one that is present
		String regionTissueTypePhrase = null;
		String generalRegionPhrase = null;
		if(locationRecord.getRegionTissueType() != RegionTissueType.NOT_APPLICABLE){
			regionTissueTypePhrase = toPrepositionalPhraseCase(locationRecord.getRegionTissueType().toString());
		}
		if(locationRecord.getGeneralRegion() != GeneralRegion.NOT_APPLICABLE){
			generalRegionPhrase = toPrepositionalPhraseCase(locationRecord.getGeneralRegion().toString());
		}
		if(regionTissueTypePhrase != null){
			if(generalRegionPhrase == null){
				return regionTissueTypePhrase;
			}
			return regionTissueTypePhrase + " of the " + generalRegionPhrase;
		}
		if(generalRegionPhrase != null){
			return generalRegionPhrase;
		}
		return "";
	}

	private static String orientationPhrase(BodyLocation locationRecord){
		ArrayList<String> orientationParts = new ArrayList<>();
		if(locationRecord.getSagittalPlane() != SagittalPlane.NOT_APPLICABLE){
			orientationParts.add(locationRecord.getSagittalPlane().getName());
		}
		if(locationRecord.getTransversePlane() != TransversePlane.NOT_APPLICABLE) {
			orientationParts.add(locationRecord.getTransversePlane().getName());
		}
		if(locationRecord.getCoronalPlane() != CoronalPlane.NOT_APPLICABLE){
			orientationParts.add(locationRecord.getCoronalPlane().getName());
		}
		if(orientationParts.size() == 0){
			return "";
		}
		return String.join(" ", orientationParts);
	}
	
	public static String devicePhrase(TreatmentDevice device) {
		if(device == null) return null;
		
		String deviceStr = "";
		switch(device) {
			case NOT_APPLICABLE : return null;
			case CHEST_NEEDLE_DECOMPRESSION : deviceStr = "NCD";
				break;
			default: deviceStr = toPrepositionalPhraseCase(device.toString());
		}
		
		return "with " + deviceStr;
	}
	
	public static String routePhrase(MedicationAdministrationRoute route) {
		if(route == null) return null;
		
		switch(route) {
			case BUCCAL : return "via buccal route";
			case INTRADERMAL : return "via ID";
			case INTRAMUSCULAR : return "via IM";
			case INTRAOSSEOUS_BOLUS : return "via IO Bolus";
			case INTRAOSSEOUS_DRIP : return "via IO Drip";
			case INTRAVENOUS_BOLUS : return "via IV Bolus";
			case INTRAVENOUS_DRIP : return "via IV Drip";
			case ORAL : return "orally";
			case RECTAL : return "rectally";
			case SUBLINGUAL : return "via sublingual route";
		}
		
		return null;
	}
	
	public static String dosagePhrase(Float dosage, Integer period) {
		if((dosage == null) || (dosage == 0f)) {
			return null;
		}
		
		String periodStr = "";
		if((period != null) && (period != 0)) {
			periodStr = " every " + period.toString() + " minutes";
		}
		
		return "with " + dosage.toString() + " units"+ periodStr;
	}
	
	private static String toPrepositionalPhraseCase(String s) {
		String[] parts = s.split("_");
		String phraseString = "";
				
		for (String part : parts) {
			phraseString += " " + part.toLowerCase();
		}
		
		return phraseString.substring(1);
		
	}
	
	static String toSentenceCase(String s) {
		String[] parts = s.split("_");
		String sentenceCaseString = "";
		
		sentenceCaseString = toProperCase(parts[0]);
		
		if(parts.length > 1) {
			for (String part : Arrays.copyOfRange(parts, 1, parts.length)) {
				sentenceCaseString += " " + part.toLowerCase();
			}

		}
		return sentenceCaseString;
	}

	static String toProperCase(String s) {
		return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
	}
}
