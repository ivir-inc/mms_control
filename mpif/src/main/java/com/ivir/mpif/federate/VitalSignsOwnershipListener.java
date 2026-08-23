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

package com.ivir.mpif.federate;

import com.ivir.mpif.simdata.ConcurrentDataStorage;
import com.ivir.mpif.simdata.OwnershipState;
import com.ivir.mpif.simdata.VitalSigns;
import com.ivir.mpif.simdata.VitalSignsSimDataService;
import devstudio.generatedcode.HlaUserSuppliedTag;
import devstudio.generatedcode.HlaVitalSigns;
import devstudio.generatedcode.HlaVitalSignsAttributes;
import devstudio.generatedcode.HlaVitalSignsOwnershipListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.stream.Collectors;

public class VitalSignsOwnershipListener implements HlaVitalSignsOwnershipListener {
    Logger logger = LoggerFactory.getLogger(VitalSignsOwnershipListener.class);
    private VitalSignsSimDataService vitalSignsSimDataService;

    public VitalSignsOwnershipListener(VitalSignsSimDataService vitalSignsSimDataService){
        this.vitalSignsSimDataService = vitalSignsSimDataService;
    }

    @Override
    public void releaseOwnershipRequested(HlaVitalSigns hlaVitalSigns, Set<HlaVitalSignsAttributes.Attribute> set, HlaUserSuppliedTag<Object> hlaUserSuppliedTag) {
        if (hlaVitalSigns.hasPatientId()){
            VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(hlaVitalSigns.getPatientId());
            if(vitalSigns != null){
                vitalSigns.setOwnershipState(OwnershipState.RELEASE_OWNERSHIP_REQUESTED);
                vitalSignsSimDataService.put(vitalSigns);
                try {
                    logWarningIfNotFullSet(set);
                    hlaVitalSigns.releaseOwnership(set);
                } catch (Exception e) {
                    logger.error("Could not release ownership of VitalSigns for patientId {}", hlaVitalSigns.getPatientId(), e);
                }
                vitalSigns.setOwnershipState(OwnershipState.OWNERSHIP_RELEASED);
                vitalSignsSimDataService.put(vitalSigns);
            }
        }
    }

    @Override
    public void ownershipAcquired(HlaVitalSigns hlaVitalSigns, Set<HlaVitalSignsAttributes.Attribute> set, HlaUserSuppliedTag<Object> hlaUserSuppliedTag) {
        if (hlaVitalSigns.hasPatientId()){
            VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(hlaVitalSigns.getPatientId());
            if(vitalSigns != null){
                vitalSigns.setOwnershipState(OwnershipState.OWNERSHIP_ACQUIRED);
                vitalSignsSimDataService.put(vitalSigns);
            }
        }
    }

    @Override
    public void ownershipOffered(HlaVitalSigns hlaVitalSigns, Set<HlaVitalSignsAttributes.Attribute> set, HlaUserSuppliedTag<Object> hlaUserSuppliedTag) {
        if (hlaVitalSigns.hasPatientId()){
            VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(hlaVitalSigns.getPatientId());
            if(vitalSigns != null){
                vitalSigns.setOwnershipState(OwnershipState.OWNERSHIP_OFFERED);
                vitalSignsSimDataService.put(vitalSigns);
            }
        }
    }

    @Override
    public void attributeOwnershipDenied(HlaVitalSigns hlaVitalSigns, Set<HlaVitalSignsAttributes.Attribute> set) {
        if (hlaVitalSigns.hasPatientId()){
            VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(hlaVitalSigns.getPatientId());
            if(vitalSigns != null){
                vitalSigns.setOwnershipState(OwnershipState.ATTRIBUTE_OWNERSHIP_DENIED);
                vitalSignsSimDataService.put(vitalSigns);
            }
        }
    }

    @Override
    public void cancelAcquireOwnershipSucceeded(HlaVitalSigns hlaVitalSigns, Set<HlaVitalSignsAttributes.Attribute> set) {
        if (hlaVitalSigns.hasPatientId()){
            VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(hlaVitalSigns.getPatientId());
            if(vitalSigns != null){
                vitalSigns.setOwnershipState(OwnershipState.CANCEL_ACQUIRE_OWNERSHIP_SUCCEEDED);
                vitalSignsSimDataService.put(vitalSigns);
            }
        }
    }

    private void logWarningIfNotFullSet(Set<HlaVitalSignsAttributes.Attribute> acquireRequestSet){
        List<String> missingAttributes = new ArrayList<>();
        for (HlaVitalSignsAttributes.Attribute attribute : HlaVitalSignsAttributes.Attribute.values()) {
            if (!acquireRequestSet.contains(attribute) && !attribute.equals(HlaVitalSignsAttributes.Attribute.HLA_PRIVILEGE_TO_DELETE_OBJECT)) {
                missingAttributes.add(attribute.name());
            }
        }
        if(missingAttributes.size() > 0){
            logger.warn("Releasing ownership of VitalSigns with missing attributes: {}", String.join(", ", missingAttributes));
        }
    }
}
