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

package com.ivir.mpif.federate;

import com.ivir.mpif.simdata.*;
import com.ivir.mpif.treatment.TreatmentService;
import devstudio.generatedcode.*;
import devstudio.generatedcode.datatypes.*;
import devstudio.generatedcode.datatypes.BodyLocationRecord;
import devstudio.generatedcode.exceptions.HlaInternalException;
import devstudio.generatedcode.exceptions.HlaNotConnectedException;
import devstudio.generatedcode.exceptions.HlaRtiException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.HashSet;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

@SpringBootTest(classes = TreatmentAdapterTest.class)
public class TreatmentAdapterTest {
    @Mock
    MmsFederate mmsFederate;

    @Mock
    TreatmentService treatmentService;

    @Mock
    HlaWorld hlaWorld;

    @Mock
    HlaMedicationTreatmentManager hlaMedicationTreatmentManager;

    @Mock
    HlaMedicationTreatment hlaMedicationTreatment;

    @Mock
    HlaMedicationTreatmentUpdater hlaMedicationTreatmentUpdater;

    @Mock
    HlaPhysicalTreatmentManager hlaPhysicalTreatmentManager;

    @Mock
    HlaPhysicalTreatment hlaPhysicalTreatment;

    @Mock
    HlaPhysicalTreatmentUpdater hlaPhysicalTreatmentUpdater;


    @Captor
    ArgumentCaptor<Treatment> treatmentCaptor;

    @InjectMocks
    TreatmentAdapter sut = new TreatmentAdapter();



    @BeforeEach
    public void setup() throws HlaRtiException, HlaNotConnectedException, HlaInternalException {
        when(mmsFederate.getHlaWorld()).thenReturn(hlaWorld);
        when(hlaWorld.getHlaMedicationTreatmentManager()).thenReturn(hlaMedicationTreatmentManager);
        when(hlaMedicationTreatmentManager.getMedicationTreatmentByHlaInstanceName(any())).thenReturn(null);
        when(hlaMedicationTreatmentManager.createLocalHlaMedicationTreatment()).thenReturn(hlaMedicationTreatment);
        when(hlaMedicationTreatment.getHlaMedicationTreatmentUpdater()).thenReturn(hlaMedicationTreatmentUpdater);
        when(hlaWorld.getHlaPhysicalTreatmentManager()).thenReturn(hlaPhysicalTreatmentManager);
        when(hlaPhysicalTreatmentManager.getPhysicalTreatmentByHlaInstanceName(any())).thenReturn(null);
        when(hlaPhysicalTreatmentManager.createLocalHlaPhysicalTreatment()).thenReturn(hlaPhysicalTreatment);
        when(hlaPhysicalTreatment.getHlaPhysicalTreatmentUpdater()).thenReturn(hlaPhysicalTreatmentUpdater);
    }

    @Test
    public void attributesUpdated_forMedicationTreatment_addsTreatment() {
        doReturn(MedicationAdministrationRouteEnum.INTRAMUSCULAR).when(hlaMedicationTreatment).getAdministrationRoute();
        doReturn(true).when(hlaMedicationTreatment).getDosageActive();
        doReturn(5678).when(hlaMedicationTreatment).getDosageTimePeriod();
        doReturn(44f).when(hlaMedicationTreatment).getDosageValue();
        doReturn("instance").when(hlaMedicationTreatment).getHlaInstanceName();
        doReturn("injury").when(hlaMedicationTreatment).getInjuryId();
        doReturn(MedicationEnum.ASPIRIN).when(hlaMedicationTreatment).getMedication();
        doReturn("patient").when(hlaMedicationTreatment).getPatientId();
        doReturn(BodyLocationRecord.create(
                GeneralRegionEnum.KNEE,
                RegionTissueTypeEnum.NOT_APPLICABLE,
                InternalAnatomyEnum.NOT_APPLICABLE,
                SagittalPlaneEnum.LEFT,
                TransversePlaneEnum.NOT_APPLICABLE,
                CoronalPlaneEnum.POSTERIOR,
                SkeletalSystemEnum.NOT_APPLICABLE,
                DetailedAnatomyEnum.NOT_APPLICABLE,
                0)
        ).when(hlaMedicationTreatment).getTreatmentLocation();
        doReturn("treatment").when(hlaMedicationTreatment).getTreatmentId();
        doReturn(1234L).when(hlaMedicationTreatment).getTreatmentTime();

        HashSet<HlaMedicationTreatmentAttributes.Attribute> set = new HashSet<>();
        set.add(HlaMedicationTreatmentAttributes.Attribute.ADMINISTRATION_ROUTE);
        set.add(HlaMedicationTreatmentAttributes.Attribute.DOSAGE_ACTIVE);
        set.add(HlaMedicationTreatmentAttributes.Attribute.DOSAGE_TIME_PERIOD);
        set.add(HlaMedicationTreatmentAttributes.Attribute.DOSAGE_VALUE);
        set.add(HlaMedicationTreatmentAttributes.Attribute.INJURY_ID);
        set.add(HlaMedicationTreatmentAttributes.Attribute.MEDICATION);
        set.add(HlaMedicationTreatmentAttributes.Attribute.PATIENT_ID);
        set.add(HlaMedicationTreatmentAttributes.Attribute.TREATMENT_ID);
        set.add(HlaMedicationTreatmentAttributes.Attribute.TREATMENT_LOCATION);
        set.add(HlaMedicationTreatmentAttributes.Attribute.TREATMENT_TIME);

        sut.attributesUpdated(hlaMedicationTreatment, set, null, null);

        verify(treatmentService).addTreatment(treatmentCaptor.capture());
        Treatment actualTreatment = treatmentCaptor.getValue();
        assertEquals(MedicationAdministrationRoute.INTRAMUSCULAR, actualTreatment.getAdministrationRoute());
        assertEquals(TreatmentClassType.MEDICATION_TREATMENT, actualTreatment.getClassType());
        assertEquals(true, actualTreatment.getTreatmentActive());
        assertEquals(5678, actualTreatment.getDosageTimePeriod());
        assertEquals(44f, actualTreatment.getDosageValue());
        assertEquals("injury", actualTreatment.getInjuryId());
        assertEquals("instance", actualTreatment.getInstanceName());
        assertEquals(false, actualTreatment.isLocal());
        assertEquals(Medication.ASPIRIN, actualTreatment.getMedication());
        assertEquals("patient", actualTreatment.getPatientId().toString());
        assertEquals("treatment", actualTreatment.getTreatmentId());
        assertEquals(new BodyLocation()
                .setGeneralRegion(GeneralRegion.KNEE)
                .setRegionTissueType(RegionTissueType.NOT_APPLICABLE)
                .setInternalAnatomy(InternalAnatomy.NOT_APPLICABLE)
                .setSagittalPlane(SagittalPlane.LEFT)
                .setTransversePlane(TransversePlane.NOT_APPLICABLE)
                .setCoronalPlane(CoronalPlane.POSTERIOR)
                .setSkeletalSystem(SkeletalSystem.NOT_APPLICABLE)
                .setDetailedAnatomy(DetailedAnatomy.NOT_APPLICABLE)
                .setFmaid(0), actualTreatment.getTreatmentLocation());
        assertEquals(1234L, actualTreatment.getTreatmentTime());
    }

    @Test
    public void attributesUpdated_forMedicationTreatment_withLocationWithNoGeneralRegion() {
        doReturn(BodyLocationRecord.create(
                GeneralRegionEnum.NOT_APPLICABLE,
                RegionTissueTypeEnum.NOT_APPLICABLE,
                InternalAnatomyEnum.NOT_APPLICABLE,
                SagittalPlaneEnum.NOT_APPLICABLE,
                TransversePlaneEnum.UPPER,
                CoronalPlaneEnum.POSTERIOR,
                SkeletalSystemEnum.SPINE,
                DetailedAnatomyEnum.NOT_APPLICABLE,
                0)
            ).when(hlaMedicationTreatment).getTreatmentLocation();

        HashSet<HlaMedicationTreatmentAttributes.Attribute> set = new HashSet<>();
        set.add(HlaMedicationTreatmentAttributes.Attribute.TREATMENT_LOCATION);

        sut.attributesUpdated(hlaMedicationTreatment, set, null, null);

        verify(treatmentService).addTreatment(treatmentCaptor.capture());
        Treatment actualTreatment = treatmentCaptor.getValue();
        assertEquals(new BodyLocation()
                .setGeneralRegion(GeneralRegion.NOT_APPLICABLE)
                .setRegionTissueType(RegionTissueType.NOT_APPLICABLE)
                .setInternalAnatomy(InternalAnatomy.NOT_APPLICABLE)
                .setSagittalPlane(SagittalPlane.NOT_APPLICABLE)
                .setTransversePlane(TransversePlane.UPPER)
                .setCoronalPlane(CoronalPlane.POSTERIOR)
                .setSkeletalSystem(SkeletalSystem.SPINE)
                .setDetailedAnatomy(DetailedAnatomy.NOT_APPLICABLE)
                .setFmaid(0), actualTreatment.getTreatmentLocation());
    }

    @Test
    public void attributesUpdated_forPhysicalTreatment_addsTreatment() {
        doReturn(TreatmentDeviceEnum.CHEST_TUBE).when(hlaPhysicalTreatment).getDeviceUsed();
        doReturn("instance").when(hlaPhysicalTreatment).getHlaInstanceName();
        doReturn("injury").when(hlaPhysicalTreatment).getInjuryId();
        doReturn("patient").when(hlaPhysicalTreatment).getPatientId();
        doReturn(PhysicalTreatmentTypeEnum.CLEAN_WOUND).when(hlaPhysicalTreatment).getTreatment();
        doReturn(true).when(hlaPhysicalTreatment).getTreatmentActive();
        doReturn(BodyLocationRecord.create(
                        GeneralRegionEnum.NOT_APPLICABLE,
                        RegionTissueTypeEnum.NOT_APPLICABLE,
                        InternalAnatomyEnum.NOT_APPLICABLE,
                        SagittalPlaneEnum.NOT_APPLICABLE,
                        TransversePlaneEnum.UPPER,
                        CoronalPlaneEnum.POSTERIOR,
                        SkeletalSystemEnum.SPINE,
                        DetailedAnatomyEnum.NOT_APPLICABLE,
                        0)
        ).when(hlaPhysicalTreatment).getTreatmentLocation();
        doReturn("treatment").when(hlaPhysicalTreatment).getTreatmentId();
        doReturn(1234L).when(hlaPhysicalTreatment).getTreatmentTime();

        HashSet<HlaPhysicalTreatmentAttributes.Attribute> set = new HashSet<>();
        set.add(HlaPhysicalTreatmentAttributes.Attribute.DEVICE_USED);
        set.add(HlaPhysicalTreatmentAttributes.Attribute.INJURY_ID);
        set.add(HlaPhysicalTreatmentAttributes.Attribute.PATIENT_ID);
        set.add(HlaPhysicalTreatmentAttributes.Attribute.TREATMENT);
        set.add(HlaPhysicalTreatmentAttributes.Attribute.TREATMENT_ACTIVE);
        set.add(HlaPhysicalTreatmentAttributes.Attribute.TREATMENT_ID);
        set.add(HlaPhysicalTreatmentAttributes.Attribute.TREATMENT_LOCATION);
        set.add(HlaPhysicalTreatmentAttributes.Attribute.TREATMENT_TIME);

        sut.attributesUpdated(hlaPhysicalTreatment, set, null, null);

        verify(treatmentService).addTreatment(treatmentCaptor.capture());
        Treatment actualTreatment = treatmentCaptor.getValue();
        assertEquals(TreatmentClassType.PHYSICAL_TREATMENT, actualTreatment.getClassType());
        assertEquals(TreatmentDevice.CHEST_TUBE, actualTreatment.getDeviceUsed());
        assertEquals("injury", actualTreatment.getInjuryId());
        assertEquals("instance", actualTreatment.getInstanceName());
        assertEquals(false, actualTreatment.isLocal());
        assertEquals("patient", actualTreatment.getPatientId().toString());
        assertEquals(PhysicalTreatmentType.CLEAN_WOUND, actualTreatment.getTreatment());
        assertEquals(true, actualTreatment.getTreatmentActive());
        assertEquals("treatment", actualTreatment.getTreatmentId());
        assertEquals(new BodyLocation()
                .setGeneralRegion(GeneralRegion.NOT_APPLICABLE)
                .setRegionTissueType(RegionTissueType.NOT_APPLICABLE)
                .setInternalAnatomy(InternalAnatomy.NOT_APPLICABLE)
                .setSagittalPlane(SagittalPlane.NOT_APPLICABLE)
                .setTransversePlane(TransversePlane.UPPER)
                .setCoronalPlane(CoronalPlane.POSTERIOR)
                .setSkeletalSystem(SkeletalSystem.SPINE)
                .setDetailedAnatomy(DetailedAnatomy.NOT_APPLICABLE)
                .setFmaid(0), actualTreatment.getTreatmentLocation());
        assertEquals(1234L, actualTreatment.getTreatmentTime());
    }

    @Test
    public void entityAdded_withMedicationTreatment_publishesTreatment(){
        Treatment addedTreatment = new Treatment()
                .setClassType(TreatmentClassType.MEDICATION_TREATMENT)
                .setMedication(Medication.CALCIUM_GLUCONATE)
                .setAdministrationRoute(MedicationAdministrationRoute.SUBLINGUAL)
                .setTreatmentActive(true)
                .setDosageTimePeriod(1)
                .setDosageValue(2f)
                .setInjuryId("injury")
                .setPatientId("patient")
                .setTreatmentId("treatment")
                .setTreatmentLocation(new BodyLocation()
                        .setGeneralRegion(GeneralRegion.KNEE)
                        .setRegionTissueType(RegionTissueType.NOT_APPLICABLE)
                        .setInternalAnatomy(InternalAnatomy.NOT_APPLICABLE)
                        .setSagittalPlane(SagittalPlane.LEFT)
                        .setTransversePlane(TransversePlane.NOT_APPLICABLE)
                        .setCoronalPlane(CoronalPlane.POSTERIOR)
                        .setSkeletalSystem(SkeletalSystem.NOT_APPLICABLE)
                        .setDetailedAnatomy(DetailedAnatomy.NOT_APPLICABLE)
                        .setFmaid(0))
                .setTreatmentTime(3L)
                .setLocal(true);

        sut.entityAdded(addedTreatment);

        verify(hlaMedicationTreatmentUpdater).setMedication(MedicationEnum.CALCIUM_GLUCONATE);
        verify(hlaMedicationTreatmentUpdater).setAdministrationRoute(MedicationAdministrationRouteEnum.SUBLINGUAL);
        verify(hlaMedicationTreatmentUpdater).setDosageActive(true);
        verify(hlaMedicationTreatmentUpdater).setDosageTimePeriod(1);
        verify(hlaMedicationTreatmentUpdater).setDosageValue(2f);
        verify(hlaMedicationTreatmentUpdater).setInjuryId("injury");
        verify(hlaMedicationTreatmentUpdater).setPatientId("patient");
        verify(hlaMedicationTreatmentUpdater).setTreatmentId("treatment");
        verify(hlaMedicationTreatmentUpdater).setTreatmentLocation(BodyLocationRecord.create(
                GeneralRegionEnum.KNEE,
                RegionTissueTypeEnum.NOT_APPLICABLE,
                InternalAnatomyEnum.NOT_APPLICABLE,
                SagittalPlaneEnum.LEFT,
                TransversePlaneEnum.NOT_APPLICABLE,
                CoronalPlaneEnum.POSTERIOR,
                SkeletalSystemEnum.NOT_APPLICABLE,
                DetailedAnatomyEnum.NOT_APPLICABLE,
               0
        ));
        verify(hlaMedicationTreatmentUpdater).setTreatmentTime(3L);
    }

    @Test
    public void entityAdded_withPhysicalTreatment_publishesTreatment(){
        Treatment addedTreatment = new Treatment()
                .setClassType(TreatmentClassType.PHYSICAL_TREATMENT)
                .setDeviceUsed(TreatmentDevice.EYE_SHIELD)
                .setInjuryId("injury")
                .setPatientId("patient")
                .setTreatment(PhysicalTreatmentType.OPEN_NASAL_AIRWAY)
                .setTreatmentActive(true)
                .setTreatmentId("treatment")
                .setTreatmentLocation(new BodyLocation()
                        .setGeneralRegion(GeneralRegion.KNEE)
                        .setRegionTissueType(RegionTissueType.NOT_APPLICABLE)
                        .setInternalAnatomy(InternalAnatomy.NOT_APPLICABLE)
                        .setSagittalPlane(SagittalPlane.LEFT)
                        .setTransversePlane(TransversePlane.NOT_APPLICABLE)
                        .setCoronalPlane(CoronalPlane.POSTERIOR)
                        .setSkeletalSystem(SkeletalSystem.NOT_APPLICABLE)
                        .setDetailedAnatomy(DetailedAnatomy.NOT_APPLICABLE)
                        .setFmaid(0))
                .setTreatmentTime(3L)
                .setLocal(true);

        sut.entityAdded(addedTreatment);

        verify(hlaPhysicalTreatmentUpdater).setDeviceUsed(TreatmentDeviceEnum.EYE_SHIELD);
        verify(hlaPhysicalTreatmentUpdater).setInjuryId("injury");
        verify(hlaPhysicalTreatmentUpdater).setPatientId("patient");
        verify(hlaPhysicalTreatmentUpdater).setTreatment(PhysicalTreatmentTypeEnum.OPEN_NASAL_AIRWAY);
        verify(hlaPhysicalTreatmentUpdater).setTreatmentActive(true);
        verify(hlaPhysicalTreatmentUpdater).setTreatmentId("treatment");
        verify(hlaPhysicalTreatmentUpdater).setTreatmentLocation(BodyLocationRecord.create(
                GeneralRegionEnum.KNEE,
                RegionTissueTypeEnum.NOT_APPLICABLE,
                InternalAnatomyEnum.NOT_APPLICABLE,
                SagittalPlaneEnum.LEFT,
                TransversePlaneEnum.NOT_APPLICABLE,
                CoronalPlaneEnum.POSTERIOR,
                SkeletalSystemEnum.NOT_APPLICABLE,
                DetailedAnatomyEnum.NOT_APPLICABLE,
                0
        ));
        verify(hlaPhysicalTreatmentUpdater).setTreatmentTime(3L);
    }
}
