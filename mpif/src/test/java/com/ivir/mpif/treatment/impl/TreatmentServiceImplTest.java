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

package com.ivir.mpif.treatment.impl;

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.mconfig.MpifConfigService;
import com.ivir.mpif.simdata.*;
import com.ivir.mpif.treatment.data.MedicationTreatmentDetail;
import com.ivir.mpif.treatment.data.Scenario;
import com.ivir.mpif.treatment.data.ScenarioStorage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.HashMap;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@SpringBootTest(classes = TreatmentServiceImplTest.class)
public class TreatmentServiceImplTest {
    @Mock
    private MpifConfigService mpifConfigService;

    @Mock
    private ScenarioStorage scenarioStorage;

    @Mock
    private HashMap<PatientId,Integer> patientToActiveScenarioMap;

    @Mock
    private TreatmentSimDataService treatmentSimDataService;

    @InjectMocks
    public TreatmentServiceImpl sut = new TreatmentServiceImpl();

    private Scenario scenario = Mockito.mock(Scenario.class);

    @BeforeEach
    public void setup() {
        when(patientToActiveScenarioMap.get(any())).thenReturn(1);
        when(scenarioStorage.getScenario(any(Integer.class))).thenReturn(scenario);
    }

    @Test
    public void addMedicationTreatment_AddsTreatment() {
        sut.addMedicationTreatment(new PatientId("test"), "InjuryId", Medication.ASPIRIN,
                MedicationAdministrationRoute.RECTAL, 20f, 10);

        Treatment expectedTreatment = new Treatment()
                .setPatientId(new PatientId("test"))
                .setTreatmentId("null-test-0")
                .setClassType(TreatmentClassType.MEDICATION_TREATMENT)
                .setTreatmentActive(true)
                .setMedication(Medication.ASPIRIN)
                .setAdministrationRoute(MedicationAdministrationRoute.RECTAL)
                .setDosageValue(20f)
                .setDosageTimePeriod(10)
                .setLocal(true);
        verify(treatmentSimDataService).add(eq(expectedTreatment));
    }

    @Test
    public void addMedicationTreatment_WithNonMatchingEnums_SetsNulls(){
        doReturn(new MedicationTreatmentDetail("Test Medication").setCorrectDosage(3f)).when(scenario).getMedicationTreatmentByName(any());

        sut.addMedicationTreatment(new PatientId("test"), null, null,
                null, null, null);

        Treatment expectedTreatment = new Treatment()
                .setPatientId(new PatientId("test"))
                .setTreatmentId("null-test-0")
                .setClassType(TreatmentClassType.MEDICATION_TREATMENT)
                .setTreatmentActive(true)
                .setInjuryId(null)
                .setMedication(null)
                .setAdministrationRoute(null)
                .setDosageValue(null)
                .setDosageTimePeriod(null)
                .setLocal(true);
        verify(treatmentSimDataService).add(eq(expectedTreatment));
    }

    @Test
    public void addMedicationTreatment_WitNonMatchingName_SetsNulls(){
        doReturn(null).when(scenario).getMedicationTreatmentByName(any());

        sut.addMedicationTreatment(new PatientId("test"), "Test", Medication.OXYGEN,
                MedicationAdministrationRoute.INTRAOSSEOUS_DRIP, null, null);

        Treatment expectedTreatment = new Treatment()
                .setPatientId(new PatientId("test"))
                .setTreatmentId("null-test-0")
                .setClassType(TreatmentClassType.MEDICATION_TREATMENT)
                .setTreatmentActive(true)
                .setMedication(Medication.OXYGEN)
                .setAdministrationRoute(MedicationAdministrationRoute.INTRAOSSEOUS_DRIP)
                .setDosageValue(null)
                .setLocal(true);
        verify(treatmentSimDataService).add(eq(expectedTreatment));
    }

}
