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

import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import static com.ivir.mpif.simdata.ConcurrentSimDataMock.ConcurrentSimDataEnumMock.*;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(classes = ConcurrentDataStorageTest.class)
public class ConcurrentDataStorageTest {

    private ConcurrentDataStorage<ConcurrentSimDataMock, ConcurrentSimDataMock.ConcurrentSimDataEnumMock> sut = new ConcurrentDataStorage(ConcurrentSimDataMock.class);

    @Test
    public void add_withAutoIncrementObject_UpdatesTheId(){
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock();
        simData.setValue(FIELD1_INT, 1);
        simData.setValue(FIELD2_STR, "TEST");
        sut.add(simData);

        simData = sut.get(0l);
        assertEquals(1, simData.getValue(FIELD1_INT,Integer.class));
        assertEquals("TEST", simData.getValue(FIELD2_STR, String.class));
        assertEquals("0", simData.getIndex());


        simData = new ConcurrentSimDataMock();
        simData.setValue(FIELD1_INT, 33);
        simData.setValue(FIELD2_STR, "Another add");
        sut.add(simData);


        simData = sut.get(1l);
        assertEquals(33, simData.getValue(FIELD1_INT,Integer.class));
        assertEquals("Another add", simData.getValue(FIELD2_STR, String.class));
        assertEquals("1", simData.getIndex());
    }

    @Test
    public void add_withAutoIncrementObject_ThrowExceptionIfIndexIsSet() {
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD3_LON, true);
        simData.setValue(FIELD3_LON,3l); //this is the index field
        try {
            sut.add(simData);
            fail("Add should have thrown an exception");
        }catch (Exception e){
            assertTrue(e.getMessage().contains("Index must be null"));
        }
    }

    @Test
    public void add_noAutoIncrement_storesWithProvidedIndex(){
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD2_STR, false);
        simData.setValue(FIELD2_STR, "Index A");
        simData.setValue(FIELD3_LON, 22l);
        sut.add(simData);

        simData = sut.get("Index A");
        assertEquals(22l, simData.getValue(FIELD3_LON,Long.class));
        assertEquals("Index A", simData.getValue(FIELD2_STR, String.class));
    }

    @Test
    public void add_noAutoIncrement_failsIfIndexFieldIsNotSet(){
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD2_STR, false);
        simData.setValue(FIELD3_LON, 22l);
        try {
            sut.add(simData);
            fail("Add should have thrown an exception since FIELD2 is not set");
        }catch(Exception e){
            assertTrue(e.getMessage().contains("index field must be set"));
        }
    }

    @Test
    public void add_noAutoIncrement_failsIfAddedTwice(){
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD1_INT, false);
        simData.setValue(FIELD1_INT, 5);
        simData.setValue(FIELD2_STR, "TEST");
        sut.add(simData);

        simData = new ConcurrentSimDataMock(FIELD1_INT, false);
        simData.setValue(FIELD1_INT, 5);
        simData.setValue(FIELD2_STR, "TEST Again");
        try {
            sut.add(simData);
            fail("Should not be allowed to be added since field 1 is the same number");
        }catch (Exception e){
            assertTrue(e.getMessage().contains("already exists"));
        }
    }

    @Test
    public void add_sendsEntityWithChanges() throws InterruptedException {
        ListenerMock listenerMock = new ListenerMock();
        sut.addDataStorageListener(listenerMock);

        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD1_INT, false);
        simData.setValue(FIELD1_INT, 5);
        simData.setValue(FIELD2_STR, "TEST");
        sut.add(simData);

        listenerMock.waitForDone.take();
        assertEquals(buildSet(FIELD1_INT, FIELD2_STR), listenerMock.entity.getUpdatedAttributes());
        assertEquals(5, listenerMock.entity.getValue(FIELD1_INT, Integer.class));
        assertEquals("TEST", listenerMock.entity.getValue(FIELD2_STR, String.class));
    }

    @Test
    public void put_updatesEntity() throws InterruptedException {
        ListenerMock listenerMock = new ListenerMock();

        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD1_INT, false);
        simData.setValue(FIELD1_INT, 5);
        simData.setValue(FIELD2_STR, "TEST");
        sut.add(simData);

        simData = sut.get(5);
        sut.addDataStorageListener(listenerMock);
        simData.setValue(FIELD3_LON, 3234323l);
        sut.put(simData);
        listenerMock.waitForDone.take();

        assertEquals(buildSet(FIELD3_LON), listenerMock.entity.getUpdatedAttributes());
        assertEquals("TEST", simData.getValue(FIELD2_STR, String.class));
    }

    @Test
    public void searchByAttribute_findItem(){
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD3_LON, true);
        simData.setValue(FIELD2_STR,"TEST");
        sut.add(simData);

        simData = new ConcurrentSimDataMock(FIELD3_LON, true);
        simData.setValue(FIELD1_INT,33);
        sut.add(simData);

        List<ConcurrentSimDataMock> searchList = sut.searchByAttribute(FIELD2_STR,"TEST");
        assertEquals(1, searchList.size());
        assertEquals("TEST", searchList.get(0).getValue(FIELD2_STR,String.class));
    }

    @Test
    public void getAllOrderAdded_WhenEmpty_ReturnsEmptyList(){
        assertEquals(0, sut.getAllOrderAdded().size());
    }

    @Test
    public void getAllOrderAdded_WithAdd_GetsFromFirstToLast(){
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev1");
        sut.add(simData);

        simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev2");
        sut.add(simData);

        simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev3");
        sut.add(simData);

        List<ConcurrentSimDataMock> addedList= sut.getAllOrderAdded();
        assertEquals("ev1", addedList.get(0).getValue(FIELD2_STR,String.class));
        assertEquals("ev2", addedList.get(1).getValue(FIELD2_STR,String.class));
        assertEquals("ev3", addedList.get(2).getValue(FIELD2_STR,String.class));
    }

    @Test
    public void getAllOrderedAdded_WithPutAndAdd_GetsFromFirstToLast(){
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev1");
        sut.add(simData);

        simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev2");
        sut.put(simData);

        simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev3");
        sut.add(simData);

        List<ConcurrentSimDataMock> addedList= sut.getAllOrderAdded();
        assertEquals("ev1", addedList.get(0).getValue(FIELD2_STR,String.class));
        assertEquals("ev2", addedList.get(1).getValue(FIELD2_STR,String.class));
        assertEquals("ev3", addedList.get(2).getValue(FIELD2_STR,String.class));
    }

    @Test
    public void getAllOrderedAdded_WithDelete_GetsFromFirstToLastExcludingDeleted(){
        ConcurrentSimDataMock simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev1");
        sut.add(simData);

        simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev2");
        sut.add(simData);

        simData = new ConcurrentSimDataMock(FIELD1_INT, true);
        simData.setValue(FIELD2_STR,"ev3");
        sut.add(simData);

        //delete the second one
        sut.delete(1);

        List<ConcurrentSimDataMock> addedList= sut.getAllOrderAdded();
        assertEquals(2, addedList.size());
        assertEquals("ev1", addedList.get(0).getValue(FIELD2_STR,String.class));
        assertEquals("ev3", addedList.get(1).getValue(FIELD2_STR,String.class));
    }

    private Set<ConcurrentSimDataMock.ConcurrentSimDataEnumMock> buildSet(ConcurrentSimDataMock.ConcurrentSimDataEnumMock... enumMocks){
        HashSet<ConcurrentSimDataMock.ConcurrentSimDataEnumMock> enumSet = new HashSet<>();
        enumSet.addAll(List.of(enumMocks));
        return enumSet;
    }

    class ListenerMock implements ConcurrentDataStorageListener<ConcurrentSimDataMock>{
        public ConcurrentSimDataMock entity;
        public ArrayBlockingQueue<Boolean> waitForDone = new ArrayBlockingQueue<>(1);

        public ListenerMock(){
            entity = null;
            waitForDone = new ArrayBlockingQueue<>(1);
        }

        @Override
        public void entityAdded(ConcurrentSimDataMock newEntity) {
            try {
                entity = newEntity;
                waitForDone.put(true);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        }

        @Override
        public void entityUpdated(ConcurrentSimDataMock updatedEntity) {
            try {
                entity = updatedEntity;
                waitForDone.put(true);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        }
    }
}
