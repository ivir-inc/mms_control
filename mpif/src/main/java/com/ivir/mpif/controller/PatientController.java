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

import com.ivir.mpif.controller.model.BasicDeleteReturn;
import com.ivir.mpif.controller.model.RestPatient;
import com.ivir.mpif.db.EntityExistsException;
import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.NoSuchElementException;

@RestController
public class PatientController {
    @Autowired
    PatientService patientService;

    @GetMapping("/mms/patientList")
    public List<RestPatient> getPatients() {
        return patientService.getPatients().stream().map((pe)->new RestPatient(pe)).toList();
    }

    @PutMapping(path="/mms/patientList",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE)
    public RestPatient updatePatient(@RequestBody RestPatient patient){
        validatePatientInput(patient);
        try {
            Patient updatedPatient = patientService.updatePatient(patient.getId(), patient.getMonitorPatient(),
                    patient.getPhysiologySource(), null, patient.getPatientCaseNum());
            patientService.savePatients();
            return new RestPatient(updatedPatient);
        }catch (NoSuchElementException noSuchElementEx){
           throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Patient does not exist");
        }
    }

    @PostMapping(path="/mms/patientList",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public RestPatient createPatient(@RequestBody RestPatient patient){
        validatePatientInput(patient);
        try {
            Patient newPatient = patientService.addPatient(patient.getId(), patient.getMonitorPatient(), patient.getPhysiologySource(), patient.getSourceLocked());
            patientService.savePatients();
            return new RestPatient(newPatient);
        }catch ( EntityExistsException ex){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Patient with that ID already exists");
        }
    }

    private void validatePatientInput(RestPatient newPatient){
       if(newPatient == null){
           throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You must include patient");
       }
       if((newPatient.getId() == null) || newPatient.getId().isEmpty()){
           throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "The field patientId cannot be null or empty");
       }
    }

    @DeleteMapping(path="/mms/patientList/patient/{patientId}",
    produces = MediaType.APPLICATION_JSON_VALUE)
    public BasicDeleteReturn deletePatients(@PathVariable String patientId){
        BasicDeleteReturn basicDeleteReturn = new BasicDeleteReturn();
        if((patientId == null)||patientId.isEmpty()){
           throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You must include at least one Patient ID");
        }
        if(patientService.deletePatient(patientId)) {
            patientService.savePatients();
           return new BasicDeleteReturn(1,null);
        } else{
            return new BasicDeleteReturn(0, "Delete failed");
        }
    }

}
