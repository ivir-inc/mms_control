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

package com.ivir.mpif.patient.impl;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.db.EntityExistsException;
import com.ivir.mpif.patient.db.PatientEntity;
import com.ivir.mpif.patient.db.PatientRepository;
import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientSource;
import com.ivir.mpif.patient.PatientService;
import jakarta.annotation.PostConstruct;
import org.dizitart.no2.exceptions.UniqueConstraintException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

@Service
public class PatientServiceImpl implements PatientService {
    private static final Logger logger = LoggerFactory.getLogger(PatientServiceImpl.class);

    @Autowired
    PatientRepository patientRepository;

    @PostConstruct
    public void init(){
        loadPatients();
    }

    @Override
    public Patient addPatient(String patientId, Boolean monitorPatient, PatientSource physiologySource, Boolean sourceLocked) {
        if(patientId == null){
            throw new IllegalArgumentException("patientID cannot be null");
        }
        patientId = new PatientId(patientId).getIdAsString(); //using PatientID class to make sure it is formatted correctly
        PatientEntity patientEntity = new PatientEntity()
                .setId(patientId)
                .setSourceLocked(defaultIfNull(sourceLocked, Boolean.FALSE))
                .setVisible(defaultIfNull(monitorPatient,Boolean.TRUE))
                .setPhysiologySource(defaultIfNull(physiologySource,PatientSource.UNKNOWN));

        logger.debug("Adding patient {}", patientEntity);
        try {
            patientRepository.insert(patientEntity);
        }catch(UniqueConstraintException uniqueConstraintException){
            throw new EntityExistsException("Patient already exists");
        }
        return toPatient(patientEntity);
    }

    private <T> T defaultIfNull(T test, T defaultVal){
        if(test == null){
            return defaultVal;
        }
        return test;
    }

    @Override
    public Patient updatePatient(String patientId, Boolean monitorPatient, PatientSource physiologySource,
                                 Boolean sourceLocked, Integer caseNum) {
        if(patientId == null){
            throw new IllegalArgumentException("patientID cannot be null");
        }
        patientId = patientId.strip();
        PatientEntity patientEntity = patientRepository.getById(patientId);
        if(patientEntity == null){
           throw new NoSuchElementException("Patient was not found");
        }
        updatePatientEntityIfDiff(patientEntity, monitorPatient, physiologySource, sourceLocked, caseNum);
        logger.debug("Updating patient {}", patientEntity);
        patientRepository.update(patientEntity);
        return toPatient(patientEntity);
    }

    @Override
    public Patient addUpdatePatient(String patientId, Boolean monitorPatient, PatientSource physiologySource,
                                    Boolean sourceLocked, Integer caseNum){
        if(patientId == null){
            throw new IllegalArgumentException("patientID cannot be null");
        }
        patientId = patientId.strip();
        PatientEntity patientEntity = patientRepository.getById(patientId);
        if(patientEntity == null){
            logger.debug("Adding patient in addUpdate to {}", patientEntity);
            return addPatient(patientId, monitorPatient, physiologySource, sourceLocked);
        }else{
            updatePatientEntityIfDiff(patientEntity, monitorPatient, physiologySource, sourceLocked, caseNum);
            logger.debug("Updating patient in addUpdate to {}", patientEntity);
            patientRepository.update(patientEntity);
            return toPatient(patientEntity);
        }
    }

    private void updatePatientEntityIfDiff(PatientEntity patientEntity,  Boolean monitorPatient,
                                           PatientSource physiologySource, Boolean sourceLocked, Integer caseNum){
        if(monitorPatient == null){
            monitorPatient = false;
        }
        if(monitorPatient != patientEntity.getVisible()){
            patientEntity.setVisible(monitorPatient);
        }
        if((physiologySource !=  null) && (physiologySource != patientEntity.getPhysiologySource())){
            patientEntity.setPhysiologySource(physiologySource);
        }
        if((sourceLocked != null) && (sourceLocked != patientEntity.getSourceLocked())){
            patientEntity.setSourceLocked(sourceLocked);
        }
        if((caseNum != null) && (caseNum != patientEntity.getPatientCaseNum())){
            patientEntity.setPatientCaseNum(caseNum);
        }
    }

    @Override
    public void savePatients(){
        List<PatientEntity> internalPatients = patientRepository.getAll().stream()
                .filter(p -> p.getPhysiologySource() == PatientSource.INTERNAL)
                .toList();
        PatientFileManager patientFileManager = new PatientFileManager();
        patientFileManager.savePatients(internalPatients);
    }

    public void loadPatients(){
        PatientFileManager patientFileManager = new PatientFileManager();
        patientFileManager.setScenarioFolder("scenarios");
        List<PatientEntity> loadedPatients =  patientFileManager.loadPatients();
        loadedPatients.forEach((patient)->{
            this.addUpdatePatient(patient.getId(), patient.getVisible(), patient.getPhysiologySource(),false, null);
        });
    }

    private Patient toPatient(PatientEntity patientEntity){
        return new Patient()
                .setId(new PatientId(patientEntity.getId()))
                .setPhysiologySource(patientEntity.getPhysiologySource())
                .setVisible(patientEntity.getVisible())
                .setSourceLocked(patientEntity.getSourceLocked())
                .setPatientCaseNum(patientEntity.getPatientCaseNum());
    }

    @Override
    public Optional<Patient> getPatient(PatientId patientId){
        PatientEntity patientEntity = patientRepository.getById(patientId.getIdAsString());
        if(patientEntity == null){
            return Optional.empty();
        }
        return Optional.of(toPatient(patientEntity));
    }

    @Override
    public List<Patient> getPatients() {
        return patientRepository.getAll().stream().map(this::toPatient).toList();
    }

    @Override
    public boolean deletePatient(String patientId){
        if((patientId == null) || patientId.isEmpty()){
            throw new IllegalArgumentException("patientId must not be null");
        }
        PatientEntity patient = patientRepository.getById(patientId);
        if(patient == null){
            throw new NoSuchElementException("Patient with id " + patientId + " is does not exist");
        }
        if((patient.getSourceLocked() != null) && patient.getSourceLocked()){
            throw new IllegalArgumentException("Patient is locked");
        }
        patientRepository.remove(patient);
        return true;
    }

    @Override
    public Patient assignCaseNumToPatient(PatientId patientId, Integer caseNum) {
        PatientEntity patientEntity = patientRepository.getById(patientId.getIdAsString());
        patientEntity.setPatientCaseNum(caseNum);
        logger.debug("assigning case num.  updating patient to {}", patientEntity);
        patientRepository.update(patientEntity);
        return toPatient(patientEntity);
    }


}