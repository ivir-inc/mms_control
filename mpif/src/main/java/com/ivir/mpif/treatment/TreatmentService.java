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

package com.ivir.mpif.treatment;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.simdata.*;
import com.ivir.mpif.treatment.data.Scenario;
import com.ivir.mpif.treatment.data.TreatmentLayout;

import java.util.List;
import java.util.Optional;

public interface  TreatmentService {

    Optional<Integer> getActiveScenarioId(PatientId patientId);
    Optional<Scenario> getActiveScenarioByPatientId(PatientId patientId);
    List<Scenario> getAllScenarios();
    TreatmentLayout getTreatmentLayout();
    void updateTreatmentLayout(TreatmentLayout treatmentLayout);
    TreatmentLayout resetTreatmentLayout();
    void addTreatment(Treatment treatment);
    void addMedicationTreatment(PatientId patientId, String injuryId, Medication medication,
                                MedicationAdministrationRoute route, Float dosageValue, Integer dosageInterval);
    void addPhysicalTreatment(PatientId patientId, PhysicalTreatmentType treatment, String injuryId, TreatmentDevice deviceUsed,
                              BodyLocation treatmentLocation);
    Treatment getTreatmentById(long Id);
    Treatment getTreatmentByInstanceName(String instanceName);
    void addTreatmentListener(ConcurrentDataStorageListener<Treatment> treatmentDataStorageListener);

    /**
     * sets the active scenario
     * @param patientId id of the patient.
     * @param scenarioId id of active scenario.  null unsets the scenario
     * @return true if scenario is successfully changes.  false, if not.
     */
    boolean setActiveScenario(PatientId patientId, Integer scenarioId);
}
