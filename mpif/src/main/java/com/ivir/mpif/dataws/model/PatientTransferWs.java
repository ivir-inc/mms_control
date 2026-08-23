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

package com.ivir.mpif.dataws.model;

import com.ivir.mpif.simdata.TransferState;

public class PatientTransferWs {
    private String patientId;
    private String transferState;
    private String originFacilityId;
    private String destinationFacilityId;

    public String getPatientId() {
        return patientId;
    }

    public PatientTransferWs setPatientId(String patientId) {
        this.patientId = patientId;
        return this;
    }

    public String getTransferState() {
        return transferState;
    }

    public PatientTransferWs setTransferState(String transferState) {
        this.transferState = transferState;
        return this;
    }

    public String getOriginFacilityId() {
        return originFacilityId;
    }

    public PatientTransferWs setOriginFacilityId(String originFacilityId) {
        this.originFacilityId = originFacilityId;
        return this;
    }

    public String getDestinationFacilityId() {
        return destinationFacilityId;
    }

    public PatientTransferWs setDestinationFacilityId(String destinationFacilityId) {
        this.destinationFacilityId = destinationFacilityId;
        return this;
    }

}
