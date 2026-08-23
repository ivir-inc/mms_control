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

import com.ivir.mpif.controller.model.RestInjury;
import com.ivir.mpif.injury.InjuryService;
import com.ivir.mpif.simdata.Injury;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import static com.ivir.mpif.common.Utilities.doIfNotNull;

@RestController
@RequestMapping("/mms/injury")
public class InjuryController {
    @Autowired
    private InjuryService injuryService;

    @PostMapping()
    public Object applyInjury(@RequestBody RestInjury restInjury){
        if(restInjury == null){
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Injury must be included");
        }
        Injury injury = new Injury();
        injury.setLocal(true);
        doIfNotNull(restInjury.getBodyLocation(),injury::setLocation);
        doIfNotNull(restInjury.getDescription(),injury::setDescription);
        doIfNotNull(restInjury.getDetail(),injury::setDetail);
        doIfNotNull(restInjury.getHemorrhageRate(),injury::setHemorrhageRate);
        doIfNotNull(restInjury.getInjuryName(),injury::setName);
        doIfNotNull(restInjury.getInjuryId(),injury::setInjuryId);
        doIfNotNull(restInjury.getInjuryType(),injury::setInjuryType);
        doIfNotNull(restInjury.getMechanismOfInjury(),injury::setMechanismOfInjury);
        doIfNotNull(restInjury.getPatientId(),injury::setPatientId);
        doIfNotNull(restInjury.getSeverity(),injury::setSeverity);
        doIfNotNull(restInjury.getTime(),injury::setTime);
        doIfNotNull(restInjury.getTotalBodySurfaceArea(),injury::setTotalBodySurfaceArea);
        injuryService.apply(injury);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @GetMapping("/all")
    public List<RestInjury> getInjuries() {
       return injuryService.getAll().stream().map(this::toRest).toList();
    }

    @GetMapping("/patient/{patientId}")
    public List<RestInjury> getInjuriesByPatientId(@PathVariable String patientId) {
        return injuryService.getByPatientId(patientId).stream().map(this::toRest).toList();
    }

    private RestInjury toRest(Injury injury){
        RestInjury restInjury = new RestInjury();
        doIfNotNull(injury.getLocation(), restInjury::setBodyLocation);
        doIfNotNull(injury.getDetail(), restInjury::setDetail);
        doIfNotNull(injury.getDescription(), restInjury::setDescription);
        doIfNotNull(injury.getHemorrhageRate(), restInjury::setHemorrhageRate);
        doIfNotNull(injury.getInjuryType(), restInjury::setInjuryType);
        doIfNotNull(injury.getInjuryId(), restInjury::setInjuryId);
        doIfNotNull(injury.getMechanismOfInjury(), restInjury::setMechanismOfInjury);
        doIfNotNull(injury.getName(), restInjury::setInjuryName);
        doIfNotNull(injury.getPatientId(), restInjury::setPatientId);
        doIfNotNull(injury.getSeverity(), restInjury::setSeverity);
        doIfNotNull(injury.getTime(), restInjury::setTime);
        doIfNotNull(injury.getTotalBodySurfaceArea(), restInjury::setTotalBodySurfaceArea);
        return restInjury;
    }


}
