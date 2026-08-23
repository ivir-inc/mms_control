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
import 'package:flutter_ui/modules/treatments/data/storage/last_treatment_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("PatientCaseRest");

class PatientCaseRest {
  static const String patientCasesUrl = "mms/patient-case";

  String _combineUrl(String baseUrl, String endpoint) {
    // Remove trailing slash from baseUrl and leading slash from endpoint
    baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    endpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

    return "$baseUrl/$endpoint";
  }

  Future<List<PatientCase>> fetchPatientCasesInfo() async {
    _logger.logTrace(1, "in fetchPatientCasesInfo");
    String getFullUrl =
        _combineUrl(BaseUrlManager.baseUrl, '$patientCasesUrl/all');
    try {
      // _logger.logTrace(1, "Sending query: $getFullUrl");
      final response = await http.get(Uri.parse(getFullUrl));
      if (response.statusCode == 200) {
        // _logger.logTrace(1, "Received 200 status code");
        return responseToPatientCaseList(response);
      } else {
        _logger.logError(1,
            'Failed to get Patient Cases. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.logError(1, 'Error attempting to get Patient Cases: $e');
      return []; // Return empty list on failure
    }
  }

  List<PatientCase> responseToPatientCaseList(Response response) {
    try {
      Iterable jsonDecodedList = json.decode(response.body);
      return jsonDecodedList
          .map((jsonDecoded) => PatientCase.fromJson(jsonDecoded))
          .toList();
    } catch (e) {
      _logger.logError(1, "Error parsing Patient Case data: $e");
      return [];
    }
  }

  Future<PatientCase> postNewPatientCase(PatientCase patientCase) async {
    String postFullUrl = _combineUrl(BaseUrlManager.baseUrl, patientCasesUrl);
    Map<String, dynamic> patientCaseJson = patientCase.toJson();
    _logger.logTrace(1, "POST Request Body: ${jsonEncode(patientCaseJson)}");

    try {
      final response = await http.post(
        Uri.parse(postFullUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(patientCaseJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.logTrace(1, "Successfully posted new Patient Case");
        return PatientCase.fromJson(json.decode(response.body));
      } else {
        _logger.logError(2,
            'Failed to post new Patient Case. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to post new Patient Case');
      }
    } catch (e) {
      _logger.logError(2, 'Error posting new Patient Case: $e');
      throw Exception("Error attempting to post new Patient Case");
    }
  }

  Future<List<PatientCase>> putUpdatePatientCases(
      List<PatientCase> patientCases) async {
    String putFullUrl = _combineUrl(BaseUrlManager.baseUrl, patientCasesUrl);
    List<PatientCase> updatedPatientCases = [];

    for (PatientCase patientCase in patientCases) {
      Map<String, dynamic> patientCaseJson = patientCase.toJson();
      // _logger.logTrace(1,
      //     "PUT Request Body for ${patientCase.name}: ${jsonEncode(patientCaseJson)}");

      try {
        final response = await http.put(
          Uri.parse(putFullUrl),
          headers: {
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              patientCaseJson), // Send each Patient Case as a single JSON object
        );

        if (response.statusCode == 204) {
          _logger.logTrace(1,
              "Successfully updated Patient Case with name: ${patientCase.name}");

          // Ask for updated case definition:

          try {
            final updatedPatientCaseResponse = await http.get(
              Uri.parse('$putFullUrl/${patientCase.caseNum}'),
              headers: {
                "Accept": "application/json",
                'Content-Type': 'application/json; charset=UTF-8',
              },
            );
            updatedPatientCases.add(PatientCase.fromJson(
                json.decode(updatedPatientCaseResponse.body)));
          } on Exception catch (e) {
            _logger.logError(2,
                'Error retrieving updated Patient Case with name: ${patientCase.name}: $e');
          }
        } else {
          _logger.logError(2,
              'Failed to update Patient Case with name: ${patientCase.name}. Status code: ${response.statusCode}, Body: ${response.body}');
          throw Exception(
              'Failed to update Patient Case with name: ${patientCase.name}');
        }
      } catch (e) {
        _logger.logError(2,
            'Error updating Patient Case with name: ${patientCase.name}: $e');
        throw Exception(
            "Error attempting to update Patient Case with name: ${patientCase.name}");
      }
    }

    return updatedPatientCases;
  }

  Future<void> deletePatientCase(int patientCaseNum) async {
    _logger.logTrace(2, 'Deleting Patient Case with num: $patientCaseNum');

    // Construct the full URL with the Patient Case name
    String deleteUrl =
        _combineUrl(BaseUrlManager.baseUrl, '$patientCasesUrl/$patientCaseNum');

    try {
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _logger.logTrace(
            2, "Successfully deleted Patient Case with num: $patientCaseNum");
      } else {
        _logger.logError(2,
            'Failed to delete Patient Case. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete Patient Case');
      }
    } catch (e) {
      _logger.logError(2, 'Error deleting Patient Case: $e');
      throw Exception("Error attempting to delete Patient Case");
    }
  }

  // TODO: Confirm if needed. Probably not.
  Future<void> deletePatientCaseList(List<String> patientCaseNames) async {
    _logger.logTrace(2, 'in deletePatientCaseList()');
    String deleteFullUrl = _combineUrl(BaseUrlManager.baseUrl, patientCasesUrl);

    try {
      final response = await http.delete(
        Uri.parse(deleteFullUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(patientCaseNames),
      );

      if (response.statusCode == 200) {
        _logger.logTrace(2, "Successfully deleted Patient Cases");
      } else {
        _logger.logError(2,
            'Failed to delete Patient Cases. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete Patient Cases');
      }
    } catch (e) {
      _logger.logError(2, 'Error deleting Patient Cases: $e');
      throw Exception("Error attempting to delete Patient Cases");
    }
  }

  Future<bool> assignPatientCaseToPatient(
      String patientId, int patientCaseNum) async {
    final String url = _combineUrl(BaseUrlManager.baseUrl,
        '$patientCasesUrl/patient-assignment?patientId=$patientId&caseNum=$patientCaseNum');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201) {
        _logger.log(1,
            "Patient case num $patientCaseNum successfully assigned to patient: $patientId");
        return true;
      } else {
        _logger.log(1,
            "Failed to assign patient case num $patientCaseNum to patient id $patientId. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _logger.log(1,
          "Error assigning patient case num $patientCaseNum to patient id $patientId: $e");
    }
    return false;
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
  Future<bool> postPhysicalTreatment(
      String treatmentName, BodyLocationRecord bodyLocation,
      {required String deviceUsed, String? injury, String? patientId}) async {
    const physicalTreatmentUrl = 'mms/treatment/physical';
    String url = "${BaseUrlManager.baseUrl}/$physicalTreatmentUrl";

    Map<String, dynamic> payload = {
      "patientId": patientId,
      "treatment": treatmentName,
      "deviceUsed": deviceUsed,
      "treatmentLocation": bodyLocation.toJson(),
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
        return true;
      }
    } catch (e) {
      _logger.log(1, "Error posting treatment: $e");
    }
    return false;
  }

  /// Post medication details for a given patient.
  Future<bool> postMedication(
    String dynamicMedicationName,
    String patientId,
    String administrationRoute,
    double dosageValue,
    int dosageTimePeriod,
  ) async {
    const medicationTreatmentUrl = 'mms/treatment/medication';
    String url = "${BaseUrlManager.baseUrl}/$medicationTreatmentUrl";

    // Create payload with the medication name as a string
    Map<String, dynamic> payload = {
      "medication": dynamicMedicationName, // Use medication as a string
      "patientId": patientId,
      "administrationRoute": administrationRoute,
      "dosageValue": dosageValue,
      "dosageTimePeriod": dosageTimePeriod,
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
        LastTreatmentStore().putLastTreatment(patientId, dynamicMedicationName);
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
