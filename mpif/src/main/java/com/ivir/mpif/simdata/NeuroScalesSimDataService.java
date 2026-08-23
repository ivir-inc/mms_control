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

import java.util.ArrayList;
import java.util.Optional;

public class NeuroScalesSimDataService extends ConcurrentDataStorage<NeuroScales, NeuroScales.Attributes>{
    public NeuroScalesSimDataService(){
        super(NeuroScales.class);
    }

    public Optional<NeuroScales> getNeuroScales(String id){
        return Optional.ofNullable(super.get(id));
    }

    public Optional<NeuroScales> getNeuroScalesByInstanceName(String instanceName){
        return getFirstOrNull(super.searchByAttribute(NeuroScales.Attributes.INSTANCE_NAME_STR,instanceName));
    }

    public Optional<NeuroScales> getNeuroScalesByPatientId(String patientId){
        return getFirstOrNull(super.searchByAttribute(NeuroScales.Attributes.PATIENT_ID_STR,patientId));
    }

    private Optional<NeuroScales> getFirstOrNull(ArrayList<NeuroScales> returnList){
        if(returnList.isEmpty()){
            return Optional.empty();
        }else{
            return Optional.ofNullable(returnList.get(0));
        }
    }

    public void addNeuroScales(NeuroScales neuroScales){
        if(neuroScales.getInstanceName() == null){
            neuroScales.setInstanceName("MPIF: " + neuroScales.getAutoId());
        }
        super.add(neuroScales);
    }

    public void putNeuroScales(NeuroScales neuroScales) {
        super.put(neuroScales);
    }

    public ArrayList<NeuroScales> getAllNeuroScales(){
        return new ArrayList<NeuroScales>(super.getAll());
    }

}
