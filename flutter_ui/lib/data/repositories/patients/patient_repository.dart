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

import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/data/provider/patients/patient_rest.dart';

Logger _logger = Logger("PatientRepository");

class PatientRepository {
  final PatientRest patientRest;
  final Map<String, Patient> patientMap = {};

  PatientRepository(this.patientRest);

  Patient? getPatient(String id) {
    return patientMap[id];
  }

  Future<Patient> addNewPatient(Patient newPatient) async {
    _logger.logTrace(1, 'Adding new patient to REST API');
    Patient postedPatient = await patientRest.postNewPatient(newPatient);
    putPatient(postedPatient);
    _logger.logDebug(1, "New patient added: ${postedPatient.id}");
    return postedPatient;
  }

  void putPatient(Patient patient) {
    patientMap[patient.id] = patient;
  }

  Future<List<Patient>> fetchAllPatients() async {
    final List<Patient> restList = await patientRest.fetchPatientsInfo();
    patientMap.clear();
    for (var patient in restList) {
      putPatient(patient);
    }
    _logger.logDebug(1, "Total patients fetched: ${restList.length}");
    return patientMap.values.toList();
  }

  Future<List<Patient>> updatePatients(List<Patient> changedPatients) async {
    _logger.logTrace(2, 'Updating patients in the REST API');
    try {
      List<Patient> updatedPatients =
          await patientRest.putUpdatePatients(changedPatients);
      for (var patient in updatedPatients) {
        putPatient(patient); // Update local cache with new patient data
      }
      _logger.logTrace(2, "Successfully updated patients");
      return updatedPatients;
    } catch (e) {
      _logger.logError(2, 'Error updating patients: $e');
      throw Exception("Error attempting to update patients");
    }
  }

  Future<void> deletePatients(List<Patient> patientsToDelete) async {
    List<String> patientIds =
        patientsToDelete.map((patient) => patient.id).toList();
    _logger.logTrace(2, 'Deleting patients from REST API: $patientIds');

    for (String id in patientIds) {
      await patientRest.deletePatient(id);
      patientMap.remove(id);
    }

    _logger.logDebug(
        2, "${patientsToDelete.length} patients deleted successfully.");
  }

  Future<List<Patient>> refreshFromServer() async {
    _logger.logTrace(1, 'Refreshing patients from REST API (server truth)');
    final List<Patient> restList = await patientRest.fetchPatientsInfo();

    // Replace local cache with EXACT server set
    patientMap.clear();
    for (final p in restList) {
      putPatient(p);
    }
    _logger.logDebug(1, "Server returned ${restList.length} patients");
    return patientMap.values.toList();
  }
}
