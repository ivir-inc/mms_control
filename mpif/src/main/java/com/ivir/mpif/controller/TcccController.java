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

import com.ivir.mpif.controller.model.RestTccc;
import com.ivir.mpif.simdata.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
@RequestMapping("/mms/forms/dd1380")
public class TcccController {
    private static final Logger logger = LoggerFactory.getLogger(TcccController.class);

    @Autowired
    private TcccSimDataService tcccSimDataService;

    @GetMapping("/{patientId}")
    public Object getTcccByPatient(@PathVariable String patientId){
        logger.debug("calling getTcccByPatientId with patient {}", patientId);
        Optional<Tccc> tcccOpt = tcccSimDataService.getByPatientId(patientId);
        if(tcccOpt.isPresent()){
            return ResponseEntity.ok(TcccRestMapper.toRest(tcccOpt.get()));
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/text/{patientId}")
    public Object getTcccTextByPatient(@PathVariable String patientId){
        logger.debug("calling getTcccTextByPatientId with patient {}", patientId);
        return ResponseEntity.ok("patientId: " + patientId + "\n" +
                "battleRosterNumber: 1234\n" +
                "firstName: Bob\n" +
                "lastName: Dole\n" +
                "evacuationLevelRequest: Some Level\n"
        );
    }
}
