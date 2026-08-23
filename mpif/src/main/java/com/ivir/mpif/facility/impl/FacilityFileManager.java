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

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ivir.mpif.facility.db.FacilityRecord;

import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;

public class FacilityFileManager {
    private String scenarioFolder = "scenarios";
    private String facilityFileName = "default";

    public String getScenarioFolder() {
        return scenarioFolder;
    }

    public FacilityFileManager setScenarioFolder(String scenarioFolder) {
        this.scenarioFolder = scenarioFolder;
        return this;
    }

    public String getFacilityFileName() {
        return facilityFileName;
    }

    public FacilityFileManager setFacilityFileName(String facilityFileName) {
        this.facilityFileName = facilityFileName;
        return this;
    }

    public void saveFacilities(List<FacilityRecord> facilityList) {
        ObjectMapper mapper = new ObjectMapper();
        try {
            mapper.writerWithDefaultPrettyPrinter()
                    .writeValue(Paths.get(scenarioFolder + "/" + facilityFileName + ".fac").toFile(), facilityList);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void removeNonFileValues(List<FacilityRecord> facilityList) {
        for (FacilityRecord facilityRecord : facilityList) {
            facilityRecord.setFacilityId(null);
        }
    }

    public List<FacilityRecord> loadFacilities() {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return Arrays.asList(mapper.readValue(Paths.get(scenarioFolder + "/" + facilityFileName + ".fac").toFile(), FacilityRecord[].class));
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
