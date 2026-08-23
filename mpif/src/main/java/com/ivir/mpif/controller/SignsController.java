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

import java.util.Map;
import java.util.logging.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ivir.mpif.simdata.Signs;
import com.ivir.mpif.simdata.SignsSimDataService;

@RestController
@RequestMapping("/mms/signs")
public class SignsController {
    private static final Logger logger = Logger.getLogger("SignsController");
    private final SignsSimDataService signsSimDataService;

    @Autowired
    public SignsController(SignsSimDataService signsSimDataService) {
        this.signsSimDataService = signsSimDataService;
    }

    @GetMapping("/{patientId}")
    public ResponseEntity<?> getSigns(@PathVariable String patientId) {
        logger.info("Fetching signs from local storage for patient: " + patientId);

        if (patientId == null || patientId.trim().isEmpty()) {
            logger.warning("Invalid request: patientId cannot be null or empty.");
            return ResponseEntity.badRequest().body(Map.of("error", "Patient ID cannot be null or empty."));
        }

        try {
            Signs patientSigns = signsSimDataService.getSignsByPatientId(patientId);

            if (patientSigns != null) {
                logger.info("Successfully retrieved signs for patient: " + patientId + 
                    " | InstanceName=" + patientSigns.getInstanceName() +
                    " | HeartSound=" + patientSigns.getHeartSound() +
                    " | LungSound=" + patientSigns.getLungSound() +
                    " | BowelSound=" + patientSigns.getBowelSound() +
                    " | Cough=" + patientSigns.getCoughSound() +
                    " | ECG=" + patientSigns.getEcgRhythm() +
                    " | PupilSize=" + patientSigns.getPupilSize()
                );
                return ResponseEntity.ok(patientSigns);
            } else {
                logger.warning("No signs found for patient: " + patientId);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                    "error", "No signs found for patient: " + patientId,
                    "suggestion", "Ensure the patient is federated before requesting signs."
                ));
            }
        } catch (Exception e) {
            logger.severe("Unexpected error retrieving signs for patient: " + patientId + " | " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                "error", "An unexpected error occurred while retrieving signs.",
                "details", e.getMessage(),
                "suggestion", "Try again later or contact support if the issue persists."
            ));
        }
    }

    @PutMapping("/{patientId}")
    public ResponseEntity<?> updateSigns(@PathVariable String patientId, @RequestBody Signs updatedSigns) {
        logger.info("Received update request for patient: " + patientId);

        // Validate request
        if (updatedSigns == null) {
            logger.warning("Update failed: Signs object is missing.");
            return ResponseEntity.badRequest().body(Map.of("error", "Signs object cannot be null."));
        }
        if (updatedSigns.getPatientId() == null || updatedSigns.getPatientId().trim().isEmpty()) {
            logger.warning("Update failed: Patient ID is missing in request body.");
            return ResponseEntity.badRequest().body(Map.of("error", "Patient ID must be provided in the request body."));
        }
        if (!updatedSigns.getPatientId().equals(patientId)) {
            logger.warning("Update failed: Mismatched patient ID. URL ID: " + patientId + ", Body ID: " + updatedSigns.getPatientId());
            return ResponseEntity.badRequest().body(Map.of("error", "Mismatched patient ID. Ensure the ID in the URL matches the one in the request body."));
        }

        try {
            // Update SignsSimDataService (adapter will listen and update HLA)
            logger.info("Storing updated signs in local storage for patient: " + patientId);
            signsSimDataService.putSigns(updatedSigns);

            return ResponseEntity.ok(Map.of("message", "Signs successfully updated for patient: " + patientId));
        } catch (Exception e) {
            logger.severe("Unexpected error updating signs for patient: " + patientId + " | " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                "error", "An unexpected error occurred while updating signs.",
                "details", e.getMessage(),
                "suggestion", "Try again later or contact support if the issue persists."
            ));
        }
    }
}
