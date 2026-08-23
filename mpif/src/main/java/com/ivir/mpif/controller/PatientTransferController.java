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

import com.ivir.mpif.controller.model.RestInitiateTransfer;
import com.ivir.mpif.controller.model.RestPatientTransfer;
import com.ivir.mpif.patientxfer.PatientTransferService;
import com.ivir.mpif.simdata.PatientTransfer;
import com.ivir.mpif.simdata.PatientTransferSimDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
@RequestMapping("/mms/patientXfer")
public class PatientTransferController {
    @Autowired
    PatientTransferSimDataService patientTransferSimDataService;

    @Autowired
    PatientTransferService patientTransferService;

    @GetMapping("/{patientId}")
    public ResponseEntity<?> getPatientTransfer(@PathVariable String patientId) {
        if (patientId == null || patientId.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Patient ID cannot be null or empty.");
        }

        PatientTransfer patientTransfer = patientTransferSimDataService.getPatientTransferByPatientId(patientId);
        if (patientTransfer == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(toRest(patientTransfer));
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllPatientTransfers() {
        var transfers = patientTransferSimDataService.getAll();
        if (transfers.isEmpty()) {
            return ResponseEntity.ok(new ArrayList<RestPatientTransfer>());
        } else {
            return ResponseEntity.ok(transfers.stream().map(this::toRest).toList());
        }
    }

    @PostMapping("/initiate")
    public ResponseEntity<?> initiateTransfer(@RequestBody RestInitiateTransfer request) {
        if (request == null) {
            return ResponseEntity.badRequest().body("Request body cannot be null.");
        }
        String patientId = request.getPatientId();
        if (patientId == null || patientId.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Patient ID cannot be null or empty.");
        }
        patientTransferService.initiateTransfer(patientId, request.getDestinationFacilityId());
        return ResponseEntity.ok("Transfer initiated for patient ID: " + patientId);
    }


    private RestPatientTransfer toRest(PatientTransfer patientTransfer) {
        if (patientTransfer == null) {
            return null;
        }
        RestPatientTransfer restPatientTransfer = new RestPatientTransfer();
        restPatientTransfer.setPatientId(patientTransfer.getPatientId());
        restPatientTransfer.setTransferState(patientTransfer.getTransferState());
        restPatientTransfer.setOriginFacilityId(patientTransfer.getOriginFacilityId());
        restPatientTransfer.setDestinationFacilityId(patientTransfer.getDestinationFacilityId());
        return restPatientTransfer;
    }
}
