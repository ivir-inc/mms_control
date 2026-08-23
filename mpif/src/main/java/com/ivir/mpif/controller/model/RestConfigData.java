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

public class RestConfigData {
    private String facility;
    private Boolean showExternalPatients;


    public String getFacility() {
        return this.facility;
    }

    public RestConfigData setFacility(String facility) {
        this.facility = facility;
        return this;
    }

    public Boolean getShowExternalPatients() {
        return this.showExternalPatients;
    }

    public RestConfigData setShowExternalPatients(Boolean showExternalPatients) {
        this.showExternalPatients = showExternalPatients;
        return this;
    }
    

    @Override
    public String toString() {
        return "{" +
            " facility='" + getFacility() + "'" +
            ", showExternalPatients='" + getShowExternalPatients() + "'" +
            "}";
    }
    

    
}
