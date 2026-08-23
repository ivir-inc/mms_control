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

package com.ivir.mpif.patient.impl;

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ivir.mpif.patient.db.PatientEntity;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class PatientFileManager {
    private String scenarioFolder = "scenarios";
    private String patientFileName = "default";

    public String getScenarioFolder() {
        return scenarioFolder;
    }

    public PatientFileManager setScenarioFolder(String scenarioFolder) {
        this.scenarioFolder = scenarioFolder;
        return this;
    }

    public String getPatientFileName() {
        return patientFileName;
    }

    public PatientFileManager setPatientFileName(String patientFileName) {
        this.patientFileName = patientFileName;
        return this;
    }

    public void savePatients(List<PatientEntity> patientList){
        removeNonFileValues(patientList);
        ObjectMapper mapper = new ObjectMapper();
        try {
            mapper.writerWithDefaultPrettyPrinter()
                    .writeValue(Paths.get(scenarioFolder+"/"+patientFileName+".pts").toFile(), patientList);
        } catch (JsonGenerationException e) {
            e.printStackTrace();
        } catch (JsonMappingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void removeNonFileValues(List<PatientEntity> patientList){
        for (PatientEntity patientEntity : patientList){
            patientEntity.setPatientCaseNum(null);
        }
    }

    public List<PatientEntity> loadPatients(){
        ObjectMapper mapper = new ObjectMapper();

        String fileName = patientFileName+".pts";
        PatientEntity[] patientArray = null;
        try {
            patientArray = mapper.readValue(Paths.get(scenarioFolder+"/"+fileName).toFile(), PatientEntity[].class);
        } catch (JsonParseException e) {
            e.printStackTrace();
        } catch (JsonMappingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        if(patientArray == null){
            return new ArrayList<PatientEntity>();
        }
        return Arrays.asList(patientArray);
    }
}
