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

import com.ivir.mpif.simdata.EvacuationPriority;
import com.ivir.mpif.simdata.TriageClassification;

public class RestCasualtyState {
    private String id;
    private Boolean local;
    private String instanceName;
    private String facilityId;
    private String patientId;
    private EvacuationPriority evacuationPriority;
    private TriageClassification triageClassification;

    public String getId() {
        return id;
    }

    public RestCasualtyState setId(String id) {
        this.id = id;
        return this;
    }

    public Boolean isLocal() {
        return local;
    }

    public RestCasualtyState setLocal(Boolean local) {
        this.local = local;
        return this;
    }

    public String getInstanceName() {
        return instanceName;
    }

    public RestCasualtyState setInstanceName(String instanceName) {
        this.instanceName = instanceName;
        return this;
    }

    public String getFacilityId() {
        return facilityId;
    }

    public RestCasualtyState setFacilityId(String facilityId) {
        this.facilityId = facilityId;
        return this;
    }

    public String getPatientId() {
        return patientId;
    }

    public RestCasualtyState setPatientId(String patientId) {
        this.patientId = patientId;
        return this;
    }

    public EvacuationPriority getEvacuationPriority() {
        return evacuationPriority;
    }

    public RestCasualtyState setEvacuationPriority(EvacuationPriority evacuationPriority) {
        this.evacuationPriority = evacuationPriority;
        return this;
    }

    public TriageClassification getTriageClassification() {
        return triageClassification;
    }

    public RestCasualtyState setTriageClassification(TriageClassification triageClassification) {
        this.triageClassification = triageClassification;
        return this;
    }
}
