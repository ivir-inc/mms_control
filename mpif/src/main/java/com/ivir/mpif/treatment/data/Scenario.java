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
package com.ivir.mpif.treatment.data;

import java.util.ArrayList;
import java.util.HashMap;

public class Scenario {
    private Integer id = null;
    private String name = null;
    //              treatmentName
    private final HashMap<String, MedicationTreatmentDetail> medicationTreatments = new HashMap<>();
    //                    injuryName     treatmentName
    private final HashMap<String,HashMap<String,PhysicalTreatmentDetail>> injuryBasedTreatments = new HashMap<>();
    //                    treatmentName    injuryName
    private final HashMap<String,ArrayList<String>> injuryByTreatment = new HashMap<>();

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public HashMap<String, MedicationTreatmentDetail> getMedicationTreatments() {
        return this.medicationTreatments;
    }

    /**
     * get the map of injuries to treatments.
     * @return HashMap<injuryStr,HashMap<treamentStr,TreatmentDetail>>
     */
    public HashMap<String, HashMap<String, PhysicalTreatmentDetail>> getInjuryBasedTreatments() {
        return injuryBasedTreatments;
    }

    public HashMap<String, ArrayList<String>> getInjuryByTreatment() {
        return injuryByTreatment;
    }
    
    public void addTreatment(String injury, PhysicalTreatmentDetail detail){
        HashMap<String,PhysicalTreatmentDetail> treatmentMap = this.injuryBasedTreatments.get(injury);
        if(treatmentMap == null){
            treatmentMap = new HashMap<>();
            this.injuryBasedTreatments.put(injury, treatmentMap);
        }
        treatmentMap.put(detail.getTreatmentName(), detail);

        ArrayList<String> injuryList = this.injuryByTreatment.get(detail.getTreatmentName());
        if(injuryList == null){
            injuryList = new ArrayList<>();
            this.injuryByTreatment.put(detail.getTreatmentName(), injuryList);
        }
        injuryList.add(injury);

    }
    
    public void addTreatment(MedicationTreatmentDetail detail){
        this.medicationTreatments.put(detail.getTreatmentName(), detail);
    }
    
    /**
     * get treatment by its name and injury name
     * @param treatmentName name of treatment
     * @param injuryName name of injury or null if there is no injury associated with it
     * @return treatment detail or null if not found
     */
    public PhysicalTreatmentDetail getPhysicalTreatmentByNameAndInjury(String treatmentName, String injuryName){
        HashMap<String,PhysicalTreatmentDetail> treatmentMap = null;
        treatmentMap = this.injuryBasedTreatments.get(injuryName);
        if(treatmentMap == null){
            return null;
        }else{
            return treatmentMap.get(treatmentName);
        }
    }
    
    public MedicationTreatmentDetail getMedicationTreatmentByName(String treatmentName){
        return this.medicationTreatments.get(treatmentName);
    }
    
}
