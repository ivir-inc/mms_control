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

import com.ivir.mpif.controller.model.PatientCaseMetadata;
import com.ivir.mpif.simdata.*;
import com.ivir.mpif.treatment.impl.TreatmentDeviceMap;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

@RestController
@RequestMapping("/mms/patient-case")
public class PatientCaseMetadataController {


    @GetMapping("/metadata")
    public Object getMetadata(){
        PatientCaseMetadata patientCaseMetadata = new PatientCaseMetadata();
        patientCaseMetadata.setPhysicalTreatmentType(buildPhysicalTreatmentType());
        patientCaseMetadata.setTreatmentDevice(buildTreatmentDevice());
        patientCaseMetadata.setMedication(buildMedication());
        patientCaseMetadata.setDetailedAnatomy(buildDetailedAnatomy());
        patientCaseMetadata.setSkeletalSystem(buildSkeletalSystem());
        patientCaseMetadata.setCoronalPlane(buildCoronalPlane());
        patientCaseMetadata.setTransversePlane(buildTransversePlane());
        patientCaseMetadata.setSagittalPlane(buildSagittalPlane());
        patientCaseMetadata.setInternalAnatomy(buildInternalAnatomy());
        patientCaseMetadata.setRegionTissueType(buildRegionTissueType());
        patientCaseMetadata.setGeneralRegion(buildGeneralRegion());
        patientCaseMetadata.setDeviceMap(buildDeviceMap());
        patientCaseMetadata.setAdministrationRoute(buildAdministrationRoute());

        return new ResponseEntity<>(patientCaseMetadata, HttpStatus.OK);
    }

    private ArrayList<HashMap<String, Object>> buildPhysicalTreatmentType(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(PhysicalTreatmentType.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("displayName", enumVal.getDisplayName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumMap.put("category", enumVal.getCategory());
            if(enumVal.getCategory() != null) {
                enumMap.put("catOrder", enumVal.getCategory().getOrder());
            }
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildTreatmentDevice(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(TreatmentDevice.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("displayName", enumVal.getDisplayName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildMedication(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        // NOT_APPLICABLE (category == null) is a sentinel for "no medication",
        // not a real selectable medication — exclude it so it doesn't show up
        // as a button on the medication customization page.
        Arrays.stream(Medication.values())
                .filter(enumVal -> enumVal.getCategory() != null)
                .forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumMap.put("displayName", enumVal.getDisplayName());
            enumMap.put("category", enumVal.getCategory());
            enumMap.put("catOrder", enumVal.getCategory().getOrder());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildAdministrationRoute(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(MedicationAdministrationRoute.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumMap.put("displayName", enumVal.getDisplayName());
            enumMap.put("abbreviation", enumVal.getAbbreviation());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildDetailedAnatomy(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(DetailedAnatomy.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildSkeletalSystem(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(SkeletalSystem.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildCoronalPlane(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(CoronalPlane.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildSagittalPlane(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(SagittalPlane.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildInternalAnatomy(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(InternalAnatomy.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildRegionTissueType(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(RegionTissueType.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildGeneralRegion(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(GeneralRegion.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildTransversePlane(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        Arrays.stream(TransversePlane.values()).forEach((enumVal)->{
            HashMap<String,Object> enumMap = new HashMap<>();
            enumMap.put("enum", enumVal.toString());
            enumMap.put("name", enumVal.getName());
            enumMap.put("ordinal", enumVal.getOrdinal());
            enumList.add(enumMap);
        });
        return enumList;
    }

    private ArrayList<HashMap<String, Object>> buildDeviceMap(){
        ArrayList<HashMap<String, Object>> enumList = new ArrayList<>();
        TreatmentDeviceMap.getInstance().getDeviceMap().forEach((treatment,deviceSet)->{
            HashMap<String,Object> treatmentMap = new HashMap<>();
            ArrayList<TreatmentDevice> deviceList = new ArrayList<>();
            deviceSet.forEach(deviceList::add);
            treatmentMap.put(treatment.toString(),deviceList);
            enumList.add(treatmentMap);
        });
        return enumList;
    }



}
