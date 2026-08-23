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

package com.ivir.mpif.patient;

import com.ivir.mpif.common.PatientId;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

public interface PatientService{
    List<Patient>getPatients();

    Optional<Patient> getPatient(PatientId patientId);

    /**
     *
     * @param patientId id of the patient
     * @param monitorPatient true if the patient should be monitored, false otherwise
     * @param physiologySource physiology source
     * @param sourceLocked if the source can be updated
     * @return updated patient
     */
    Patient addPatient(String patientId, Boolean monitorPatient, PatientSource physiologySource, Boolean sourceLocked);

    /**
     *
     * @param patientId id of the patient
     * @param monitorPatient true if the patient should be monitored, false otherwise
     * @param physiologySource physiology source
     * @param sourceLocked if the source can be updated
     * @return updated patient
     * @throws NoSuchElementException if patient with the ID is not found
     */
    Patient updatePatient(String patientId, Boolean monitorPatient, PatientSource physiologySource, Boolean sourceLocked, Integer caseNum);
    Patient addUpdatePatient(String patientId, Boolean monitorPatient, PatientSource physiologySource, Boolean sourceLocked, Integer caseNum);
    void savePatients();
    boolean deletePatient(String patientId);
    Patient assignCaseNumToPatient(PatientId patientId, Integer caseNum);
}
