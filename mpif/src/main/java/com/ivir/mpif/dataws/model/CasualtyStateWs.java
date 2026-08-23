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

public class CasualtyStateWs {
    private String id;
    private Boolean local;
    private String instanceName;
    private String facilityId;
    private String patientId;
    private String evacuationPriority;
    private String triageClassification;

    public String getId() {
        return id;
    }

    public CasualtyStateWs setId(String id) {
        this.id = id;
        return this;
    }

    public Boolean getLocal() {
        return local;
    }

    public CasualtyStateWs setLocal(Boolean local) {
        this.local = local;
        return this;
    }

    public String getInstanceName() {
        return instanceName;
    }

    public CasualtyStateWs setInstanceName(String instanceName) {
        this.instanceName = instanceName;
        return this;
    }

    public String getFacilityId() {
        return facilityId;
    }

    public CasualtyStateWs setFacilityId(String facilityId) {
        this.facilityId = facilityId;
        return this;
    }

    public String getPatientId() {
        return patientId;
    }

    public CasualtyStateWs setPatientId(String patientId) {
        this.patientId = patientId;
        return this;
    }

    public String getEvacuationPriority() {
        return evacuationPriority;
    }

    public CasualtyStateWs setEvacuationPriority(String evacuationPriority) {
        this.evacuationPriority = evacuationPriority;
        return this;
    }

    public String getTriageClassification() {
        return triageClassification;
    }

    public CasualtyStateWs setTriageClassification(String triageClassification) {
        this.triageClassification = triageClassification;
        return this;
    }
}
