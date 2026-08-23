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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/metadata/metadata.dart';
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_injury_editor.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_medications.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_treatments.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text_field.dart';
import 'package:collection/collection.dart';
import 'package:flutter_ui/data/model/metadata/metadata_store_access.dart';

class PatientCaseEditor extends StatefulWidget {
  final patientCaseNameController = TextEditingController();

  PatientCaseEditor({super.key});

  @override
  State<PatientCaseEditor> createState() => _PatientCaseEditorState();
}

class _PatientCaseEditorState extends State<PatientCaseEditor> {
  bool _isRenameEnabled = false;

  @override
  void initState() {
    super.initState();
    widget.patientCaseNameController.addListener(_handleRenameTextChange);
  }

  void _handleRenameTextChange() {
    setState(() {
      _isRenameEnabled =
          widget.patientCaseNameController.text.trim().isNotEmpty;
    });
  }

  void _handleSubmitRenamePatientCase(
      String value, PatientCaseBuilderState state) {
    final newPatientCaseName = value;

    if (newPatientCaseName.isNotEmpty) {
      // Send rename Patient Case event
      context.read<PatientCaseBuilderBloc>().add(
            PatientCaseBuilderEvent(
              PatientCaseBuilderAction.renamePatientCase,
              patientCaseName: state.patientCaseUnderEditOrDisplay,
              newNameForPatientCase: newPatientCaseName,
              context: context,
            ),
          );

      // Clear the text field after adding the patient
      widget.patientCaseNameController.clear();
    } else {
      // Show a Snackbar if the input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient Case name cannot be blank.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Text(widget.patientCaseName ?? 'None');

    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: MmsColors.mainBodyBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: MmsColors.translucentBlack,
              offset: Offset(1, 1),
              blurRadius: 1,
              spreadRadius: 2,
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height - 42, // Ensure finite height
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
          builder: (context, state) {
            // Determine name of Patient Case

            return MmsRoundedBarlessPanel(
              caption:
                  "Patient Case Editor - ${state.patientCaseUnderEditOrDisplay ?? 'Loading'} ${state.saving == SaveStatus.saving ? '(saving)' : '(saved)'}",
              widget: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("${state.patientCaseUnderEditOrDisplay}: "),
                        MmsTextField(
                          width: 240,
                          textController: widget.patientCaseNameController,
                          height: 80,
                          maxLines: 1,
                          onSubmitted: (value) =>
                              _handleSubmitRenamePatientCase(value, state),
                        ),
                        MmsPaddedRaisedButton(
                          "Rename",
                          onPressed: _isRenameEnabled
                              ? () {
                                  _handleSubmitRenamePatientCase(
                                    widget.patientCaseNameController.text
                                        .trim(),
                                    state,
                                  );
                                }
                              : null,
                        ),
                        const Spacer(),
                        _SexDropdown(state: state),
                      ],
                    ),
                    Expanded(
                      child: Row(children: [
                        const Expanded(child: _InjuriesSection()),
                        const SizedBox(width: 16),
                        const Expanded(child: _TreatmentsSection()),
                        const SizedBox(width: 16),
                        const Expanded(child: _MedicationsSection()),
                        const SizedBox(width: 16),
                        Expanded(child: _VitalsSection()),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.patientCaseNameController.removeListener(_handleRenameTextChange);
    super.dispose();
  }
}

// Injuries
class _InjuriesSection extends StatefulWidget {
  // Constructor
  const _InjuriesSection();

  @override
  State<_InjuriesSection> createState() => _InjuriesSectionState();
}

class _InjuriesSectionState extends State<_InjuriesSection> {
  Map<Injury, bool?> injurySelectionMap = {};

  void setCheckboxState(Injury key, bool? value) {
    setState(() {
      injurySelectionMap[key] = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: "Injuries",
      child: Column(
        children: [
          // Injury list + add controls
          Expanded(
            child: _InjuryRows(injurySelectionMap, setCheckboxState),
          ),

          const SizedBox(height: 12),

          // Remove button pinned to bottom
          Align(
            alignment: Alignment.bottomLeft,
            child: BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: injurySelectionMap.values
                          .any((selected) => selected == true)
                      ? () => _confirmDeleteInjuries(
                          context, state.patientCaseUnderEditOrDisplay)
                      : null,
                  child: const Text("Remove Selected"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteInjuries(
    BuildContext context,
    String? patientCaseUnderEditOrDisplay,
  ) async {
    // Determine number of selected injuries
    final selectedInjuries = injurySelectionMap.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    final titleText =
        selectedInjuries.length == 1 ? 'Remove Injury?' : 'Remove Injuries?';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: const Text(
            'This action cannot be undone. Are you sure you want to proceed?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      context.read<PatientCaseBuilderBloc>().add(
            PatientCaseBuilderEvent(
              PatientCaseBuilderAction.removeInjuries,
              patientCaseName: patientCaseUnderEditOrDisplay,
              injuryIds: selectedInjuries,
              context: context,
            ),
          );
      injurySelectionMap.clear(); // Clear selected injuries
    }
  }
}

class _InjuryRows extends StatefulWidget {
  final Map<Injury, bool?> injurySelectionMap;
  final void Function(Injury, bool?) callback;
  final newInjuryIdController = TextEditingController();

  _InjuryRows(this.injurySelectionMap, this.callback);

  @override
  State<_InjuryRows> createState() => _InjuryRowsState();
}

class _InjuryRowsState extends State<_InjuryRows> {
  void _handleSubmitAddInjury(String value, PatientCaseBuilderState state) {
    final newInjuryName = value;

    if (newInjuryName.isNotEmpty) {
      // Access the PatientCaseBuilderBloc from the context
      final patientCaseBuilderBloc = context.read<PatientCaseBuilderBloc>();

      // Dispatch an add Injury event to the bloc
      patientCaseBuilderBloc.add(
        PatientCaseBuilderEvent(PatientCaseBuilderAction.addInjury,
            patientCaseName: state.patientCaseUnderEditOrDisplay,
            injuryId: newInjuryName,
            context: context),
      );

      // Clear the text field after adding the patient
      widget.newInjuryIdController.clear();
    } else {
      // Show a Snackbar if the input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Injury name cannot be blank.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
      builder: (context, state) {
        final patientCase = state.patientCases.firstWhere(
          (pc) => pc.name == state.patientCaseUnderEditOrDisplay,
        );

        final injuries = patientCase.injuries ?? [];

        // Rebuild selection map only for new injuries
        for (var injury in injuries) {
          widget.injurySelectionMap.putIfAbsent(injury, () => false);
        }

        return Column(
          children: [
            // Scrollable area (either list or "no injuries" message)
            Expanded(
              child: injuries.isEmpty
                  ? const Center(
                      child: Text(
                        'No injuries listed.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView(
                      children: injuries.map((injury) {
                        return Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(injury.id,
                                    overflow: TextOverflow.ellipsis),
                                value: widget.injurySelectionMap[injury],
                                onChanged: (bool? value) =>
                                    widget.callback(injury, value),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.create_sharp),
                              color: Colors.black,
                              onPressed: () {
                                context.read<PatientCaseBuilderBloc>().add(
                                      PatientCaseBuilderEvent(
                                        PatientCaseBuilderAction.editInjury,
                                        injuryId: injury.id,
                                        context: context,
                                      ),
                                    );

                                final GlobalKey<PatientCaseInjuryEditorState>
                                    injuryEditorKey =
                                    GlobalKey<PatientCaseInjuryEditorState>();

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MmsDismissibleScreen(
                                          const ValueKey(
                                              "PatientCaseInjuryEditorScreenDismissible"),
                                          PatientCaseInjuryEditor(
                                            key: injuryEditorKey,
                                            injuryId: injury,
                                          ),
                                          onAttemptDismiss: () async {
                                            return await injuryEditorKey
                                                    .currentState
                                                    ?.validateBeforeDismiss() ??
                                                true;
                                          },
                                          scrollable: true,
                                        )));
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 8),

            // "Add Injury" controls
            Row(
              children: [
                Expanded(
                    child: MmsTextField(
                  height: 80,
                  maxLines: 1,
                  textController: widget.newInjuryIdController,
                  onSubmitted: (value) => _handleSubmitAddInjury(value, state),
                )),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _handleSubmitAddInjury(
                        widget.newInjuryIdController.text.trim(), state);
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// Treatments
class _TreatmentsSection extends StatelessWidget {
  // Constructor
  const _TreatmentsSection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: "Treatments",
      child: Column(
        children: [
          // Treatments list
          const Expanded(
            child: _TreatmentRows(),
          ),

          const SizedBox(height: 12),

          // Remove button pinned to bottom
          Align(
            alignment: Alignment.bottomLeft,
            child: BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
              builder: (context, state) {
                return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const MmsDismissibleScreen(
                                ValueKey(
                                    "PatientCaseTreatmentsScreenDismissible"),
                                PatientCaseTreatments(editMode: true),
                                scrollable: true,
                              )));
                    },
                    child: const Text("Edit"));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentRows extends StatelessWidget {
  const _TreatmentRows();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
      builder: (context, state) {
        final patientCase = state.patientCases.firstWhere(
          (pc) => pc.name == state.patientCaseUnderEditOrDisplay,
        );

        return Column(
          children: [
            // Scrollable area (either list or "No Treatments" message)
            Expanded(
              child: patientCase.treatments == null ||
                      patientCase.treatments!.getEnabledTypes().isEmpty
                  ? const Center(
                      child: Text(
                        'No Treatments listed.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView(
                      children: patientCase.treatments!
                          .getEnabledTypes()
                          .map((String key) {
                        final metadata =
                            context.read<MetadataStoreAccess>().store.metadata;
                        final displayName = metadata?.physicalTreatmentType
                                ?.firstWhere(
                                  (item) => item.name == key,
                                  orElse: () => PhysicalTreatmentTypeItem(
                                      name: key, displayName: key),
                                )
                                .displayName ??
                            key;

                        return SizedBox(
                          height: 36,
                          child: Row(
                            children: [
                              Text(displayName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// Medications
class _MedicationsSection extends StatelessWidget {
  // Constructor
  const _MedicationsSection();

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: "Medications",
      child: Column(
        children: [
          // Medications list
          const Expanded(
            child: _MedicationsRows(),
          ),

          const SizedBox(height: 12),

          // Remove button pinned to bottom
          Align(
            alignment: Alignment.bottomLeft,
            child: BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
              builder: (context, state) {
                return Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MmsDismissibleScreen(
                                    ValueKey(
                                        "PatientCaseMedicationsScreenDismissible"),
                                    PatientCaseMedications(editMode: true),
                                    scrollable: true,
                                  )));
                        },
                        child: const Text("Edit")),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationsRows extends StatelessWidget {
  const _MedicationsRows();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
      builder: (context, state) {
        final patientCase = state.patientCases.firstWhere(
          (pc) => pc.name == state.patientCaseUnderEditOrDisplay,
        );

        return Column(
          children: [
            // Scrollable area (either list or "No Medications" message)
            Expanded(
              child: patientCase.medications == null ||
                      patientCase.medications!.getEnabledTypes().isEmpty
                  ? const Center(
                      child: Text(
                        'No Medications listed.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView(
                      children: patientCase.medications!
                          .getEnabledTypes()
                          .map((String key) {
                        final metadata =
                            context.read<MetadataStoreAccess>().store.metadata;
                        final displayName = metadata?.medication
                                ?.firstWhere(
                                  (item) => item.name == key,
                                  orElse: () => MedicationItem(
                                      name: key, displayName: key),
                                )
                                .displayName ??
                            key;

                        return SizedBox(
                          height: 36,
                          child: Row(
                            children: [
                              Text(displayName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// Vitals
class _VitalsSection extends StatefulWidget {
  @override
  State<_VitalsSection> createState() => _VitalsSectionState();
}

class _VitalsSectionState extends State<_VitalsSection> {
  bool _editMode = false;
  bool _initialized = false;
  final FocusNode _hrFocus = FocusNode();
  final FocusNode _sbpFocus = FocusNode();
  final FocusNode _dbpFocus = FocusNode();
  final FocusNode _spo2Focus = FocusNode();
  final FocusNode _tempFocus = FocusNode();
  final FocusNode _etco2Focus = FocusNode();
  final FocusNode _rrFocus = FocusNode();

  final _hrController = TextEditingController();
  final _sbpController = TextEditingController();
  final _dbpController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _tempController = TextEditingController();
  final _etco2Controller = TextEditingController();
  final _rrController = TextEditingController();

  String? _activeErrorMessage;
  FocusNode? _activeFocus;
  final Map<FocusNode, bool> _fieldValidity = {};

  @override
  void initState() {
    super.initState();

    _hrFocus.addListener(() => _handleFocusChange(
        _hrFocus, "HR must be between 30 and 180 bpm.", _hrController, 30, 180,
        isInt: true));
    _sbpFocus.addListener(() => _handleFocusChange(
        _sbpFocus, "Systolic BP must be 60–150 mmHg.", _sbpController, 60, 150,
        isInt: true));
    _dbpFocus.addListener(() => _handleFocusChange(
        _dbpFocus, "Diastolic BP must be 20–120 mmHg.", _dbpController, 20, 120,
        isInt: true));
    _spo2Focus.addListener(() => _handleFocusChange(_spo2Focus,
        "SpO2 must be between 60 and 100%.", _spo2Controller, 60, 100));
    _etco2Focus.addListener(() => _handleFocusChange(_etco2Focus,
        "EtCO2 must be between 25 and 60.", _etco2Controller, 25, 60,
        isInt: true));
    _rrFocus.addListener(() => _handleFocusChange(
        _rrFocus, "Respiratory Rate must be 4–30.", _rrController, 4, 30,
        isInt: true));
    _tempFocus.addListener(() => _handleFocusChange(_tempFocus,
        "Temperature must be 90.0–106.0F.", _tempController, 90, 106));
  }

  bool _areVitalsCleared(InitialVitalSigns? vitals) {
    return vitals == null ||
        (vitals.hr == null &&
            vitals.sbp == null &&
            vitals.dbp == null &&
            vitals.spo2 == null &&
            vitals.temp == null &&
            vitals.etco2 == null &&
            vitals.rr == null);
  }

  void _handleFocusChange(
    FocusNode node,
    String errorMessage,
    TextEditingController controller,
    double min,
    double max, {
    bool isInt = false,
  }) {
    if (!node.hasFocus) {
      final isValid = _validateField(controller, min, max, isInt: isInt);
      setState(() {
        _fieldValidity[node] = isValid;
        if (!isValid) {
          // show/update message and remember which field raised it
          _activeErrorMessage = errorMessage;
          _activeFocus = node;
        } else {
          // on a valid blur, only clear the message if:
          //  a) all fields are valid now, or
          //  b) this field owned the current message
          final anyInvalid = _fieldValidity.values.any((v) => v == false);
          if (!anyInvalid || _activeFocus == node) {
            _activeErrorMessage = null;
            if (_activeFocus == node) _activeFocus = null;
          }
        }
      });

      // Now check for Systolic < Diastolic if both are valid
      final sbpValid = _validateField(_sbpController, 60, 150, isInt: true);
      final dbpValid = _validateField(_dbpController, 20, 120, isInt: true);

      final sbp = int.tryParse(_sbpController.text.trim());
      final dbp = int.tryParse(_dbpController.text.trim());

      if (sbpValid && dbpValid && sbp != null && dbp != null) {
        if (sbp < dbp) {
          setState(() {
            _activeErrorMessage =
                "Systolic BP must be greater than or equal to Diastolic BP.";
            _fieldValidity[_sbpFocus] = false;
            _fieldValidity[_dbpFocus] = false;
            // don't clear here; keep message visible until both are valid
          });
        } else {
          setState(() {
            // Clear error if previously invalid
            _fieldValidity[_sbpFocus] = true;
            _fieldValidity[_dbpFocus] = true;

            // Only clear BP message if no fields remain invalid
            final anyInvalid = _fieldValidity.values.any((v) => v == false);
            if (!anyInvalid &&
                _activeErrorMessage ==
                    "Systolic BP must be greater than or equal to Diastolic BP.") {
              _activeErrorMessage = null;
            }
          });
        }
      }
    }
  }

  bool get hasValidationErrors {
    return _fieldValidity.values.any((isValid) => isValid == false);
  }

  bool _validateField(TextEditingController controller, double min, double max,
      {bool isInt = false}) {
    final text = controller.text.trim();
    if (text.isEmpty) return true; // Allow blank inputs
    final value = double.tryParse(text);
    if (value == null) return false;
    if (isInt && value % 1 != 0) return false;
    return value >= min && value <= max;
  }

  void _toggleEditMode(PatientCase patientCase, BuildContext context,
      PatientCaseBuilderState state) {
    if (_editMode) {
      // Done pressed: Validate
      final ok = validateInputs();
      if (!ok) {
        // put the cursor on the first invalid field (if known)
        if (_activeFocus != null) {
          _activeFocus!.requestFocus();
        }
        // show the specific error message if we have one
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _activeErrorMessage ?? 'Please fix the highlighted fields.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Round inputs before dispatch
      _hrController.text = roundInput(_hrController);
      _sbpController.text = roundInput(_sbpController);
      _dbpController.text = roundInput(_dbpController);
      _spo2Controller.text = roundInput(_spo2Controller, precision: 1);
      _tempController.text = roundInput(_tempController, precision: 1);
      _etco2Controller.text = roundInput(_etco2Controller);
      _rrController.text = roundInput(_rrController);

      // Dispatch to Bloc
      final updatedVitals = InitialVitalSigns(
        hr: int.tryParse(_hrController.text),
        sbp: int.tryParse(_sbpController.text),
        dbp: int.tryParse(_dbpController.text),
        spo2: double.tryParse(_spo2Controller.text),
        temp: double.tryParse(_tempController.text),
        etco2: double.tryParse(_etco2Controller.text),
        rr: double.tryParse(_rrController.text),
      );

      context.read<PatientCaseBuilderBloc>().add(
            PatientCaseBuilderEvent(
              PatientCaseBuilderAction.updateInitialVitalSigns,
              patientCaseName: state.patientCaseUnderEditOrDisplay,
              context: context,
              updatedVitals: updatedVitals,
            ),
          );
    } else {
      // entering edit mode: reset validity  message
      _fieldValidity
        ..clear()
        ..addAll({
          _hrFocus: true,
          _sbpFocus: true,
          _dbpFocus: true,
          _spo2Focus: true,
          _tempFocus: true,
          _etco2Focus: true,
          _rrFocus: true,
        });
      _activeErrorMessage = null;

      // Edit pressed: Populate controllers
      _hrController.text = "${patientCase.initialVitalSigns?.hr ?? ''}";
      _sbpController.text = "${patientCase.initialVitalSigns?.sbp ?? ''}";
      _dbpController.text = "${patientCase.initialVitalSigns?.dbp ?? ''}";
      _spo2Controller.text = "${patientCase.initialVitalSigns?.spo2 ?? ''}";
      _tempController.text = "${patientCase.initialVitalSigns?.temp ?? ''}";
      _etco2Controller.text = "${patientCase.initialVitalSigns?.etco2 ?? ''}";
      _rrController.text = "${patientCase.initialVitalSigns?.rr ?? ''}";
    }

    setState(() => _editMode = !_editMode);
  }

  bool _validateAndMark({
    required TextEditingController controller,
    required FocusNode node,
    required double min,
    required double max,
    required String msg,
    bool isInt = false,
  }) {
    final ok = _validateField(controller, min, max, isInt: isInt);
    _fieldValidity[node] = ok;
    if (!ok && _activeErrorMessage == null) {
      _activeErrorMessage = msg;
      _activeFocus = node;
    }
    return ok;
  }

  bool validateInputs() {
    // reset any previous message; rebuild borders
    _activeErrorMessage = null;

    // First: partial BP (unchanged)
    final sbpText = _sbpController.text.trim();
    final dbpText = _dbpController.text.trim();
    final hasPartialBP = (sbpText.isEmpty && dbpText.isNotEmpty) ||
        (sbpText.isNotEmpty && dbpText.isEmpty);
    if (hasPartialBP) {
      setState(() {
        _activeErrorMessage =
            "Enter both Systolic and Diastolic BP or leave both blank.";
        _activeFocus = _sbpFocus;
        _fieldValidity[_sbpFocus] = false;
        _fieldValidity[_dbpFocus] = false;
      });
      return false;
    }

    // Range checks for every field
    bool ok = true;
    ok = ok &&
        _validateAndMark(
          controller: _hrController,
          node: _hrFocus,
          min: 30,
          max: 180,
          msg: "HR must be between 30 and 180 bpm.",
          isInt: true,
        );
    ok = ok &&
        _validateAndMark(
          controller: _sbpController,
          node: _sbpFocus,
          min: 60,
          max: 150,
          msg: "Systolic BP must be 60–150 mmHg.",
          isInt: true,
        );
    ok = ok &&
        _validateAndMark(
          controller: _dbpController,
          node: _dbpFocus,
          min: 20,
          max: 120,
          msg: "Diastolic BP must be 20–120 mmHg.",
          isInt: true,
        );
    ok = ok &&
        _validateAndMark(
          controller: _spo2Controller,
          node: _spo2Focus,
          min: 60,
          max: 100,
          msg: "SpO2 must be between 60 and 100%.",
        );
    ok = ok &&
        _validateAndMark(
          controller: _tempController,
          node: _tempFocus,
          min: 90,
          max: 106,
          msg: "Temperature must be 90.0–106.0F.",
        );
    ok = ok &&
        _validateAndMark(
          controller: _etco2Controller,
          node: _etco2Focus,
          min: 25,
          max: 60,
          msg: "EtCO2 must be between 25 and 60.",
          isInt: true,
        );
    ok = ok &&
        _validateAndMark(
          controller: _rrController,
          node: _rrFocus,
          min: 4,
          max: 30,
          msg: "Respiratory Rate must be 4–30.",
          isInt: true,
        );

    // Type-only checks for non-empty fields (you already had this logic)
    if (ok) {
      final fields = [
        _hrController,
        _spo2Controller,
        _tempController,
        _etco2Controller,
        _rrController,
      ];
      for (final c in fields) {
        final t = c.text.trim();
        if (t.isNotEmpty && double.tryParse(t) == null) ok = false;
      }
    }

    // Relational BP check last (kept as-is)
    final sbp = int.tryParse(sbpText);
    final dbp = int.tryParse(dbpText);
    if (sbp != null && dbp != null && sbp < dbp) {
      ok = false;
      _activeErrorMessage =
          "Systolic BP must be greater than or equal to Diastolic BP.";
      _activeFocus = _sbpFocus;
      _fieldValidity[_sbpFocus] = false;
      _fieldValidity[_dbpFocus] = false;
    }

    setState(() {}); // refresh error borders / message
    return ok;
  }

  String roundInput(TextEditingController controller, {int precision = 0}) {
    final value = double.tryParse(controller.text);
    if (value == null) return '';
    return value.toStringAsFixed(precision);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: "Initial Vital Signs",
      child: BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
        builder: (context, state) {
          final patientCase = state.patientCases.firstWhere(
            (pc) => pc.name == state.patientCaseUnderEditOrDisplay,
          );

          if (!_initialized) {
            _hrController.text = "${patientCase.initialVitalSigns?.hr ?? ''}";
            _sbpController.text = "${patientCase.initialVitalSigns?.sbp ?? ''}";
            _dbpController.text = "${patientCase.initialVitalSigns?.dbp ?? ''}";
            _spo2Controller.text =
                "${patientCase.initialVitalSigns?.spo2 ?? ''}";
            _tempController.text =
                "${patientCase.initialVitalSigns?.temp ?? ''}";
            _etco2Controller.text =
                "${patientCase.initialVitalSigns?.etco2 ?? ''}";
            _rrController.text = "${patientCase.initialVitalSigns?.rr ?? ''}";
            _initialized = true;
          }

          return Column(
            children: [
              VitalsEditor(
                editMode: _editMode,
                initialVitalSigns: patientCase.initialVitalSigns,
                hrController: _hrController,
                sbpController: _sbpController,
                dbpController: _dbpController,
                spo2Controller: _spo2Controller,
                tempController: _tempController,
                etco2Controller: _etco2Controller,
                rrController: _rrController,
                hrFocus: _hrFocus,
                sbpFocus: _sbpFocus,
                dbpFocus: _dbpFocus,
                spo2Focus: _spo2Focus,
                tempFocus: _tempFocus,
                etco2Focus: _etco2Focus,
                rrFocus: _rrFocus,
                onSubmitted: () => _toggleEditMode(patientCase, context, state),
                fieldValidity: _fieldValidity,
              ),
              if (_activeErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _activeErrorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: ElevatedButton(
                      onPressed: _editMode && hasValidationErrors
                          ? null
                          : () => _toggleEditMode(patientCase, context, state),
                      child: Text(_editMode ? "Done" : "Edit"),
                    ),
                  ),
                  const SizedBox(width: 25),
                  ElevatedButton(
                    onPressed: _areVitalsCleared(patientCase.initialVitalSigns)
                        ? null
                        : () => _confirmClearInitialVitalSigns(
                            context, state.patientCaseUnderEditOrDisplay),
                    child: const Text("Clear"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmClearInitialVitalSigns(
      BuildContext context, String? patientCaseUnderEditOrDisplay) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Initial Vital Signs?'),
          content: const Text(
              'This action cannot be undone. Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      // Proceed with the deletion logic
      if (context.mounted) {
        // Clear UI controllers
        _hrController.clear();
        _sbpController.clear();
        _dbpController.clear();
        _spo2Controller.clear();
        _tempController.clear();
        _etco2Controller.clear();
        _rrController.clear();

        // Reset validation state + message and re-render
        _fieldValidity.clear();
        _activeErrorMessage = null;
        setState(() {});

        // Dispatch to Bloc
        context.read<PatientCaseBuilderBloc>().add(
              PatientCaseBuilderEvent(
                PatientCaseBuilderAction.clearInitialVitalSigns,
                patientCaseName: patientCaseUnderEditOrDisplay,
                context: context,
              ),
            );
      }
    }
  }

  @override
  void dispose() {
    _hrFocus.dispose();
    _sbpFocus.dispose();
    _dbpFocus.dispose();
    _spo2Focus.dispose();
    _tempFocus.dispose();
    _etco2Focus.dispose();
    _rrFocus.dispose();

    _hrController.dispose();
    _sbpController.dispose();
    _dbpController.dispose();
    _spo2Controller.dispose();
    _tempController.dispose();
    _etco2Controller.dispose();
    _rrController.dispose();
    super.dispose();
  }
}

class VitalsEditor extends StatelessWidget {
  final bool editMode;
  final InitialVitalSigns? initialVitalSigns;
  final TextEditingController hrController;
  final TextEditingController sbpController;
  final TextEditingController dbpController;
  final TextEditingController spo2Controller;
  final TextEditingController tempController;
  final TextEditingController etco2Controller;
  final TextEditingController rrController;

  // Added: FocusNodes
  final FocusNode hrFocus;
  final FocusNode sbpFocus;
  final FocusNode dbpFocus;
  final FocusNode spo2Focus;
  final FocusNode tempFocus;
  final FocusNode etco2Focus;
  final FocusNode rrFocus;

  final VoidCallback? onSubmitted;

  final Map<FocusNode, bool> fieldValidity;

  const VitalsEditor({
    super.key,
    required this.editMode,
    required this.initialVitalSigns,
    required this.hrController,
    required this.sbpController,
    required this.dbpController,
    required this.spo2Controller,
    required this.tempController,
    required this.etco2Controller,
    required this.rrController,
    required this.hrFocus,
    required this.sbpFocus,
    required this.dbpFocus,
    required this.spo2Focus,
    required this.tempFocus,
    required this.etco2Focus,
    required this.rrFocus,
    required this.onSubmitted,
    required this.fieldValidity,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          _vital("HR", hrController, "bpm", editMode,
              focusNode: hrFocus,
              order: 0.0,
              inputFormatters: [
                RangeTextInputFormatter(min: 30, max: 180, isInt: true),
              ]),
          _bpvital("BP", sbpController, dbpController, "mmHg", editMode,
              sbpFocus: sbpFocus,
              dbpFocus: dbpFocus,
              inputFormattersSbp: [
                RangeTextInputFormatter(min: 60, max: 150, isInt: true),
              ],
              inputFormattersDbp: [
                RangeTextInputFormatter(min: 20, max: 120, isInt: true),
              ]),
          _vital("O2 Sat", spo2Controller, "%", editMode,
              focusNode: spo2Focus,
              order: 2.0,
              precision: 1,
              inputFormatters: [
                RangeTextInputFormatter(min: 60, max: 100, maxDecimalPlaces: 1),
              ]),
          _vital("Temp", tempController, "F", editMode,
              focusNode: tempFocus,
              order: 3.0,
              precision: 1,
              inputFormatters: [
                RangeTextInputFormatter(min: 90, max: 106, maxDecimalPlaces: 1),
              ]),
          _vital("EtCO2", etco2Controller, "mmHg", editMode,
              focusNode: etco2Focus,
              order: 4.0,
              inputFormatters: [
                RangeTextInputFormatter(min: 25, max: 60, isInt: true),
              ]),
          _vital(
            "RR",
            rrController,
            "br/min",
            editMode,
            focusNode: rrFocus,
            order: 5.0,
            inputFormatters: [
              RangeTextInputFormatter(min: 4, max: 30, isInt: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vital(
    String label,
    TextEditingController controller,
    String unit,
    bool editMode, {
    required FocusNode focusNode,
    required double order,
    int precision = 0,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final valueText = controller.text.trim();
    final double? value = double.tryParse(valueText);
    final formatted = value != null ? value.toStringAsFixed(precision) : "--";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 60, child: MmsText("$label:")),
          editMode
              ? FocusTraversalOrder(
                  order: NumericFocusOrder(order),
                  child: SizedBox(
                    width: 60,
                    child: EditableNumericLabel(
                      key: ValueKey(
                          "${focusNode.hashCode}-${fieldValidity[focusNode]}"),
                      strValue: valueText,
                      editMode: editMode,
                      controller: controller,
                      focusNode: focusNode,
                      precision: precision,
                      onSubmitted: onSubmitted,
                      inputFormatters: inputFormatters,
                      isValid: fieldValidity[focusNode],
                    ),
                  ),
                )
              : SizedBox(
                  width: editMode ? 105 : 60,
                  child: MmsText(formatted, textAlign: TextAlign.left),
                ),
          const SizedBox(width: 10),
          SizedBox(width: 50, child: MmsText(unit)),
        ],
      ),
    );
  }

  Widget _bpvital(
    String label,
    TextEditingController sys,
    TextEditingController dia,
    String unit,
    bool editMode, {
    required FocusNode sbpFocus,
    required FocusNode dbpFocus,
    required List<TextInputFormatter>? inputFormattersSbp,
    required List<TextInputFormatter>? inputFormattersDbp,
  }) {
    final sysText = sys.text.trim();
    final diaText = dia.text.trim();
    final hasBothValues = sysText.isNotEmpty && diaText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 60, child: MmsText("$label:")),
          if (editMode) ...[
            FocusTraversalOrder(
              order: const NumericFocusOrder(1.0),
              child: SizedBox(
                width: 50,
                child: EditableNumericLabel(
                  key: ValueKey(
                      "${sbpFocus.hashCode}-${fieldValidity[sbpFocus]}"),
                  strValue: sysText,
                  editMode: editMode,
                  controller: sys,
                  focusNode: sbpFocus,
                  precision: 0,
                  onSubmitted: onSubmitted,
                  inputFormatters: inputFormattersSbp,
                  isValid: fieldValidity[sbpFocus],
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Text('/'),
            const SizedBox(width: 5),
            FocusTraversalOrder(
              order: const NumericFocusOrder(1.1),
              child: SizedBox(
                width: 50,
                child: EditableNumericLabel(
                  key: ValueKey(
                      "${dbpFocus.hashCode}-${fieldValidity[dbpFocus]}"),
                  strValue: diaText,
                  editMode: editMode,
                  controller: dia,
                  focusNode: dbpFocus,
                  precision: 0,
                  onSubmitted: onSubmitted,
                  inputFormatters: inputFormattersDbp,
                  isValid: fieldValidity[dbpFocus],
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: editMode ? 105 : 60,
              child: hasBothValues
                  ? MmsText("$sysText/$diaText", textAlign: TextAlign.left)
                  : const MmsText("--", textAlign: TextAlign.left),
            ),
          ],
          const SizedBox(width: 10),
          SizedBox(width: 50, child: MmsText(unit)),
        ],
      ),
    );
  }
}

class _SexDropdown extends StatelessWidget {
  final PatientCaseBuilderState state;

  const _SexDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    final patientCase = state.patientCases.firstWhereOrNull(
      (pc) => pc.name == state.patientCaseUnderEditOrDisplay,
    );
    final currentSex = patientCase?.biologicalSex ?? BiologicalSexEnum.female;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Sex:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 8),
        DropdownButton<BiologicalSexEnum>(
          value: currentSex,
          items: BiologicalSexEnum.values
              .map((sex) => DropdownMenuItem(
                    value: sex,
                    child: Text(sex.label),
                  ))
              .toList(),
          onChanged: (BiologicalSexEnum? newSex) {
            if (newSex == null) return;
            context.read<PatientCaseBuilderBloc>().add(
                  PatientCaseBuilderEvent(
                    PatientCaseBuilderAction.updateBiologicalSex,
                    patientCaseName: state.patientCaseUnderEditOrDisplay,
                    updatedBiologicalSex: newSex,
                  ),
                );
          },
        ),
      ],
    );
  }
}

// Common container
class _SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// A text display object that has editing and non-editing modes.
// Can be created with a value, and a number of digits of precision
// Holds a value.
// While editing, label changes into a text field that allows numeric entry
class EditableNumericLabel extends StatefulWidget {
  final String strValue;
  final bool editMode;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int precision;
  final VoidCallback? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? isValid;

  const EditableNumericLabel({
    super.key,
    required this.strValue,
    required this.editMode,
    required this.controller,
    required this.focusNode,
    this.precision = 0,
    this.onSubmitted,
    this.inputFormatters,
    this.isValid,
  });

  @override
  State<EditableNumericLabel> createState() => _EditableNumericLabelState();
}

class _EditableNumericLabelState extends State<EditableNumericLabel> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.controller.text.isNotEmpty
        ? widget.controller.text
        : widget.strValue;
  }

  InputDecoration _getDecoration() {
    final showError = widget.isValid == false;
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: showError ? Colors.red : Colors.grey.shade400, width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: showError ? Colors.red : Colors.blue.shade500, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editMode) {
      return TextField(
        focusNode: widget.focusNode,
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: widget.inputFormatters,
        decoration: _getDecoration(),
        onSubmitted: (_) {
          // First, trigger FocusNode listeners (so _handleFocusChange runs)
          FocusScope.of(context).unfocus();

          // Then run the provided submit action (which calls _toggleEditMode)
          if (widget.onSubmitted != null) widget.onSubmitted!();
        },
      );
    } else {
      final value = double.tryParse(widget.controller.text);
      final formatted = value != null
          ? value.toStringAsFixed(widget.precision)
          : widget.controller.text;

      return Text(formatted);
    }
  }
}

class RangeTextInputFormatter extends TextInputFormatter {
  final double min;
  final double max;
  final bool isInt;
  final int maxDecimalPlaces;

  RangeTextInputFormatter({
    required this.min,
    required this.max,
    this.isInt = false,
    this.maxDecimalPlaces = 1,
  });

  final _numberRegex = RegExp(r'^-?\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Allow empty input or in-progress typing
    if (text.isEmpty || !_numberRegex.hasMatch(text)) return newValue;

    final value = double.tryParse(text);
    if (value == null) return newValue;

    // Allow typing partial values even if currently out of range
    // Do NOT block here — validate on form submission instead

    // Optional: limit decimal precision
    final parts = text.split('.');
    if (parts.length == 2 && parts[1].length > maxDecimalPlaces) {
      return oldValue;
    }

    // If integer required, block decimal inputs
    if (isInt && text.contains('.')) return oldValue;

    return newValue;
  }
}
