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

package com.ivir.mpif.injury.impl;

import com.ivir.mpif.federate.MmsFederate;
import com.ivir.mpif.injury.InjuryService;
import com.ivir.mpif.simdata.ConcurrentDataStorageListener;
import com.ivir.mpif.simdata.Injury;
import com.ivir.mpif.simdata.InjurySimDataService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class InjuryServiceImpl implements InjuryService {
    private static Logger log = LoggerFactory.getLogger(InjuryServiceImpl.class);
    private static int autoInjuryIdCounter = 0;

    private String fedName = null;

    @Autowired
    InjurySimDataService injurySimDataService;
    @Autowired
    MmsFederate mmsFederate;

    @Override
    public void add(Injury injury) {
        injurySimDataService.add(injury);
    }

    @Override
    public void update(Injury injury) {
        injurySimDataService.put(injury);
    }

    @Override
    public Injury apply(Injury injury) {
        injury.setInjuryId(generatePatientId(injury.getInjuryId(), injury.getName(), injury.getPatientId()));
        injurySimDataService.put(injury);
        return injury;
    }

    @Override
    public Optional<Injury> getByAutoId(String autoId){
        return Optional.ofNullable(injurySimDataService.get(autoId));
    }

    @Override
    public List<Injury> getByPatientId(String patientId) {
        return injurySimDataService.getByPatientId(patientId);
    }

    @Override
    public List<Injury> getAll(){
        return injurySimDataService.getAll().stream().toList();
    }

    @Override
    public void addInjuryListener(ConcurrentDataStorageListener<Injury> listener) {
        injurySimDataService.addDataStorageListener(listener);
    }

    private String generatePatientId(String injuryId, String injuryName, String patientId){
        if(isSet(injuryId)){
            log.trace("InjuryId was provided, using that");
            return injuryId;
        }else if(isSet(injuryName) && isSet(patientId)){
            StringBuilder idBuilder = new StringBuilder();
            idBuilder.append(getFedName())
                    .append("-")
                    .append(patientId)
                    .append("-")
                    .append(injuryName);
            return idBuilder.toString();
        }
        return new StringBuilder(getFedName())
                .append("-")
                .append(autoInjuryIdCounter++)
                .toString();
    }

    private String getFedName(){
        if(fedName == null){
            fedName = mmsFederate.getFederateName();
            if(fedName != null){
                fedName = fedName.toLowerCase();
            }else{
                return "offline";
            }
        }
        return fedName;
    }

    private boolean isSet(String value){
        if(value == null){
            return false;
        }
        return !value.isEmpty();
    }

}
