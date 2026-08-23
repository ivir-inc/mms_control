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

package com.ivir.mpif.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.ivir.mpif.controller.model.*;
import com.ivir.mpif.simdata.Medication;
import com.ivir.mpif.simdata.MedicationAdministrationRoute;
import com.ivir.mpif.simdata.PhysicalTreatmentType;
import com.ivir.mpif.simdata.TreatmentDevice;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.treatment.TreatmentService;
import com.ivir.mpif.treatment.data.Scenario;
import com.ivir.mpif.treatment.data.TreatmentLayout;
import com.ivir.mpif.treatment.data.TreatmentLayout.Column;
import com.ivir.mpif.treatment.data.TreatmentLayout.Panel;

@RestController
public class TreatmentController {
    private TreatmentService treatmentService;

    public TreatmentController(TreatmentService treatmentService){
        this.treatmentService = treatmentService;
    }

    @GetMapping("/mms/treatment/scenarios")
    public List<RestScenario> getScenarios(){
        TreatmentLayout treatmentLayout = treatmentService.getTreatmentLayout();
        ArrayList<RestScenario> restScenarios = new ArrayList<>();
        for(Scenario scen : treatmentService.getAllScenarios()){
            restScenarios.add(restScenarioToLayout(treatmentLayout, scen));
        }
        return restScenarios;
    }

    @GetMapping("/mms/treatment/scenarios/active")
    public Object getActiveScenarioByPatientId(@RequestParam(name = "patientId") String patientId){
        Optional<Scenario> scenario = treatmentService.getActiveScenarioByPatientId(new PatientId(patientId));
        if(scenario.isEmpty()){
            return new ResponseEntity<Void>(HttpStatus.NO_CONTENT);
        }
        return new ResponseEntity<>(restScenarioToLayout(treatmentService.getTreatmentLayout(),scenario.get()), HttpStatus.OK);
    }

    @PostMapping("/mms/treatment/scenarios/active")
    public Object setActiveScenarioId(@RequestParam(name="patientId") String patientId,
                                      @RequestParam(name="activeScenarioId") Integer scenarioId){
        Integer idToUse = null;
        if(scenarioId < -1){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Scenario ID must be -1 or greater");
        }else if(scenarioId > -1){
           idToUse = scenarioId;
        }
        if(treatmentService.setActiveScenario(new PatientId(patientId), idToUse)){
            return new ResponseEntity<>(HttpStatus.CREATED);
        }
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @GetMapping("/mms/treatment/layout")
    public RestLayout getLayout() {
        return toRestLayout(treatmentService.getTreatmentLayout());
    }

    @PutMapping("/mms/treatment/layout")
    public Object saveLayout(@RequestBody RestLayout restLayout) {
        this.treatmentService.updateTreatmentLayout(toTreatmentLayout(restLayout));
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PutMapping("/mms/treatment/layout/reset")
    public Object resetLayout() {
        return toRestLayout(treatmentService.resetTreatmentLayout());
    }

    @PostMapping("/mms/treatment/medication")
    public Object applyMedicationTreatment(@RequestBody SendMedicationTreatment treatmentDetails){
        try {
            treatmentService.addMedicationTreatment(
                    new PatientId(treatmentDetails.getPatientId()),
                    treatmentDetails.getInjuryId(),
                    Medication.getByName(treatmentDetails.getMedication()),
                    MedicationAdministrationRoute.getByName(treatmentDetails.getAdministrationRoute()),
                    treatmentDetails.getDosageValue(),
                    treatmentDetails.getDosageTimePeriod());
        }catch(Exception e){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,e.getMessage());
        }
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @PostMapping("/mms/treatment/physical")
    public Object applyPhysicalTreatment(@RequestBody SendPhysicalTreatment treatmentDetails){
        try {
            treatmentService.addPhysicalTreatment(
                    new PatientId(treatmentDetails.getPatientId()),
                    PhysicalTreatmentType.getByName(treatmentDetails.getTreatment()),
                    treatmentDetails.getInjuryId(),
                    TreatmentDevice.getByName(treatmentDetails.getDeviceUsed()),
                    BodyLocationUtil.fromRest(treatmentDetails.getTreatmentLocation()));
        }catch (Exception e){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,e.getMessage());
        }
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    private static RestLayout toRestLayout(TreatmentLayout treatmentLayout) {
        return new RestLayout()
                .setTreatments(panelsToCategories(treatmentLayout.getTreatmentPanels()))
                .setMedications(panelsToCategories(treatmentLayout.getMedicationPanels()));
    }

    private static List<RestCategory> panelsToCategories(ArrayList<Panel> panels) {
        List<RestCategory> categories = new ArrayList<>();
        for (Panel panel : panels) {
            List<RestColumn> restColumns = new ArrayList<>();
            for (Column column : panel.getColumns()) {
                restColumns.add(new RestColumn()
                        .setName(column.getColumnName())
                        .setTreatments(new ArrayList<>(column.getTreatments())));
            }
            categories.add(new RestCategory()
                    .setName(panel.getPanelName())
                    .setColumns(restColumns));
        }
        return categories;
    }

    private static TreatmentLayout toTreatmentLayout(RestLayout restLayout) {
        TreatmentLayout layout = TreatmentLayout.builder();
        for (RestCategory category : restLayout.getTreatments()) {
            populatePanel(layout.treatmentPanel(category.getName()), category);
        }
        for (RestCategory category : restLayout.getMedications()) {
            populatePanel(layout.medicationPanel(category.getName()), category);
        }
        return layout;
    }

    private static void populatePanel(Panel panel, RestCategory category) {
        int colIndex = 0;
        for (RestColumn restColumn : category.getColumns()) {
            Column column = panel.column(colIndex++).columnName(restColumn.getName());
            for (String treatment : restColumn.getTreatments()) {
                column.addTreatment(treatment);
            }
        }
    }

    private static RestScenario restScenarioToLayout(TreatmentLayout layout, Scenario scenario){
        RestScenario restScenario = new RestScenario();
        restScenario.setId(scenario.getId());
        restScenario.setScenarioName(scenario.getName());

        //Physical Treatments
        for(Panel panel : layout.getTreatmentPanels()){
            RestTreatmentType treatmentType = new RestTreatmentType();
            restScenario.getSpecs().getTreatments().add(treatmentType);
            treatmentType.setType(panel.getPanelName());
            for(Column column : panel.getColumns()){
                RestTreatmentSubtype subtype = new RestTreatmentSubtype();
                treatmentType.getDetails().add(subtype);
                subtype.setSubType(column.getColumnName());
                for(String treatment : column.getTreatments()){
                    RestPhysicalTreatmentDetailSpecific treatmentDetail = new RestPhysicalTreatmentDetailSpecific();
                    treatmentDetail.setName(treatment);
                    subtype.getSpecifics().add(treatmentDetail);
                    ArrayList<String> injuryList = scenario.getInjuryByTreatment().get(treatment);
                    if(injuryList != null){
                        for(String injury : injuryList){
                            treatmentDetail.getInjuries().add(injury);
                        }
                    }
                }
            }
        }

        //Medication Treatments
        for(Panel panel : layout.getMedicationPanels()){
            RestTreatmentType treatmentType = new RestTreatmentType();
            restScenario.getSpecs().getMedication().add(treatmentType);
            treatmentType.setType(panel.getPanelName());
            for(Column column : panel.getColumns()){
                RestTreatmentSubtype subtype = new RestTreatmentSubtype();
                treatmentType.getDetails().add(subtype);
                subtype.setSubType(column.getColumnName());
                for(String treatment : column.getTreatments()){
                    RestMedicationDetailSpecific treatmentDetail = new RestMedicationDetailSpecific();
                    treatmentDetail.setName(treatment);
                    subtype.getSpecifics().add(treatmentDetail);
                    if(scenario.getMedicationTreatmentByName(treatment) != null){
                        treatmentDetail.setAllowed(true);
                    }
                }
            }
        }
        return restScenario;
    }
}
