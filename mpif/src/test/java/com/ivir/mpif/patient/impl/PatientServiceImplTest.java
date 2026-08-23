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

package com.ivir.mpif.patient.impl;

import com.ivir.mpif.patient.db.PatientEntity;
import com.ivir.mpif.patient.db.PatientRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.util.NoSuchElementException;

@SpringBootTest(classes = PatientServiceImplTest.class)
public class PatientServiceImplTest {

    @Mock
    PatientRepository patientRepository;

    @InjectMocks
    public PatientServiceImpl sut = new PatientServiceImpl();

    @Test
    public void deletePatient_ThrowsException_OnNullPatientId(){
        assertThrows(IllegalArgumentException.class, () -> sut.deletePatient(null));
        assertThrows(IllegalArgumentException.class, () -> sut.deletePatient(""));
        verify(patientRepository, times(0)).remove(any());
    }

    @Test
    public void deletePatient_ThrowsException_IfPatientIsNotFound(){
        doReturn(null).when(patientRepository).getById(any());
        assertThrows(NoSuchElementException.class, () -> sut.deletePatient("1232"));
        verify(patientRepository, times(0)).remove(any());
    }

    @Test
    public void deletePatient_ThrowsException_IfPatientIsLocked(){
        PatientEntity patientEntity = new PatientEntity().setId("12345").setSourceLocked(true);
        doReturn(patientEntity).when(patientRepository).getById(any());
        assertThrows(IllegalArgumentException.class, () -> sut.deletePatient("12345"));
        verify(patientRepository, times(0)).remove(any());
    }

    @Test
    public void deletePatient_ReturnsTrue_WhenValid(){
        PatientEntity patientEntity = new PatientEntity().setId("12345").setSourceLocked(false);
        doReturn(patientEntity).when(patientRepository).getById(any());
        assertTrue(sut.deletePatient("12345"));
        verify(patientRepository, times(1)).remove(patientEntity);
    }
}