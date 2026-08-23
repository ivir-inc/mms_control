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

package com.ivir.mpif.ownership.impl;
import com.ivir.mpif.ownership.OwnershipService;
import com.ivir.mpif.simdata.VitalSigns;
import com.ivir.mpif.simdata.VitalSignsSimDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OwnershipServiceImpl implements OwnershipService{
    @Autowired
    VitalSignsSimDataService vitalSignsSimDataService;

    @Override
    public void acquireOwnership(String patientId) {
        VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(patientId);
        if (vitalSigns != null) {
            vitalSignsSimDataService.sendEvent(vitalSigns, VitalSignsSimDataService.EVENT_ACQUIRE_OWNERSHIP_REQUESTED);
        }
    }
}
