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
package com.ivir.mpif.treatment.impl.file;

import java.util.ArrayList;

/**
 *
 * @author lewanw
 */
public class ScenarioFile {
    private String name = null;
    private ArrayList<InjuryFile> injuries = null;
    private ArrayList<MedicationTreatmentFile> medications = null;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public ArrayList<InjuryFile> getInjuries() {
        return injuries;
    }

    public void setInjuries(ArrayList<InjuryFile> injuries) {
        this.injuries = injuries;
    }

    public ArrayList<MedicationTreatmentFile> getMedications() {
        return medications;
    }

    public void setMedications(ArrayList<MedicationTreatmentFile> medications) {
        this.medications = medications;
    }
    
    
}
