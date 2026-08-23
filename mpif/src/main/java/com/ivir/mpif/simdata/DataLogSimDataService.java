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

/**
 *
 * @author blewa
 */
public class DataLogSimDataService {
    DataStorage<DataLog> dataStore = new DataStorage<>();
    
    public void addDataLog(DataLog log){
        dataStore.add(log);
    }
    
    public DataLog getDataLog(String instanceName){
        return dataStore.get(instanceName);
    }
    
    public void addDataLogStorageListener(DataStorageListener<DataLog> listener){
        dataStore.addDataStorageListener(listener);
    }
    
    public void addDataLogUpdateListener(String id, EntityUpdateListener<DataLog> listener){
        dataStore.addEntityUpdateListener(id, listener);
    }    
}
