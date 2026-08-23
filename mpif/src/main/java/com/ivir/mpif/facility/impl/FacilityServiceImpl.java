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

package com.ivir.mpif.facility.impl;

import com.ivir.mpif.facility.FacilityService;
import com.ivir.mpif.facility.db.FacilityRecord;
import com.ivir.mpif.facility.db.FacilityRepository;
import com.ivir.mpif.simdata.Facility;
import com.ivir.mpif.simdata.FacilitySimDataService;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;

@Service
public class FacilityServiceImpl implements FacilityService {
    private static Logger log = LoggerFactory.getLogger(FacilityServiceImpl.class);
    private ExecutorService executor;
    private boolean federationStarted = false;

    @Autowired
    private FacilityRepository facilityRepository;

    @Autowired
    private FacilitySimDataService facilitySimDataService;

    @PostConstruct
    public void init(){
        this.executor = Executors.newSingleThreadExecutor();
        loadFacilities();
    }

    @PreDestroy
    public void tearDown(){
        shutdown();
    }

    @Override
    public void setFederationStarted(){
        this.federationStarted = true;
        log.info("Federation started, will now add facilities to simulation data if active");
        // Add all existing facilities to simulation data
        List<FacilityRecord> allFacilities = facilityRepository.getAll();
        //build a set of facilities IDs already in simdata
        Set<String> simDataFacilityIds = facilitySimDataService.getAll().stream()
                .map(Facility::getFacilityId)
                .collect(Collectors.toSet());
        for (FacilityRecord facilityRecord : allFacilities) {
            if(!simDataFacilityIds.contains(facilityRecord.getFacilityId())){
                addUpdateSimDataIfActive(facilityRecord);
            }
        }
    }

    @Override
    public Optional<FacilityRecord> getFacilityRecordByFacilityId(String facilityId) {
        return Optional.ofNullable(facilityRepository.getByFacilityId(facilityId));
    }

    @Override
    public FacilityRecord add(FacilityRecord facilityRecord) {
        FacilityRecord newRecord = facilityRepository.add(facilityRecord);
        queueSave();
        addUpdateSimDataIfActive(newRecord);
        return newRecord;
    }

    @Override
    public void update(FacilityRecord facilityRecord) {
        facilityRepository.update(facilityRecord);
        queueSave();
        addUpdateSimDataIfActive(facilityRecord);
    }

    private void addUpdateSimDataIfActive(FacilityRecord facilityRecord) {
        boolean newFacility = false;
        if(federationStarted && facilityRecord.getActive()){
            Facility facility = facilitySimDataService.getByFacilityId(facilityRecord.getFacilityId());
            if(facility == null){
                facility = new Facility();
                facility.setFacilityId(facilityRecord.getFacilityId());
                facility.setLocal(true);
                newFacility = true;
            }
            if(facilityRecord.getFacilityType() != null) {
                facility.setFacilityType(facilityRecord.getFacilityType());
            }
            if(facilityRecord.getLocation() != null) {
                facility.setLocation(facilityRecord.getLocation());
            }
            if(facilityRecord.getRoleOfCare() != null) {
                facility.setRoleOfCare(facilityRecord.getRoleOfCare());
            }
            if(facilityRecord.getPatientCapacity() != null) {
                facility.setPatientCapacity(facilityRecord.getPatientCapacity());
            }
            if(newFacility){
                log.info("Adding new facility to simulation data: {}", facilityRecord.getFacilityId());
                facilitySimDataService.add(facility);
            } else {
                log.info("Updating existing facility in simulation data: {}", facilityRecord.getFacilityId());
                facilitySimDataService.put(facility);
            }
        }
    }


    @Override
    public List<FacilityRecord> getAll() {
        return facilityRepository.getAll();
    }

    @Override
    public Optional<FacilityRecord> delete(String facilityId) {
        if(facilityId == null || facilityId.isEmpty()) {
            throw new IllegalArgumentException("facilityId must not be null or empty");
        }
        FacilityRecord deletedRecord = facilityRepository.deleteByFacilityId(facilityId);
        if (deletedRecord != null) {
            queueSave();
        }
        return Optional.ofNullable(deletedRecord);
    }

    private void shutdown() {
        log.info("shutting down facility service");
        if (executor != null) {
            executor.shutdown();
        }
    }

    private void loadFacilities() {
        log.info("loading facilities from scenario file");
        FacilityFileManager facilityFileManager = new FacilityFileManager();
        List<FacilityRecord> facilities = facilityFileManager.loadFacilities();
        facilities.forEach(facilityRepository::add);
    }

    private void queueSave() {
        List<FacilityRecord> snapshot;
        synchronized (this) {
            snapshot = facilityRepository.getAll();
        }
        executor.submit(()-> saveFacilities(snapshot));
    }

    private void saveFacilities(List<FacilityRecord> snapshot) {
        log.debug("saving facilities to scenario file");
        FacilityFileManager facilityFileManager = new FacilityFileManager();
        facilityFileManager.setScenarioFolder("scenarios");
        facilityFileManager.saveFacilities(snapshot);
    }

}
