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

import com.ivir.mpif.controller.model.ScenEngVitalsChange;
import com.ivir.mpif.controller.model.VitalsChangeEnum;
import com.ivir.mpif.sceneng.ScenarioEngineBypassService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;
import java.util.HashMap;
import java.util.concurrent.BlockingQueue;

@RestController
public class ScenarioEngineController {
    Logger logger = LoggerFactory.getLogger(ScenarioEngineController.class);
    private HashMap<String, BlockingQueue<String>> patientLockMap = new HashMap<>();

    @Autowired
    private ScenarioEngineBypassService scenarioEngineBypassServiceService;

    @PostMapping(path="/mms/sceneng/vitals",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public Object updatePatient(@RequestParam(name = "patientId") String patientId, @RequestBody ScenEngVitalsChange vitalsChange){
        if (vitalsChange.getVitalsType() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You must include vitalsType");
        }

        if (patientId == null || patientId.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You must include patientId");
        }

        BlockingQueue<String> lockQueue = null;
        try {
            lockQueue = patientLockMap.computeIfAbsent(patientId, k -> {
                return new java.util.concurrent.ArrayBlockingQueue<>(1);
            });
            lockQueue.put("patientId");

            Optional<VitalsChangeEnum> optVitalsChangeEnum = VitalsChangeEnum.getVCEnumByRestName(vitalsChange.getVitalsType());
            try {
                scenarioEngineBypassServiceService.changeVitalsNow(patientId, vitalsChange.getVitalsType(), vitalsChange.getTargetVital(), null);
            } catch (IllegalArgumentException iae) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, iae.getMessage());
            }
            return new ResponseEntity<>(HttpStatus.CREATED);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            if(lockQueue != null) {
                lockQueue.clear();
            }
        }
    }


//    public Object updatePatient(@RequestParam(name = "patientId") String patientId, @RequestBody ScenEngVitalsChange vitalsChange){
//        if(vitalsChange.getVitalsType() == null){
//            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"You must include vitalsType");
//        }
//
//        Optional<VitalsChangeEnum> optVitalsChangeEnum = VitalsChangeEnum.getVCEnumByRestName(vitalsChange.getVitalsType());
//        if (optVitalsChangeEnum.isPresent()) {
//            // get target
//            Float targetFloat = vitalsChange.getTargetVital();
//            if (targetFloat == null) {
//                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"You must include target number");
//            }
//
//            // see if there is a rate
//            boolean useRate = false;
//            Float rateFloat = vitalsChange.getRate();
//            if (rateFloat != null) {
//                useRate = true;
//            }
//
//            ManualControl<?> manualControl = null;
//
//            switch (optVitalsChangeEnum.get()) {
//                case HR:
//                case BP_DIASTOLIC:
//                case BP_SYSTOLIC:
//                    if (!useRate) {
//                        manualControl = ManualControl.instantaneousUpdate(Math.round(targetFloat));
//                    } else {
//                        if(targetFloat < 0) {
//                            manualControl = ManualControl.gradualUpdate(rateFloat,Math.round(targetFloat),500);
//                        }else {
//                            manualControl = ManualControl.gradualUpdate(rateFloat,-500, Math.round(targetFloat));
//                        }
//                    }
//                    break;
//                case RR:
//                case ETCO2:
//                case SPO2:
//                case TEMP:
//                    if (!useRate) {
//                        manualControl = ManualControl.instantaneousUpdate(targetFloat);
//                    } else {
//                        if(targetFloat < 0) {
//                            manualControl = ManualControl.gradualUpdate(rateFloat,targetFloat,500f);
//                        }else {
//                            manualControl = ManualControl.gradualUpdate(rateFloat,-500f, targetFloat);
//                        }
//                    }
//                    break;
//            }
//            if(manualControl == null) {
//                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Invalid vitalsType");
//            }
//            scenarioEngineService.updatePatientData(new PatientId(patientId), optVitalsChangeEnum.get().getControlFact(),manualControl);
//            return new ResponseEntity<>(HttpStatus.CREATED);
//        }
//        throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"You must include vitalsType");
//    }
}
