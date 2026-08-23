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

import com.ivir.mpif.simdata.BodyLocationCoarse;

/**
 *
 * @author lewanw
 */
public class MedicationTreatmentDetail {
    private String treatmentName = null;
    private BodyLocationCoarse location = null;
    private String medicationName = null;
    private String route = null;
    private Float dosageUnderVal = null;
    private Float dosageOverVal = null;
    private Float dosageCorrectVal = null;
    private Integer timePeriod = null;
    private Boolean analgesics = null;
    private Boolean anaphylaxisTreatment = null;
    private Boolean antiEmetics = null;
    private Boolean bloodProducts = null;
    private String cardiacMedication = null;
    private Boolean cbrneTreatment = null;
    private String clottingMedication = null;
    private String fluidMedication = null;
    private Boolean hypoglycemiaTreatment = null;
    private String infectionMedication = null;
    private Boolean nutrition = null;
    private Boolean overdoseTreatment = null;
    private Boolean paralytics = null;
    private Boolean pressers = null;
    private Boolean respiratoryTreatment = null;
    private Boolean sedation = null;
    private Boolean seizureTreatment = null;

    public MedicationTreatmentDetail(String treatmentName){
        this.treatmentName = treatmentName;
    }

    public String getTreatmentName() {
        return treatmentName;
    }

    public MedicationTreatmentDetail setTreatmentName(String treatmentName) {
        this.treatmentName = treatmentName;
        return this;
    }

    public BodyLocationCoarse getLocation() {
        return location;
    }

    public MedicationTreatmentDetail setLocation(BodyLocationCoarse location) {
        this.location = location;
        return this;
    }

    public String getMedicationName() {
        return medicationName;
    }

    public MedicationTreatmentDetail setMedicationName(String medicationName) {
        this.medicationName = medicationName;
        return this;
    }

    public String getRoute() {
        return route;
    }

    public MedicationTreatmentDetail setRoute(String route) {
        this.route = route;
        return this;
    }

    public Float getOverDosage() {
        return this.dosageOverVal;
    }

    public MedicationTreatmentDetail setOverDosage(Float dosage) {
        this.dosageOverVal = dosage;
        return this;
    }

    public Float getUnderDosage() {
        return this.dosageUnderVal;
    }

    public MedicationTreatmentDetail setUnderDosage(Float dosage) {
        this.dosageUnderVal = dosage;
        return this;
    }
    
    public Float getCorrectDosage() {
        return this.dosageCorrectVal;
    }

    public MedicationTreatmentDetail setCorrectDosage(Float dosage) {
        this.dosageCorrectVal = dosage;
        return this;
    }
    
    public Integer getTimePeriod() {
        return timePeriod;
    }

    public MedicationTreatmentDetail setTimePeriod(Integer timePeriod) {
        this.timePeriod = timePeriod;
        return this;
    }

    public Float getDosageUnderVal() {
        return dosageUnderVal;
    }

    public MedicationTreatmentDetail setDosageUnderVal(Float dosageUnderVal) {
        this.dosageUnderVal = dosageUnderVal;
        return this;
    }

    public Float getDosageOverVal() {
        return dosageOverVal;
    }

    public MedicationTreatmentDetail setDosageOverVal(Float dosageOverVal) {
        this.dosageOverVal = dosageOverVal;
        return this;
    }

    public Float getDosageCorrectVal() {
        return dosageCorrectVal;
    }

    public MedicationTreatmentDetail setDosageCorrectVal(Float dosageCorrectVal) {
        this.dosageCorrectVal = dosageCorrectVal;
        return this;
    }

    public Boolean getAnalgesics() {
        return analgesics;
    }

    public MedicationTreatmentDetail setAnalgesics(Boolean analgesics) {
        this.analgesics = analgesics;
        return this;
    }

    public Boolean getAnaphylaxisTreatment() {
        return anaphylaxisTreatment;
    }

    public MedicationTreatmentDetail setAnaphylaxisTreatment(Boolean anaphylaxisTreatment) {
        this.anaphylaxisTreatment = anaphylaxisTreatment;
        return this;
    }

    public Boolean getAntiEmetics() {
        return antiEmetics;
    }

    public MedicationTreatmentDetail setAntiEmetics(Boolean antiEmetics) {
        this.antiEmetics = antiEmetics;
        return this;
    }

    public Boolean getBloodProducts() {
        return bloodProducts;
    }

    public MedicationTreatmentDetail setBloodProducts(Boolean bloodProducts) {
        this.bloodProducts = bloodProducts;
        return this;
    }

    public String getCardiacMedication() {
        return cardiacMedication;
    }

    public MedicationTreatmentDetail setCardiacMedication(String cardiacMedication) {
        this.cardiacMedication = cardiacMedication;
        return this;
    }

    public Boolean getCbrneTreatment() {
        return cbrneTreatment;
    }

    public MedicationTreatmentDetail setCbrneTreatment(Boolean cbrneTreatment) {
        this.cbrneTreatment = cbrneTreatment;
        return this;
    }

    public String getClottingMedication() {
        return clottingMedication;
    }

    public MedicationTreatmentDetail setClottingMedication(String clottingMedication) {
        this.clottingMedication = clottingMedication;
        return this;
    }

    public String getFluidMedication() {
        return fluidMedication;
    }

    public MedicationTreatmentDetail setFluidMedication(String fluidMedication) {
        this.fluidMedication = fluidMedication;
        return this;
    }

    public Boolean getHypoglycemiaTreatment() {
        return hypoglycemiaTreatment;
    }

    public MedicationTreatmentDetail setHypoglycemiaTreatment(Boolean hypoglycemiaTreatment) {
        this.hypoglycemiaTreatment = hypoglycemiaTreatment;
        return this;
    }

    public String getInfectionMedication() {
        return infectionMedication;
    }

    public MedicationTreatmentDetail setInfectionMedication(String infectionMedication) {
        this.infectionMedication = infectionMedication;
        return this;
    }

    public Boolean getNutrition() {
        return nutrition;
    }

    public MedicationTreatmentDetail setNutrition(Boolean nutrition) {
        this.nutrition = nutrition;
        return this;
    }

    public Boolean getOverdoseTreatment() {
        return overdoseTreatment;
    }

    public MedicationTreatmentDetail setOverdoseTreatment(Boolean overdoseTreatment) {
        this.overdoseTreatment = overdoseTreatment;
        return this;
    }

    public Boolean getParalytics() {
        return paralytics;
    }

    public MedicationTreatmentDetail setParalytics(Boolean paralytics) {
        this.paralytics = paralytics;
        return this;
    }

    public Boolean getPressers() {
        return pressers;
    }

    public MedicationTreatmentDetail setPressers(Boolean pressers) {
        this.pressers = pressers;
        return this;
    }

    public Boolean getRespiratoryTreatment() {
        return respiratoryTreatment;
    }

    public MedicationTreatmentDetail setRespiratoryTreatment(Boolean respiratoryTreatment) {
        this.respiratoryTreatment = respiratoryTreatment;
        return this;
    }

    public Boolean getSedation() {
        return sedation;
    }

    public MedicationTreatmentDetail setSedation(Boolean sedation) {
        this.sedation = sedation;
        return this;
    }

    public Boolean getSeizureTreatment() {
        return seizureTreatment;
    }

    public MedicationTreatmentDetail setSeizureTreatment(Boolean seizureTreatment) {
        this.seizureTreatment = seizureTreatment;
        return this;
    }

    @Override
    public String toString() {
        return "MedicationTreatmentDetail{" +
                "treatmentName='" + treatmentName + '\'' +
                ", location=" + location +
                ", medicationName='" + medicationName + '\'' +
                ", route='" + route + '\'' +
                ", dosageUnderVal=" + dosageUnderVal +
                ", dosageOverVal=" + dosageOverVal +
                ", dosageCorrectVal=" + dosageCorrectVal +
                ", timePeriod=" + timePeriod +
                ", analgesics=" + analgesics +
                ", anaphylaxisTreatment=" + anaphylaxisTreatment +
                ", antiEmetics=" + antiEmetics +
                ", bloodProducts=" + bloodProducts +
                ", cardiacMedication='" + cardiacMedication + '\'' +
                ", cbrneTreatment=" + cbrneTreatment +
                ", clottingMedication='" + clottingMedication + '\'' +
                ", fluidMedication='" + fluidMedication + '\'' +
                ", hypoglycemiaTreatment=" + hypoglycemiaTreatment +
                ", infectionMedication='" + infectionMedication + '\'' +
                ", nutrition=" + nutrition +
                ", overdoseTreatment=" + overdoseTreatment +
                ", paralytics=" + paralytics +
                ", pressers=" + pressers +
                ", respiratoryTreatment=" + respiratoryTreatment +
                ", sedation=" + sedation +
                ", seizureTreatment=" + seizureTreatment +
                '}';
    }
}
