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

package com.ivir.mpif.common;

import java.io.Serializable;
import java.util.Objects;

public class PatientId implements Serializable, Comparable<PatientId>{
    private String patientId;

    public PatientId(String patientId){
        if(patientId != null){
            this.patientId = patientId.trim();
        }
    }

    public String getIdAsString(){
        return this.patientId;
    }

    public void setId(String id) {
        if (id == null) {
            this.patientId = null;
        } else {
            this.patientId = patientId.trim();
        }
    }

    public boolean isEmpty(){
        if(patientId == null){
            return true;
        }
        return patientId.isEmpty();
    }

    @Override
    public String toString(){
        return this.patientId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PatientId patientId1 = (PatientId) o;
        return Objects.equals(patientId, patientId1.patientId);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(patientId);
    }

    //---------------------------------------------------------------------------------------------
    //                                Comparable Implementation
    //---------------------------------------------------------------------------------------------

    @Override
    public int compareTo(PatientId o) {
        if(o == null){
            return 1;
        }
        return this.patientId.compareTo(o.patientId);
    }
}
