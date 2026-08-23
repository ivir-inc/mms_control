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

import static com.ivir.mpif.simdata.MedicationCategory.*;

public enum Medication {
    NOT_APPLICABLE("notApplicable", 0L, "Not Applicable", null),
    SALINE09("saline09", 1L, "Saline 0.9%", FLUID),
    SALINE3("saline3", 2L, "Saline 3%", FLUID),
    MORPHINE("morphine", 3L, "Morphine", DRUG),
    KETAMINE("ketamine", 4L, "Ketamine", DRUG),
    EPINEPHRINE("epinephrine", 5L, "Epinephrine", DRUG),
    DEXTROSE("dextrose", 6L, "Dextrose", DRUG),
    LACTATED_RINGERS("lactatedRingers", 7L, "Lactated Ringers", FLUID),
    OXYGEN("oxygen", 8L, "Oxygen", FLUID),
    ASPIRIN("aspirin", 9L, "Aspirin", DRUG),
    CALCIUM_GLUCONATE("calciumGluconate", 10L, "Calcium Gluconate", DRUG),
    SODIUM_CHLORIDE("sodiumChloride", 11L, "Sodium Cl", DRUG),
    MIDAZOLAM_HYDROCHLORIDE("midazolamHydrochloride", 12L, "Midazolam Hcl", DRUG),
    DIPHENHYDRAMINE("diphenhydramine", 13L, "Diphenhydramine", DRUG),
    ACETAMINOPHEN("acetaminophen", 14L, "Acetaminophen", DRUG),
    MOXIFLOXACIN("moxifloxacin", 15L, "Moxifloxacin", ANTI_INFECTION),
    ERTAPENEM("ertapenem", 16L, "Ertapenem", ANTI_INFECTION),
    MELOXICAM("meloxicam", 17L, "Meloxicam", DRUG),
    ONDANSETRON("ondansetron", 18L, "Ondansetron", DRUG),
    FENTANYL_CITRATE("fentanylCitrate", 19L, "Fentanyl Citrate", DRUG),
    METHYLPREDNISOLONE("methylprednisolone", 20L, "Methyl Prednisolone", DRUG),
    NALOXONE("naloxone", 21L, "Naloxone", DRUG),
    TRANEXAMIC_ACID("tranexamicAcid", 22L, "TXA", FLUID),
    ATROPINE("atropine", 23L, "Atropine", DRUG),
    LIDOCAINE("lidocaine", 24L, "Lidocaine", DRUG),
    ADENOSINE("adenosine", 25L, "Adenosine", DRUG),
    HEXTEND("hextend", 26L, "Hextend", FLUID),
    FRESH_WHOLE_BLOOD("freshWholeBlood", 27L, "Fresh Whole Blood", FLUID),
    PLASMA("plasma", 28L, "Plasma", FLUID),
    RED_BLOOD_CELLS("redBloodCells", 29L, "RBCs", FLUID),
    PLASMALYTE_A("plasmalyteA", 30L, "PlasmalyteA", FLUID),
    CLINDAMYCIN("clindamycin", 31L, "Clindamycin", ANTI_INFECTION),
    ACYCLOVIR("acyclovir", 32L, "Acyclovir", ANTI_INFECTION),
    NARCAN("narcan", 33L, "Narcan", DRUG),
    IBUPROFEN("ibuprofen", 34L, "Ibuprofen", DRUG);

    public final String _name;
    public final long _ordinal;
    public final String _displayName;
    public final MedicationCategory _category;

    private static HashMap<String, Medication> nameMap = new HashMap<>();

    static{
        for(Medication value : Medication.values()){
            nameMap.put(value.getName(),value);
        }
    }

    private Medication(String name, long ordinal, String displayName, MedicationCategory category) {
        _name = name;
        _ordinal = ordinal;
        _displayName = displayName;
        _category = category;
    }

    public long getOrdinal() {
        return _ordinal;
    }

    public String getName() {
        return _name;
    }

    public String getDisplayName(){
        return _displayName;
    }

    public MedicationCategory getCategory(){
        return _category;
    }

    public static Medication getByName(String name){
        if(name == null){
            return null;
        }
        return nameMap.get(name);
    }

}
