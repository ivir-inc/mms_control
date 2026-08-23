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

import com.ivir.mpif.pcb.PatientCase;
import jakarta.annotation.PostConstruct;
import org.dizitart.no2.Nitrite;
import org.dizitart.no2.repository.ObjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class PatientCaseRepository {
    private static int caseNumCounter = 0;
    private ObjectRepository<PatientCase> repository;

    @Autowired
    private Nitrite nitrite;

    @PostConstruct
    public void init(){
        repository = nitrite.getRepository(PatientCase.class);
    }

    public PatientCase add(PatientCase entity){
        if(entity.getCaseNum() != null){
            throw new IllegalArgumentException("case num must be null for insert");
        }
        entity.setCaseNum(caseNumCounter ++);
        repository.insert(entity);
        return entity;
    }

    public void update(PatientCase entity){
        repository.update(entity);
    }

    public PatientCase getByCaseNum(Integer caseNum){
        return repository.getById(caseNum);
    }

    public List<PatientCase> getAll(){
        return repository.find().toList();
    }

    public PatientCase deleteByCaseNum(Integer caseNum){
        PatientCase patientCase = getByCaseNum(caseNum);
        if(patientCase == null){
            return null;
        }
        repository.remove(patientCase);
        return patientCase;
    }

    public static int getNextCaseNum(){
        return caseNumCounter;
    }

}
