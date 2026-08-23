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

import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/provider/patient_cases/patient_case_rest.dart';

Logger _logger = Logger("PatientCaseRepository");

class PatientCaseRepository {
  final PatientCaseRest patientCaseRest;
  final Map<String?, PatientCase> patientCaseMap = {};

  PatientCaseRepository(this.patientCaseRest);

  PatientCase? getPatientCase(String id) {
    return patientCaseMap[id];
  }

  Future<PatientCase> addNewPatientCase(PatientCase newPatientCase) async {
    _logger.logTrace(1, 'Adding new Patient Case to REST API');
    PatientCase postedPatientCase =
        await patientCaseRest.postNewPatientCase(newPatientCase);
    putPatientCase(postedPatientCase);
    _logger.logDebug(1, "New Patient Case added: ${postedPatientCase.name}");
    return postedPatientCase;
  }

  void putPatientCase(PatientCase patientCase) {
    patientCaseMap[patientCase.name] = patientCase;
  }

  Future<List<PatientCase>> fetchAllPatientCases() async {
    // _logger.logTrace(1, 'Fetching all Patient Cases from REST API');
    List<PatientCase> restList = await patientCaseRest.fetchPatientCasesInfo();
    for (var patientCase in restList) {
      putPatientCase(patientCase);
    }
    _logger.logDebug(1, "Total Patient Cases fetched: ${restList.length}");
    return patientCaseMap.values.toList();
  }

  Future<List<PatientCase>> updatePatientCases(
      List<PatientCase> changedPatientCases) async {
    _logger.logTrace(2, 'Updating Patient Cases in the REST API');
    try {
      List<PatientCase> updatedPatientCases =
          await patientCaseRest.putUpdatePatientCases(changedPatientCases);
      for (var patientCase in updatedPatientCases) {
        putPatientCase(
            patientCase); // Update local cache with new Patient Case data
      }
      _logger.logTrace(2, "Successfully updated Patient Cases");
      return updatedPatientCases;
    } catch (e) {
      _logger.logError(2, 'Error updating Patient Cases: $e');
      throw Exception("Error attempting to update Patient Cases");
    }
  }

  Future<void> deletePatientCase(
      int? patientCaseNum, String? patientCaseNameToDelete) async {
    if (patientCaseNum != null) {
      await patientCaseRest.deletePatientCase(patientCaseNum);
      patientCaseMap.remove(patientCaseNameToDelete);
      _logger.logDebug(
          2, "Patient Case [$patientCaseNameToDelete] deleted successfully.");
    }
  }

  Future<void> assignPatientCaseToPatient(
      String patientId, int patientCaseNum) async {
    _logger.logTrace(1, 'Assigning Patient Case To Patient - REST API');
    try {
      await patientCaseRest.assignPatientCaseToPatient(
          patientId, patientCaseNum);
    } catch (e) {
      _logger.logError(2, 'Error assigning patient case to patient: $e');
      throw Exception("Error attempting to assign patient case to patient");
    }
    _logger.logDebug(
        1, "Patient Case $patientCaseNum assigned to Patient $patientId");
  }

  Future<bool> sendPhysicalTreatment(
      String patientId,
      String dynamicTreatmentName,
      String dynamicDeviceName,
      BodyLocationRecord bodyLocation) async {
    _logger.logTrace(1, 'Passing physical treatment to REST API');
    final success = await patientCaseRest.postPhysicalTreatment(
        dynamicTreatmentName, bodyLocation,
        deviceUsed: dynamicDeviceName, patientId: patientId);
    return success;
  }

  Future<bool> sendMedication(
    String dynamicMedicationName,
    String patientId,
    String administrationRoute,
    double dosageValue,
    int dosageTimePeriod,
  ) async {
    _logger.logTrace(1, 'Passing medication to REST API');
    final success = await patientCaseRest.postMedication(dynamicMedicationName,
        patientId, administrationRoute, dosageValue, dosageTimePeriod);
    return success;
  }
}
