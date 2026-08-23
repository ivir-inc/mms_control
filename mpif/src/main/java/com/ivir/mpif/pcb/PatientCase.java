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

package com.ivir.mpif.pcb;

import org.dizitart.no2.repository.annotations.Entity;
import org.dizitart.no2.repository.annotations.Id;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;

@Entity
public class PatientCase {
    @Id
    private Integer caseNum;
    private String name;
    private BiologicalSex biologicalSex;
    private List<PCTreatment> treatments = new ArrayList<>();
    private PCVitals vitals;
    private List<PCInjury> injuries = new ArrayList<>();

    public Integer getCaseNum() {
        return caseNum;
    }

    public PatientCase setCaseNum(Integer caseNum) {
        this.caseNum = caseNum;
        return this;
    }

    public String getName() {
        return name;
    }

    public PatientCase setName(String name) {
        this.name = name;
        return this;
    }

    public BiologicalSex getBiologicalSex() {
        return biologicalSex;
    }

    public PatientCase setBiologicalSex(BiologicalSex biologicalSex) {
        this.biologicalSex = biologicalSex;
        return this;
    }

    public List<PCTreatment> getTreatments() {
        return treatments;
    }

    public PatientCase setTreatments(List<PCTreatment> treatments) {
        this.treatments = treatments;
        return this;
    }

    public PCVitals getVitals() {
        return vitals;
    }

    public PatientCase setVitals(PCVitals vitals) {
        this.vitals = vitals;
        return this;
    }

    public List<PCInjury> getInjuries() {
        return injuries;
    }

    public PatientCase setInjuries(List<PCInjury> injuries) {
        this.injuries = injuries;
        return this;
    }

   public PatientCase buildPCVitals(Consumer<PCVitals> vitalsBuilder){
        PCVitals pcVitals = new PCVitals();
        this.vitals = pcVitals;
        vitalsBuilder.accept(pcVitals);
        return this;
    }

    public PatientCase buildPCTreatment(Consumer<PCTreatment> treatmentBuilder){
        PCTreatment treatment = new PCTreatment();
        this.treatments.add(treatment);
        treatmentBuilder.accept(treatment);
        return this;
    }

    public PatientCase buildPCInjury(Consumer<PCInjury> injuryBuilder){
        PCInjury injury = new PCInjury();
        this.injuries.add(injury);
        injuryBuilder.accept(injury);
        return this;
    }

    @Override
    public String toString() {
        return "PatientCase{" +
                "caseNum=" + caseNum +
                ", name='" + name + '\'' +
                ", biologicalSex='" + biologicalSex + '\'' +
                ", treatments=" + treatments +
                ", vitals=" + vitals +
                ", injuries=" + injuries +
                '}';
    }


}
