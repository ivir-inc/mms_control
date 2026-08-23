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

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart'; // Import for ScaffoldMessenger
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/data/model/vitals/vitals_model.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter_ui/data/provider/patients/patient_deleted_wire_store.dart';
import 'package:flutter_ui/data/repositories/patients/patient_repository.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

part 'patient_management_event.dart';
part 'patient_management_state.dart';

Logger _logger = Logger("PatientManagementBloc");

class PatientManagementBloc
    extends Bloc<PatientManagementEvent, PatientManagementState> {
  final PatientRepository patientRepository;
  late final PatientDeletedWireStore _pdStore;

  // Define fallback default patients
  final List<Patient> defaultPatients = [
    Patient(
        "Test PatientID - A", "Test Patient A", PatientSource.external, false),
    Patient(
        "Test PatientID - C", "Test Patient C", PatientSource.external, false),
    Patient(
        "Test PatientID - B", "Test Patient B", PatientSource.external, false),
  ];

  PatientManagementBloc(this.patientRepository)
      : super(
            const PatientManagementState(patients: [], patientVisibility: {})) {
    on<PatientManagementEvent>(_handlePatientManagementEvent);

    // Initialize with fallback patients on startup
    add(const PatientManagementEvent(PatientManagementAction.initialize, []));

    // React to WS deletions
    _pdStore = PatientDeletedWireStore(
      onDeleted: (id) {
        // existing: update patient list
        add(PatientManagementEvent(
          PatientManagementAction.remoteDelete,
          const [],
          patientIds: [id],
          locallyCreated: false,
        ));

        // Clear stale vitals so the UI shows "--" immediately
        VitalsValuesStore().removeVitalsForPatient(id);
      },
    );
    MmsDataRouter().registerStoreForDataType('PatientDeleted', _pdStore);
  }

  Future<void> _handlePatientManagementEvent(
    PatientManagementEvent event,
    Emitter<PatientManagementState> emitter,
  ) async {
    switch (event.action) {
      case PatientManagementAction.initialize:
        await _handleInitializeEvent(emitter);
        break;

      case PatientManagementAction.addPatient:
        await _handleAddPatientEvent(event, emitter, event.context);
        break;

      case PatientManagementAction.updatePhysiologySource:
        _handleUpdatePhysiologySource(event, emitter);
        break;

      case PatientManagementAction.toggleVisibility:
        _handleToggleVisibilityEvent(event, emitter);
        break;

      case PatientManagementAction.assignPatientCase:
        if (event.context != null) {
          await _handleAssignPatientCaseToPatientEvent(
              event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot assign patient case');
        }
        break;

      case PatientManagementAction.deletePatients:
        if (event.context != null) {
          await _handleDeletePatientsEvent(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot delete patients');
        }
        break;

      case PatientManagementAction.refreshFromServer:
        await _handleRefreshFromServerEvent(event, emitter);
        break;

      case PatientManagementAction.remoteDelete:
        _handleRemoteDelete(event, emitter);
        break;

      case PatientManagementAction.updatePatients:
      // Add handling if necessary.
    }
  }

  // Initialize patient list and set default visibility
  Future<void> _handleInitializeEvent(
    Emitter<PatientManagementState> emitter,
  ) async {
    _logger.logDebug(1, "Handling initialize PatientManagement Event");
    try {
      final patientList = await patientRepository.fetchAllPatients();
      _logger.logDebug(
          1, "Fetched patients from repository: ${patientList.length}");

      if (patientList.isEmpty) {
        _logger.logDebug(1, "No patients found, using fallback patients");
        emitter(state.copyWith(
            patients: defaultPatients,
            patientVisibility: _initializeVisibility(defaultPatients)));
      } else {
        emitter(state.copyWith(
            patients: patientList,
            patientVisibility: _initializeVisibility(patientList)));
      }
    } catch (e) {
      _logger.logError(1, 'Error during patient initialization: $e');
      emitter(state.copyWith(
          patients: defaultPatients,
          patientVisibility: _initializeVisibility(defaultPatients)));
    }
  }

  Future<void> _handleAddPatientEvent(
    PatientManagementEvent event,
    Emitter<PatientManagementState> emitter,
    BuildContext? context,
  ) async {
    _logger.logDebug(1, "Handling addPatient Event");

    try {
      final List<Patient> newPatients = event.patients.cast<Patient>();

      // Check if the patient ID already exists in the current state
      if (state.patients.any((p) => p.id == newPatients.first.id)) {
        _logger.logError(
            1, "Patient ID '${newPatients.first.id}' already exists.");

        // Show red flash banner on failure
        if (context != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Patient name already exists. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            _logger.logError(1, 'Failed to show SnackBar.');
          }
        }

        return;
      }

      if (event.locallyCreated) {
        // Persist the new patient via the repository
        await patientRepository.addNewPatient(newPatients.first);

        // Depend here on subsequent Patient messages on websocket
        // for updating the Bloc (triggers 'else' block below)
      } else {
        // Patient came in over the wire. These could be from
        // local additions via MMS Control, or because of a
        // federation-originated patient. Update the patient list
        // with the new patient.

        // Add just the new patient to existing state
        final updatedPatients = List<Patient>.from(state.patients)
          ..add(newPatients.first);

        final updatedVisibility =
            Map<String, bool>.from(state.patientVisibility)
              ..[newPatients.first.id] = newPatients.first.monitorPatient;

        emitter(state.copyWith(
          patients: updatedPatients,
          patientVisibility: updatedVisibility,
        ));
      }
    } catch (e) {
      _logger.logError(1, 'Error adding patient: $e');
    }
  }

  void _handleUpdatePhysiologySource(
    PatientManagementEvent event,
    Emitter<PatientManagementState> emitter,
  ) async {
    _logger.logDebug(1, "Handling updatePhysiologySource Event");

    final patientId = event.patientId;
    final newSource = event.patientSource ?? PatientSource.unknown;

    // Find and update the patient’s physiology source
    final patientIndex = state.patients.indexWhere((p) => p.id == patientId);
    if (patientIndex != -1) {
      final updatedPatient = state.patients[patientIndex].copyWith(
        physiologySource: newSource,
      );

      // Emit the updated state for immediate UI feedback
      final updatedPatients = List<Patient>.from(state.patients)
        ..[patientIndex] = updatedPatient;
      emitter(state.copyWith(
        patients: updatedPatients,
        patientVisibility: state.patientVisibility,
      ));

      // Update the backend
      try {
        await patientRepository.updatePatients([updatedPatient]);
        _logger.logTrace(
            1, "Successfully updated physiology source for $patientId");
      } catch (e) {
        _logger.logError(1, 'Error updating physiology source: $e');
      }
    } else {
      _logger.logError(1, 'Patient with ID $patientId not found');
    }
  }

  // Optimistic visibility update for patients
  Future<void> _handleToggleVisibilityEvent(
    PatientManagementEvent event,
    Emitter<PatientManagementState> emitter,
  ) async {
    _logger.logDebug(1, "Handling toggleVisibility Event");

    // Clone current state for updates
    final List<Patient> updatedPatients = List.from(state.patients);
    final Map<String, bool> updatedVisibility =
        Map.from(state.patientVisibility);

    // Update each patient with the correct monitorPatient value from the event
    for (var patient in event.patients) {
      final patientIndex =
          updatedPatients.indexWhere((p) => p.id == patient.id);
      if (patientIndex != -1) {
        // Directly set monitorPatient to the desired value
        final updatedPatient = updatedPatients[patientIndex].copyWith(
          monitorPatient: patient.monitorPatient,
        );

        updatedPatients[patientIndex] = updatedPatient;
        updatedVisibility[patient.id] = updatedPatient.monitorPatient;
      }
    }

    // Emit updated state
    emitter(state.copyWith(
      patients: updatedPatients,
      patientVisibility: updatedVisibility,
    ));

    // Persist updated visibility to backend
    try {
      await patientRepository.updatePatients(event.patients);
      _logger.logTrace(
          1, "Successfully updated monitorPatient field for visibility");
    } catch (e) {
      _logger.logError(1, 'Failed to update patient visibility: $e');
    }
  }

  // Assign Patient Case to a Patient. Doing this here rather than
  // the Patient Case Builder bloc because we need to trigger patient-related
  // UI updates if an attribute of the Patients changes (which is exactly
  // what we're doing here).
  Future<void> _handleAssignPatientCaseToPatientEvent(
    PatientManagementEvent event,
    Emitter<PatientManagementState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleAssignPatientCaseToPatientEvent Event");

    final patientId = event.patientId;
    final patientCaseNum = event.patientCaseNum;

    // Find and update the patient’s physiology source
    final patientIndex = state.patients.indexWhere((p) => p.id == patientId);
    if (patientIndex != -1) {
      final updatedPatient = state.patients[patientIndex].copyWith(
        patientCaseNum: patientCaseNum,
      );

      // Emit the updated state for immediate UI feedback
      final updatedPatients = List<Patient>.from(state.patients)
        ..[patientIndex] = updatedPatient;
      emitter(state.copyWith(
        patients: updatedPatients,
      ));

      // Update the backend
      try {
        await patientRepository.updatePatients([updatedPatient]);
        _logger.logTrace(1,
            "Successfully assigned patient case $patientCaseNum to patient $patientId");
      } catch (e) {
        _logger.logError(1, 'Error assigning patient case to patient: $e');
      }
    } else {
      _logger.logError(1, 'Patient with ID $patientId not found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete patient. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete patients and emit updated state
  Future<void> _handleDeletePatientsEvent(
    PatientManagementEvent event,
    Emitter<PatientManagementState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(1, "Handling deletePatients Event");

    try {
      // First attempt to delete the patients from the backend
      await patientRepository.deletePatients(event.patients);

      // If the deletion is successful, update the state
      final updatedPatients = List<Patient>.from(state.patients)
        ..removeWhere((patient) => event.patients.contains(patient));

      // Remove deleted patients from the visibility map
      final updatedVisibility = Map<String, bool>.from(state.patientVisibility)
        ..removeWhere((id, _) => event.patients.any((p) => p.id == id));

      // Emit the updated state immediately to reflect the change
      emitter(state.copyWith(
        patients: updatedPatients,
        patientVisibility: updatedVisibility,
      ));

      _logger.logDebug(1, "Patients deleted successfully");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error deleting patients: $e');

      // Show red flash banner on failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete patient. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Initialize the visibility map from the patient list
  Map<String, bool> _initializeVisibility(List<Patient> patients) {
    final visibilityMap = {
      for (var patient in patients) patient.id: patient.monitorPatient
    };
    //_logger.logDebug(1, "Initialized visibility map: $visibilityMap");
    return visibilityMap;
  }

  Future<void> _handleRefreshFromServerEvent(PatientManagementEvent event,
      Emitter<PatientManagementState> emitter) async {
    _logger.logDebug(1, "Handling refreshFromServer Event");

    // 1) Snapshot current state
    final List<Patient> previous = List<Patient>.unmodifiable(state.patients);

    try {
      // 2) Ask repository to fetch fresh list and *replace* its cache
      final List<Patient> serverPatients =
          await patientRepository.refreshFromServer();

      // 3) Build ID -> Patient maps
      final Map<String, Patient> prevById = {
        for (final p in previous) p.id: p,
      };
      final Map<String, Patient> nextById = {
        for (final p in serverPatients) p.id: p,
      };

      // 4) Compute diffs
      final List<Patient> added = [];
      final List<Patient> updated = [];
      final List<String> removedIds = [];

      for (final entry in nextById.entries) {
        final String id = entry.key;
        final Patient nextP = entry.value;
        final Patient? prevP = prevById[id];
        if (prevP == null) {
          added.add(nextP);
        } else if (nextP != prevP) {
          // relies on Patient == (Equatable) to be meaningful
          updated.add(nextP);
        }
      }

      for (final id in prevById.keys) {
        if (!nextById.containsKey(id)) {
          removedIds.add(id);
        }
      }

      _logger.logTrace(
        1,
        "Refresh diffs — added: ${added.length}, updated: ${updated.length}, removed: ${removedIds.length}",
      );

      // 5) Rebuild visibility map:
      //    - remove deleted
      //    - set visibility for new/updated from server (server is ground truth)
      final Map<String, bool> newVisibility = {
        for (final p in serverPatients) p.id: p.monitorPatient,
      };

      // 6) Emit ONE new state with server as truth
      emitter(state.copyWith(
        patients: serverPatients,
        patientVisibility: newVisibility,
      ));
    } catch (e) {
      _logger.logError(1, "Error during refreshFromServer: $e");
      // Optional policy: keep current UI if refresh fails (no emit).
      // If you *want* to surface a failure banner, you can inject a context into the event.
    }
  }

  void _handleRemoteDelete(
    PatientManagementEvent event,
    Emitter<PatientManagementState> emitter,
  ) {
    final ids = event.patientIds ?? const <String>[];
    if (ids.isEmpty) return;

    final updatedPatients = List<Patient>.from(state.patients)
      ..removeWhere((p) => ids.contains(p.id));

    final updatedVisibility = Map<String, bool>.from(state.patientVisibility)
      ..removeWhere((id, _) => ids.contains(id));

    emitter(state.copyWith(
      patients: updatedPatients,
      patientVisibility: updatedVisibility,
    ));
  }

  @override
  Future<void> close() {
    MmsDataRouter().removeStoreForDataType('PatientDeleted', _pdStore);
    return super.close();
  }
}
