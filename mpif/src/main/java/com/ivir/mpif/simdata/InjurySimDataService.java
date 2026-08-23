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

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class InjurySimDataService extends ConcurrentDataStorage<Injury, Injury.Attributes>{
    public InjurySimDataService(){
        super(Injury.class);
    }

    public Injury getByInstanceName(String instanceName){
        if(instanceName == null){
            return null;
        }
        return getAll().stream()
                .filter((injury)-> instanceName.equals(injury.getInstanceName()))
                .findFirst()
                .orElse(null);
    }

    public List<Injury> getByPatientId(String patientId){
        if(patientId == null){
            return new ArrayList<Injury>();
        }
        return getAll().stream()
                .filter((injury)->patientId.equals(injury.getPatientId()))
                .toList();
    }

}
