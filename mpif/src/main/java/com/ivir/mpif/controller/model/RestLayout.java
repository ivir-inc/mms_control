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

import java.util.List;

public class RestLayout {
    List<RestCategory> treatments;
    List<RestCategory> medications;

    public List<RestCategory> getTreatments() {
        return treatments;
    }

    public RestLayout setTreatments(List<RestCategory> treatments) {
        this.treatments = treatments;
        return this;
    }

    public List<RestCategory> getMedications() {
        return medications;
    }

    public RestLayout setMedications(List<RestCategory> medications) {
        this.medications = medications;
        return this;
    }
}
