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

package com.ivir.mpif.controller.model;

import java.util.ArrayList;
import java.util.List;

public class RestPatientCase {
    private Integer caseNum;
    private String name;
    private String biologicalSex;
    private List<RestPCPhysicalTreatment> physicalTreatments = new ArrayList<>();
    private List<RestPCMedication> medications = new ArrayList<>();
    private RestPCVitals vitals;
    private List<RestPCInjury> injuries = new ArrayList<>();

    public Integer getCaseNum() {
        return caseNum;
    }

    public RestPatientCase setCaseNum(Integer caseNum) {
        this.caseNum = caseNum;
        return this;
    }

    public String getName() {
        return name;
    }

    public RestPatientCase setName(String name) {
        this.name = name;
        return this;
    }

    public String getBiologicalSex() {
        return biologicalSex;
    }

    public RestPatientCase setBiologicalSex(String biologicalSex) {
        this.biologicalSex = biologicalSex;
        return this;
    }

    public List<RestPCPhysicalTreatment> getPhysicalTreatments() {
        return physicalTreatments;
    }

    public RestPatientCase setPhysicalTreatments(List<RestPCPhysicalTreatment> treatments) {
        this.physicalTreatments = treatments;
        return this;
    }

    public List<RestPCMedication> getMedications() {
        return medications;
    }

    public RestPatientCase setMedications(List<RestPCMedication> medications) {
        this.medications = medications;
        return this;
    }

    public RestPCVitals getVitals() {
        return vitals;
    }

    public RestPatientCase setVitals(RestPCVitals vitals) {
        this.vitals = vitals;
        return this;
    }

    public List<RestPCInjury> getInjuries() {
        return injuries;
    }

    public RestPatientCase setInjuries(List<RestPCInjury> injuries) {
        this.injuries = injuries;
        return this;
    }

    @Override
    public String toString() {
        return "RestPatientCase{" +
                "caseNum=" + caseNum +
                ", name='" + name + '\'' +
                ", biologicalSex='" + biologicalSex + '\'' +
                ", physicalTreatments=" + physicalTreatments +
                ", medications=" + medications +
                ", vitals=" + vitals +
                ", injuries=" + injuries +
                '}';
    }
}
