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

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(classes = ConcurrentSimDataTest.class)
public class ConcurrentSimDataTest {

    @Test
    public void setValue_updateOnNullValue(){
        ConcurrentSimData<ConcurrentSimDataEnumMock> sut = new ConcurrentSimData<>(ConcurrentSimDataEnumMock.class,
                ConcurrentSimDataEnumMock.FIELD1_INT);
        sut.setValue(ConcurrentSimDataEnumMock.FIELD1_INT, 1);

        assertEquals(buildSet(ConcurrentSimDataEnumMock.FIELD1_INT),sut.getUpdatedAttributes());
        assertEquals(1, sut.getValue(ConcurrentSimDataEnumMock.FIELD1_INT));
    }

    @Test
    public void setValue_updatedSinceDifferent(){
        //Setup
        ConcurrentSimData<ConcurrentSimDataEnumMock> sut = new ConcurrentSimData<>(ConcurrentSimDataEnumMock.class,
                ConcurrentSimDataEnumMock.FIELD1_INT);
        sut.setValue(ConcurrentSimDataEnumMock.FIELD1_INT, 1);
        assertEquals(1, sut.getValue(ConcurrentSimDataEnumMock.FIELD1_INT));
        sut.resetUpdateSet();

        //Execute
        sut.setValue(ConcurrentSimDataEnumMock.FIELD1_INT, 5);

        assertEquals(5, sut.getValue(ConcurrentSimDataEnumMock.FIELD1_INT));
        assertEquals(buildSet(ConcurrentSimDataEnumMock.FIELD1_INT),sut.getUpdatedAttributes());
    }

    @Test
    public void setValue_putWithTheSameValue_doesNotTriggerUpdate(){
        //Setup
        ConcurrentSimData<ConcurrentSimDataEnumMock> sut = new ConcurrentSimData<>(ConcurrentSimDataEnumMock.class,
                ConcurrentSimDataEnumMock.FIELD1_INT);
        sut.setValue(ConcurrentSimDataEnumMock.FIELD1_INT, 1);
        assertEquals(1, sut.getValue(ConcurrentSimDataEnumMock.FIELD1_INT));
        sut.resetUpdateSet();


        //Execute
        sut.setValue(ConcurrentSimDataEnumMock.FIELD1_INT, 1);

        assertEquals(0, sut.getUpdatedAttributes().size());
    }

    @Test
    public void setValue_putMultipleFields_BeforeReset(){
        //Setup
        ConcurrentSimData<ConcurrentSimDataEnumMock> sut = new ConcurrentSimData<>(ConcurrentSimDataEnumMock.class,
                ConcurrentSimDataEnumMock.FIELD1_INT);

        //execute
        sut.setValue(ConcurrentSimDataEnumMock.FIELD1_INT, 1);
        sut.setValue(ConcurrentSimDataEnumMock.FIELD2_STR, "Test");
        sut.setValue(ConcurrentSimDataEnumMock.FIELD3_LON, 3);

        assertTrue(sut.getUpdatedAttributes().containsAll(buildSet(ConcurrentSimDataEnumMock.FIELD1_INT,
                ConcurrentSimDataEnumMock.FIELD2_STR, ConcurrentSimDataEnumMock.FIELD3_LON)));
    }




    private enum ConcurrentSimDataEnumMock{
        FIELD1_INT,
        FIELD2_STR,
        FIELD3_LON
    }

    private Set<ConcurrentSimDataEnumMock> buildSet(ConcurrentSimDataEnumMock ... enumMocks){
        HashSet<ConcurrentSimDataEnumMock> enumSet = new HashSet<>();
        enumSet.addAll(List.of(enumMocks));
        return enumSet;
    }

}
