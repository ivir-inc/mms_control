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

import com.ivir.mpif.controller.model.RestPatient;
import com.ivir.mpif.patient.Patient;
import com.ivir.mpif.patient.PatientService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.NoSuchElementException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;

@SpringBootTest(classes = PatientControllerTest.class)
public class PatientControllerTest {
    @Mock
    PatientService patientService;

    @InjectMocks
    PatientController sut = new PatientController();

    @BeforeEach
    public void setup(){
        when(patientService.updatePatient(any(), any(), any(), any(), any())).thenReturn(new Patient());
        when(patientService.deletePatient(eq("goodId"))).thenReturn(true);
        when(patientService.deletePatient(eq("anotherGoodId"))).thenReturn(true);
        when(patientService.deletePatient(eq("badId"))).thenReturn(false);
    }

    @Test
    public void updatePatient_WithNoId_ThrowsException(){
        try {
            //by default, patientId is null
            sut.createPatient(new RestPatient());
            fail("should not get here");
        }catch (ResponseStatusException rex){
            assertEquals(HttpStatus.BAD_REQUEST, rex.getStatusCode());
        }
    }

    @Test
    public void updatePatient_OfNonexistentPatient_ThrowsException(){
        try {
            doThrow(new NoSuchElementException("does not exist")).when(patientService).updatePatient(any(), any(), any(), any(), any());
            sut.createPatient(new RestPatient());
            fail("should not get here");
        }catch (ResponseStatusException rex){
            assertEquals(HttpStatus.BAD_REQUEST, rex.getStatusCode());
        }
    }

    @Test
    public void deletePatient_Patients_RespondWithDeleted(){
        assertEquals(1,sut.deletePatients("goodId").getDeletedCount());
        assertEquals(1,sut.deletePatients("anotherGoodId").getDeletedCount());
        assertEquals(0,sut.deletePatients("badId").getDeletedCount());
    }

    @Test
    public void deletePatient_NoPatients_ThrowsBadRequest(){
        try {
            sut.deletePatients(null);
            fail("Should not get here");
        }catch(ResponseStatusException ex){
            assertTrue(ex.getMessage().contains("You must include at least one Patient ID"));
            assertEquals(ex.getStatusCode(), HttpStatus.BAD_REQUEST);
        }
    }

}
