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

@Component
public class CasualtyStateSimDataService  extends ConcurrentDataStorage<CasualtyState, CasualtyState.Attributes>{

    public CasualtyStateSimDataService() {
        super(CasualtyState.class);
    }

    public CasualtyState getByInstanceName(String instanceName) {
        if (instanceName == null) {
            return null;
        }
        return getAll().stream()
                .filter((casualtyState) -> instanceName.equals(casualtyState.getInstanceName()))
                .findFirst()
                .orElse(null);
    }

    public CasualtyState getByPatientId(String patientId) {
        if (patientId == null) {
            return null;
        }
        return getAll().stream()
                .filter((casualtyState) -> patientId.equals(casualtyState.getPatientId()))
                .findFirst()
                .orElse(null);
    }
}
