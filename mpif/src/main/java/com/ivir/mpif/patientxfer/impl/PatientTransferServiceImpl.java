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

package com.ivir.mpif.patientxfer.impl;

import com.ivir.mpif.facility.FacilityService;
import com.ivir.mpif.facility.db.FacilityRecord;
import com.ivir.mpif.federate.VitalSignsAdapter;
import com.ivir.mpif.ownership.OwnershipService;
import com.ivir.mpif.patientxfer.PatientTransferService;
import com.ivir.mpif.simdata.*;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;

@Service
public class PatientTransferServiceImpl implements PatientTransferService, ConcurrentDataStorageListener<VitalSigns>{
    Logger logger = LoggerFactory.getLogger(PatientTransferServiceImpl.class);

    @Autowired
    private PatientTransferSimDataService patientTransferSimDataService;

    @Autowired
    private VitalSignsSimDataService vitalSignsSimDataService;

    @Autowired
    private OwnershipService ownershipService;

    @Autowired
    private MagicTransferSimDataService magicTransferSimDataService;

    @Autowired
    private FacilityService facilityService;

    @Autowired
    private CasualtyStateSimDataService casualtyStateSimDataService;

    @PostConstruct
    public void init(){
        vitalSignsSimDataService.addDataStorageListener(this);
    }

    @Override
    public String initiateTransfer(String patientId, String destinationFacilityId) {
        logger.debug("Initiating transfer for patientId: {}", patientId);

        PatientTransfer patientTransfer = patientTransferSimDataService.getPatientTransferByPatientId(patientId);
        if(patientTransfer == null){
            patientTransfer = new PatientTransfer(patientId);
            patientTransfer.setTransferState(TransferState.AT_ORIGIN);
            patientTransfer.setDestinationFacilityId(destinationFacilityId);
        }

        VitalSigns vitalSigns = vitalSignsSimDataService.getVitalSignsByPatientId(patientId);
        if(vitalSigns == null){
            logger.warn("Cannot initiate transfer - vitals do not exist for patientId: {}", patientId);
            patientTransferSimDataService.put(patientTransfer);
            return "Cannot initiate transfer - vitals do not exist for patientId: " + patientId;
        }
        if(!vitalSigns.getOwnershipState().hasOwnership()){
            logger.debug("we do not own this patient, acquiring ownership for transfer");
            transferFromOrigin(vitalSigns, patientTransfer);
        }else{
            logger.debug("we already own this patient, transferring to holding");
            transferToRequestForTransfer(vitalSigns, patientTransfer);
        }

        return "";
    }

    private void transferFromOrigin(VitalSigns vitalSigns, PatientTransfer patientTransfer){
        patientTransfer.setTransferState(TransferState.TRANSITING_FROM_ORIGIN);
        patientTransferSimDataService.put(patientTransfer);
        ownershipService.acquireOwnership(vitalSigns.getId());
    }

    private void transferToHolding(VitalSigns vitalSigns, PatientTransfer patientTransfer){
        patientTransfer.setTransferState(TransferState.IN_HOLDING);
//        patientTransferSimDataService.put(patientTransfer);

        boolean controlledLocally = checkIfDestinationControlledLocally(patientTransfer);

        if(controlledLocally){
            logger.debug("Destination facility is controlled locally, transferring directly to destination");
            transferToDestination(vitalSigns, patientTransfer);
        }else{
            logger.debug("Destination facility is NOT controlled locally");
            transferToRequestForTransfer(vitalSigns, patientTransfer);
        }
    }

    private boolean checkIfDestinationControlledLocally(PatientTransfer patientTransfer){
        if(patientTransfer.getDestinationFacilityId() == null){
            return false;
        }
        FacilityRecord record = facilityService.getFacilityRecordByFacilityId(
                patientTransfer.getDestinationFacilityId())
                .orElse(new FacilityRecord().setControlledLocal(false));
        return record.getControlledLocal();
    }

    private void transferToRequestForTransfer(VitalSigns vitalSigns, PatientTransfer patientTransfer){
        patientTransfer.setTransferState(TransferState.REQUEST_FOR_TRANSFER);
        patientTransferSimDataService.put(patientTransfer);
        MagicTransfer magicTransfer = new MagicTransfer();
        magicTransfer.setPatientId(vitalSigns.getId());
        String destinationFacilityId = patientTransfer.getDestinationFacilityId() != null ?
                patientTransfer.getDestinationFacilityId() : "TBD";
        magicTransfer.setFacilityId(destinationFacilityId);
        magicTransfer.setLocal(true);
        magicTransferSimDataService.add(magicTransfer);
    }

    private void transferFromRequestForTransfer(VitalSigns vitalSigns, PatientTransfer patientTransfer){
        patientTransfer.setTransferState(TransferState.TRANSITING_TO_DESTINATION);
        patientTransferSimDataService.put(patientTransfer);
    }

    private void transferToDestination(VitalSigns vitalSigns, PatientTransfer patientTransfer){
        patientTransfer.setTransferState(TransferState.AT_DESTINATION);
        patientTransferSimDataService.put(patientTransfer);
        CasualtyState casualtyState = getOrCreateCasualtyState(vitalSigns.getId());
        casualtyState.setFacilityId(patientTransfer.getDestinationFacilityId());
        casualtyStateSimDataService.put(casualtyState);
    }

    private CasualtyState getOrCreateCasualtyState(String patientId){
        CasualtyState casualtyState = casualtyStateSimDataService.getByPatientId(patientId);
        if(casualtyState == null){
            casualtyState = new CasualtyState();
            casualtyState.setPatientId(patientId);
            casualtyState.setLocal(true);
        }
        return casualtyState;
    }

    // --------------------------------------------------------------------------------------------------------------
    // ConcurrentDataStorageListener<VitalSigns> implementation
    // --------------------------------------------------------------------------------------------------------------

    @Override
    public void entityAdded(VitalSigns newEntity) {
        PatientTransfer patientTransfer = patientTransferSimDataService.getPatientTransferByPatientId(newEntity.getId());
        assessEntitiesForNextStep(newEntity, patientTransfer);
    }

    @Override
    public void entityUpdated(VitalSigns entity) {
        PatientTransfer patientTransfer = patientTransferSimDataService.getPatientTransferByPatientId(entity.getId());
        assessEntitiesForNextStep(entity, patientTransfer);
    }

    private void assessEntitiesForNextStep(VitalSigns vitalSigns, PatientTransfer patientTransfer) {
        if (patientTransfer == null) {
            return;
        }
        if (patientTransfer.getTransferState() == TransferState.TRANSITING_FROM_ORIGIN) {
            if (vitalSigns.getOwnershipState() == OwnershipState.OWNERSHIP_ACQUIRED) {
                logger.debug("Ownership acquired for patientId: {}, transferring to holding", vitalSigns.getId());
                transferToHolding(vitalSigns, patientTransfer);
            }
        }
        if (patientTransfer.getTransferState() == TransferState.REQUEST_FOR_TRANSFER) {
            if (vitalSigns.getOwnershipState() == OwnershipState.RELEASE_OWNERSHIP_REQUESTED) {
                transferFromRequestForTransfer(vitalSigns, patientTransfer);
            }
            if (vitalSigns.getOwnershipState() == OwnershipState.OWNERSHIP_RELEASED) {
                transferToDestination(vitalSigns, patientTransfer);
            }
        }
        if (patientTransfer.getTransferState() == TransferState.TRANSITING_TO_DESTINATION) {
            if (vitalSigns.getOwnershipState() == OwnershipState.OWNERSHIP_RELEASED) {
                transferToDestination(vitalSigns, patientTransfer);
            }
        }
    }

}
