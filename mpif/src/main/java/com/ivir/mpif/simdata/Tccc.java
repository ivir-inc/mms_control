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

import java.io.Serial;

public class Tccc extends ConcurrentSimData<Tccc.Attributes>{
    @Serial
    private static final long serialVersionUID = -3303248114157364353L;

    public enum Attributes{
        ID,
        LOCAL_BOOL,
        INSTANCE_NAME_STR,
        PATIENT_ID_STR,
        BATTLE_ROSTER_NUMBER_STR,
        EVACUATION_LEVEL_REQUEST_ENUM,
        LAST_NAME_STR,
        FIRST_NAME_STR,
        SOCIAL_SECURITY_ACCOUNT_NUMBER_STR,
        GENDER_ENUM,
        DATE_STR,
        TIME_STR,
        SERVICE_STR,
        UNIT_STR,
        ALLERGIES_STR,
        MECHANISM_OF_INJURY_OBJ,
        INJURY_ANNOTATION_OBJ,
        SIGNS_SYMPTOMS_OBJ,
        TREATMENT_CIRCULATORY_TOURNIQUET_OBJ,
        TREATMENT_CIRCULATORY_DRESSING_OBJ,
        TREATMENT_AIRWAY_OBJ,
        TREATMENT_BREATHING_OBJ,
        TREATMENT_FLUIDS_OBJ,
        TREATMENT_BLOOD_PRODUCTS_OBJ,
        TREATMENT_MEDICATIONS_ANALGESIC_OBJ,
        TREATMENT_MEDICATIONS_ANTIBIOTIC_OBJ,
        TREATMENT_MEDICATIONS_OTHER_OBJ,
        TREATMENT_OTHER_OBJ,
        TREATMENT_NOTES_STR,
        RESPONDER_OBJ
    }

    public Tccc(){
        super(Tccc.Attributes.class, Attributes.ID, true);
    }

    public String getId(){
        return getIndex();
    }

    public Boolean isLocal(){
        return getValue(Attributes.LOCAL_BOOL,Boolean.class);
    }

    public Tccc setLocal(Boolean local){
        setValue(Attributes.LOCAL_BOOL, local);
        return this;
    }

    public String getInstanceName(){
        return getValue(Attributes.INSTANCE_NAME_STR, String.class);
    }

    public Tccc setInstanceName(String instanceName){
        setValue(Attributes.INSTANCE_NAME_STR, instanceName);
        return this;
    }

    public String getPatientId(){
        return getValue(Attributes.PATIENT_ID_STR, String.class);
    }

    public Tccc setPatientId(String patientId){
        setValue(Attributes.PATIENT_ID_STR, patientId);
        return this;
    }

    public String getBattleRosterNumber(){
        return getValue(Attributes.BATTLE_ROSTER_NUMBER_STR, String.class);
    }

    public Tccc setBattleRosterNumber(String battleRosterNumber){
        setValue(Attributes.BATTLE_ROSTER_NUMBER_STR, battleRosterNumber);
        return this;
    }

    public EvacuationCategory getEvacuationLevelRequest(){
        return getValue(Attributes.EVACUATION_LEVEL_REQUEST_ENUM, EvacuationCategory.class);
    }

    public Tccc setEvacuationLevelRequest(EvacuationCategory evacuationLevelRequest){
        setValue(Attributes.EVACUATION_LEVEL_REQUEST_ENUM, evacuationLevelRequest);
        return this;
    }

    public String getLastName() {
        return getValue(Attributes.LAST_NAME_STR, String.class);
    }

    public Tccc setLastName(String lastName){
        setValue(Attributes.LAST_NAME_STR, lastName);
        return this;
    }

    public String getFirstName(){
        return getValue(Attributes.FIRST_NAME_STR, String.class);
    }

    public Tccc setFirstName(String firstName){
        setValue(Attributes.FIRST_NAME_STR, firstName);
        return this;
    }

    public String getSocialSecurityAccountNumber(){
        return getValue(Attributes.SOCIAL_SECURITY_ACCOUNT_NUMBER_STR, String.class);
    }

    public Tccc setSocialSecurityAccountNumber(String ssn){
        setValue(Attributes.SOCIAL_SECURITY_ACCOUNT_NUMBER_STR, ssn);
        return this;
    }

    public Gender getGender() {
        return getValue(Attributes.GENDER_ENUM, Gender.class);
    }

    public Tccc setGender(Gender gender){
        setValue(Attributes.GENDER_ENUM, gender);
        return this;
    }

    public String getDate(){
        return getValue(Attributes.DATE_STR, String.class);
    }

    public Tccc setDate(String date){
        setValue(Attributes.DATE_STR, date);
        return this;
    }

    public String getTime(){
        return getValue(Attributes.TIME_STR, String.class);
    }

    public Tccc setTime(String time){
        setValue(Attributes.TIME_STR, time);
        return this;
    }

    public String getService(){
        return getValue(Attributes.SERVICE_STR, String.class);
    }

    public Tccc setService(String service){
        setValue(Attributes.SERVICE_STR, service);
        return this;
    }

    public String getUnit(){
        return getValue(Attributes.UNIT_STR, String.class);
    }

    public Tccc setUnit(String unit){
        setValue(Attributes.UNIT_STR, unit);
        return this;
    }

    public String getAllergies(){
        return getValue(Attributes.ALLERGIES_STR, String.class);
    }

    public Tccc setAllergies(String allergies){
        setValue(Attributes.ALLERGIES_STR, allergies);
        return this;
    }

    public MechanismOfInjuryComms getMechanismOfInjury(){
        return getValue(Attributes.MECHANISM_OF_INJURY_OBJ, MechanismOfInjuryComms.class);
    }

    public Tccc setMechanismOfInjury(MechanismOfInjuryComms moi) {
        setValue(Attributes.MECHANISM_OF_INJURY_OBJ, moi);
        return this;
    }

    public InjuryAnnotation getInjuryAnnotation(){
        return getValue(Attributes.INJURY_ANNOTATION_OBJ, InjuryAnnotation.class);
    }

    public Tccc setInjuryAnnotation(InjuryAnnotation injuryAnnotation) {
        setValue(Attributes.INJURY_ANNOTATION_OBJ, injuryAnnotation);
        return this;
    }

    public ComparableList<SignsSymptoms> getSignsSymptoms(){
        return (ComparableList<SignsSymptoms>) getValue(Attributes.SIGNS_SYMPTOMS_OBJ);
    }

    public Tccc setSignsSymptoms(ComparableList<SignsSymptoms> signsSymptoms) {
        setValue(Attributes.SIGNS_SYMPTOMS_OBJ, signsSymptoms);
        return this;
    }

    public TreatmentCirculatoryTourniquet getTreatmentCirculatoryTourniquet(){
        return getValue(Attributes.TREATMENT_CIRCULATORY_TOURNIQUET_OBJ, TreatmentCirculatoryTourniquet.class);
    }

    public Tccc setTreatmentCirculatoryTourniquet(TreatmentCirculatoryTourniquet treatment) {
        setValue(Attributes.TREATMENT_CIRCULATORY_TOURNIQUET_OBJ, treatment);
        return this;
    }

    public TreatmentCirculatoryDressing getTreatmentCirculatoryDressing(){
        return getValue(Attributes.TREATMENT_CIRCULATORY_DRESSING_OBJ, TreatmentCirculatoryDressing.class);
    }

    public Tccc setTreatmentCirculatoryDressing(TreatmentCirculatoryDressing treatment) {
        setValue(Attributes.TREATMENT_CIRCULATORY_DRESSING_OBJ, treatment);
        return this;
    }

    public TreatmentAirway getTreatmentAirway(){
        return getValue(Attributes.TREATMENT_AIRWAY_OBJ, TreatmentAirway.class);
    }

    public Tccc setTreatmentAirway(TreatmentAirway treatment) {
        setValue(Attributes.TREATMENT_AIRWAY_OBJ, treatment);
        return this;
    }

    public TreatmentBreathing getTreatmentBreathing(){
        return getValue(Attributes.TREATMENT_BREATHING_OBJ, TreatmentBreathing.class);
    }

    public Tccc setTreatmentBreathing(TreatmentBreathing treatment) {
        setValue(Attributes.TREATMENT_BREATHING_OBJ, treatment);
        return this;
    }

    public ComparableList<TreatmentFluid> getTreatmentFluids(){
        return (ComparableList<TreatmentFluid>) getValue(Attributes.TREATMENT_FLUIDS_OBJ);
    }

    public Tccc setTreatmentFluids(ComparableList<TreatmentFluid> treatmentFluids) {
        setValue(Attributes.TREATMENT_FLUIDS_OBJ, treatmentFluids);
        return this;
    }

    public ComparableList<TreatmentFluid> getTreatmentBloodProducts(){
        return (ComparableList<TreatmentFluid>) getValue(Attributes.TREATMENT_BLOOD_PRODUCTS_OBJ);
    }

    public Tccc setTreatmentBloodProducts(ComparableList<TreatmentFluid> treatmentBloodProducts) {
        setValue(Attributes.TREATMENT_BLOOD_PRODUCTS_OBJ, treatmentBloodProducts);
        return this;
    }

    public ComparableList<TreatmentMedications> getTreatmentMedicationsAnalgesic(){
        return (ComparableList<TreatmentMedications>) getValue(Attributes.TREATMENT_MEDICATIONS_ANALGESIC_OBJ);
    }

    public Tccc setTreatmentMedicationsAnalgesic(ComparableList<TreatmentMedications> treatmentMedications) {
        setValue(Attributes.TREATMENT_MEDICATIONS_ANALGESIC_OBJ, treatmentMedications);
        return this;
    }

    public ComparableList<TreatmentMedications> getTreatmentMedicationsAntibiotic(){
        return (ComparableList<TreatmentMedications>) getValue(Attributes.TREATMENT_MEDICATIONS_ANTIBIOTIC_OBJ);
    }

    public Tccc setTreatmentMedicationsAntibiotic(ComparableList<TreatmentMedications> treatmentMedications) {
        setValue(Attributes.TREATMENT_MEDICATIONS_ANTIBIOTIC_OBJ, treatmentMedications);
        return this;
    }

    public ComparableList<TreatmentMedications> getTreatmentMedicationsOther(){
        return (ComparableList<TreatmentMedications>) getValue(Attributes.TREATMENT_MEDICATIONS_OTHER_OBJ);
    }

    public Tccc setTreatmentMedicationsOther(ComparableList<TreatmentMedications> treatmentMedications) {
        setValue(Attributes.TREATMENT_MEDICATIONS_OTHER_OBJ, treatmentMedications);
        return this;
    }

    public TreatmentOther getTreatmentOther(){
        return getValue(Attributes.TREATMENT_OTHER_OBJ, TreatmentOther.class);
    }

    public Tccc setTreatmentOther(TreatmentOther treatment) {
        setValue(Attributes.TREATMENT_OTHER_OBJ, treatment);
        return this;
    }

    public String getTreatmentNotes(){
        return getValue(Attributes.TREATMENT_NOTES_STR, String.class);
    }

    public Tccc setTreatmentNotes(String treatmentNotes){
        setValue(Attributes.TREATMENT_NOTES_STR, treatmentNotes);
        return this;
    }

    public Responder getResponder(){
        return getValue(Attributes.RESPONDER_OBJ, Responder.class);
    }

    public Tccc setResponder(Responder responder){
        setValue(Attributes.RESPONDER_OBJ, responder);
        return this;
    }
}
