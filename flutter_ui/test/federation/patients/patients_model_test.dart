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

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui/data/model/patients/patients_model.dart';

void main() {
  test("parses patient summary for PatientInfoStore", () {
    String jsonString = """
    { 
    "patientSummary": [
        {
            "patientId": "bob",
            "patientName": null,
            "patientSource": "UNKNOWN",
            "monitorPatient" : true,
            "connectorInfoList": []
        },
        {
            "patientId": "testpatient",
            "patientName": null,
            "patientSource": "FEDERATION",
            "connectorInfoList": []
        },
         {
            "patientId": "george",
            "patientName": null,
            "patientSource": "SCENARIO_ENGINE",
            "connectorInfoList": []
        },
        {
            "patientId": "bubba",
            "patientName": null,
            "connectorInfoList": []
        }
      ]
    }
    """;

    buildStoreFromJson(jsonString);

    expect(PatientSource.unknown,
        PatientInfoStore().patientInfo("bob")!.patientSource);
    expect(true, PatientInfoStore().patientInfo("bob")!.monitorPatient);
    expect(PatientSource.federation,
        PatientInfoStore().patientInfo("testpatient")!.patientSource);
    expect(
        false, PatientInfoStore().patientInfo("testpatient")!.monitorPatient);
    expect(PatientSource.scenarioEngine,
        PatientInfoStore().patientInfo("george")!.patientSource);
    expect(PatientSource.unknown,
        PatientInfoStore().patientInfo("bubba")!.patientSource);
  });

  test("Patient store get all patients", () {
    String jsonString = """
    { 
    "patientSummary": [
        {
            "patientId": "bob",
            "patientName": null,
            "patientSource": "UNKNOWN",
            "monitorPatient" : true,
            "connectorInfoList": []
        },
        {
            "patientId": "testpatient",
            "patientName": null,
            "patientSource": "FEDERATION",
            "monitorPatient" : true,
            "connectorInfoList": []
        },
         {
            "patientId": "george",
            "patientName": null,
            "patientSource": "SCENARIO_ENGINE",
            "monitorPatient" : false,
            "connectorInfoList": []
        },
        {
            "patientId": "bubba",
            "patientName": null,
            "monitorPatient" : false,
            "connectorInfoList": []
        }
      ]
    }
    """;

    buildStoreFromJson(jsonString);

    List<SinglePatientInfo> patientLists = PatientInfoStore().allPatients();
    expect(patientLists.length, 4);
  });

  test("Filter patients by monitorPatient", () {
    String jsonString = """
    { 
    "patientSummary": [
        {
            "patientId": "bob",
            "patientName": null,
            "patientSource": "UNKNOWN",
            "monitorPatient" : true,
            "connectorInfoList": []
        },
        {
            "patientId": "testpatient",
            "patientName": null,
            "patientSource": "FEDERATION",
            "monitorPatient" : true,
            "connectorInfoList": []
        },
         {
            "patientId": "george",
            "patientName": null,
            "patientSource": "SCENARIO_ENGINE",
            "monitorPatient" : true,
            "connectorInfoList": []
        },
        {
            "patientId": "bubba",
            "patientName": null,
            "monitorPatient" : false,
            "connectorInfoList": []
        }
      ]
    }
    """;

    buildStoreFromJson(jsonString);

    List<SinglePatientInfo> patientLists =
        PatientInfoStore().patientsMonitorStatus(true);
    expect(patientLists.length, 3);

    patientLists = PatientInfoStore().patientsMonitorStatus(false);
    expect(patientLists.length, 1);
  });
}

void buildStoreFromJson(String jsonString) {
  dynamic jsonDecoded = json.decode(jsonString);
  Map<String, dynamic> convertedMap = jsonDecoded as Map<String, dynamic>;
  dynamic dynamicList = convertedMap["patientSummary"];
  List<Map<String, dynamic>> converted =
      List<Map<String, dynamic>>.from(dynamicList);
  PatientInfoStore().loadFromJson(converted, isMain: true);
}
