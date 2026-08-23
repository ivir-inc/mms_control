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
import java.util.Optional;

@Component
public class BodyFluidsSimDataService extends ConcurrentDataStorage<BodyFluids, BodyFluids.Attributes>{
    public BodyFluidsSimDataService(){
        super(BodyFluids.class);
    }

    public Optional<BodyFluids> getBodyFluids(String id){
        return Optional.ofNullable(super.get(id));
    }

    public Optional<BodyFluids> getBodyFluidsByInstanceName(String instanceName){
        return getFirstOrNull(super.searchByAttribute(BodyFluids.Attributes.INSTANCE_NAME_STR,instanceName));
    }

    public Optional<BodyFluids> getBodyFluidsByPatientId(String patientId){
        return getFirstOrNull(super.searchByAttribute(BodyFluids.Attributes.PATIENT_ID_STR,patientId));
    }

    private Optional<BodyFluids> getFirstOrNull(ArrayList<BodyFluids> returnList){
        if(returnList.isEmpty()){
            return Optional.empty();
        }else{
            return Optional.ofNullable(returnList.get(0));
        }
    }

    public void addBodyFluids(BodyFluids bodyFluids){
        if(bodyFluids.getInstanceName() == null){
            bodyFluids.setInstanceName("MPIF: " + bodyFluids.getAutoId());
        }
        super.add(bodyFluids);
    }

    public void putBodyFluids(BodyFluids bodyFluids) {
        super.put(bodyFluids);
    }

    public ArrayList<BodyFluids> getAllBodyFluids(){
        return new ArrayList<BodyFluids>(super.getAll());
    }

}
