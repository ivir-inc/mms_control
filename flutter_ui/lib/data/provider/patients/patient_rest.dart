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
import 'package:http/http.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("PatientRest");

class PatientRest {
  static const String patientsUrl =
      "mms/patientList"; // Ensure no leading slash

  String _combineUrl(String baseUrl, String endpoint) {
    // Remove trailing slash from baseUrl and leading slash from endpoint
    baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    endpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

    return "$baseUrl/$endpoint";
  }

  Future<List<Patient>> fetchPatientsInfo() async {
    _logger.logTrace(1, "in fetchPatientsInfo");
    String getFullUrl = _combineUrl(BaseUrlManager.baseUrl, patientsUrl);
    try {
      // _logger.logTrace(1, "Sending query: $getFullUrl");
      final response = await http.get(Uri.parse(getFullUrl));
      if (response.statusCode == 200) {
        // _logger.logTrace(1, "Received 200 status code");
        return responseToPatientList(response);
      } else {
        _logger.logError(
            1, 'Failed to get Patients. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.logError(1, 'Error attempting to get Patients: $e');
      return []; // Return empty list on failure
    }
  }

  List<Patient> responseToPatientList(Response response) {
    try {
      Iterable jsonDecodedList = json.decode(response.body);
      return jsonDecodedList
          .map((jsonDecoded) => Patient.fromJson(jsonDecoded))
          .toList();
    } catch (e) {
      _logger.logError(1, "Error parsing patient data: $e");
      return [];
    }
  }

  Future<Patient> postNewPatient(Patient newPatient) async {
    String postFullUrl = _combineUrl(BaseUrlManager.baseUrl, patientsUrl);
    Map<String, dynamic> patientJson = newPatient.toJson();
    _logger.logTrace(1, "POST Request Body: ${jsonEncode(patientJson)}");

    try {
      final response = await http.post(
        Uri.parse(postFullUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(patientJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.logTrace(1, "Successfully posted new patient");
        return Patient.fromJson(json.decode(response.body));
      } else {
        _logger.logError(2,
            'Failed to post new patient. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to post new patient');
      }
    } catch (e) {
      _logger.logError(2, 'Error posting new patient: $e');
      throw Exception("Error attempting to post new patient");
    }
  }

  Future<List<Patient>> putUpdatePatients(List<Patient> patients) async {
    String putFullUrl = _combineUrl(BaseUrlManager.baseUrl, patientsUrl);
    List<Patient> updatedPatients = [];

    for (Patient patient in patients) {
      Map<String, dynamic> patientJson = patient.toJson();
      _logger.logTrace(
          1, "PUT Request Body for ${patient.id}: ${jsonEncode(patientJson)}");

      try {
        final response = await http.put(
          Uri.parse(putFullUrl),
          headers: {
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              patientJson), // Send each patient as a single JSON object
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          _logger.logTrace(
              1, "Successfully updated patient with ID: ${patient.id}");
          updatedPatients.add(Patient.fromJson(json.decode(response.body)));
        } else {
          _logger.logError(2,
              'Failed to update patient with ID: ${patient.id}. Status code: ${response.statusCode}, Body: ${response.body}');
          throw Exception('Failed to update patient with ID: ${patient.id}');
        }
      } catch (e) {
        _logger.logError(
            2, 'Error updating patient with ID: ${patient.id}: $e');
        throw Exception(
            "Error attempting to update patient with ID: ${patient.id}");
      }
    }

    return updatedPatients;
  }

  Future<void> deletePatient(String patientId) async {
    _logger.logTrace(2, 'Deleting patient with ID: $patientId');

    // Encode ONLY the path segment (e.g., names/IDs with #, ?, /, spaces, etc.)
    final encodedId = Uri.encodeComponent(patientId);

    final deleteUrl = _combineUrl(
      BaseUrlManager.baseUrl,
      '$patientsUrl/patient/$encodedId',
    );

    try {
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _logger.logTrace(2, "Successfully deleted patient with ID: $patientId");
      } else {
        _logger.logError(2,
            'Failed to delete patient. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete patient');
      }
    } catch (e) {
      _logger.logError(2, 'Error deleting patient: $e');
      throw Exception("Error attempting to delete patient");
    }
  }

  Future<void> deletePatientList(List<String> patientIds) async {
    _logger.logTrace(2, 'in deletePatientList()');
    String deleteFullUrl = _combineUrl(BaseUrlManager.baseUrl, patientsUrl);

    try {
      final response = await http.delete(
        Uri.parse(deleteFullUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(patientIds),
      );

      if (response.statusCode == 200) {
        _logger.logTrace(2, "Successfully deleted patients");
      } else {
        _logger.logError(2,
            'Failed to delete patients. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete patients');
      }
    } catch (e) {
      _logger.logError(2, 'Error deleting patients: $e');
      throw Exception("Error attempting to delete patients");
    }
  }
}
