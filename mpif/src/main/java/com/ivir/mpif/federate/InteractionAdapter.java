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

import com.ivir.mpif.common.PatientId;
import com.ivir.mpif.simdata.*;
import devstudio.generatedcode.*;
import devstudio.generatedcode.datatypes.FederationStateEnum;
import devstudio.generatedcode.datatypes.MedicalEvacuationStateEnum;
import devstudio.generatedcode.datatypes.TransportTypeEnum;
import devstudio.generatedcode.exceptions.*;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class InteractionAdapter implements HlaInteractionListener, MmsFederateInitializationListener, ConcurrentDataStorageListener<PatientControl> {
    private org.slf4j.Logger logger = LoggerFactory.getLogger(this.getClass());

    private HlaInteractionManager hlaInteractionManager;
    MmsFederate mmsFederate;

    @Autowired
    FederationControlSimDataService federationControlSimDataService;
    @Autowired
    InstructorControlSimDataService instructorControlSimDataService;
    @Autowired
    FederationStateAdapter federationStateAdapter;
    @Autowired
    MedEvacSimDataService medEvacSimDataService;
    @Autowired
    PatientControlSimDataService patientControlSimDataService;
    @Autowired
    MagicTransferSimDataService magicTransferSimDataService;

    @Override
    public void initializing(MmsFederate mmsFederate) {
        this.mmsFederate = mmsFederate;
        hlaInteractionManager = this.mmsFederate.getHlaWorld().getHlaInteractionManager();
        hlaInteractionManager.addHlaInteractionListener(this);
        patientControlSimDataService.addDataStorageListener(this);
        federationControlSimDataService.addDataStorageListener(new FederationControlSimDataListenerForFederate(hlaInteractionManager));
        magicTransferSimDataService.addDataStorageListener(new MagicTransferSimDataListener());
    }


    private void addFederationControlEntry(FederationCommandEnum command, String parameter) {
    	FederationControl control = new FederationControl()
    			.setCommand(command)
    			.setTime(Instant.now())
    			.setLocal(false);
    	if(parameter != null) {
    		control.setParameter(parameter);
    	}
    	federationControlSimDataService.add(control);
    }
    
    
    public Results sendSelectScenario(){
        try {
            hlaInteractionManager.sendSelectScenario("mms");
            return new Results(true);
        } catch (HlaNotConnectedException | HlaFomException | 
                HlaInternalException | HlaRtiException | 
                HlaSaveInProgressException | HlaRestoreInProgressException ex) {
            logger.error("could not send selectScenario",ex);
            return new Results(false, ex.getMessage());
        }
    }

    public Results sendRestResponse(RestBypass restResponse){
        try{
            hlaInteractionManager.sendRestResponse(restResponse.getMessageId(),restResponse.getRequestor(), restResponse.getResponder(), restResponse.getResultCode(),restResponse.getResultPayload());
            logger.trace("restResponse sent successfully");
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send restResponse",ex);
            return new Results(false, ex.getMessage());
        }
    }

    public Results sendRestCall(RestBypass call){
        try{
            hlaInteractionManager.sendRestCall(call.getMessageId(), call.getResponder(), call.getRequestor(), call.getCallMethod(), call.getPath(), call.getRequestPayload());
            logger.trace("restCall sent successfully");
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send restResponse",ex);
            return new Results(false, ex.getMessage());
        }
    }
    
    public Results sendInstructionalStart(String facilityId) {
    	if((facilityId == null) || facilityId.isEmpty()) {
    		facilityId = "n/a";
    	}
    	try {
            hlaInteractionManager.sendInstructionalStart(facilityId);
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send instructionalStart",ex);
            return new Results(false, ex.getMessage());
        }
    }

    public Results sendInstructionalStop(String facilityId) {
    	if((facilityId == null) || facilityId.isEmpty()) {
    		facilityId = "n/a";
    	}
    	try {
            hlaInteractionManager.sendInstructionalStop(facilityId);
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send instructionalStop",ex);
            return new Results(false, ex.getMessage());
        }
    }
    
    public Results sendInstructionalPause(String facilityId) {
    	if((facilityId == null) || facilityId.isEmpty()) {
    		facilityId = "n/a";
    	}
    	try {
            hlaInteractionManager.sendInstructionalPause(facilityId);
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send instructionalPause",ex);
            return new Results(false, ex.getMessage());
        }
    }

    public Results sendInstructionalResume(String facilityId) {
    	if((facilityId == null) || facilityId.isEmpty()) {
    		facilityId = "n/a";
    	}
    	try {
            hlaInteractionManager.sendInstructionalResume(facilityId);
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send instructionalResume",ex);
            return new Results(false, ex.getMessage());
        }
    }

    public Results sendPatientStart(Long atTimeMs, PatientId patientId) {
        if (patientId == null) {
            patientId = new PatientId("n/a");
        }
        if (atTimeMs == null) {
            atTimeMs = 0l;
        }
        try {
            logger.trace("sending StartPatient interaction");
            hlaInteractionManager.sendStartPatient(atTimeMs, patientId.getIdAsString());
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send sendStartPatient", ex);
            return new Results(false, ex.getMessage());
        }
    }

    public Results sendPatientStop(Long atTimeMs, PatientId patientId) {
        if (patientId == null) {
            patientId = new PatientId("n/a");
        }
        if (atTimeMs == null) {
            atTimeMs = 0l;
        }
        try {
            logger.trace("sending StopPatient interaction");
            hlaInteractionManager.sendStopPatient(atTimeMs, patientId.getIdAsString());
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send sendStopPatient", ex);
            return new Results(false, ex.getMessage());
        }
    }

    public Results sendPatientPause(Long atTimeMs, PatientId patientId) {
        if (patientId == null) {
            patientId = new PatientId("n/a");
        }
        if (atTimeMs == null) {
            atTimeMs = 0l;
        }
        try {
            logger.trace("sending PausePatient interaction");
            hlaInteractionManager.sendPausePatient(atTimeMs, patientId.getIdAsString());
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send sendPausePatient", ex);
            return new Results(false, ex.getMessage());
        }
    }

    public Results sendPatientResume(Long atTimeMs, PatientId patientId) {
        if (patientId == null) {
            patientId = new PatientId("n/a");
        }
        if (atTimeMs == null) {
            atTimeMs = 0l;
        }
        try {
            logger.trace("sending ResumePatient interaction");
            hlaInteractionManager.sendResumePatient(atTimeMs, patientId.getIdAsString());
            return new Results(true);
        } catch (Exception ex) {
            logger.error("could not send sendResumePatient", ex);
            return new Results(false, ex.getMessage());
        }
    }
    
    public Results sendMedEvacRequest(String patientId, String transportType, String siteName) {
    	if(patientId == null) {
    		logger.error("Patient ID must not be null for sendMedEvacRequest");
    		return new Results(false,"must include patient id");
    	}
    	TransportTypeEnum transportEnum = TransportTypeEnum.UNKNOWN;
    	try {
    		transportEnum = TransportTypeEnum.valueOf(transportType.toUpperCase());
    	}catch(Exception e) {
    		logger.info("TransportType is invalid for {} using default.  error:{}", patientId, e.getMessage());
    	}
    	
    	if(siteName == null) {
    		siteName = "n/a";
    	}
    	
    	try {
            hlaInteractionManager.sendMedicalEvacuationRequest(patientId, transportEnum, siteName);
            return new Results(true);
    	}catch(Exception ex) {
            logger.error("could not send sen MedEvacRequest",ex);
            return new Results(false, ex.getMessage());
    	}
    }
    
    public Results sendMedEvacUpdate(String patientId, EvacStateEnum evacState, String vehicleId, String siteName) {
    	if(patientId == null) {
    		logger.error("Patient ID must not be null for sendMedEvacUpdate");
    		return new Results(false,"must include patient id");
    	}
    	MedicalEvacuationStateEnum medicalEvacuationState = null;
    	try {
    		medicalEvacuationState = MedicalEvacuationStateEnum.valueOf(evacState.toString());
    	}catch(Exception e) {
    		//no work here, we will be checking it in the line below
    	}
    	
    	if(medicalEvacuationState == null) {
            logger.warn("Did not send interaction because MedicalEvacuationState was missing");
    		return new Results(false,"Must include enum that maps to MedicalEvacuationState");
    	}
    	
    	if(vehicleId == null) {
    		vehicleId = "n/a";
    	}
    	
    	if(siteName == null) {
    		siteName = "n/a";
    	}
    	
    	try {
            hlaInteractionManager.sendMedicalEvacuationUpdate(patientId, medicalEvacuationState, vehicleId, siteName);
            return new Results(true);
    	}catch(Exception ex) {
            logger.error("could not send MedEvacRequest",ex);
            return new Results(false, ex.getMessage());
    	}
    }

    public Results sendMagicTransfer(String patientId, String facilityId){
        try {
            hlaInteractionManager.sendMagicTransfer(patientId, facilityId);
            return new Results(true);
        } catch (HlaNotConnectedException | HlaFomException |
                HlaInternalException | HlaRtiException |
                HlaSaveInProgressException | HlaRestoreInProgressException ex) {
            logger.error("could not send magicTransfer",ex);
            return new Results(false, ex.getMessage());
        }
    }

    public class Results{
        public boolean success = false;
        public String message = null;
        
        public Results(boolean successful){
            this.success = successful;
        }
        
        public Results(boolean successful, String message){
            this.success = successful;
            this.message = message;
        }
    }

    //----------------------------------------------------------------------------------------------
    //                          HlaInteractionListener Implementation
    //----------------------------------------------------------------------------------------------


    @Override
    public void requestTCCC(boolean b, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {

    }

    @Override
    public void provideTCCC(boolean b, HlaInteractionManager.HlaProvideTCCCParameters hlaProvideTCCCParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {

    }

    @Override
    public void selectScenario(boolean b, HlaInteractionManager.HlaSelectScenarioParameters hlaSelectScenarioParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {

    }

    @Override
    public void instructionalStart(boolean localCall, HlaInteractionManager.HlaInstructionalStartParameters hlaInstructionalStartParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!localCall) {
            instructorControlSimDataService.add(
                    new InstructorControl()
                            .setLocal(false)
                            .setCommand(InstructorControlCmdEnum.START)
                            .setFacilityId(hlaInstructionalStartParameters.getTrainingFacilityId(null)));
        }
    }

    @Override
    public void instructionalStop(boolean localCall, HlaInteractionManager.HlaInstructionalStopParameters hlaInstructionalStopParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!localCall) {
            instructorControlSimDataService.add(
                    new InstructorControl()
                            .setLocal(false)
                            .setCommand(InstructorControlCmdEnum.STOP)
                            .setFacilityId(hlaInstructionalStopParameters.getTrainingFacilityId(null)));
        }
    }

    @Override
    public void instructionalPause(boolean localCall, HlaInteractionManager.HlaInstructionalPauseParameters hlaInstructionalPauseParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!localCall) {
            instructorControlSimDataService.add(
                    new InstructorControl()
                            .setLocal(false)
                            .setCommand(InstructorControlCmdEnum.PAUSE)
                            .setFacilityId(hlaInstructionalPauseParameters.getTrainingFacilityId(null)));
        }
    }

    @Override
    public void instructionalResume(boolean localCall, HlaInteractionManager.HlaInstructionalResumeParameters hlaInstructionalResumeParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!localCall) {
            instructorControlSimDataService.add(
                    new InstructorControl()
                            .setLocal(false)
                            .setCommand(InstructorControlCmdEnum.RESUME)
                            .setFacilityId(hlaInstructionalResumeParameters.getTrainingFacilityId(null)));
        }
    }

    @Override
    public void requestLab(boolean b, HlaInteractionManager.HlaRequestLabParameters hlaRequestLabParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {

    }

    @Override
    public void loadPatient(boolean b, HlaInteractionManager.HlaLoadPatientParameters hlaLoadPatientParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {

    }

    @Override
    public void startPatient(boolean localCall, HlaInteractionManager.HlaStartPatientParameters hlaStartPatientParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!localCall){
            PatientControl patientControl = new PatientControl();
            patientControl.setPatientId(hlaStartPatientParameters.getPatientId("anon"));
            patientControl.setSimulationElapsedTime(hlaStartPatientParameters.getSimulationElapsedTime(0));
            patientControl.setCommand(PatientControlCommandEnum.START);
            patientControl.setLocal(false);
            patientControlSimDataService.add(patientControl);
        }
    }

    @Override
    public void stopPatient(boolean localCall, HlaInteractionManager.HlaStopPatientParameters hlaPatientParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!localCall){
            PatientControl patientControl = new PatientControl();
            patientControl.setPatientId(hlaPatientParameters.getPatientId("anon"));
            patientControl.setSimulationElapsedTime(hlaPatientParameters.getSimulationElapsedTime(0));
            patientControl.setCommand(PatientControlCommandEnum.STOP);
            patientControl.setLocal(false);
            patientControlSimDataService.add(patientControl);
        }
    }

    @Override
    public void pausePatient(boolean localCall, HlaInteractionManager.HlaPausePatientParameters hlaPatientParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!localCall){
            PatientControl patientControl = new PatientControl();
            patientControl.setPatientId(hlaPatientParameters.getPatientId("anon"));
            patientControl.setSimulationElapsedTime(hlaPatientParameters.getSimulationElapsedTime(0));
            patientControl.setCommand(PatientControlCommandEnum.PAUSE);
            patientControl.setLocal(false);
            patientControlSimDataService.add(patientControl);
        }
    }

    @Override
    public void resumePatient(boolean localCall, HlaInteractionManager.HlaResumePatientParameters hlaPatientParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!localCall){
            PatientControl patientControl = new PatientControl();
            patientControl.setPatientId(hlaPatientParameters.getPatientId("anon"));
            patientControl.setSimulationElapsedTime(hlaPatientParameters.getSimulationElapsedTime(0));
            patientControl.setCommand(PatientControlCommandEnum.RESUME);
            patientControl.setLocal(false);
            patientControlSimDataService.add(patientControl);
        }
    }

    @Override
    public void start(boolean localCall, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        federationStateAdapter.updateFederationState(FederationStateEnum.RUNNING);
        if(localCall){
            return;
        }
        federationControlSimDataService.add(
                new FederationControl()
                        .setCommand(FederationCommandEnum.START)
                        .setTime(Instant.now())
                        .setLocal(false));
    }

    @Override
    public void stop(boolean b, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        federationStateAdapter.updateFederationState(FederationStateEnum.STOPPED);
    }

    @Override
    public void pause(boolean b, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        federationStateAdapter.updateFederationState(FederationStateEnum.PAUSED);
    }

    @Override
    public void resume(boolean b, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        federationStateAdapter.updateFederationState(FederationStateEnum.RUNNING);
    }

    @Override
    public void save(boolean b, HlaInteractionManager.HlaSaveParameters hlaSaveParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {

    }

    @Override
    public void restore(boolean b, HlaInteractionManager.HlaRestoreParameters hlaRestoreParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {

    }

    @Override
    public void setTimeScale(boolean b, HlaInteractionManager.HlaSetTimeScaleParameters hlaSetTimeScaleParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {

    }

    @Override
    public void restCall(boolean localCall, HlaInteractionManager.HlaRestCallParameters hlaRestCallParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
    }

    @Override
    public void restResponse(boolean local, HlaInteractionManager.HlaRestResponseParameters hlaRestResponseParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        logger.trace("restResponse received from:" + hlaRestResponseParameters.getFromId("null") + " to:" + hlaRestResponseParameters.getToId("null"));
    }


    @Override
    public void medicalEvacuationRequest(boolean local, HlaInteractionManager.HlaMedicalEvacuationRequestParameters hlaParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!local) {
            MedEvac medEvac = medEvacSimDataService.get(hlaParameters.getPatientId());
            if(medEvac == null) {
                medEvac = new MedEvac().setPatientId(hlaParameters.getPatientId());
            }
            medEvac.setEvacState(EvacStateEnum.EVAC_REQUEST_SENT);
            medEvac.setFacilityId(hlaParameters.getFacilityId());
            medEvac.setTransportType(hlaParameters.getTransportType().toString());
            medEvacSimDataService.put(medEvac);
        }
    }

    @Override
    public void medicalEvacuationUpdate(boolean local, HlaInteractionManager.HlaMedicalEvacuationUpdateParameters hlaParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!local) {
            MedEvac medEvac = medEvacSimDataService.get(hlaParameters.getPatientId());
            if(medEvac == null) {
                medEvac = new MedEvac().setPatientId(hlaParameters.getPatientId());
            }
            medEvac.setEvacState(EvacStateEnum.valueOf(hlaParameters.getMedicalEvacuationState().toString()));
            medEvac.setFacilityId(hlaParameters.getFacilityId());
            medEvac.setVehicleId(hlaParameters.getVehicleId());
            medEvacSimDataService.put(medEvac);
        }
    }

    @Override
    public void medicalEvacuationResponse(boolean local, HlaInteractionManager.HlaMedicalEvacuationResponseParameters hlaParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!local) {
            MedEvac medEvac = medEvacSimDataService.get(hlaParameters.getPatientId());
            if(medEvac == null) {
                medEvac = new MedEvac().setPatientId(hlaParameters.getPatientId());
            }
            medEvac.setEvacState(EvacStateEnum.valueOf(hlaParameters.getMedicalEvacuationState().toString()));
            medEvac.setFacilityId(hlaParameters.getFacilityId());
            medEvac.setVehicleId(hlaParameters.getVehicleId());
            medEvacSimDataService.put(medEvac);
        }
    }

    @Override
    public void magicTransfer(boolean local, HlaInteractionManager.HlaMagicTransferParameters hlaMagicTransferParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        if(!local){
            MagicTransfer magicTransfer = new MagicTransfer();
            magicTransfer.setLocal(false);
            magicTransfer.setPatientId(hlaMagicTransferParameters.getPatientId());
            magicTransfer.setFacilityId(hlaMagicTransferParameters.getFacilityId());
            magicTransferSimDataService.add(magicTransfer);
            logger.debug("MagicTransfer received: {}", magicTransfer);
        }
    }

    @Override
    public void vitalsDisplayControl(boolean b, HlaInteractionManager.HlaVitalsDisplayControlParameters hlaVitalsDisplayControlParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        logger.info("Vitals Display Control received");

    }

    @Override
    public void magicVitals(boolean b, HlaInteractionManager.HlaMagicVitalsParameters hlaMagicVitalsParameters, HlaTimeStamp hlaTimeStamp, HlaLogicalTime hlaLogicalTime) {
        logger.info("Magic vitals received");
    }

    //------------------------------------------------------------------------------------------------------------------
    //                           PatientControlDataService Listener
    //------------------------------------------------------------------------------------------------------------------

    @Override
    public void entityAdded(PatientControl newEntity) {
        if(newEntity.isLocal()){
            switch(newEntity.getCommand()){
                case STOP -> sendPatientStop(newEntity.getSimulationElapsedTime(),newEntity.getPatient());
                case START -> sendPatientStart(newEntity.getSimulationElapsedTime(),newEntity.getPatient());
                case PAUSE -> sendPatientPause(newEntity.getSimulationElapsedTime(),newEntity.getPatient());
                case RESUME -> sendPatientResume(newEntity.getSimulationElapsedTime(),newEntity.getPatient());
            }
        }
    }

    @Override
    public void entityUpdated(PatientControl entity) {
        //ignore
    }

    //----------------------------------------------------------------------------------------------
    //                          MagicTransferSimDataService Listener
    //----------------------------------------------------------------------------------------------

    private class MagicTransferSimDataListener implements ConcurrentDataStorageListener<MagicTransfer> {

        @Override
        public void entityAdded(MagicTransfer newEntity) {
            if (newEntity.isLocal()) {
                try {
                    hlaInteractionManager.sendMagicTransfer(newEntity.getPatientId(), newEntity.getFacilityId());
                } catch (Exception e) {
                    logger.error("Error sending MagicTransfer", e);
                }
            }
        }

        @Override
        public void entityUpdated(MagicTransfer entity) {
            // ignore
        }
    }

}
