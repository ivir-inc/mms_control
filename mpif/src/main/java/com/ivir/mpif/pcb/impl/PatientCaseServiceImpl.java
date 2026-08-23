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

package com.ivir.mpif.pcb.impl;

import java.util.Optional;
import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientService;
import com.ivir.mpif.pcb.PatientCase;
import com.ivir.mpif.pcb.PatientCaseService;
import com.ivir.mpif.pcb.db.PatientCaseRepository;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicReference;

@Service
public class PatientCaseServiceImpl implements PatientCaseService {
    private static Logger log = LoggerFactory.getLogger(PatientCaseServiceImpl.class);
    private ExecutorService executor;

    @Autowired
    private PatientCaseRepository patientCaseRepository;

    @Autowired
    private PatientService patientService;

    @PostConstruct
    public void init(){
        this.executor = Executors.newSingleThreadExecutor();
        loadPatientCases();
    }

    @PreDestroy
    public void tearDown(){
        shutdown();
    }

    @Override
    public Optional<PatientCase> getByCaseNum(int caseNum) {
        return Optional.ofNullable(patientCaseRepository.getByCaseNum(caseNum));
    }

    @Override
    public PatientCase add(PatientCase patientCase){
        PatientCase newCase = patientCaseRepository.add(patientCase);
        queueSave();
        return newCase;
    }

    @Override
    public void update(PatientCase patientCase){
        patientCaseRepository.update(patientCase);
        queueSave();
    }

    @Override
    public List<PatientCase> getAll() {
        return patientCaseRepository.getAll();
    }

    @Override
    public void assignToPatient(Integer caseNum, PatientId patientId) {
        if(caseNum == null){
            throw new IllegalArgumentException("caseNum cannot be null");
        }
        if((patientId == null) || (patientId.isEmpty())){
            throw  new IllegalArgumentException("patientId cannot be null");
        }
        if(patientCaseRepository.getByCaseNum(caseNum) == null){
            throw new IllegalArgumentException("caseNum does not match existing case");
        }
        Optional<Patient> patientOpt = patientService.getPatient(patientId);
        if(patientOpt.isEmpty()){
            throw new IllegalArgumentException("patientId does not match existing patient");
        }
        log.debug("Assigning caseNum {} to patient {}", caseNum, patientId);
        patientService.assignCaseNumToPatient(patientId, caseNum);
    }

    @Override
    public Optional<PatientCase> getPatientAssignment(PatientId patientId){
        if((patientId == null) || (patientId.isEmpty())){
            throw  new IllegalArgumentException("patientId cannot be null");
        }
        AtomicReference<PatientCase> patientCaseAt = new AtomicReference<>();
        patientService.getPatient(patientId).ifPresent((patient)->{
            if(patient.getPatientCaseNum() == null){
                log.debug("found patient but caseNum in patient is empty");
            }else{
                patientCaseAt.set(patientCaseRepository.getByCaseNum(patient.getPatientCaseNum()));
            }
        });
        return Optional.ofNullable(patientCaseAt.get());
    }

    @Override
    public Optional<PatientCase> delete(Integer caseNum) {
        if(caseNum == null){
            throw new IllegalArgumentException("caseNum cannot be null");
        }
        PatientCase deletedCase = patientCaseRepository.deleteByCaseNum(caseNum);
        if(deletedCase != null){
            queueSave();
        }
        return Optional.ofNullable(deletedCase);
    }

    private void queueSave() {
        List<PatientCase> snapshot;
        synchronized (this) {
            snapshot = patientCaseRepository.getAll();
        }
        executor.submit(() -> savePatientCases(snapshot));
    }

    public void shutdown() {
        executor.shutdown();
    }

    private void loadPatientCases(){
        log.info("loading patient cases from scenario file");
        PatientCaseFileManager patientCaseFileManager = new PatientCaseFileManager();
        patientCaseFileManager.setScenarioFolder("scenarios");
        List<PatientCase> loadedPatients =  patientCaseFileManager.loadPatientCases();
        loadedPatients.forEach((patientCase)->{
            patientCaseRepository.add(patientCase);
        });
    }

    private void savePatientCases(List<PatientCase> snapShot){
        log.debug("saving patient cases to scenario file");
        PatientCaseFileManager patientCaseFileManager = new PatientCaseFileManager();
        patientCaseFileManager.setScenarioFolder("scenarios");
        patientCaseFileManager.savePatientCases(snapShot);
    }


}
