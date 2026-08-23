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

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.ivir.mpif.simdata;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 *
 * @author blewa
 * @param <T>
 */
public class DataStorage<T extends SimData> {
    private final HashMap<String,T> dataMap = new HashMap<>();
    private final CopyOnWriteArrayList<DataStorageListener<T>> dataStorageListenerList = new CopyOnWriteArrayList<>();
    
    protected void add(T newEntity){
        T currentVersion = dataMap.get(newEntity.getIndex());
        if(currentVersion != null){
            throw new RuntimeException("Entity with that index already exists");
        }else{
            dataMap.put(newEntity.getIndex(), newEntity);
            this.fireEntityAdded(newEntity);
        }
    }
        
    protected T get(String indexStr){
        return this.dataMap.get(indexStr);
    }

    protected T delete(String indexStr){
        return this.dataMap.remove(indexStr);
    }
    
    public ArrayList<T> searchByAttribute(SimDataAttribute att, Comparable value) {
        ArrayList<T> foundList = new ArrayList<>();
        for (T item : dataMap.values()) {
            if (value == null) {
                if (item.getValue(att) == null) {
                    foundList.add(item);
                }
            } else if (item.compareValue(att, value) == 0) {
                foundList.add(item);
            }
        }

        return foundList;
    }
    
    public Collection<T> getAll(){
    	return dataMap.values();
    }
    
    public void clearAll() {
    	dataMap.clear();
    }
    
    protected int storageSize(){
        return this.dataMap.size();
    }
    
    private void fireEntityAdded(T entity){
        if(dataStorageListenerList.size() > 0){
            new Thread(() -> dataStorageListenerList.forEach((listener)->listener.entityAdded(entity))).start();
        }
    }
    
    public void addDataStorageListener(DataStorageListener<T> listener){
        this.dataStorageListenerList.add(listener);
    }
    
    public void addEntityUpdateListener(String id, EntityUpdateListener<T> listener){
        T entity = this.dataMap.get(id);
        if(entity == null){
            throw new RuntimeException("You cannot add listener before entity exists");
        }else{
            entity.addEntityUpdateListener(listener);
        }
    }
        
}
