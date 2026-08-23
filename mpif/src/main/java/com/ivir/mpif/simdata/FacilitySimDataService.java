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

import org.springframework.stereotype.Component;

@Component
public class FacilitySimDataService extends ConcurrentDataStorage<Facility, Facility.Attributes> {
    public FacilitySimDataService() {
        super(Facility.class);
    }

    public Facility getByInstanceName(String instanceName) {
        if (instanceName == null) {
            return null;
        }
        return getAll().stream()
                .filter((facility) -> instanceName.equals(facility.getInstanceName()))
                .findFirst()
                .orElse(null);
    }

    public Facility getByFacilityId(String facilityId) {
        if (facilityId == null) {
            return null;
        }
        return getAll().stream()
                .filter((facility) -> facilityId.equals(facility.getFacilityId()))
                .findFirst()
                .orElse(null);
    }
}
