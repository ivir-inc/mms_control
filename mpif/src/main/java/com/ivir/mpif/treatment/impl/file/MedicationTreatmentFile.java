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

package com.ivir.mpif.treatment.impl.file;

import com.ivir.mpif.simdata.BodyLocationCoarse;

public class MedicationTreatmentFile {
    private String treatmentName = null;
    private BodyLocationCoarse location = null;
    private String medication = null;
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

    public String getTreatmentName() {
        return treatmentName;
    }

    public void setTreatmentName(String treatmentName) {
        this.treatmentName = treatmentName;
    }

    public BodyLocationCoarse getLocation() {
        return location;
    }

    public void setLocation(BodyLocationCoarse location) {
        this.location = location;
    }

    public String getMedication() {
        return medication;
    }

    public void setMedication(String medication) {
        this.medication = medication;
    }

    public String getRoute() {
        return route;
    }

    public void setRoute(String route) {
        this.route = route;
    }

    public Float getDosageUnderVal() {
        return dosageUnderVal;
    }

    public void setDosageUnderVal(Float dosageUnderVal) {
        this.dosageUnderVal = dosageUnderVal;
    }

    public Float getDosageOverVal() {
        return dosageOverVal;
    }

    public void setDosageOverVal(Float dosageOverVal) {
        this.dosageOverVal = dosageOverVal;
    }

    public Float getDosageCorrectVal() {
        return dosageCorrectVal;
    }

    public void setDosageCorrectVal(Float dosageCorrectVal) {
        this.dosageCorrectVal = dosageCorrectVal;
    }

    public Integer getTimePeriod() {
        return timePeriod;
    }

    public void setTimePeriod(Integer timePeriod) {
        this.timePeriod = timePeriod;
    }

    public Boolean getAnalgesics() {
        return analgesics;
    }

    public void setAnalgesics(Boolean analgesics) {
        this.analgesics = analgesics;
    }

    public Boolean getAnaphylaxisTreatment() {
        return anaphylaxisTreatment;
    }

    public void setAnaphylaxisTreatment(Boolean anaphylaxisTreatment) {
        this.anaphylaxisTreatment = anaphylaxisTreatment;
    }

    public Boolean getAntiEmetics() {
        return antiEmetics;
    }

    public void setAntiEmetics(Boolean antiEmetics) {
        this.antiEmetics = antiEmetics;
    }

    public Boolean getBloodProducts() {
        return bloodProducts;
    }

    public void setBloodProducts(Boolean bloodProducts) {
        this.bloodProducts = bloodProducts;
    }

    public String getCardiacMedication() {
        return cardiacMedication;
    }

    public void setCardiacMedication(String cardiacMedication) {
        this.cardiacMedication = cardiacMedication;
    }

    public Boolean getCbrneTreatment() {
        return cbrneTreatment;
    }

    public void setCbrneTreatment(Boolean cbrneTreatment) {
        this.cbrneTreatment = cbrneTreatment;
    }

    public String getClottingMedication() {
        return clottingMedication;
    }

    public void setClottingMedication(String clottingMedication) {
        this.clottingMedication = clottingMedication;
    }

    public String getFluidMedication() {
        return fluidMedication;
    }

    public void setFluidMedication(String fluidMedication) {
        this.fluidMedication = fluidMedication;
    }

    public Boolean getHypoglycemiaTreatment() {
        return hypoglycemiaTreatment;
    }

    public void setHypoglycemiaTreatment(Boolean hypoglycemiaTreatment) {
        this.hypoglycemiaTreatment = hypoglycemiaTreatment;
    }

    public String getInfectionMedication() {
        return infectionMedication;
    }

    public void setInfectionMedication(String infectionMedication) {
        this.infectionMedication = infectionMedication;
    }

    public Boolean getNutrition() {
        return nutrition;
    }

    public void setNutrition(Boolean nutrition) {
        this.nutrition = nutrition;
    }

    public Boolean getOverdoseTreatment() {
        return overdoseTreatment;
    }

    public void setOverdoseTreatment(Boolean overdoseTreatment) {
        this.overdoseTreatment = overdoseTreatment;
    }

    public Boolean getParalytics() {
        return paralytics;
    }

    public void setParalytics(Boolean paralytics) {
        this.paralytics = paralytics;
    }

    public Boolean getPressers() {
        return pressers;
    }

    public void setPressers(Boolean pressers) {
        this.pressers = pressers;
    }

    public Boolean getRespiratoryTreatment() {
        return respiratoryTreatment;
    }

    public void setRespiratoryTreatment(Boolean respiratoryTreatment) {
        this.respiratoryTreatment = respiratoryTreatment;
    }

    public Boolean getSedation() {
        return sedation;
    }

    public void setSedation(Boolean sedation) {
        this.sedation = sedation;
    }

    public Boolean getSeizureTreatment() {
        return seizureTreatment;
    }

    public void setSeizureTreatment(Boolean seizureTreatment) {
        this.seizureTreatment = seizureTreatment;
    }
}
