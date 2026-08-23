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

package com.ivir.mpif.controller.model;

public class RestMagicTransfer {
    private String patientId;
    private String facilityId;
    private boolean local;

    public String getPatientId() {
        return patientId;
    }

    public RestMagicTransfer setPatientId(String patientId) {
        this.patientId = patientId;
        return this;
    }

    public String getFacilityId() {
        return facilityId;
    }

    public RestMagicTransfer setFacilityId(String facilityId) {
        this.facilityId = facilityId;
        return this;
    }

    public boolean isLocal() {
        return local;
    }

    public RestMagicTransfer setLocal(boolean local) {
        this.local = local;
        return this;
    }
}
