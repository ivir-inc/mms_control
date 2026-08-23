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

package com.ivir.mpif.simdata;

import java.util.List;
import java.util.logging.Logger;

import org.springframework.stereotype.Component;

@Component
public class SignsSimDataService extends ConcurrentDataStorage<Signs, Signs.Attributes> {
    public SignsSimDataService() {
        super(Signs.class);
    }

    private static final Logger logger = Logger.getLogger("SignsSimDataService");

    public Signs getSignsByPatientId(String patientId) {
        logger.info("Searching for existing signs by patient ID: " + patientId);

        // Ensure we correctly search by patientId
        List<Signs> results = super.searchByAttribute(Signs.Attributes.PATIENT_ID, patientId);
        if (results.isEmpty()) {
            logger.warning("No existing signs found for patient: " + patientId);
            return null; // Do NOT create new signs automatically!
        }

        return results.get(0); // Assuming patientId is unique, return the first match.
    }

    public void addSigns(Signs signs) {
        if (signs == null || signs.getPatientId() == null) {
            logger.warning("Invalid Signs data. Cannot add to storage.");
            return;
        }

        // Ensure no duplicate entry for the same patientId
        if (getSignsByPatientId(signs.getPatientId()) != null) {
            logger.warning("Signs already exist for patient: " + signs.getPatientId() + ". Skipping add.");
            return;
        }

        logger.info("Adding new Signs object for patient: " + signs.getPatientId());
        super.add(signs);
    }

    public void putSigns(Signs newSigns) {
        if (newSigns == null || newSigns.getPatientId() == null) {
            logger.warning("putSigns() failed: Invalid Signs object.");
            return;
        }

        logger.info("Attempting to update local storage for patient: " + newSigns.getPatientId());

        // Retrieve the existing entry without automatically creating a new one
        Signs existingSigns = getSignsByPatientId(newSigns.getPatientId());

        if (existingSigns == null) {
            logger.info("No previous signs found. Creating new entry.");
            super.put(newSigns);
            return;
        }

        // Merge updates (only update fields that are non-null)
        boolean isUpdated = false;

        if (newSigns.getHeartSound() != null && !newSigns.getHeartSound().equals(existingSigns.getHeartSound())) {
            existingSigns.setHeartSound(newSigns.getHeartSound());
            isUpdated = true;
        }
        if (newSigns.getLungSound() != null && !newSigns.getLungSound().equals(existingSigns.getLungSound())) {
            existingSigns.setLungSound(newSigns.getLungSound());
            isUpdated = true;
        }
        if (newSigns.getBowelSound() != null && !newSigns.getBowelSound().equals(existingSigns.getBowelSound())) {
            existingSigns.setBowelSound(newSigns.getBowelSound());
            isUpdated = true;
        }
        if (newSigns.getCoughSound() != null && !newSigns.getCoughSound().equals(existingSigns.getCoughSound())) {
            existingSigns.setCoughSound(newSigns.getCoughSound());
            isUpdated = true;
        }
        if (newSigns.getEcgRhythm() != null && !newSigns.getEcgRhythm().equals(existingSigns.getEcgRhythm())) {
            existingSigns.setEcgRhythm(newSigns.getEcgRhythm());
            isUpdated = true;
        }
        if (newSigns.getPupilSize() != null && !newSigns.getPupilSize().equals(existingSigns.getPupilSize())) {
            existingSigns.setPupilSize(newSigns.getPupilSize());
            isUpdated = true;
        }

        if (isUpdated) {
            super.put(existingSigns);
            logger.info("Successfully updated local storage for patient: " + existingSigns.getPatientId() +
                " with new values: HeartSound=" + existingSigns.getHeartSound() +
                ", LungSound=" + existingSigns.getLungSound() +
                ", BowelSound=" + existingSigns.getBowelSound() +
                ", Cough=" + existingSigns.getCoughSound() +
                ", ECG=" + existingSigns.getEcgRhythm() +
                ", PupilSize=" + existingSigns.getPupilSize()
            );
        } else {
            logger.info("ℹNo changes detected for patient: " + existingSigns.getPatientId());
        }
    }

    public void removeSigns(String patientId) {
        Signs storedSigns = getSignsByPatientId(patientId);
        if (storedSigns != null) {
            logger.info("Removing Signs data for patient: " + patientId);
            super.delete(storedSigns.getInstanceName()); // Ensure this correctly maps to the stored key
        } else {
            logger.warning("No Signs data found to remove for patient: " + patientId);
        }
    }
}
