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

public class MagicTransfer  extends ConcurrentSimData<MagicTransfer.Attributes> {
    public enum Attributes {
        ID,
        LOCAL_BOOL,
        PATIENT_ID_STR,
        FACILITY_ID_STR,
    }

    public MagicTransfer() {
        super(MagicTransfer.Attributes.class, Attributes.ID, true);
    }

    public String getId() {
        return this.getIndex();
    }

    public Boolean isLocal() {
        return this.getValue(Attributes.LOCAL_BOOL, Boolean.class);
    }

    public MagicTransfer setLocal(Boolean isLocal) {
        this.setValue(Attributes.LOCAL_BOOL, isLocal);
        return this;
    }

    public String getPatientId() {
        return this.getValue(Attributes.PATIENT_ID_STR, String.class);
    }

    public MagicTransfer setPatientId(String patientId) {
        this.setValue(Attributes.PATIENT_ID_STR, patientId);
        return this;
    }

    public String getFacilityId() {
        return this.getValue(Attributes.FACILITY_ID_STR, String.class);
    }

    public MagicTransfer setFacilityId(String facilityId) {
        this.setValue(Attributes.FACILITY_ID_STR, facilityId);
        return this;
    }
}
