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

public class PatientTransfer extends ConcurrentSimData<PatientTransfer.Attributes> {
    public enum Attributes{
        PATIENT_ID_STR,
        TRANSFER_STATE_ENUM,
        ORIGIN_FACILITY_ID_STR,
        DESTINATION_FACILITY_ID_STR
    }

    public PatientTransfer(String patientId){
        super(Attributes.class, Attributes.PATIENT_ID_STR);
        super.setIndex(patientId);
    }

    public String getId(){
        return this.getIndex();
    }

    public String getPatientId(){
        return this.getIndex();
    }

    public PatientTransfer setTransferState(TransferState state){
        this.setValue(Attributes.TRANSFER_STATE_ENUM, state);
        return this;
    }

    public TransferState getTransferState(){
        return this.getValue(Attributes.TRANSFER_STATE_ENUM, TransferState.class);
    }

    public String getOriginFacilityId(){
        return this.getValue(Attributes.ORIGIN_FACILITY_ID_STR, String.class);
    }

    public PatientTransfer setOriginFacilityId(String facilityId){
        this.setValue(Attributes.ORIGIN_FACILITY_ID_STR, facilityId);
        return this;
    }

    public String getDestinationFacilityId(){
        return this.getValue(Attributes.DESTINATION_FACILITY_ID_STR, String.class);
    }

    public PatientTransfer setDestinationFacilityId(String facilityId){
        this.setValue(Attributes.DESTINATION_FACILITY_ID_STR, facilityId);
        return this;
    }

}
