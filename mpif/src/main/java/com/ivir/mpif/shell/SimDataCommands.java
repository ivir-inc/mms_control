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

package com.ivir.mpif.shell;

import com.ivir.mpif.simdata.ConcurrentDataStorage;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.shell.standard.ShellComponent;
import org.springframework.shell.standard.ShellMethod;
import org.springframework.shell.standard.ShellOption;

import java.util.HashMap;
import java.util.List;

@ShellComponent
public class SimDataCommands {
    @Autowired
    List<ConcurrentDataStorage<?, ?>> concurrentDataStorages;

    private HashMap<String , ConcurrentDataStorage<?, ?>> concurrentDataStorageMap = new HashMap<>();

    @PostConstruct
    public void init() {

        concurrentDataStorages.forEach(storage -> {
            concurrentDataStorageMap.put(storage.getType().getSimpleName(), storage);
        });
    }

    @ShellMethod(key = "listDataStorage", value = "List all data storage services")
    public void listDateStorage(){
        concurrentDataStorageMap.forEach((name, storage) -> {
            System.out.println(name + ": " + storage.storageSize());
        });
    }

    @ShellMethod(key = "queryDataStorage", value = "Query a specific data storage by name")
    public void queryDataStorage(@ShellOption(defaultValue = "NONE") String storageName) {
        if(storageName.equals("NONE")){
            System.out.println("Please provide a storage name");
            return;
        }
        ConcurrentDataStorage<?, ?> storage = concurrentDataStorageMap.get(storageName);
        if(storage == null){
            System.out.println("Storage with name: " + storageName + " not found");
            return;
        }
        System.out.println("Storage: " + storageName + " contains " + storage.storageSize() + " entities.");
        storage.getAll().forEach(entity -> {
            System.out.println(entity.toString());
        });
    }
}
