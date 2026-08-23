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

public class RestPCPhysicalTreatment {
    private String injuryName;
    private RestBodyLocation location;
    private String physicalTreatment;
    private String physicalDevice;

    public String getInjuryName() {
        return injuryName;
    }

    public RestPCPhysicalTreatment setInjuryName(String injuryName) {
        this.injuryName = injuryName;
        return this;
    }

    public RestBodyLocation getLocation() {
        return location;
    }

    public RestPCPhysicalTreatment setLocation(RestBodyLocation location) {
        this.location = location;
        return this;
    }

    public String getPhysicalTreatment() {
        return physicalTreatment;
    }

    public RestPCPhysicalTreatment setPhysicalTreatment(String physicalTreatment) {
        this.physicalTreatment = physicalTreatment;
        return this;
    }

    public String getPhysicalDevice() {
        return physicalDevice;
    }

    public RestPCPhysicalTreatment setPhysicalDevice(String physicalDevice) {
        this.physicalDevice = physicalDevice;
        return this;
    }
}
