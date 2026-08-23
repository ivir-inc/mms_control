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

package com.ivir.mpif.patient.db;

import com.ivir.mpif.patient.PatientSource;
import jakarta.annotation.PostConstruct;
import org.dizitart.no2.Nitrite;
import org.dizitart.no2.collection.Document;
import org.dizitart.no2.collection.events.CollectionEventInfo;
import org.dizitart.no2.collection.events.CollectionEventListener;
import org.dizitart.no2.repository.ObjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Consumer;

@Component
public class PatientRepository {
    private @Autowired Nitrite nitrite;
    private ObjectRepository<PatientEntity> repository;

    @PostConstruct
    public void init(){
        repository = nitrite.getRepository(PatientEntity.class);
    }

    public PatientEntity getById(String id) {
        return repository.getById(id);
    }

    public void update(PatientEntity patientEntity) {
        repository.update(patientEntity);
    }

    public List<PatientEntity> getAll(){
        return repository.find().toList();
    }

    public void insert(PatientEntity patientEntity){
        repository.insert(patientEntity);
    }

    public void remove(PatientEntity patientEntity){
        repository.remove(patientEntity);
    }

    public void addListener(Consumer<PatientEntity> newPatientConsumer,
                            Consumer<PatientEntity> updatedConsumer,
                            Consumer<PatientEntity> removedConsumer){
        repository.subscribe(new PatientEventListener(newPatientConsumer, updatedConsumer, removedConsumer));
    }

    private class PatientEventListener implements CollectionEventListener{
        private Consumer<PatientEntity> _newConsumer;
        private Consumer<PatientEntity> _updatedConsumer;
        private Consumer<PatientEntity> _removedConsumer;

        public PatientEventListener(Consumer<PatientEntity> newPatientConsumer,
                                    Consumer<PatientEntity> updatedConsumer,
                                    Consumer<PatientEntity> removedConsumer){
            _newConsumer = newPatientConsumer;
            _updatedConsumer = updatedConsumer;
            _removedConsumer = removedConsumer;
        }

        @Override
        public void onEvent(CollectionEventInfo<?> collectionEventInfo) {
            try {
                Document document = (Document) collectionEventInfo.getItem();
                PatientEntity patientEntity = new PatientEntity();
                patientEntity.setPatientCaseNum(document.get("patientCaseNum", Integer.class));
                patientEntity.setId(document.get("id", String.class));
                patientEntity.setPhysiologySource(toPatientSource(document.get("physiologySource")));
                patientEntity.setVisible(document.get("visible", Boolean.class));
                patientEntity.setSourceLocked(document.get("sourceLocked", Boolean.class));

                switch (collectionEventInfo.getEventType()) {
                    case Insert -> _newConsumer.accept(patientEntity);
                    case Remove -> _removedConsumer.accept(patientEntity);
                    default -> _updatedConsumer.accept(patientEntity);
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        }
    }

    private PatientSource toPatientSource(Object value){
        if(value == null){
            return null;
        }
        return PatientSource.valueOf(value.toString());
    }
}
