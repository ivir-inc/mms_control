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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class TcccSimDataService extends ConcurrentDataStorage<Tccc, Tccc.Attributes> {
   private static final Logger logger = LoggerFactory.getLogger(TcccSimDataService.class);

    public TcccSimDataService() {
        super(Tccc.class);
    }

    public Optional<Tccc> getByPatientId(String patientId){
        if((patientId == null) || patientId.isBlank()){
            logger.debug("getByPatientId() called with null or blank patientId");
            return Optional.empty();
        }
        return super.searchByAttribute(Tccc.Attributes.PATIENT_ID_STR, patientId).stream().findFirst();
    }

    public Optional<Tccc> getByInstanceName(String instanceName){
        if((instanceName == null) || instanceName.isBlank()){
            logger.debug("getByInstanceName() called with null or blank instanceName");
            return Optional.empty();
        }
        return searchByAttribute(Tccc.Attributes.INSTANCE_NAME_STR, instanceName).stream().findFirst();
    }

}
