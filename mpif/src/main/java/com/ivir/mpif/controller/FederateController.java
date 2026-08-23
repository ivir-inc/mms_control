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

package com.ivir.mpif.controller;

import com.ivir.mpif.controller.model.*;
import com.ivir.mpif.federate.InteractionAdapter;
import com.ivir.mpif.federate.MmsFederate;
import com.ivir.mpif.simdata.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collection;

@RestController
public class FederateController {
    private MmsFederate mmsFederate;
    private DeviceConnectorSimDataService deviceConnectorSimDataService;
    private PatientControlSimDataService patientControlSimDataService;
    private FederationControlSimDataService federationControlSimDataService;

    public FederateController(MmsFederate mmsFederate, DeviceConnectorSimDataService deviceConnectorSimDataService,
                             PatientControlSimDataService patientControlSimDataService,
                              FederationControlSimDataService federationControlSimDataService){
       this.mmsFederate = mmsFederate;
       this.deviceConnectorSimDataService = deviceConnectorSimDataService;
       this.patientControlSimDataService = patientControlSimDataService;
       this.federationControlSimDataService = federationControlSimDataService;
    }

    @GetMapping("/mms/federation")
    public RestFederationStatus getFederationStatus() {
        RestFederationStatus federationStatus = new RestFederationStatus();
        federationStatus.setSimTime("02:02:00");
        federationStatus.setFederates(mmsFederate.getFederateList());
        return federationStatus;
    }

    @GetMapping("/mms/federation/connection")
    public RestConnectionInformation getConnection() {
        return buildFederationConnectionInformation();
    }

    @PostMapping(path="/mms/federation/connection/request",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public RestConnectionInformation postRequest(@RequestBody RestConnectionRequest hlaAction){
        if(hlaAction.getRequestAction().equalsIgnoreCase("join")) {
            mmsFederate.connect();
        }else if(hlaAction.getRequestAction().equalsIgnoreCase("resign")) {
            mmsFederate.disconnect();
        }
        return buildFederationConnectionInformation();
    }

    @GetMapping("/mms/federation/connectors")
    public RestConnectors getConnectors(){
        RestConnectors connectors = new RestConnectors();
        connectors.setFederation(buildFederationConnectionInformation());
        RestConnectionInformation info = new RestConnectionInformation();

        Collection<DeviceConnector> deviceCollection = deviceConnectorSimDataService.getAllConnectors();
        ArrayList<RestConnectorInformation> connectorList = new ArrayList<>();
        for(DeviceConnector device : deviceCollection){
            RestConnectorInformation connector  = new RestConnectorInformation();
            connector.setHost(device.getHost());
            connector.setName(device.getName());
            connector.setPort(device.getPort());
            connector.setMessage(device.getMessage());
            connector.setStatus(device.getStatus());
            connectorList.add(connector);
        }
        connectors.setConnectors(connectorList);
        return connectors;
    }

    private RestConnectionInformation buildFederationConnectionInformation(){
        RestConnectionInformation info = new RestConnectionInformation();
        String status = "DISCONNECTED";
        if(mmsFederate.isConnected()){
            status = "CONNECTED";
        }
        info.setStatus(status);
        info.setFederateName(mmsFederate.getFederateName());
        info.setFederationName(mmsFederate.getFederationName());
        info.setRtiAddress(mmsFederate.getRtiHost());
        return info;
    }

    @PostMapping(path="/mms/federation/control",
            consumes = MediaType.APPLICATION_JSON_VALUE)
    public Object postControl(@RequestBody RestControlRequest hlaAction){
        if(hlaAction.getAction() == null){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Must contain a valid action");
        }
        if(hlaAction.getAction().contains("patient")){
            addPatientControl(hlaAction.getAction(), hlaAction.getPatientId());
        }else{
            addFederationControl(hlaAction.getAction());
        }
        return new ResponseEntity<>(HttpStatus.OK);
    }

    private void addFederationControl(String controlAction){
        FederationControl federationControl = new FederationControl().setLocal(true).setTime(Instant.now());
        switch(controlAction){
            case "start" -> federationControl.setCommand(FederationCommandEnum.START);
            case "stop" -> federationControl.setCommand(FederationCommandEnum.STOP);
            case "pause" -> federationControl.setCommand(FederationCommandEnum.PAUSE);
            case "resume" -> federationControl.setCommand(FederationCommandEnum.RESUME);
            case "save" -> federationControl.setCommand(FederationCommandEnum.SAVE);
            default -> throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Must contain a valid action");
        }
        this.federationControlSimDataService.add(federationControl);
    }

    private void addPatientControl(String patientAction, String patientId){
        PatientControl patientControl = new PatientControl().setPatientId(patientId);
        patientControl.setLocal(true);
        switch (patientAction){
            case "patientStart" -> patientControl.setCommand(PatientControlCommandEnum.START);
            case "patientStop" -> patientControl.setCommand(PatientControlCommandEnum.STOP);
            case "patientPause" -> patientControl.setCommand(PatientControlCommandEnum.PAUSE);
            case "patientResume" -> patientControl.setCommand(PatientControlCommandEnum.RESUME);
            default -> throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Must contain a valid action");
        }
        this.patientControlSimDataService.add(patientControl);
    }
}
