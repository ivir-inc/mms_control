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

import com.ivir.mpif.simdata.BodyLocationCoarse;
import com.ivir.mpif.simdata.ComparableList;

import java.util.ArrayList;
import java.util.List;

public class RestInjuryLocation {
    public String injuryType = "";
    public List<BodyLocationCoarse> injuryLocation = new ArrayList<>();

    public String getInjuryType() {
        return injuryType;
    }

    public RestInjuryLocation setInjuryType(String injuryType) {
        this.injuryType = injuryType;
        return this;
    }

    public List<BodyLocationCoarse> getInjuryLocation() {
        return injuryLocation;
    }

    public RestInjuryLocation setInjuryLocation(List<BodyLocationCoarse> injuryLocation) {
        this.injuryLocation = injuryLocation;
        return this;
    }
}
