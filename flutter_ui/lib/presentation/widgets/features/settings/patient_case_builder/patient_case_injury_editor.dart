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
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/data/model/patient_injury/patient_injury.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_body_location.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text_field.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text_field_with_blur.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter

class PatientCaseInjuryEditor extends StatefulWidget {
  final Injury? injuryId;
  final bool readOnly;
  final PatientInjury? readOnlyData;

  const PatientCaseInjuryEditor({
    super.key,
    this.injuryId,
    this.readOnly = false,
    this.readOnlyData,
  });

  @override
  State<PatientCaseInjuryEditor> createState() =>
      PatientCaseInjuryEditorState();
}

class PatientCaseInjuryEditorState extends State<PatientCaseInjuryEditor> {
  late final TextEditingController _renameInjuryController;
  late final TextEditingController _injurySeverityController;
  late final TextEditingController _injuryDetailController;

  String injuryType = 'Not Applicable';
  String injuryDescription = 'Not Applicable';
  bool _isRenameTextNotEmpty = false;
  String? _validationError;
  bool _isEditingText = false;
  bool _justUpdatedInjuryType = false;
  FocusNode? _activeFocusNode;
  final FocusNode _injuryDetailFocus = FocusNode();
  final FocusNode _injurySeverityFocus = FocusNode();

  Map<String, dynamic> mechanismOfInjuryDropdowns = {
    'gunshotCaliber': 'Not Applicable',
    'gunshotAmmunitionType': 'Not Applicable',
    'blade': 'Not Applicable',
    'blast': 'Not Applicable',
    'vehicleCrash': 'Not Applicable',
    'fall': 'Not Applicable',
    'cbrn': 'Not Applicable',
    'shrapnel': 'Not Applicable',
  };

  final GlobalKey _mechanismKey = GlobalKey();
  double _mechanismHeight = 0;

  @override
  void initState() {
    super.initState();
    _renameInjuryController = TextEditingController();
    _injurySeverityController = TextEditingController();
    _injuryDetailController = TextEditingController();

    _renameInjuryController.addListener(() {
      setState(() {
        _isRenameTextNotEmpty = _renameInjuryController.text.trim().isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.readOnly) return;
      final renderBox =
          _mechanismKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _mechanismHeight = renderBox.size.height;
        });
      }
      final state = context.read<PatientCaseBuilderBloc>().state;
      final injury = _getInjuryFromState(state);
      _syncWithInjuryData(injury);
    });
  }

  @override
  void dispose() {
    _renameInjuryController.dispose();
    _injurySeverityController.dispose();
    _injuryDetailController.dispose();
    _injuryDetailFocus.dispose();
    _injurySeverityFocus.dispose();
    super.dispose();
  }

  void _handleSubmitRenameInjury(String value, PatientCaseBuilderState state) {
    final newIdForInjury = value;

    if (newIdForInjury.isNotEmpty) {
      context.read<PatientCaseBuilderBloc>().add(
            PatientCaseBuilderEvent(
              PatientCaseBuilderAction.renameInjury,
              patientCaseName: state.patientCaseUnderEditOrDisplay,
              injuryId: state.injuryIdUnderEdit,
              newIdForInjury: newIdForInjury,
              context: context,
            ),
          );
      _renameInjuryController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Injury name cannot be blank.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void updateControllerSafely(
      TextEditingController controller, String newValue) {
    final currentText = controller.text;

    final isUserEditing = controller.selection.isValid &&
        controller.selection.baseOffset != controller.selection.extentOffset;

    // Don't overwrite if user input is invalid
    if (_validationError != null && controller == _injurySeverityController) {
      return;
    }

    // Only update if the user is NOT editing and the value is different
    if (!isUserEditing && currentText != newValue) {
      controller.text = newValue;

      // Move cursor to end to avoid jumpiness
      controller.selection = TextSelection.collapsed(offset: newValue.length);
    }
  }

  String get injuryLocationString {
    final state = context.read<PatientCaseBuilderBloc>().state;
    final injury =
        _getInjuryFromState(state); // Method to extract the injury from state
    return injury.location != null
        ? BodyLocationRecord.generateLabel(
            sagittal: injury.location!.sagittalPlane,
            coronal: injury.location!.coronalPlane,
            region: injury.location!.generalRegion,
          )
        : 'None';
  }

  Injury _getInjuryFromState(PatientCaseBuilderState state) {
    final patientCase = state.patientCases.firstWhere(
      (pc) => pc.name == state.patientCaseUnderEditOrDisplay,
    );

    return patientCase.injuries!.firstWhere(
      (inj) => inj.id == state.injuryIdUnderEdit,
    );
  }

  String computeInjuryLocationString(Injury injury) {
    return injury.location != null
        ? BodyLocationRecord.generateLabel(
            sagittal: injury.location!.sagittalPlane,
            coronal: injury.location!.coronalPlane,
            region: injury.location!.generalRegion,
          )
        : 'None';
  }

  void _syncWithInjuryData(Injury injury) {
    setState(() {
      injuryType = injury.injuryType?.enumValue ??
          InjuryTypeEnum.notApplicable.enumValue;
      injuryDescription = injury.description?.enumValue ??
          InjuryDescriptionEnum.notApplicable.enumValue;

      final severityValue = computeSeverityValue(injury);
      if (severityValue != null) {
        updateControllerSafely(_injurySeverityController, severityValue);
      }

      if (_injurySeverityController.text == severityValue &&
          _validationError != null) {
        setState(() {
          _validationError = null;
        });
      }

      updateControllerSafely(_injuryDetailController, injury.detail ?? '');

      final mechanism = injury.mechanism?.getSelectedMechanismAsMap();
      if (mechanism != null && mechanism.isNotEmpty) {
        mechanismOfInjuryDropdowns = Map.from(mechanism);
      }
    });
  }

  String? computeSeverityValue(Injury injury) {
    if (injury.injuryType == InjuryTypeEnum.hemorrhage &&
        injury.hemorrhageRateMlPerMin != null) {
      return injury.hemorrhageRateMlPerMin!.toString();
    } else if (injury.injuryType == InjuryTypeEnum.burn &&
        injury.burnBodySurfaceAreaPercentage != null) {
      return injury.burnBodySurfaceAreaPercentage!.toString();
    } else if (injury.severityScore != null) {
      return injury.severityScore!.toString();
    } else {
      return null;
    }
  }

  @override
  void didUpdateWidget(covariant PatientCaseInjuryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.readOnly) return;

    final state = context.read<PatientCaseBuilderBloc>().state;
    final injury = _getInjuryFromState(state);

    _syncWithInjuryData(injury);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly && widget.readOnlyData != null) {
      return _buildReadOnly(widget.readOnlyData!);
    }

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
        height: MediaQuery.of(context).size.height - 42,
        padding: const EdgeInsets.all(20),
        child: BlocListener<PatientCaseBuilderBloc, PatientCaseBuilderState>(
          listener: (context, state) {
            if (_justUpdatedInjuryType) {
              _justUpdatedInjuryType = false; // reset the flag
              return;
            }

            final injury = _getInjuryFromState(state);
            _syncWithInjuryData(injury);
          },
          child: BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
            builder: (context, state) {
              return MmsRoundedBarlessPanel(
                caption:
                    "Injury Editor - ${state.injuryIdUnderEdit ?? 'Loading'} ${state.saving == SaveStatus.saving ? '(saving)' : '(saved)'}",
                widget: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 0,
                      maxHeight: MediaQuery.of(context).size.height + 22,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("${state.injuryIdUnderEdit}:"),
                              const SizedBox(width: 10),
                              MmsTextField(
                                height: 80,
                                width: 300,
                                maxLines: 1,
                                textController: _renameInjuryController,
                                onSubmitted: (value) =>
                                    _handleSubmitRenameInjury(value, state),
                              ),
                              const SizedBox(width: 10),
                              MmsPaddedRaisedButton(
                                "Rename",
                                onPressed: _isRenameTextNotEmpty
                                    ? () {
                                        _handleSubmitRenameInjury(
                                            _renameInjuryController.text.trim(),
                                            state);
                                      }
                                    : null, // disables the button
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _infoBox(
                                    "Injury Location", injuryLocationString,
                                    button: true, fixedHeight: 120),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: enumDropdown<InjuryTypeEnum>(
                                title: "Injury Type",
                                selected: InjuryTypeEnum.values.firstWhere(
                                  (e) => e.enumValue == injuryType,
                                  orElse: () => InjuryTypeEnum.notApplicable,
                                ),
                                values: InjuryTypeEnum.values,
                                onChanged: (val) {
                                  setState(() {
                                    injuryType = val.enumValue;
                                    _injurySeverityController.clear();
                                    _validationError = null;
                                    _justUpdatedInjuryType = true;
                                  });

                                  context.read<PatientCaseBuilderBloc>().add(
                                        PatientCaseBuilderEvent(
                                          PatientCaseBuilderAction
                                              .updateInjuryType,
                                          patientCaseName: state
                                              .patientCaseUnderEditOrDisplay,
                                          injuryId: state.injuryIdUnderEdit,
                                          updatedInjuryType: val,
                                          context: context,
                                        ),
                                      );

                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    if (mounted) {
                                      _injurySeverityFocus.requestFocus();
                                    }
                                  });
                                },
                                getEnumValue: (e) => e.enumValue,
                                getLabel: (e) => e.label,
                                fixedHeight: 120,
                              )),
                              const SizedBox(width: 10),
                              Expanded(
                                child: enumDropdown<InjuryDescriptionEnum>(
                                  title: "Injury Description",
                                  selected:
                                      InjuryDescriptionEnum.values.firstWhere(
                                    (e) => e.enumValue == injuryDescription,
                                    orElse: () =>
                                        InjuryDescriptionEnum.notApplicable,
                                  ),
                                  values: InjuryDescriptionEnum.values,
                                  onChanged: (val) => setState(() {
                                    injuryDescription = val.enumValue;
                                    context.read<PatientCaseBuilderBloc>().add(
                                          PatientCaseBuilderEvent(
                                            PatientCaseBuilderAction
                                                .updateInjuryDescription,
                                            patientCaseName: state
                                                .patientCaseUnderEditOrDisplay,
                                            injuryId: state.injuryIdUnderEdit,
                                            updatedInjuryDescription: val,
                                            context: context,
                                          ),
                                        );
                                  }),
                                  getEnumValue: (e) => e.enumValue,
                                  getLabel: (e) => e.label,
                                  fixedHeight: 120,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: _injurySeverityBox(state)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 200,
                                height: _mechanismHeight > 0
                                    ? _mechanismHeight
                                    : 300,
                                child: _infoBox("Injury Detail", '', // unused
                                    infoBoxMultiLineController:
                                        _injuryDetailController,
                                    isMultiline: true,
                                    forceExpand: true,
                                    state: state),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: _mechanismOfInjurySection(state)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoBox(
    String title,
    String content, {
    bool button = false,
    TextEditingController? infoBoxMultiLineController,
    bool isMultiline = false,
    bool forceExpand = false,
    double? fixedHeight,
    Widget? child,
    PatientCaseBuilderState? state,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      height: fixedHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (button)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content),
                const SizedBox(height: 6),
                MmsPaddedRaisedButton("Select Location", onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MmsDismissibleScreen(
                        const ValueKey(
                            "PatientCaseInjuryLocationScreenDismissible"),
                        PatientCaseBodyLocation(
                          editMode: true,
                        ),
                        scrollable: true,
                      ),
                    ),
                  );
                }),
              ],
            )
          else if (isMultiline && forceExpand)
            Expanded(
              child: TextFieldWithBlur(
                controller: infoBoxMultiLineController,
                focusNode: _injuryDetailFocus,
                expands: true,
                maxLines: null,
                minLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: MmsColors.mdGrey),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: MmsColors.black,
                  fontSize: 16,
                ),
                callback: (injuryDetail) {
                  context.read<PatientCaseBuilderBloc>().add(
                        PatientCaseBuilderEvent(
                          PatientCaseBuilderAction.updateInjuryDetail,
                          patientCaseName: state!.patientCaseUnderEditOrDisplay,
                          injuryId: state.injuryIdUnderEdit,
                          updatedInjuryDetail: injuryDetail,
                          context: context,
                        ),
                      );
                },
                onFocusChanged: (hasFocus) {
                  setState(() {
                    _isEditingText = hasFocus;
                    _activeFocusNode = hasFocus ? _injuryDetailFocus : null;
                  });
                },
              ),
            )
          else if (child != null)
            child
          else
            Text(content),
        ],
      ),
    );
  }

  Widget enumDropdown<T>({
    required String title,
    required T selected,
    required List<T> values,
    required void Function(T) onChanged,
    required String Function(T) getEnumValue,
    required String Function(T) getLabel,
    double? fixedHeight,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      height: fixedHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            key: ValueKey<String>(
                getEnumValue(selected)), // Force widget rebuild on change
            isExpanded: true,
            value: getEnumValue(selected),
            onChanged: (val) {
              final newValue = values.firstWhere(
                (e) => getEnumValue(e) == val,
                orElse: () => values.first,
              );
              onChanged(newValue);
            },
            items: values
                .map((e) => DropdownMenuItem<String>(
                      value: getEnumValue(e),
                      child: Text(getLabel(e)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _mechanismOfInjurySection(PatientCaseBuilderState state) {
    return Container(
      key: _mechanismKey,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mechanism of Injury",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Row 1
          Row(
            children: [
              Expanded(
                child: enumDropdown<GunshotCaliberEnum>(
                  title: "Caliber",
                  selected: GunshotCaliberEnum.values.firstWhere(
                    (e) =>
                        e.enumValue ==
                        mechanismOfInjuryDropdowns['gunshotCaliber'],
                    orElse: () => GunshotCaliberEnum.notApplicable,
                  ),
                  values: GunshotCaliberEnum.values,
                  onChanged: (val) {
                    setState(() {
                      setMechanismOfInjury('gunshotCaliber', val.enumValue);
                    });
                    fireInjuryMechanismUpdateEvent(
                        state, MechanismOfInjuryRecord(gunshotCaliber: val));
                  },
                  getEnumValue: (e) => e.enumValue,
                  getLabel: (e) => e.label,
                ),
              ),
              Expanded(
                child: enumDropdown<GunshotAmmunitionTypeEnum>(
                  title: "Ammo Type",
                  selected: GunshotAmmunitionTypeEnum.values.firstWhere(
                    (e) =>
                        e.enumValue ==
                        mechanismOfInjuryDropdowns['gunshotAmmunitionType'],
                    orElse: () => GunshotAmmunitionTypeEnum.notApplicable,
                  ),
                  values: GunshotAmmunitionTypeEnum.values,
                  onChanged: (val) {
                    setState(() {
                      setMechanismOfInjury(
                          'gunshotAmmunitionType', val.enumValue);
                    });
                    fireInjuryMechanismUpdateEvent(state,
                        MechanismOfInjuryRecord(gunshotAmmunitionType: val));
                  },
                  getEnumValue: (e) => e.enumValue,
                  getLabel: (e) => e.label,
                ),
              ),
              Expanded(
                child: enumDropdown<BladeTypeEnum>(
                  title: "Blade Type",
                  selected: BladeTypeEnum.values.firstWhere(
                    (e) => e.enumValue == mechanismOfInjuryDropdowns['blade'],
                    orElse: () => BladeTypeEnum.notApplicable,
                  ),
                  values: BladeTypeEnum.values,
                  onChanged: (val) {
                    setState(() {
                      setMechanismOfInjury('blade', val.enumValue);
                    });
                    fireInjuryMechanismUpdateEvent(
                        state, MechanismOfInjuryRecord(blade: val));
                  },
                  getEnumValue: (e) => e.enumValue,
                  getLabel: (e) => e.label,
                ),
              ),
              Expanded(
                child: enumDropdown<BlastTypeEnum>(
                  title: "Blast Type",
                  selected: BlastTypeEnum.values.firstWhere(
                    (e) => e.enumValue == mechanismOfInjuryDropdowns['blast'],
                    orElse: () => BlastTypeEnum.notApplicable,
                  ),
                  values: BlastTypeEnum.values,
                  onChanged: (val) {
                    setState(() {
                      setMechanismOfInjury('blast', val.enumValue);
                    });
                    fireInjuryMechanismUpdateEvent(
                        state, MechanismOfInjuryRecord(blast: val));
                  },
                  getEnumValue: (e) => e.enumValue,
                  getLabel: (e) => e.label,
                ),
              ),
            ],
          ),

          // Row 2
          Row(
            children: [
              Expanded(
                child: enumDropdown<VehicleCrashEnum>(
                  title: "Vehicle Crash",
                  selected: VehicleCrashEnum.values.firstWhere(
                    (e) =>
                        e.enumValue ==
                        mechanismOfInjuryDropdowns['vehicleCrash'],
                    orElse: () => VehicleCrashEnum.notApplicable,
                  ),
                  values: VehicleCrashEnum.values,
                  onChanged: (val) {
                    setState(() {
                      setMechanismOfInjury('vehicleCrash', val.enumValue);
                    });
                    fireInjuryMechanismUpdateEvent(
                        state, MechanismOfInjuryRecord(vehicleCrash: val));
                  },
                  getEnumValue: (e) => e.enumValue,
                  getLabel: (e) => e.label,
                ),
              ),
              Expanded(
                child: enumDropdown<FallTypeEnum>(
                  title: "Fall",
                  selected: FallTypeEnum.values.firstWhere(
                    (e) => e.enumValue == mechanismOfInjuryDropdowns['fall'],
                    orElse: () => FallTypeEnum.notApplicable,
                  ),
                  values: FallTypeEnum.values,
                  onChanged: (val) {
                    setState(() {
                      setMechanismOfInjury('fall', val.enumValue);
                    });
                    fireInjuryMechanismUpdateEvent(
                        state, MechanismOfInjuryRecord(fall: val));
                  },
                  getEnumValue: (e) => e.enumValue,
                  getLabel: (e) => e.label,
                ),
              ),
              Expanded(
                child: enumDropdown<CBRNTypeEnum>(
                  title: "CBRN",
                  selected: CBRNTypeEnum.values.firstWhere(
                    (e) => e.enumValue == mechanismOfInjuryDropdowns['cbrn'],
                    orElse: () => CBRNTypeEnum.notApplicable,
                  ),
                  values: CBRNTypeEnum.values,
                  onChanged: (val) {
                    setState(() {
                      setMechanismOfInjury('cbrn', val.enumValue);
                    });
                    fireInjuryMechanismUpdateEvent(
                        state, MechanismOfInjuryRecord(cbrn: val));
                  },
                  getEnumValue: (e) => e.enumValue,
                  getLabel: (e) => e.label,
                ),
              ),
              Expanded(
                child: enumDropdown<ShrapnelTypeEnum>(
                  title: "Shrapnel",
                  selected: ShrapnelTypeEnum.values.firstWhere(
                    (e) =>
                        e.enumValue == mechanismOfInjuryDropdowns['shrapnel'],
                    orElse: () => ShrapnelTypeEnum.notApplicable,
                  ),
                  values: ShrapnelTypeEnum.values,
                  onChanged: (val) {
                    setState(() {
                      setMechanismOfInjury('shrapnel', val.enumValue);
                    });
                    fireInjuryMechanismUpdateEvent(
                        state, MechanismOfInjuryRecord(shrapnel: val));
                  },
                  getEnumValue: (e) => e.enumValue,
                  getLabel: (e) => e.label,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void setMechanismOfInjury(
      String injuryMechanismGeneral, String injuryMechanismSpecific) {
    mechanismOfInjuryDropdowns[injuryMechanismGeneral] =
        injuryMechanismSpecific;
  }

  void fireInjuryMechanismUpdateEvent(
      PatientCaseBuilderState state, MechanismOfInjuryRecord moir) {
    context.read<PatientCaseBuilderBloc>().add(PatientCaseBuilderEvent(
          PatientCaseBuilderAction.updateInjuryMechanism,
          patientCaseName: state.patientCaseUnderEditOrDisplay,
          injuryId: state.injuryIdUnderEdit,
          updatedMechanismOfInjury: moir,
          context: context,
        ));
  }

  Widget _injurySeverityBox(PatientCaseBuilderState state) {
    Widget inputField(String unitLabel, {required String type}) {
      List<TextInputFormatter> inputFormatters;

      if (type == 'severity') {
        // Only allow whole numbers (integers only)
        inputFormatters = [FilteringTextInputFormatter.digitsOnly];
      } else {
        // Allow decimals: up to 2 decimal places
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
        ];
      }

      bool isValid(String value) {
        final doubleValue = double.tryParse(value);
        final intValue = int.tryParse(value);

        switch (type) {
          case 'hemorrhage':
            return doubleValue != null &&
                doubleValue >= 0 &&
                doubleValue <= 6000;
          case 'tbsa':
            return doubleValue != null &&
                doubleValue >= 0 &&
                doubleValue <= 100;
          case 'severity':
            return intValue != null && intValue >= 0 && intValue <= 10;
          default:
            return true;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: Align(
                    alignment: Alignment.center,
                    child: TextFieldWithBlur(
                      controller: _injurySeverityController,
                      focusNode: _injurySeverityFocus,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: inputFormatters,
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: MmsColors.black,
                          fontSize: 16),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 1, color: MmsColors.mdGrey),
                        ),
                      ),
                      callback: (value) {
                        setState(() {
                          _validationError = isValid(value)
                              ? null
                              : switch (type) {
                                  'hemorrhage' => 'Enter a value ≤ 6000',
                                  'tbsa' => 'Enter % TBSA from 0 to 100',
                                  'severity' => 'Enter a whole number 0–10',
                                  _ => null,
                                };
                        });

                        if (_validationError == null) {
                          context.read<PatientCaseBuilderBloc>().add(
                                PatientCaseBuilderEvent(
                                  PatientCaseBuilderAction.updateInjurySeverity,
                                  patientCaseName:
                                      state.patientCaseUnderEditOrDisplay,
                                  injuryId: state.injuryIdUnderEdit,
                                  updatedInjuryType:
                                      injuryType.toInjuryTypeEnum(),
                                  updatedInjurySeverityDouble:
                                      (type == 'severity')
                                          ? null
                                          : double.tryParse(value),
                                  updatedInjurySeverityInteger:
                                      (type == 'severity')
                                          ? int.tryParse(value)
                                          : null,
                                  context: context,
                                ),
                              );
                        }
                      },
                      onFocusChanged: (hasFocus) {
                        setState(() {
                          _isEditingText = hasFocus;
                          _activeFocusNode =
                              hasFocus ? _injurySeverityFocus : null;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(unitLabel),
            ],
          ),
          if (_validationError != null)
            const SizedBox(height: 2), // micro spacing
          if (_validationError != null)
            Text(
              _validationError!,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.red,
                height: 0.9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // prevent wrapping
            ),
        ],
      );
    }

    String title = "Injury Severity";

    final type = injuryType.toLowerCase();

    if (type == "hemorrhage") {
      return _infoBox(
        title,
        "",
        child: inputField("ml/min", type: 'hemorrhage'),
        fixedHeight: 120,
      );
    } else if (type == "burn") {
      return _infoBox(
        title,
        "",
        child: inputField("% TBSA", type: 'tbsa'),
        fixedHeight: 120,
      );
    } else {
      return _infoBox(
        title,
        "",
        child: inputField("0–10", type: 'severity'),
        fixedHeight: 120,
      );
    }
  }

  String _readOnlySeverityText(PatientInjury data) {
    final type = data.injuryType.toLowerCase();
    if (type == 'hemorrhage' && data.hemorrhageRate != null) {
      return '${data.hemorrhageRate} ml/min';
    } else if (type == 'burn' && data.burnTbsa != null) {
      return '${data.burnTbsa} % TBSA';
    } else {
      return data.severity.toString();
    }
  }

  Widget _buildReadOnly(PatientInjury data) {
    final caption =
        'Injury Details — ${data.injuryId.isNotEmpty ? data.injuryId : data.injuryType}';
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
        height: MediaQuery.of(context).size.height - 42,
        padding: const EdgeInsets.all(20),
        child: MmsRoundedBarlessPanel(
          caption: caption,
          widget: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height + 22,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _infoBox(
                            'Injury Location',
                            data.locations.isNotEmpty
                                ? data.locations.join(' ')
                                : 'None',
                            fixedHeight: 120,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _infoBox('Injury Type', data.injuryType,
                              fixedHeight: 120),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _infoBox(
                              'Injury Description', data.description,
                              fixedHeight: 120),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _infoBox(
                              'Injury Severity', _readOnlySeverityText(data),
                              fixedHeight: 120),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 200,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Injury Detail',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(data.detail.isNotEmpty
                                      ? data.detail
                                      : '—'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _readOnlyMechanismSection(data)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _readOnlyMechanismSection(PatientInjury data) {
    const labels = {
      'gunshotCaliber': 'Caliber',
      'gunshotAmmunitionType': 'Ammo Type',
      'blade': 'Blade Type',
      'blast': 'Blast Type',
      'vehicleCrash': 'Vehicle Crash',
      'fall': 'Fall',
      'cbrn': 'CBRN',
      'shrapnel': 'Shrapnel',
    };

    Widget mechBox(String title, String value) => Expanded(
          child: _infoBox(title, value),
        );

    final entries = labels.entries.toList();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mechanism of Injury',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: entries
                .take(4)
                .map((e) =>
                    mechBox(e.value, data.mechanism[e.key] ?? 'Not Applicable'))
                .toList(),
          ),
          Row(
            children: entries
                .skip(4)
                .map((e) =>
                    mechBox(e.value, data.mechanism[e.key] ?? 'Not Applicable'))
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<bool> validateBeforeDismiss() async {
    // Step 1: If user is actively editing, blur the field
    if (_isEditingText && _activeFocusNode != null) {
      _activeFocusNode!.unfocus(); // triggers blur + validation
      await Future.delayed(const Duration(
          milliseconds: 100)); // small delay for validation to propagate
    }

    // Step 2: Now validate
    if (_validationError != null) {
      if (!mounted) return false; // Guard context usage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix validation errors before closing."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }
}
