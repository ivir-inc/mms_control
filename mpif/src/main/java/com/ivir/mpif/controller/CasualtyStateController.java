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

import com.ivir.mpif.controller.model.RestCasualtyState;
import com.ivir.mpif.simdata.CasualtyState;
import com.ivir.mpif.simdata.CasualtyStateSimDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
@RequestMapping("/mms/casualtyState")
public class CasualtyStateController {
    @Autowired
    private CasualtyStateSimDataService casualtyStateSimDataService;

    @GetMapping("/{patientId}")
    public ResponseEntity<?> getCasualtyState(@PathVariable String patientId) {
        if (patientId == null || patientId.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("patientId cannot be null or empty.");
        }

        CasualtyState casualtyStateData = casualtyStateSimDataService.getByPatientId(patientId);
        return ResponseEntity.ok(toRestCasualtyState(casualtyStateData));
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllCasualtyStates() {
        var facilities = casualtyStateSimDataService.getAll();
        if (facilities.isEmpty()) {
            return ResponseEntity.ok(new ArrayList<RestCasualtyState>());
        }
        return ResponseEntity.ok(facilities.stream().map(this::toRestCasualtyState).toList());
    }

    @PutMapping(consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> updateCasualtyState(@RequestBody RestCasualtyState restCasualtyState) {
        if (restCasualtyState == null || restCasualtyState.getPatientId() == null || restCasualtyState.getPatientId().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("CasualtyState data must be provided with a valid Patient ID.");
        }

        CasualtyState casualtyState = casualtyStateSimDataService.getByPatientId(restCasualtyState.getPatientId());
        if(casualtyState == null) {
            return ResponseEntity.notFound().build();
        }
        updateCasualtyState(casualtyState, restCasualtyState);
        casualtyStateSimDataService.put(casualtyState);
        return ResponseEntity.ok(toRestCasualtyState(casualtyState));
    }

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> createCasualtyState(@RequestBody RestCasualtyState restCasualtyState) {
        if (restCasualtyState == null || restCasualtyState.getPatientId() == null || restCasualtyState.getPatientId().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("CasualtyState data must be provided with a valid Patient ID.");
        }
        CasualtyState casualtyState = new CasualtyState();
        casualtyState.setPatientId(restCasualtyState.getPatientId());
        casualtyState.setLocal(true);
        updateCasualtyState(casualtyState, restCasualtyState);
        casualtyStateSimDataService.add(casualtyState);
        return ResponseEntity.ok(toRestCasualtyState(casualtyState));
    }

    private void updateCasualtyState(CasualtyState casualtyState, RestCasualtyState restCasualtyState) {
        if (restCasualtyState.getEvacuationPriority() != null) {
            casualtyState.setEvacuationPriority(restCasualtyState.getEvacuationPriority());
        }
        if (restCasualtyState.getTriageClassification() != null) {
            casualtyState.setTriageClassification(restCasualtyState.getTriageClassification());
        }
        if (restCasualtyState.getFacilityId() != null) {
            casualtyState.setFacilityId(restCasualtyState.getFacilityId());
        }
    }


    private RestCasualtyState toRestCasualtyState(CasualtyState casualtyState) {
        RestCasualtyState restCasualtyState = new RestCasualtyState();
        restCasualtyState.setId(casualtyState.getId());
        restCasualtyState.setLocal(casualtyState.isLocal());
        restCasualtyState.setInstanceName(casualtyState.getInstanceName());
        restCasualtyState.setFacilityId(casualtyState.getFacilityId());
        restCasualtyState.setPatientId(casualtyState.getPatientId());
        restCasualtyState.setEvacuationPriority(casualtyState.getEvacuationPriority());
        restCasualtyState.setTriageClassification(casualtyState.getTriageClassification());
        return restCasualtyState;
    }
}
