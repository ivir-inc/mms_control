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

import com.ivir.mpif.controller.model.RestFacility;
import com.ivir.mpif.facility.FacilityService;
import com.ivir.mpif.facility.db.FacilityRecord;
import com.ivir.mpif.simdata.Facility;
import com.ivir.mpif.simdata.FacilitySimDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
@RequestMapping("/mms/facility")
public class FacilityController {
    @Autowired
    private FacilitySimDataService facilitySimDataService;

    @Autowired
    private FacilityService facilityService;

    @GetMapping("/hla/{facilityId}")
    public ResponseEntity<?> getFacility(@PathVariable String facilityId) {
        if (facilityId == null || facilityId.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Facility ID cannot be null or empty.");
        }

        Facility facilityData = facilitySimDataService.getByFacilityId(facilityId);
        return ResponseEntity.ok(toRestFacility(facilityData));
    }

    @GetMapping("/saved/{facilityId}")
    public ResponseEntity<?> getSavedFacility(@PathVariable String facilityId) {
        if (facilityId == null || facilityId.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Facility ID cannot be null or empty.");
        }

        FacilityRecord facilityRecord = facilityService.getFacilityRecordByFacilityId(facilityId)
                .orElse(null);
        if (facilityRecord == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(toRestFacility(facilityRecord));
    }

    @GetMapping("/saved/all")
    public ResponseEntity<?> getAllSavedFacilities() {
        var facilities = facilityService.getAll();
        if (facilities.isEmpty()) {
            return ResponseEntity.ok(new ArrayList<RestFacility>());
        }
        return ResponseEntity.ok(facilities.stream().map(this::toRestFacility).toList());
    }

    @GetMapping("/hla/all")
    public ResponseEntity<?> getAllFacilities() {
        var facilities = facilitySimDataService.getAll();
        if (facilities.isEmpty()) {
            return ResponseEntity.ok(new ArrayList<RestFacility>());
        }
        return ResponseEntity.ok(facilities.stream().map(this::toRestFacility).toList());
    }

    @PutMapping(path="/saved", consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> updateFacility(@RequestBody RestFacility restFacility) {
        if (restFacility == null || restFacility.getFacilityId() == null || restFacility.getFacilityId().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Facility data must be provided with a valid facility ID.");
        }

        FacilityRecord facility = facilityService.getFacilityRecordByFacilityId(restFacility.getFacilityId())
                .orElse(null);

        if(facility == null) {
            return ResponseEntity.notFound().build();
        }
        updateFacilityRecord(facility, restFacility);
        facilityService.update(facility);
        return ResponseEntity.ok(toRestFacility(facility));
    }

    @PostMapping(path="/saved", consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> addFacility(@RequestBody RestFacility restFacility) {
        if (restFacility == null || restFacility.getFacilityId() == null || restFacility.getFacilityId().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Facility data must be provided with a valid facility ID.");
        }

        FacilityRecord facilityRecord = new FacilityRecord();
        updateFacilityRecord(facilityRecord, restFacility);
        facilityRecord.setFacilityId(restFacility.getFacilityId());
        facilityRecord = facilityService.add(facilityRecord);
        return ResponseEntity.ok(toRestFacility(facilityRecord));
    }

    @DeleteMapping(path="/saved/{facilityId}",
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> deleteFacility(@PathVariable String facilityId) {
        if (facilityId == null || facilityId.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Facility ID cannot be null or empty.");
        }
FacilityRecord facilityRecord = facilityService.delete(facilityId) .orElse(null); if (facilityRecord == null) { return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(toRestFacility(facilityRecord));
    }

    private void updateFacilityRecord(FacilityRecord facilityRecord, RestFacility restFacility) {
        if (restFacility.getFacilityType() != null) {
            facilityRecord.setFacilityType(restFacility.getFacilityType());
        }
        if (restFacility.getPatientCapacity() != null) {
            facilityRecord.setPatientCapacity(restFacility.getPatientCapacity());
        }
        if (restFacility.getLocation() != null) {
            facilityRecord.setLocation(restFacility.getLocation());
        }
        if (restFacility.getRoleOfCare() != null) {
            facilityRecord.setRoleOfCare(restFacility.getRoleOfCare());
        }
        if (restFacility.isActive() != null) {
            facilityRecord.setActive(restFacility.isActive());
        }
        if (restFacility.getControlledLocal() != null) {
            facilityRecord.setControlledLocal(restFacility.getControlledLocal());
        }
    }

    private RestFacility toRestFacility(Facility facility) {
        RestFacility restFacility = new RestFacility();
        restFacility.setId(facility.getId());
        restFacility.setLocal(facility.isLocal());
        restFacility.setFacilityId(facility.getFacilityId());
        restFacility.setInstanceName(facility.getInstanceName());
        restFacility.setLocation(facility.getLocation());
        restFacility.setRoleOfCare(facility.getRoleOfCare());
        restFacility.setFacilityType(facility.getFacilityType());
        restFacility.setPatientCapacity(facility.getPatientCapacity());
        return restFacility;
    }

    private RestFacility toRestFacility(FacilityRecord facilityRecord){
    RestFacility restFacility = new RestFacility();
        restFacility.setFacilityId(facilityRecord.getFacilityId());
        restFacility.setInstanceName(facilityRecord.getInstanceName());
        restFacility.setLocation(facilityRecord.getLocation());
        restFacility.setRoleOfCare(facilityRecord.getRoleOfCare());
        restFacility.setFacilityType(facilityRecord.getFacilityType());
        restFacility.setPatientCapacity(facilityRecord.getPatientCapacity());
        restFacility.setActive(facilityRecord.getActive());
        restFacility.setControlledLocal(facilityRecord.getControlledLocal());
        return restFacility;
    }
}
