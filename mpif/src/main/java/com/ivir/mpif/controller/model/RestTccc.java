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

import com.ivir.mpif.simdata.*;

import java.util.List;

public class RestTccc {
    private Boolean local;
    private String instanceName;
    private String patientId;
       private String battleRosterNumber;
       private EvacuationCategory evacuationLevelRequest;
       private String lastName;
       private String firstName;
       private String socialSecurityAccountNumber;
       private Gender gender;
       private String date;
       private String time;
       private String service;
       private String unit;
       private String allergies;
       private MechanismOfInjuryComms mechanismOfInjury;
       private RestInjuryAnnotation injuryAnnotation;
       private List<SignsSymptoms> signsSymptoms;
       private TreatmentCirculatoryTourniquet treatmentCirculatoryTourniquet;
       private TreatmentCirculatoryDressing treatmentCirculatoryDressing;
       private TreatmentAirway treatmentAirway;
       private TreatmentBreathing treatmentBreathing;
       private List<TreatmentFluid> treatmentFluids;
       private List<TreatmentFluid> treatmentBloodProducts;
       private List<TreatmentMedications> treatmentMedicationsAnalgesic;
       private List<TreatmentMedications> treatmentMedicationsAntibiotic;
       private List<TreatmentMedications> treatmentMedicationsOther;
       private TreatmentOther treatmentOther;
       private String treatmentNotes;
       private Responder responder;

    public Boolean getLocal() {
        return local;
    }

    public RestTccc setLocal(Boolean local) {
        this.local = local;
        return this;
    }

    public String getInstanceName() {
        return instanceName;
    }

    public RestTccc setInstanceName(String instanceName) {
        this.instanceName = instanceName;
        return this;
    }

    public String getPatientId() {
        return patientId;
    }

    public RestTccc setPatientId(String patientId) {
        this.patientId = patientId;
        return this;
    }

    public String getBattleRosterNumber() {
        return battleRosterNumber;
    }

    public RestTccc setBattleRosterNumber(String battleRosterNumber) {
        this.battleRosterNumber = battleRosterNumber;
        return this;
    }

    public EvacuationCategory getEvacuationLevelRequest() {
        return evacuationLevelRequest;
    }

    public RestTccc setEvacuationLevelRequest(EvacuationCategory evacuationLevelRequest) {
        this.evacuationLevelRequest = evacuationLevelRequest;
        return this;
    }

    public String getLastName() {
        return lastName;
    }

    public RestTccc setLastName(String lastName) {
        this.lastName = lastName;
        return this;
    }

    public String getFirstName() {
        return firstName;
    }

    public RestTccc setFirstName(String firstName) {
        this.firstName = firstName;
        return this;
    }

    public String getSocialSecurityAccountNumber() {
        return socialSecurityAccountNumber;
    }

    public RestTccc setSocialSecurityAccountNumber(String socialSecurityAccountNumber) {
        this.socialSecurityAccountNumber = socialSecurityAccountNumber;
        return this;
    }

    public Gender getGender() {
        return gender;
    }

    public RestTccc setGender(Gender gender) {
        this.gender = gender;
        return this;
    }

    public String getDate() {
        return date;
    }

    public RestTccc setDate(String date) {
        this.date = date;
        return this;
    }

    public String getTime() {
        return time;
    }

    public RestTccc setTime(String time) {
        this.time = time;
        return this;
    }

    public String getService() {
        return service;
    }

    public RestTccc setService(String service) {
        this.service = service;
        return this;
    }

    public String getUnit() {
        return unit;
    }

    public RestTccc setUnit(String unit) {
        this.unit = unit;
        return this;
    }

    public String getAllergies() {
        return allergies;
    }

    public RestTccc setAllergies(String allergies) {
        this.allergies = allergies;
        return this;
    }

    public MechanismOfInjuryComms getMechanismOfInjury() {
        return mechanismOfInjury;
    }

    public RestTccc setMechanismOfInjury(MechanismOfInjuryComms mechanismOfInjury) {
        this.mechanismOfInjury = mechanismOfInjury;
        return this;
    }

    public RestInjuryAnnotation getInjuryAnnotation() {
        return injuryAnnotation;
    }

    public RestTccc setInjuryAnnotation(RestInjuryAnnotation injuryAnnotation) {
        this.injuryAnnotation = injuryAnnotation;
        return this;
    }

    public List<SignsSymptoms> getSignsSymptoms() {
        return signsSymptoms;
    }

    public RestTccc setSignsSymptoms(List<SignsSymptoms> signsSymptoms) {
        this.signsSymptoms = signsSymptoms;
        return this;
    }

    public TreatmentCirculatoryTourniquet getTreatmentCirculatoryTourniquet() {
        return treatmentCirculatoryTourniquet;
    }

    public RestTccc setTreatmentCirculatoryTourniquet(TreatmentCirculatoryTourniquet treatmentCirculatoryTourniquet) {
        this.treatmentCirculatoryTourniquet = treatmentCirculatoryTourniquet;
        return this;
    }

    public TreatmentCirculatoryDressing getTreatmentCirculatoryDressing() {
        return treatmentCirculatoryDressing;
    }

    public RestTccc setTreatmentCirculatoryDressing(TreatmentCirculatoryDressing treatmentCirculatoryDressing) {
        this.treatmentCirculatoryDressing = treatmentCirculatoryDressing;
        return this;
    }

    public TreatmentAirway getTreatmentAirway() {
        return treatmentAirway;
    }

    public RestTccc setTreatmentAirway(TreatmentAirway treatmentAirway) {
        this.treatmentAirway = treatmentAirway;
        return this;
    }

    public TreatmentBreathing getTreatmentBreathing() {
        return treatmentBreathing;
    }

    public RestTccc setTreatmentBreathing(TreatmentBreathing treatmentBreathing) {
        this.treatmentBreathing = treatmentBreathing;
        return this;
    }

    public List<TreatmentFluid> getTreatmentFluids() {
        return treatmentFluids;
    }

    public RestTccc setTreatmentFluids(List<TreatmentFluid> treatmentFluids) {
        this.treatmentFluids = treatmentFluids;
        return this;
    }

    public List<TreatmentFluid> getTreatmentBloodProducts() {
        return treatmentBloodProducts;
    }

    public RestTccc setTreatmentBloodProducts(List<TreatmentFluid> treatmentBloodProducts) {
        this.treatmentBloodProducts = treatmentBloodProducts;
        return this;
    }

    public List<TreatmentMedications> getTreatmentMedicationsAnalgesic() {
        return treatmentMedicationsAnalgesic;
    }

    public RestTccc setTreatmentMedicationsAnalgesic(List<TreatmentMedications> treatmentMedicationsAnalgesic) {
        this.treatmentMedicationsAnalgesic = treatmentMedicationsAnalgesic;
        return this;
    }

    public List<TreatmentMedications> getTreatmentMedicationsAntibiotic() {
        return treatmentMedicationsAntibiotic;
    }

    public RestTccc setTreatmentMedicationsAntibiotic(List<TreatmentMedications> treatmentMedicationsAntibiotic) {
        this.treatmentMedicationsAntibiotic = treatmentMedicationsAntibiotic;
        return this;
    }

    public List<TreatmentMedications> getTreatmentMedicationsOther() {
        return treatmentMedicationsOther;
    }

    public RestTccc setTreatmentMedicationsOther(List<TreatmentMedications> treatmentMedicationsOther) {
        this.treatmentMedicationsOther = treatmentMedicationsOther;
        return this;
    }

    public TreatmentOther getTreatmentOther() {
        return treatmentOther;
    }

    public RestTccc setTreatmentOther(TreatmentOther treatmentOther) {
        this.treatmentOther = treatmentOther;
        return this;
    }

    public String getTreatmentNotes() {
        return treatmentNotes;
    }

    public RestTccc setTreatmentNotes(String treatmentNotes) {
        this.treatmentNotes = treatmentNotes;
        return this;
    }

    public Responder getResponder() {
        return responder;
    }

    public RestTccc setResponder(Responder responder) {
        this.responder = responder;
        return this;
    }
}
