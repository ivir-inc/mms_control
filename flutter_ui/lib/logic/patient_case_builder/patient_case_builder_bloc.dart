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
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/data/repositories/patient_cases/patient_case_repository.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

part 'patient_case_builder_event.dart';
part 'patient_case_builder_state.dart';

Logger _logger = Logger("PatientCaseBuilderBloc");

class PatientCaseBuilderBloc
    extends Bloc<PatientCaseBuilderEvent, PatientCaseBuilderState> {
  final PatientCaseRepository patientCaseRepository;

  // TODO: Delete below section once comfortable, used for development

  // Define fallback default patients

  // final List<PatientCase> defaultPatientCases = [
  //   PatientCase(
  //       caseNum: 1,
  //       name: "Patient Case A",
  //       injuries: [
  //         Injury(
  //             id: "burn",
  //             location: BodyLocationRecord(
  //                 generalRegion: GeneralRegionEnum.face,
  //                 regionTissueType: RegionTissueTypeEnum.skin,
  //                 sagittalPlane: SagittalPlaneEnum.notApplicable,
  //                 coronalPlane: CoronalPlaneEnum.anterior),
  //             injuryType: InjuryTypeEnum.burn,
  //             burnBodySurfaceAreaPercentage: 50.1,
  //             description: InjuryDescriptionEnum.exposure,
  //             detail: "burnt right cheek",
  //             mechanism: MechanismOfInjuryRecord(cbrn: CBRNTypeEnum.chemical)),
  //         Injury(
  //             id: "puncture",
  //             location: BodyLocationRecord(
  //                 generalRegion: GeneralRegionEnum.thigh,
  //                 regionTissueType: RegionTissueTypeEnum.skin,
  //                 sagittalPlane: SagittalPlaneEnum.right,
  //                 coronalPlane: CoronalPlaneEnum.anterior),
  //             injuryType: InjuryTypeEnum.hemorrhage,
  //             hemorrhageRateMlPerMin: 25,
  //             description: InjuryDescriptionEnum.puncture,
  //             detail: "stabbing",
  //             mechanism: MechanismOfInjuryRecord(blade: BladeTypeEnum.serratedMedium))
  //       ],
  //       treatments: Treatments(['openNasalAirway', 'ventilationPEEP5']),
  //       medications: Medications(['freshWholeBlood', 'morphine', 'aspirin', 'clindamycin']),
  //       initialVitalSigns: InitialVitalSigns(hr: 77, sbp: 119, dbp: 71, spo2: 99.0, temp: 97, etco2: 37, rr: 11)),
  //   PatientCase(
  //       caseNum: 2,
  //       name: "Patient Case B",
  //       injuries: [
  //         Injury(
  //             id: "2",
  //             location: BodyLocationRecord(
  //                 generalRegion: GeneralRegionEnum.face,
  //                 regionTissueType: RegionTissueTypeEnum.skin,
  //                 sagittalPlane: SagittalPlaneEnum.left,
  //                 coronalPlane: CoronalPlaneEnum.anterior),
  //             injuryType: InjuryTypeEnum.burn,
  //             description: InjuryDescriptionEnum.notApplicable,
  //             detail: "burnt left cheek",
  //             mechanism: MechanismOfInjuryRecord(cbrn: CBRNTypeEnum.chemical))
  //       ],
  //       treatments: Treatments([]),
  //       medications: Medications([
  //         'lidocaine',
  //       ]),
  //       initialVitalSigns: InitialVitalSigns(hr: 82, sbp: 129, dbp: 79, spo2: 94.0, temp: 100.6, etco2: 35, rr: 16)),
  // ];

  final newPatientCaseTemplate = PatientCase(
      caseNum: null,
      name: "",
      injuries: <Injury>[],
      treatments: Treatments([]),
      medications: Medications([]),
      initialVitalSigns: InitialVitalSigns(),
      biologicalSex: BiologicalSexEnum.female);

  PatientCaseBuilderBloc(this.patientCaseRepository)
      : super(const PatientCaseBuilderState(patientCases: [])) {
    on<PatientCaseBuilderEvent>(_handlePatientCaseBuilderEvent);

    // Initialize with fallback patients on startup
    add(const PatientCaseBuilderEvent(PatientCaseBuilderAction.initialize,
        patientCases: []));
  }

  Future<void> _handlePatientCaseBuilderEvent(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
  ) async {
    switch (event.action) {
      case PatientCaseBuilderAction.initialize: // done
        await _handleInitializeEvent(emitter);
        break;
      case PatientCaseBuilderAction.addPatientCase: // done
        if (event.context != null) {
          await _handleAddPatientCaseEvent(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot add Patient Case');
        }
        break;
      case PatientCaseBuilderAction.renamePatientCase: // done
        if (event.context != null) {
          await _handleRenamePatientCaseEvent(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot rename Patient Case');
        }
        break;
      case PatientCaseBuilderAction.editOrDisplayPatientCase: // done
        if (event.context != null) {
          _handleEditPatientCaseEvent(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot edit Patient Case');
        }
        break;
      case PatientCaseBuilderAction.removePatientCase: // waiting on backend API
        if (event.context != null) {
          await _handleDeletePatientCaseEvent(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot delete Patient Cases');
        }
        break;
      case PatientCaseBuilderAction.addInjury: // done
        if (event.context != null) {
          await _handleAddInjury(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot add injury');
        }
        break;
      case PatientCaseBuilderAction.removeInjuries: // done
        if (event.context != null) {
          await _handleRemoveInjury(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot delete injuries');
        }
        break;
      case PatientCaseBuilderAction.editInjury: // done
        if (event.context != null) {
          _handleEditInjuryEvent(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot edit injuries');
        }
        break;
      case PatientCaseBuilderAction.renameInjury: // done
        if (event.context != null) {
          await _handleRenameInjury(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot rename injuries');
        }
        break;
      case PatientCaseBuilderAction.updateInjuryLocation: // done
        if (event.context != null) {
          await _handleUpdateInjuryLocation(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot update injury location');
        }
        break;
      case PatientCaseBuilderAction.updateInjuryType:
        if (event.context != null) {
          await _handleUpdateInjuryType(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot update injury type');
        }
        break;
      case PatientCaseBuilderAction.updateInjuryDescription:
        if (event.context != null) {
          await _handleUpdateInjuryDescription(event, emitter, event.context!);
        } else {
          _logger.logError(
              1, 'Context is null, cannot update injury description');
        }
        break;
      case PatientCaseBuilderAction.updateInjurySeverity:
        if (event.context != null) {
          await _handleUpdateInjurySeverity(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot update injury severity');
        }
        break;
      case PatientCaseBuilderAction.updateInjuryDetail:
        if (event.context != null) {
          await _handleUpdateInjuryDetail(event, emitter, event.context!);
        } else {
          _logger.logError(1, 'Context is null, cannot update injury detail');
        }
        break;
      case PatientCaseBuilderAction.updateInjuryMechanism:
        if (event.context != null) {
          await _handleUpdateInjuryMechanism(event, emitter, event.context!);
        } else {
          _logger.logError(
              1, 'Context is null, cannot update injury mechanism');
        }
        break;
      case PatientCaseBuilderAction.enableTreatment: // done
        await _handleEnableTreatment(event, emitter);
        break;
      case PatientCaseBuilderAction.disableTreatment: // done
        await _handleDisableTreatment(event, emitter);
        break;
      case PatientCaseBuilderAction.enableMedication: // done
        await _handleEnableMedication(event, emitter);
        break;
      case PatientCaseBuilderAction.disableMedication: // done
        await _handleDisableMedication(event, emitter);
        break;
      case PatientCaseBuilderAction.updateInitialVitalSigns:
        await _handleUpdateInitialVitalSigns(event, emitter);
        break;
      case PatientCaseBuilderAction.clearInitialVitalSigns:
        await _handleClearInitialVitalSigns(event, emitter, event.context!);
        break;
      case PatientCaseBuilderAction.assignPatientCaseToPatient:
        await _handleAssignPatientCaseToPatient(event, emitter, event.context!);
        break;
      case PatientCaseBuilderAction.sendPhysicalTreatment:
        await _handleSendPhysicalTreatment(event, emitter, event.context!);
        break;
      case PatientCaseBuilderAction.sendMedication:
        await _handleSendMedication(event, emitter, event.context!);
        break;
      case PatientCaseBuilderAction.updateBiologicalSex:
        await _handleUpdateBiologicalSex(event, emitter);
        break;
    }
  }

  // Initialize Patient Case list
  Future<void> _handleInitializeEvent(
    Emitter<PatientCaseBuilderState> emitter,
  ) async {
    _logger.logDebug(1, "Handling initialize PatientCaseBuilder Event");
    try {
      final patientCaseList =
          await patientCaseRepository.fetchAllPatientCases();
      _logger.logDebug(1,
          "Fetched Patient Cases from repository: ${patientCaseList.length}");

      if (patientCaseList.isEmpty) {
        _logger.logDebug(1, "No Patient Cases found.");
        // emitter(state.copyWith(
        //   patientCases: defaultPatientCases,
        // ));
      } else {
        emitter(state.copyWith(
          patientCases: patientCaseList,
        ));
      }
    } catch (e) {
      _logger.logError(1, 'Error during Patient Case initialization: $e');
      // emitter(state.copyWith(
      //   patientCases: defaultPatientCases,
      // ));
    }
  }

  Future<void> _handleAddPatientCaseEvent(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    try {
      // UI code should prevent Patient Case name from ever being null here
      assert(event.patientCaseName != null);
      final String newPatientCaseName = event.patientCaseName ?? '';

      // Check if the new name for the Patient Case already exists in a different Patient Case
      if (state.patientCases.any((p) => p.name == newPatientCaseName)) {
        _logger.logError(
            1, "Patient Case '$newPatientCaseName' already exists.");

        // Show red flash banner on failure
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Patient Case name already exists. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          _logger.logError(1, 'Failed to show SnackBar.');
        }

        return;
      }

      final newPatientCase =
          newPatientCaseTemplate.copyWith(name: newPatientCaseName);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Bloc patient case to backend, and get new Patient Case definition back
      final newPatientCaseFromRepo =
          await patientCaseRepository.addNewPatientCase(newPatientCase);

      // Update the state with the new patient and visibility
      final updatedPatientCases = List<PatientCase>.from(state.patientCases)
        ..add(newPatientCaseFromRepo);

      _logger.logDebug(1, "New Patient Case added: $updatedPatientCases");

      // Emit the updated state
      emitter(state.copyWith(
          patientCases: updatedPatientCases, saving: SaveStatus.saved));
    } catch (e) {
      _logger.logError(1, 'Error adding Patient Case: $e');
    }
  }

  Future<void> _handleRenamePatientCaseEvent(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(1, "Handling renamePatientCase Event");

    try {
      // UI *should* prevent both asserts from ever being null
      assert(event.patientCaseName != null);
      assert(event.newNameForPatientCase != null);

      final String originalPatientCaseName = event.patientCaseName ?? '';
      final String newNameForPatientCase = event.newNameForPatientCase ?? '';

      // Check if the new name for the Patient Case already exists in a different Patient Case
      if (state.patientCases.any((p) => p.name == newNameForPatientCase)) {
        _logger.logError(
            1, "Patient Case name '$newNameForPatientCase' already exists.");

        // Show red flash banner on failure
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Patient Case name already exists. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          _logger.logError(1, 'Failed to show SnackBar.');
        }

        return;
      }

      // Find Patient Case by name
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == originalPatientCaseName));

      // deep copy the found Patient Case
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      // deep copy the whole Patient Case list
      final copiedPatientCasesList =
          state.patientCases.map((e) => e.copyWith()).toList();

      // ditch the original Patient Case
      final List<PatientCase> updatedPatientCasesList = List<PatientCase>.from(
          copiedPatientCasesList as Iterable)
        ..removeWhere((pc) => pc.name!.contains(updatedPatientCase.name ?? ''));

      // Update the state with the new patient and visibility
      final updatedPatientCases = updatedPatientCasesList
        ..add(involvedPatientCase.copyWith(name: newNameForPatientCase));

      _logger.logDebug(1,
          "Patient Case rename success! New Patient Cases list: $updatedPatientCases");

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(updatedPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo,
          patientCaseUnderEditOrDisplay: newNameForPatientCase,
          saving: SaveStatus.saved));
    } catch (e) {
      _logger.logError(1, 'Error renaming Patient Case: $e');
    }
  }

  // Used to keep track of which Patient Case is being edited.
  void _handleEditPatientCaseEvent(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) {
    try {
      assert(event.patientCaseName != null);

      // Emit the updated state immediately to reflect the change
      emitter(state.copyWith(
        patientCaseUnderEditOrDisplay: event.patientCaseName ?? '',
      ));

      _logger.logDebug(
          1, "Patient Case under edit updated to ${event.patientCaseName}");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error updating Patient Case under edit: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update Patient Case under edit.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  // Delete Patient Case and emit updated state
  Future<void> _handleDeletePatientCaseEvent(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(1, "Handling deletePatientCase Event");

    try {
      // can't delete a patient case without a reference
      assert(event.patientCaseNum != null);
      assert(event.patientCaseName != null);

      final patientCaseNumToDelete = event.patientCaseNum;
      final patientCaseNameToDelete = event.patientCaseName;

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // delete from backend
      await patientCaseRepository.deletePatientCase(
          patientCaseNumToDelete, patientCaseNameToDelete);

      // If the deletion is successful, update the state
      final updatedPatientCases = List<PatientCase>.from(state.patientCases)
        ..removeWhere(
            (patientCase) => patientCase.caseNum == patientCaseNumToDelete);

      // Emit the updated state immediately to reflect the change
      emitter(state.copyWith(
          patientCases: updatedPatientCases, saving: SaveStatus.saved));

      _logger.logDebug(1, "Patient Cases deleted successfully");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error deleting Patient Cases: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete Patient Case. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(
            1, 'Failed to show SnackBar re: Error deleting Patient Cases: $e');
      }
    }
  }

  Future<void> _handleAddInjury(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(1, "Handling _handleAddInjury PatientCaseBuilder Event");

    // UI code should prevent injury id from ever being null here
    assert(event.injuryId != null);
    final String newInjuryId = event.injuryId ?? '';

    try {
      // 1. in the Patient Case list, find the patient-case-under-edit and clone it
      // 2. in the cloned Patient Case, find the injury list and add the new injury id to it
      // 3. clone the Patient Case list excluding the Patient Case under edit
      // 4. add the cloned Patient Case to the cloned Patient Case list and emit consolidated object

      // Find Patient Case by name (our unique id)
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == event.patientCaseName));

      // Check if the new id for the injury already exists in the Patient Case
      if (involvedPatientCase.injuries!.any((p) => p.id == newInjuryId)) {
        _logger.logError(
            1, "Injury add failed; injury '$newInjuryId' already exists.");

        // Show red flash banner on failure
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Injury name already exists. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          _logger.logError(1, 'Failed to show SnackBar.');
        }
        return;
      }

      // deep copy the found Patient Case (required by 'emitter' or it will not emit new state)
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      // initialize injury list if necessary
      updatedPatientCase.injuries ??= <Injury>[];

      // find the injury list and add the new injury id to it
      updatedPatientCase.injuries!.add(Injury(id: newInjuryId));

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1, "Injury $newInjuryId added successfully");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error adding injury $newInjuryId: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add injury. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleRemoveInjury(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    try {
      final List<Injury>? injuryList = event.injuryIds;

      // The only way this event should be fired is from a Patient Case
      // so we should always have one
      assert(event.patientCaseName != null);

      if (injuryList != null) {
        // Find Patient Case by name (our unique id)
        final PatientCase involvedPatientCase = state.patientCases
            .firstWhere((pc) => (pc.name == event.patientCaseName));

        // deep copy the found Patient Case
        final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

        // remove all selected injuries from the Patient Case
        final idsToRemove = injuryList.map((injury) => injury.id).toSet();

        updatedPatientCase.injuries =
            List<Injury>.from(updatedPatientCase.injuries ?? [])
              ..removeWhere((injury) => idsToRemove.contains(injury.id));

        final newPatientCases =
            createNewPatientCasesWithPatCase(updatedPatientCase);

        // Enter saving state
        emitter(state.copyWith(saving: SaveStatus.saving));

        // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
        // to be sure back and front end are consistent
        final newPatientCasesFromRepo =
            await patientCaseRepository.updatePatientCases(newPatientCases);

        // finally emit the updated Patient Cases to trigger the UI to rebuild
        emitter(state.copyWith(
            patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

        _logger.logDebug(1, "Injuries deleted successfully");
      }
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error deleting injuries: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete injuries. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

// Used to keep track of which injury is being edited.
  void _handleEditInjuryEvent(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) {
    try {
      assert(event.injuryId != null);

      // Emit the updated state immediately to reflect the change
      emitter(state.copyWith(
        injuryIdUnderEdit: event.injuryId ?? '',
      ));

      _logger.logDebug(1, "Injury under edit updated to ${event.injuryId}");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error updating Injury under edit: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update injury under edit.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleRenameInjury(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleRenameInjury PatientCaseBuilder Event");

    try {
      assert(event.patientCaseName != null);

      // UI code should prevent new injury id from ever being null
      assert(event.newIdForInjury != null);

      // 1. in the Patient Case list, find the patient-case-under-edit and clone it
      // 2. in the cloned Patient Case, find the injury-id-under-edit. modify that injury's id.
      // 3. clone the Patient Case list excluding the Patient Case under edit
      // 4. add the cloned Patient Case to the cloned Patient Case list and emit consolidated object

      // 1.1 Find Patient Case by name (our unique id)
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == event.patientCaseName));

      // there should be an injury in the Patient Case (UI enforced)
      assert(involvedPatientCase.injuries != null &&
          involvedPatientCase.injuries!.isNotEmpty);

      // Check if the new id for the injury already exists in the Patient Case
      if (involvedPatientCase.injuries!
          .any((p) => p.id == event.newIdForInjury)) {
        _logger.logError(1,
            "Injury rename failed; injury '${event.newIdForInjury}' already exists.");

        // Show red flash banner on failure
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Injury name already exists. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          _logger.logError(1, 'Failed to show SnackBar.');
        }
        return;
      }

      // 1.2 deep copy the found Patient Case
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      // Find the particular injury being renamed
      final involvedInjury = updatedPatientCase.injuries!
          .firstWhere((injury) => (injury.id == event.injuryId));

      // Actually do the rename
      involvedInjury.id = event.newIdForInjury!;

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo,
          injuryIdUnderEdit: involvedInjury.id,
          saving: SaveStatus.saved));

      _logger.logDebug(1,
          "Injury ${event.injuryId} in Patient Case ${event.patientCaseName} renamed to ${event.newIdForInjury} successfully");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1,
          'Error renaming injury ${event.injuryId} to ${event.newIdForInjury} in Patient Case ${event.patientCaseName}: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to rename injury. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleUpdateInjuryLocation(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleUpdateInjuryLocation PatientCaseBuilder Event");

    try {
      assert(event.patientCaseName != null);

      final PatientCase involvedPatientCase = state.patientCases.firstWhere(
        (pc) => pc.name == event.patientCaseName,
      );

      assert(involvedPatientCase.injuries != null &&
          involvedPatientCase.injuries!.isNotEmpty);

      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      final involvedInjury = updatedPatientCase.injuries!.firstWhere(
        (injury) => injury.id == event.injuryId,
      );

      if (event.bodyLocation != null) {
        involvedInjury.location = event.bodyLocation;
      } else {
        involvedInjury.location = null;
      }

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1, "Injury location handling completed successfully.");
    } catch (e) {
      _logger.logError(1, 'Error modifying injury location: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to modify injury location. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleUpdateInjuryType(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleUpdateInjuryType PatientCaseBuilder Event");
    try {
      assert(event.patientCaseName != null);

      // UI code should prevent updated injury type from ever being null
      assert(event.updatedInjuryType != null);

      // 1. in the Patient Case list, find the patient-case-under-edit and clone it
      // 2. in the cloned Patient Case, find the injury-id-under-edit. modify that injury's injuryType.
      // 3. clone the Patient Case list excluding the Patient Case under edit
      // 4. add the cloned Patient Case to the cloned Patient Case list and emit consolidated object

      // 1.1 Find Patient Case by name (our unique id)
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == event.patientCaseName));

      // there should be an injury in the Patient Case (UI enforced)
      assert(involvedPatientCase.injuries != null &&
          involvedPatientCase.injuries!.isNotEmpty);

      // 1.2 deep copy the found Patient Case
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      // Find the particular injury being modified
      final involvedInjury = updatedPatientCase.injuries!
          .firstWhere((injury) => (injury.id == event.injuryId));

      // Actually update the injury type
      involvedInjury.injuryType = event.updatedInjuryType!;

      // Clear severity fields
      involvedInjury.hemorrhageRateMlPerMin = null;
      involvedInjury.burnBodySurfaceAreaPercentage = null;
      involvedInjury.severityScore = null;

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1, "Modified injury type successfully.");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error modifying injury type: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to modify injury type. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleUpdateInjuryDescription(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleUpdateInjuryDescription PatientCaseBuilder Event");

    try {
      assert(event.patientCaseName != null);

      // UI code should prevent updated injury description from ever being null
      assert(event.updatedInjuryDescription != null);

      // 1. in the Patient Case list, find the patient-case-under-edit and clone it
      // 2. in the cloned Patient Case, find the injury-id-under-edit. modify that injury's description.
      // 3. clone the Patient Case list excluding the Patient Case under edit
      // 4. add the cloned Patient Case to the cloned Patient Case list and emit consolidated object

      // 1.1 Find Patient Case by name (our unique id)
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == event.patientCaseName));

      // there should be an injury in the Patient Case (UI enforced)
      assert(involvedPatientCase.injuries != null &&
          involvedPatientCase.injuries!.isNotEmpty);

      // 1.2 deep copy the found Patient Case
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      // Find the particular injury being modified
      final involvedInjury = updatedPatientCase.injuries!
          .firstWhere((injury) => (injury.id == event.injuryId));

      // Actually update the injury description
      involvedInjury.description = event.updatedInjuryDescription!;

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1, "Modified injury description successfully.");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error modifying injury description: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to modify injury description. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleUpdateInjurySeverity(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleUpdateInjurySeverity PatientCaseBuilder Event");

    try {
      assert(event.patientCaseName != null);

      // UI code should prevent updated injury description from ever being null
      assert(event.updatedInjuryType != null);
      // one of these should not be null
      assert(event.updatedInjurySeverityDouble != null ||
          event.updatedInjurySeverityInteger != null);

      // 1. in the Patient Case list, find the patient-case-under-edit and clone it
      // 2. in the cloned Patient Case, find the injury-id-under-edit. modify that injury's severity.
      // 3. clone the Patient Case list excluding the Patient Case under edit
      // 4. add the cloned Patient Case to the cloned Patient Case list and emit consolidated object

      // 1.1 Find Patient Case by name (our unique id)
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == event.patientCaseName));

      // there should be an injury in the Patient Case (UI enforced)
      assert(involvedPatientCase.injuries != null &&
          involvedPatientCase.injuries!.isNotEmpty);

      // 1.2 deep copy the found Patient Case
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      // Find the particular injury being modified
      final involvedInjury = updatedPatientCase.injuries!
          .firstWhere((injury) => (injury.id == event.injuryId));

      // Set the relevant severity field, clear the others
      if (event.updatedInjuryType == InjuryTypeEnum.hemorrhage) {
        involvedInjury.hemorrhageRateMlPerMin =
            event.updatedInjurySeverityDouble;
        involvedInjury.burnBodySurfaceAreaPercentage = null;
        involvedInjury.severityScore = null;
      } else if (event.updatedInjuryType == InjuryTypeEnum.burn) {
        involvedInjury.burnBodySurfaceAreaPercentage =
            event.updatedInjurySeverityDouble;
        involvedInjury.hemorrhageRateMlPerMin = null;
        involvedInjury.severityScore = null;
      } else {
        involvedInjury.severityScore = event.updatedInjurySeverityInteger;
        involvedInjury.hemorrhageRateMlPerMin = null;
        involvedInjury.burnBodySurfaceAreaPercentage = null;
      }

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild, and tell the UI we're no longer saving.
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1, "Modified injury type successfully.");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error modifying injury type: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to modify injury type. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleUpdateInjuryDetail(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleUpdateInjuryDetail PatientCaseBuilder Event");

    try {
      assert(event.patientCaseName != null);
      // should not be null
      assert(event.updatedInjuryDetail != null);

      // 1. in the Patient Case list, find the patient-case-under-edit and clone it
      // 2. in the cloned Patient Case, find the injury-id-under-edit. modify that injury's detail.
      // 3. clone the Patient Case list excluding the Patient Case under edit
      // 4. add the cloned Patient Case to the cloned Patient Case list and emit consolidated object

      // 1.1 Find Patient Case by name (our unique id)
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == event.patientCaseName));

      // there should be an injury in the Patient Case (UI enforced)
      assert(involvedPatientCase.injuries != null &&
          involvedPatientCase.injuries!.isNotEmpty);

      // 1.2 deep copy the found Patient Case
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      // Find the particular injury being modified
      final involvedInjury = updatedPatientCase.injuries!
          .firstWhere((injury) => (injury.id == event.injuryId));

      // Actually update the injury detail
      involvedInjury.detail = event.updatedInjuryDetail;

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1, "Modified injury detail successfully.");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error modifying injury detail: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to modify injury detail. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleUpdateInjuryMechanism(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleUpdateInjuryMechanism PatientCaseBuilder Event");

    try {
      assert(event.patientCaseName != null);
      // should not be null
      assert(event.updatedMechanismOfInjury != null);

      // 1. in the Patient Case list, find the patient-case-under-edit and clone it
      // 2. in the cloned Patient Case, find the injury-id-under-edit. modify that injury's mechanism of injury.
      // 3. clone the Patient Case list excluding the Patient Case under edit
      // 4. add the cloned Patient Case to the cloned Patient Case list and emit consolidated object

      // 1.1 Find Patient Case by name (our unique id)
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == event.patientCaseName));

      // there should be an injury in the Patient Case (UI enforced)
      assert(involvedPatientCase.injuries != null &&
          involvedPatientCase.injuries!.isNotEmpty);

      // 1.2 deep copy the found Patient Case
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      // Find the particular injury being modified
      final involvedInjury = updatedPatientCase.injuries!
          .firstWhere((injury) => (injury.id == event.injuryId));

      if (event.updatedMechanismOfInjury != null) {
        final update = event.updatedMechanismOfInjury!;
        // ignore: prefer_const_constructors
        final current = involvedInjury.mechanism ?? MechanismOfInjuryRecord();

        involvedInjury.mechanism = current.copyWith(
          gunshotCaliber: update.gunshotCaliber,
          gunshotAmmunitionType: update.gunshotAmmunitionType,
          blade: update.blade,
          blast: update.blast,
          vehicleCrash: update.vehicleCrash,
          fall: update.fall,
          cbrn: update.cbrn,
          shrapnel: update.shrapnel,
        );
      }

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1, "Modified injury mechanism successfully.");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error modifying injury mechanism: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to modify injury mechanism. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleEnableTreatment(PatientCaseBuilderEvent event,
      Emitter<PatientCaseBuilderState> emitter) async {
    _logger.logDebug(
        1, "Handling _handleEnableTreatment PatientCaseBuilder Event");

    if (event.dynamicTreatmentName != null) {
      // Step 1: find patient case under edit
      final patientCase = state.patientCases
          .firstWhere((p) => p.name == state.patientCaseUnderEditOrDisplay);

      // Step 2: deep copy + modify treatments
      final updatedTreatments = patientCase.treatments?.copyWith(
        enable: [event.dynamicTreatmentName!],
      );

      // Step 3: update the patient case
      final updatedPatientCase =
          patientCase.copyWith(treatments: updatedTreatments);

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // Emit the updated state
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));
    }
  }

  Future<void> _handleDisableTreatment(PatientCaseBuilderEvent event,
      Emitter<PatientCaseBuilderState> emitter) async {
    _logger.logDebug(
        1, "Handling _handleDisableTreatment PatientCaseBuilder Event");

    if (event.dynamicTreatmentName != null) {
      final patientCase = state.patientCases
          .firstWhere((p) => p.name == state.patientCaseUnderEditOrDisplay);

      final updatedTreatments = patientCase.treatments?.copyWith(
        disable: [event.dynamicTreatmentName!],
      );

      final updatedPatientCase =
          patientCase.copyWith(treatments: updatedTreatments);

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // Emit the updated state
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));
    }
  }

  Future<void> _handleEnableMedication(PatientCaseBuilderEvent event,
      Emitter<PatientCaseBuilderState> emitter) async {
    _logger.logDebug(
        1, "Handling _handleEnableMedication PatientCaseBuilder Event");

    if (event.dynamicMedicationName != null) {
      // Step 1: find patient case under edit
      final patientCase = state.patientCases
          .firstWhere((p) => p.name == state.patientCaseUnderEditOrDisplay);

      // Step 2: deep copy + modify medications
      final updatedMedications = patientCase.medications?.copyWith(
        enable: [event.dynamicMedicationName!],
      );

      // Step 3: update the patient case
      final updatedPatientCase =
          patientCase.copyWith(medications: updatedMedications);

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // Step 4: emit the updated state
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));
    }
  }

  Future<void> _handleDisableMedication(PatientCaseBuilderEvent event,
      Emitter<PatientCaseBuilderState> emitter) async {
    _logger.logDebug(
        1, "Handling _handleDisableMedication PatientCaseBuilder Event");

    if (event.dynamicMedicationName != null) {
      final patientCase = state.patientCases
          .firstWhere((p) => p.name == state.patientCaseUnderEditOrDisplay);

      final updatedMedications = patientCase.medications?.copyWith(
        disable: [event.dynamicMedicationName!],
      );

      final updatedPatientCase =
          patientCase.copyWith(medications: updatedMedications);

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // Emit the updated state
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));
    }
  }

  Future<void> _handleUpdateInitialVitalSigns(PatientCaseBuilderEvent event,
      Emitter<PatientCaseBuilderState> emitter) async {
    _logger.logDebug(
        1, "Handling _handleUpdateInitialVitalSigns PatientCaseBuilder Event");

    try {
      if (event.patientCaseName == null || event.updatedVitals == null) {
        _logger.logError(1, "Missing patient case name or vitals data");
        return;
      }

      final patientCase = state.patientCases
          .firstWhere((pc) => pc.name == event.patientCaseName);
      final updatedPatientCase =
          patientCase.copyWith(initialVitalSigns: event.updatedVitals);

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));
      _logger.logDebug(1, "Initial Vital Signs updated successfully");
    } catch (e) {
      _logger.logError(1, 'Error updating Initial Vital Signs: $e');
    }
  }

  Future<void> _handleClearInitialVitalSigns(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleClearInitialVitalSigns PatientCaseBuilder Event");

    try {
      // Find Patient Case by name (our unique id)
      final PatientCase involvedPatientCase = state.patientCases
          .firstWhere((pc) => (pc.name == event.patientCaseName));

      // deep copy the found Patient Case
      final PatientCase updatedPatientCase = involvedPatientCase.copyWith();

      updatedPatientCase.initialVitalSigns = InitialVitalSigns();

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      // Enter saving state
      emitter(state.copyWith(saving: SaveStatus.saving));

      // Persist Patient Cases to backend, and get updated Patient Cases definitions from there too
      // to be sure back and front end are consistent
      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      // finally emit the updated Patient Cases to trigger the UI to rebuild
      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1, "Initial Vital Signs cleared successfully");
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error clearing Initial Vital Signs: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to clear Initial Vital Signs. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleAssignPatientCaseToPatient(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(1,
        "Handling _handleAssignPatientCaseToPatient PatientCaseBuilder Event");

    try {
      // These should all have come in on the event
      assert(event.patientId != null);
      assert(event.patientCaseNum != null);
      assert(event.context != null);

      final patientId = event.patientId;
      final patientCaseNum = event.patientCaseNum;
      if (patientId != null && patientCaseNum != null) {
        // Enter saving state
        emitter(state.copyWith(saving: SaveStatus.saving));

        await patientCaseRepository.assignPatientCaseToPatient(
            patientId, patientCaseNum);

        // Set the patient case under edit or display so that medications and treatments panels in non-edit mode (run screen)
        // know what content they should be displaying.
        final patientCaseName = state.patientCases
            .firstWhere((pc) => (pc.caseNum == event.patientCaseNum))
            .name;

        // Emit the updated state immediately to reflect the change
        emitter(state.copyWith(
            patientCaseUnderEditOrDisplay: patientCaseName ?? '',
            saving: SaveStatus.saved));

        _logger.logDebug(1, "Patient case assigned to patient successfully");
      }
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error assigning patient case to patient: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to assign patient to patient case. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleSendPhysicalTreatment(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleSendPhysicalTreatment PatientCaseBuilder Event");

    try {
      // These should all have come in on the event
      assert(event.patientId != null);
      assert(event.dynamicTreatmentName != null);
      assert(event.dynamicDeviceName != null);
      assert(event.bodyLocation != null);

      final patientId = event.patientId;
      final dynamicTreatmentName = event.dynamicTreatmentName;
      final dynamicDeviceName = event.dynamicDeviceName;
      final bodyLocation = event.bodyLocation;

      if (patientId != null &&
          dynamicTreatmentName != null &&
          dynamicDeviceName != null &&
          bodyLocation != null) {
        final success = await patientCaseRepository.sendPhysicalTreatment(
            patientId, dynamicTreatmentName, dynamicDeviceName, bodyLocation);

        // Emit the updated state immediately to reflect the change
        if (success) {
          emitter(state.copyWith(requestStatus: RequestStatus.success));
          // Reset after short delay
          await Future.delayed(const Duration(milliseconds: 300));
          emitter(state.copyWith(requestStatus: RequestStatus.initial));
        } else {
          emitter(state.copyWith(
              requestStatus: RequestStatus.failure,
              errorMessage: 'Treatment could not be sent.'));
          // Reset after short delay
          await Future.delayed(const Duration(milliseconds: 300));
          emitter(state.copyWith(requestStatus: RequestStatus.initial));
        }
        _logger.logDebug(1, "Treatment sent successfully");
      }
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error sending treatment: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send treatment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleSendMedication(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
    BuildContext context,
  ) async {
    _logger.logDebug(
        1, "Handling _handleSendMedication PatientCaseBuilder Event");

    try {
      // These should all have come in on the event
      assert(event.dynamicMedicationName != null);
      assert(event.patientId != null);
      assert(event.administrationRoute != null);
      assert(event.dosageValue != null);
      assert(event.dosageTimePeriod != null);

      final dynamicMedicationName = event.dynamicMedicationName;
      final patientId = event.patientId;
      final administrationRoute = event.administrationRoute;
      final dosageValue = event.dosageValue;
      final dosageTimePeriod = event.dosageTimePeriod;

      if (dynamicMedicationName != null &&
          patientId != null &&
          administrationRoute != null &&
          dosageValue != null &&
          dosageTimePeriod != null) {
        final success = await patientCaseRepository.sendMedication(
          dynamicMedicationName,
          patientId,
          administrationRoute,
          dosageValue,
          dosageTimePeriod,
        );

        // Emit the updated state immediately to reflect the change
        if (success) {
          emitter(state.copyWith(requestStatus: RequestStatus.success));
          // Reset after short delay
          await Future.delayed(const Duration(milliseconds: 300));
          emitter(state.copyWith(requestStatus: RequestStatus.initial));
        } else {
          emitter(state.copyWith(
              requestStatus: RequestStatus.failure,
              errorMessage: 'Medication could not be sent.'));
          // Reset after short delay
          await Future.delayed(const Duration(milliseconds: 300));
          emitter(state.copyWith(requestStatus: RequestStatus.initial));
        }
        _logger.logDebug(1, "Medication sent successfully");
      }
    } catch (e) {
      // Log an error and show error banner
      _logger.logError(1, 'Error sending medication: $e');

      // Show red flash banner on failure
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send medication. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.logError(1, 'Failed to show SnackBar.');
      }
    }
  }

  Future<void> _handleUpdateBiologicalSex(
    PatientCaseBuilderEvent event,
    Emitter<PatientCaseBuilderState> emitter,
  ) async {
    _logger.logDebug(1, "Handling _handleUpdateBiologicalSex PatientCaseBuilder Event");

    if (event.patientCaseName == null || event.updatedBiologicalSex == null) {
      _logger.logError(1, "Missing patient case name or biological sex value");
      return;
    }

    try {
      final patientCase = state.patientCases
          .firstWhere((pc) => pc.name == event.patientCaseName);
      final updatedPatientCase =
          patientCase.copyWith(biologicalSex: event.updatedBiologicalSex);

      final newPatientCases =
          createNewPatientCasesWithPatCase(updatedPatientCase);

      emitter(state.copyWith(saving: SaveStatus.saving));

      final newPatientCasesFromRepo =
          await patientCaseRepository.updatePatientCases(newPatientCases);

      emitter(state.copyWith(
          patientCases: newPatientCasesFromRepo, saving: SaveStatus.saved));

      _logger.logDebug(1,
          "Biological sex updated to ${event.updatedBiologicalSex} for ${event.patientCaseName}");
    } catch (e) {
      _logger.logError(1, 'Error updating biological sex: $e');
    }
  }

  // Helper function to clone the current Patient Case list and include within it an updated copy of the supplied Patient Case.
  List<PatientCase> createNewPatientCasesWithPatCase(
      PatientCase updatedPatientCase) {
    // deep copy the whole Patient Case list
    final copiedPatientCasesList =
        state.patientCases.map((e) => e.copyWith()).toList();

    // ditch the original Patient Case
    final List<PatientCase> updatedPatientCasesList = List<PatientCase>.from(
        copiedPatientCasesList as Iterable)
      ..removeWhere((pc) => pc.name!.contains(updatedPatientCase.name ?? ''));

    // add our new Patient Case and return updated list of Patient Cases
    return [...updatedPatientCasesList, updatedPatientCase];
  }
}
