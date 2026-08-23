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

package com.ivir.mpif.facility.db;

import jakarta.annotation.PostConstruct;
import org.dizitart.no2.Nitrite;
import org.dizitart.no2.repository.ObjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class FacilityRepository {
    private ObjectRepository<FacilityRecord> repository;

    @Autowired
    private Nitrite nitrite;

    @PostConstruct
    public void init(){
        repository = nitrite.getRepository(FacilityRecord.class);
    }

    public FacilityRecord add(FacilityRecord entity){
        repository.insert(entity);
        return entity;
    }

    public void update(FacilityRecord entity){
        repository.update(entity);
    }

    public FacilityRecord getByFacilityId(String facilityId){
        return repository.getById(facilityId);
    }

    public List<FacilityRecord> getAll(){
        return repository.find().toList();
    }

    public FacilityRecord deleteByFacilityId(String facilityId){
        FacilityRecord facilityRecord = getByFacilityId(facilityId);
        if(facilityRecord == null){
            return null;
        }
        repository.remove(facilityRecord);
        return facilityRecord;
    }
}
