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

package com.ivir.mpif.treatment.data;

import com.ivir.mpif.simdata.BodyLocationCoarse;
import com.ivir.mpif.simdata.PhysicalTreatmentType;
import com.ivir.mpif.simdata.TreatmentDevice;

public class PhysicalTreatmentDetail {
    private String treatmentName = null;
    private PhysicalTreatmentType physicalTreatment = null;
    private TreatmentDevice device = null;
    private BodyLocationCoarse location = null;
    
    public PhysicalTreatmentDetail(String name){
        this.treatmentName = name;
    }

    public String getTreatmentName(){
        return this.treatmentName;
    }
    
    public PhysicalTreatmentDetail setTreatmentName(String name){
        this.treatmentName = name;
        return this;
    }
    
    public PhysicalTreatmentType getPhysicalTreatmentType() {
        return physicalTreatment;
    }

    public PhysicalTreatmentDetail setPhysicalTreatmentType(PhysicalTreatmentType treatmentType) {
        this.physicalTreatment = treatmentType;
        return this;
    }

    public TreatmentDevice getDevice() {
        return device;
    }

    public PhysicalTreatmentDetail setDevice(TreatmentDevice device) {
        this.device = device;
        return this;
    }

    public BodyLocationCoarse getLocation() {
        return location;
    }

    public PhysicalTreatmentDetail setLocation(BodyLocationCoarse location) {
        this.location = location;
        return this;
    }

    @Override
    public String toString() {
        return "TreatmentDetail{" + "treatmentName=" + treatmentName + ", physicalTreatment=" + physicalTreatment + ", device=" + device + ", location=" + location + '}';
    }
}
