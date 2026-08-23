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

import java.util.Optional;
import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.controller.model.*;
import com.ivir.mpif.pcb.*;
import com.ivir.mpif.pcb.BiologicalSex;
import com.ivir.mpif.simdata.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/mms/patient-case")
public class PatientCaseController {
    private static Logger logger = LoggerFactory.getLogger(PatientCaseController.class);

    @Autowired
    private PatientCaseService patientCaseService;

    @PostMapping
    public Object addPatientCase(@RequestBody RestPatientCase patientCase) {
        try {
            logger.debug("POST /mms/patient-case request: {}", patientCase);
            return new ResponseEntity<>(toRest(patientCaseService.add(fromRest(patientCase))), HttpStatus.CREATED);
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }
    }

    @PutMapping
    public Object updatePatientCase(@RequestBody RestPatientCase patientCase) {
        logger.debug("PUT /mms/patient-case request: {}", patientCase);
        patientCaseService.update(fromRest(patientCase));
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @GetMapping("/{caseNum}")
    public Object getPatientCaseByCasNum(@PathVariable Integer caseNum) {
        logger.debug("GET /mms/patient-case/{}", caseNum);
        try {
            Optional<PatientCase> patientCaseOpt = patientCaseService.getByCaseNum(caseNum);
            if(patientCaseOpt.isEmpty()){
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
            return new ResponseEntity<>(toRest(patientCaseOpt.get()),HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }
    }

    @GetMapping("/all")
    public List<RestPatientCase> getAllPatientCases() {
        return patientCaseService.getAll().stream().map(this::toRest).toList();
    }

    @PostMapping("/patient-assignment")
    public Object assignToPatient(@RequestParam("patientId")String patientId, @RequestParam("caseNum") Integer caseNum){
        logger.debug("POST /mms/patient-case/patient-assignment patient:{} case{}", patientId, caseNum);
        try{
            patientCaseService.assignToPatient(caseNum, new PatientId(patientId));
            return new ResponseEntity<>(HttpStatus.CREATED);
        }catch(IllegalArgumentException e){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }
    }

    @GetMapping("/patient-assignment")
    public Object getPatientAssignment(@RequestParam("patientId")String patientId){
        try{
            Optional<PatientCase> patientCaseOpt = patientCaseService.getPatientAssignment(new PatientId(patientId));
            if(patientCaseOpt.isEmpty()){
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
            return new ResponseEntity<RestPatientCase>(toRest(patientCaseOpt.get()), HttpStatus.OK);
        }catch (IllegalArgumentException e){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }
    }

    @DeleteMapping("/{caseNum}")
    public Object deletePatientCase(@PathVariable Integer caseNum){
        Optional<PatientCase> caseOpt = patientCaseService.delete(caseNum);
        if(caseOpt.isEmpty()){
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<RestPatientCase>(toRest(caseOpt.get()),HttpStatus.OK);
    }

    private PatientCase fromRest(RestPatientCase restCase) {
        PatientCase patientCase = new PatientCase();
        patientCase.setCaseNum(restCase.getCaseNum());
        patientCase.setName(restCase.getName());
        patientCase.setBiologicalSex(BiologicalSex.getByName(restCase.getBiologicalSex()));
        patientCase.setVitals(fromRest(restCase.getVitals()));
        ArrayList<PCTreatment> treatments = new ArrayList<>();
        restCase.getPhysicalTreatments().stream().map(this::fromRest).forEach((treatment)->treatments.add(treatment));
        restCase.getMedications().stream().map(this::fromRest).forEach((treatment)->treatments.add(treatment));
        patientCase.setTreatments(treatments);
        patientCase.setInjuries(restCase.getInjuries().stream().map(this::fromRest).toList());
        return patientCase;
    }

    private PCVitals fromRest(RestPCVitals restVitals) {
        if (restVitals == null) {
            return null;
        }
        PCVitals vitals = new PCVitals();
        vitals.setHeartRate(restVitals.getHeartRate());
        vitals.setDiastolicBp(restVitals.getDiastolicBp());
        vitals.setEtco2(restVitals.getEtco2());
        vitals.setTemp(restVitals.getTemp());
        vitals.setSpO2(restVitals.getSpO2());
        vitals.setRespiratoryRate(restVitals.getRespiratoryRate());
        vitals.setSystolicBp(restVitals.getSystolicBp());
        return vitals;
    }

    private PCTreatment fromRest(RestPCPhysicalTreatment restTreatment) {
        if(restTreatment == null){
            return null;
        }
        PCTreatment treatment = new PCTreatment();
        treatment.setTreatmentType(TreatmentClassType.PHYSICAL_TREATMENT);
        treatment.setInjuryName(restTreatment.getInjuryName());
        treatment.setPhysicalTreatment(PhysicalTreatmentType.getByName(restTreatment.getPhysicalTreatment()));
        treatment.setPhysicalDevice(TreatmentDevice.getByName(restTreatment.getPhysicalDevice()));
        return treatment;
    }

    private PCTreatment fromRest(RestPCMedication restTreatment){
        if(restTreatment == null){
            return null;
        }
        PCTreatment treatment = new PCTreatment();
        treatment.setTreatmentType(TreatmentClassType.MEDICATION_TREATMENT);
        treatment.setInjuryName(restTreatment.getInjuryName());
        treatment.setLocation(BodyLocationUtil.fromRest(restTreatment.getLocation()));
        treatment.setMedDosage(restTreatment.getMedDosage());
        treatment.setMedDosageTimePeriod(restTreatment.getMedDosageTimePeriod());
        treatment.setMedication(Medication.getByName(restTreatment.getMedication()));
        treatment.setMedRoute(MedicationAdministrationRoute.getByName(restTreatment.getMedRoute()));
        return treatment;
    }

    private PCInjury fromRest(RestPCInjury restInjury){
        if(restInjury == null){
            return null;
        }
        PCInjury pcInjury = new PCInjury();
        pcInjury.setDescription(InjuryDescription.getByName(restInjury.getDescription()));
        pcInjury.setName(restInjury.getName());
        pcInjury.setDetail(restInjury.getDetail());
        pcInjury.setHemorrhageRate(restInjury.getHemorrhageRate());
        pcInjury.setSeverity(restInjury.getSeverity());
        pcInjury.setLocation(BodyLocationUtil.fromRest(restInjury.getLocation()));
        pcInjury.setTotalBodySurfaceArea(restInjury.getTotalBodySurfaceArea());
        pcInjury.setInjuryType(InjuryType.getByName(restInjury.getInjuryType()));
        pcInjury.setMechanismOfInjury(fromRest(restInjury.getMechanismOfInjury()));
        return pcInjury;
    }

    private MechanismOfInjury fromRest(RestMechanismOfInjury restMoi){
        if(restMoi == null){
            return null;
        }
        MechanismOfInjury mechanismOfInjury = new MechanismOfInjury();
        mechanismOfInjury.setBlade(BladeType.getByName(restMoi.getBlade()));
        mechanismOfInjury.setBlast(BlastType.getByName(restMoi.getBlast()));
        mechanismOfInjury.setCbrn(CbrnType.getByName(restMoi.getCbrn()));
        mechanismOfInjury.setFall(FallType.getByName(restMoi.getFall()));
        mechanismOfInjury.setGunshotAmmunitionType(GunshotAmmunitionType.getByName(restMoi.getGunshotAmmunitionType()));
        mechanismOfInjury.setGunshotCaliber(GunshotCaliber.getByName(restMoi.getGunshotCaliber()));
        mechanismOfInjury.setShrapnel(ShrapnelType.getByName(restMoi.getShrapnel()));
        mechanismOfInjury.setVehicleCrash(VehicleCrash.getByName(restMoi.getVehicleCrash()));
        return mechanismOfInjury;
    }

    private RestPatientCase toRest(PatientCase patientCase){
        RestPatientCase restPatientCase = new RestPatientCase();
        restPatientCase.setCaseNum(patientCase.getCaseNum());
        restPatientCase.setName(patientCase.getName());
        restPatientCase.setBiologicalSex(patientCase.getBiologicalSex() != null ? patientCase.getBiologicalSex().getName() : null);
        restPatientCase.setVitals(toRest(patientCase.getVitals()));
        if(patientCase.getTreatments() != null) {
            restPatientCase.setPhysicalTreatments(patientCase.getTreatments().stream()
                    .filter((treatment) -> treatment.getTreatmentType() == TreatmentClassType.PHYSICAL_TREATMENT)
                    .map(this::toPTRest)
                    .toList());
            restPatientCase.setMedications(patientCase.getTreatments().stream()
                    .filter((treatment) -> treatment.getTreatmentType() == TreatmentClassType.MEDICATION_TREATMENT)
                    .map(this::toMedRest)
                    .toList());
        }
        if(patientCase.getInjuries() != null) {
            restPatientCase.setInjuries(patientCase.getInjuries().stream().map(this::toRest).toList());
        }
        return restPatientCase;
    }

    private RestPCVitals toRest(PCVitals vitals){
        if(vitals == null){
            return null;
        }
        RestPCVitals restVitals = new RestPCVitals();
        restVitals.setDiastolicBp(vitals.getDiastolicBp());
        restVitals.setEtco2(vitals.getEtco2());
        restVitals.setHeartRate(vitals.getHeartRate());
        restVitals.setRespiratoryRate(vitals.getRespiratoryRate());
        restVitals.setSpO2(vitals.getSpO2());
        restVitals.setSystolicBp(vitals.getSystolicBp());
        restVitals.setTemp(vitals.getTemp());
        return restVitals;
    }

    private RestPCPhysicalTreatment toPTRest(PCTreatment treatment){
        if(treatment == null){
            return null;
        }
        RestPCPhysicalTreatment restTreatment = new RestPCPhysicalTreatment();
        restTreatment.setInjuryName(treatment.getInjuryName());
        if(treatment.getPhysicalDevice() != null) {
            restTreatment.setPhysicalDevice(treatment.getPhysicalDevice().getName());
        }
        if(treatment.getPhysicalTreatment() != null){
            restTreatment.setPhysicalTreatment(treatment.getPhysicalTreatment().getName());
        }
        restTreatment.setLocation(BodyLocationUtil.toRest(treatment.getLocation()));
        return restTreatment;
    }

    private RestPCMedication toMedRest(PCTreatment treatment){
        if(treatment == null){
            return null;
        }
        RestPCMedication restMedication = new RestPCMedication();
        restMedication.setInjuryName(treatment.getInjuryName());
        restMedication.setLocation(BodyLocationUtil.toRest(treatment.getLocation()));
        if(treatment.getMedication() != null) {
            restMedication.setMedication(treatment.getMedication().getName());
        }
        if(treatment.getMedRoute() != null) {
            restMedication.setMedRoute(treatment.getMedRoute().getName());
        }
        restMedication.setMedDosage(treatment.getMedDosage());
        restMedication.setMedDosageTimePeriod(treatment.getMedDosageTimePeriod());
        return restMedication;
    }

    private RestPCInjury toRest(PCInjury injury){
        if(injury == null){
            return null;
        }
        RestPCInjury restInjury = new RestPCInjury();
        if(injury.getDescription() != null){
            restInjury.setDescription(injury.getDescription().getName());
        }
        restInjury.setDetail(injury.getDetail());
        restInjury.setHemorrhageRate(injury.getHemorrhageRate());
        if(injury.getInjuryType() != null){
            restInjury.setInjuryType(injury.getInjuryType().getName());
        }
        restInjury.setLocation(BodyLocationUtil.toRest(injury.getLocation()));
        restInjury.setMechanismOfInjury(toRest(injury.getMechanismOfInjury()));
        restInjury.setName(injury.getName());
        restInjury.setSeverity(injury.getSeverity());
        restInjury.setTotalBodySurfaceArea(injury.getTotalBodySurfaceArea());
        return restInjury;
    }

    private RestMechanismOfInjury toRest(MechanismOfInjury moi){
        if(moi == null){
            return null;
        }
        RestMechanismOfInjury restMoi = new RestMechanismOfInjury();
        if(moi.getBlade() != null){
            restMoi.setBlade(moi.getBlade().getName());
        }
        if(moi.getBlast() != null){
            restMoi.setBlast(moi.getBlast().getName());
        }
        if(moi.getCbrn() != null) {
            restMoi.setCbrn(moi.getCbrn().getName());
        }
        if(moi.getFall() != null) {
            restMoi.setFall(moi.getFall().getName());
        }
        if(moi.getGunshotAmmunitionType() != null) {
            restMoi.setGunshotAmmunitionType(moi.getGunshotAmmunitionType().getName());
        }
        if(moi.getGunshotCaliber() != null) {
            restMoi.setGunshotCaliber(moi.getGunshotCaliber().getName());
        }
        if(moi.getShrapnel() != null) {
            restMoi.setShrapnel(moi.getShrapnel().getName());
        }
        if(moi.getVehicleCrash() != null) {
            restMoi.setVehicleCrash(moi.getVehicleCrash().getName());
        }
        return restMoi;
    }


}
