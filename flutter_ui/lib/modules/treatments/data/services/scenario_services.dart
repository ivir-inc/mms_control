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
import 'package:http/http.dart' as http;
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/data/services/http_helper.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import '../../presentation/widgets/scenario_holder.dart';
import '../storage/last_treatment_store.dart';

Logger _logger = Logger("TreatmentScenarioServices");

class TreatmentScenarioServices {
  /// Fetch the active scenario object for a given patient.
  /// GET: https://localhost:6544/mms/patient-case/patient-assignment?patientId={patientId}
  static Future<Scenario?> fetchActiveScenario(
      {required String patientId}) async {
    final String url =
        "${BaseUrlManager.baseUrl}/mms/patient-case/patient-assignment?patientId=$patientId"; // URL confirmed

    try {
      final response = await http.get(
        Uri.parse(MmsHttpHelper.breakCacheGetUrl(url)),
        headers: <String, String>{"accept": "application/json"},
      );

      if (response.statusCode == 200) {
        dynamic jsonResponse = json.decode(response.body);

        if (jsonResponse != null) {
          final scenario = Scenario.fromJson(jsonResponse);
          // _logger.log(1,
          //     "Fetched active scenario: ID=${scenario.id}, Name=${scenario.scenarioName}");
          return scenario;
        } else {
          _logger.log(1, "Response body is null or empty");
        }
      } else {
        // _logger.log(1,
        //     "Failed to fetch active scenario. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _logger.log(1, "Error fetching active scenario: $e");
    }

    return null;
  }

  // TODO: potential delete fetchTreatmentScenarios(); get list from patient case builder bloc instead
  /// Fetch the list of all available scenarios.
  /// GET: https://localhost:6544/mms/treatment/scenarios
  static Future<ScenarioList> fetchTreatmentScenarios() async {
    final String url =
        "${BaseUrlManager.baseUrl}/mms/treatment/scenarios"; // TODO: Review this URL

    try {
      final response = await http.get(
        Uri.parse(MmsHttpHelper.breakCacheGetUrl(url)),
        headers: <String, String>{"accept": "application/json"},
      );

      if (response.statusCode == 200) {
        dynamic jsonDecoded = json.decode(response.body);
        List<Map<String, dynamic>> converted =
            List<Map<String, dynamic>>.from(jsonDecoded);
        // _logger.log(1, "Fetched all scenarios: $converted");
        return ScenarioList.fromJson(converted);
      } else {
        _logger.log(1,
            "Failed to fetch treatment scenarios. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _logger.log(1, "Error fetching treatment scenarios: $e");
    }

    return ScenarioList();
  }

  /// Post the active scenario for a given patient.
  /// POST: https://localhost:6544/mms/patient-case/patient-assignment?patientId={patientId}&caseNum={caseNum}
  static Future<bool> postActiveScenario(int caseNum,
      {required String patientId}) async {
    final String url =
        "${BaseUrlManager.baseUrl}/mms/patient-case/patient-assignment?patientId=$patientId&caseNum=$caseNum"; // URL confirmed

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201) {
        _logger.log(
            1, "Active scenario set successfully for patient: $patientId");
        return true;
      } else {
        _logger.log(1,
            "Failed to post active scenario. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _logger.log(1, "Error posting active scenario: $e");
    }
    return false;
  }

  /// Post a physical treatment with the associated device used.
  static Future<bool> postTreatment(
      String treatmentName, String treatmentLocation,
      {required String deviceUsed, String? injury, String? patientId}) async {
    const physicalTreatmentUrl = 'mms/treatment/physical';
    String url = "${BaseUrlManager.baseUrl}/$physicalTreatmentUrl";
    if (patientId != null) {
      url += "?patientId=$patientId";
    }

    Map<String, dynamic> payload = {
      "treatmentName": treatmentName,
      "treatmentLocation": treatmentLocation,
      "deviceUsed": deviceUsed,
      "injury": injury
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201) {
        LastTreatmentStore().putLastTreatment(patientId ?? "", treatmentName);
        return true;
      }
    } catch (e) {
      _logger.log(1, "Error posting treatment: $e");
    }
    return false;
  }

  /// Post medication details for a given patient.
  static Future<bool> postMedication(
    String medication, // Now takes a String instead of MedicationEnum
    MedicationAdministrationRouteEnum route,
    String dosage, {
    String? patientId,
  }) async {
    const medicationTreatmentUrl = 'mms/treatment/medication';
    String url = "${BaseUrlManager.baseUrl}/$medicationTreatmentUrl";

    if (patientId != null) {
      url += "?patientId=$patientId";
    }

    // Create payload with the medication name as a string
    Map<String, dynamic> payload = {
      "medication": medication, // Use medication as a string
      "route": route.name,
      "dosage": dosage,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        // Save the last treatment using the medication name
        LastTreatmentStore().putLastTreatment(patientId ?? "", medication);
        return true;
      } else {
        _logger.log(1,
            "Failed to post medication. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _logger.log(1, "Error posting medication: $e");
    }

    return false;
  }
}

class MockTreatmentScenarioServices {
  static Future<Scenario?> fetchActiveScenario(
      {required String patientId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Scenario(
      id: 1,
      scenarioName: "Mock Active Scenario",
      specs: ScenarioSpecs(
        treatments: [
          TreatmentsByType(
            type: "Physical",
            detailsList: [
              TreatmentDetailsBySubType(
                subType: "GSW",
                specifics: [
                  TreatmentSpecifics(
                    name: "Mock Hemostatic Dressing",
                    deviceUsed: TreatmentDeviceEnum.bandage.toString(),
                    treatmentLocation: "ANTERIOR_RIGHT_THIGH",
                    injuries: ['Hemorrhage'],
                  ),
                ],
              ),
            ],
          ),
        ],
        medication: [
          Medication(
            type: "Pain Relief",
            detailsList: [
              MedicationDetails(
                subType: "Opioids",
                specifics: [
                  MedicationSpecifics(name: 'morphine', allowed: true),
                  MedicationSpecifics(name: 'fentanylCitrate', allowed: false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<ScenarioList> fetchTreatmentScenarios() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ScenarioList(scenarios: [
      Scenario(id: 1, scenarioName: "Mock Scenario 1"),
      Scenario(id: 2, scenarioName: "Mock Scenario 2"),
      Scenario(id: 3, scenarioName: "Mock Scenario 3"),
    ]);
  }
}
