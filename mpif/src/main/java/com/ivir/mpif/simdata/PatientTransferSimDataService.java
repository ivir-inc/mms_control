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
public class PatientTransferSimDataService extends ConcurrentDataStorage<PatientTransfer, PatientTransfer.Attributes> {

    public PatientTransferSimDataService() {
        super(PatientTransfer.class);
    }

    public PatientTransfer getPatientTransferByPatientId(String patientId) {
        return super.get(patientId);
    }

    private PatientTransfer getFirstOrNull(java.util.ArrayList<PatientTransfer> returnList) {
        if (returnList.isEmpty()) {
            return null;
        } else {
            return returnList.get(0);
        }
    }

    public void addPatientTransfer(PatientTransfer pt) {
        super.add(pt);
    }

    public void putPatientTransferDoNotFireListeners(PatientTransfer patientTransfer) {
        super.put(patientTransfer, true);
    }
}
