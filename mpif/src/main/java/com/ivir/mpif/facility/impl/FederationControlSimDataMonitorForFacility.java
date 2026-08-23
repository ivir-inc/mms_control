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

package com.ivir.mpif.facility.impl;

import com.ivir.mpif.facility.FacilityService;
import com.ivir.mpif.simdata.*;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class FederationControlSimDataMonitorForFacility implements ConcurrentDataStorageListener<FederationControl> {

    @Autowired
    private FederationControlSimDataService federationControlSimDataService;

    @Autowired
    private FacilityService facilityService;

    @PostConstruct
    public void initialize() {
        federationControlSimDataService.addDataStorageListener(this);
    }

    @Override
    public void entityAdded(FederationControl newEntity) {
        if (newEntity.getCommand() == FederationCommandEnum.START) {
            facilityService.setFederationStarted();
        }
    }

    @Override
    public void entityUpdated(FederationControl entity) {
        // No action needed on update for FederationControl
    }
}
