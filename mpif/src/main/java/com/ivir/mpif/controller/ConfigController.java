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

import com.ivir.mpif.controller.model.BasicPostReturn;
import com.ivir.mpif.controller.model.RestConfigData;
import com.ivir.mpif.mconfig.MpifConfigKey;
import com.ivir.mpif.mconfig.MpifConfigService;
import com.ivir.mpif.mconfig.MpifConfigService.PropertyPair;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConfigController {
    @Autowired
    MpifConfigService mpifConfigService;

    @GetMapping("/mms/config")
    public RestConfigData getConfiguration() {
        RestConfigData restConfigData = new RestConfigData();
        mpifConfigService.getProperty(MpifConfigKey.FACILITY_ID).ifPresent(restConfigData::setFacility);
        mpifConfigService.getPropertyAsBoolean(MpifConfigKey.PATIENTS_SHOW_EXTERNAL).ifPresent(restConfigData::setShowExternalPatients);
        return restConfigData;
    }

    @PostMapping(path="/mms/config",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public BasicPostReturn handleRequest(@RequestBody RestConfigData configData) {
        int numberChanged = mpifConfigService.updateChangedProperties(
                new PropertyPair(MpifConfigKey.FACILITY_ID,configData.getFacility()),
                new PropertyPair(MpifConfigKey.PATIENTS_SHOW_EXTERNAL,configData.getShowExternalPatients())
        );
        return new BasicPostReturn(numberChanged, null);
    }

}
