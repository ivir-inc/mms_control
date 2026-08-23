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

package com.ivir.mpif.pcb.db;

import com.ivir.mpif.db.NitriteConfig;
import com.ivir.mpif.pcb.PatientCase;
import com.ivir.mpif.simdata.InjuryDescription;
import com.ivir.mpif.simdata.InjuryType;
import com.ivir.mpif.simdata.PhysicalTreatmentType;
import com.ivir.mpif.simdata.TreatmentClassType;
import com.ivir.mpif.simdata.TreatmentDevice;
import org.dizitart.no2.Nitrite;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@SpringBootTest(classes = PatientCaseRepositoryTest.class)
public class PatientCaseRepositoryTest {

    @Mock
    Nitrite nitrite;

    @InjectMocks
    PatientCaseRepository sut = new PatientCaseRepository();

    @BeforeEach
    public void setup(){
        Nitrite nitriteDB = new NitriteConfig().nitriteDatabase();
        when(nitrite.getRepository(any(Class.class))).thenReturn(
                nitriteDB.getRepository(PatientCase.class)
        );
        sut.init();
    }

    @Test
    public void add_insertsEntity(){
        PatientCase entity = new PatientCase()
                .setName("Test")
                .buildPCVitals((vitals)->vitals.setHeartRate(23))
                .buildPCInjury((injury)->injury
                        .setInjuryType(InjuryType.FRACTURE)
                        .setDescription(InjuryDescription.CRUSH))
                .buildPCTreatment((treatment)->treatment
                        .setTreatmentType(TreatmentClassType.PHYSICAL_TREATMENT)
                        .setPhysicalDevice(TreatmentDevice.BANDAGE)
                        .setPhysicalTreatment(PhysicalTreatmentType.BANDAGE_BURN));
        sut.add(entity);
        //case num was created
        assertEquals(PatientCaseRepository.getNextCaseNum()-1,entity.getCaseNum());
    }

    @Test
    public void add_insertsEntityWorksWithNulls(){
        PatientCase entity = new PatientCase();
        entity = sut.add(new PatientCase());
        //case num was created
        assertEquals(PatientCaseRepository.getNextCaseNum()-1,entity.getCaseNum());
    }

    @Test
    public void add_withCaseNumber_throwsException(){
        PatientCase entity = new PatientCase();
        entity.setName("Test")
                .setCaseNum(3);
        try {
            entity = sut.add(entity);
            fail("add should have failed");
        }catch (Exception e){
            assertTrue(e instanceof RuntimeException);
        }
    }

//    @Test
//    public void update_changesEntity(){
//        PatientCase entity1 = insertPatientCase("Test", Arrays.asList(2), Arrays.asList(2),3);
//        PatientCase entity2 = insertPatientCase("Test 2", Arrays.asList(8), Arrays.asList(9),10);
//
//        entity1.setVitals(6);
//        sut.update(entity1);
//
//        PatientCase entity1v2 = sut.getByCaseNum(entity1.getCaseNum());
//        assertEquals(6, entity1v2.getVitals());
//    }
//
//    @Test
//    public void getByCaseNum_getsTheCorrectCase(){
//        Integer pcNum1 = insertPatientCase("Test", Arrays.asList(2), Arrays.asList(3),4).getCaseNum();
//        Integer pcNum2 = insertPatientCase("Test 1", Arrays.asList(5), Arrays.asList(6),7).getCaseNum();
//        Integer pcNum3 = insertPatientCase("Test 2", Arrays.asList(8), Arrays.asList(9),10).getCaseNum();
//
//        PatientCase entity = sut.getByCaseNum(pcNum2);
//        assertEquals("Test 1", entity.getName());
//        assertEquals(7, entity.getVitals());
//        assertEquals(5, entity.getTreatments().get(0));
//        assertEquals(6, entity.getInjuries().get(0));
//
//        entity = sut.getByCaseNum(pcNum3);
//        assertEquals("Test 2", entity.getName());
//        entity = sut.getByCaseNum(pcNum1);
//        assertEquals("Test", entity.getName());
//    }

}
