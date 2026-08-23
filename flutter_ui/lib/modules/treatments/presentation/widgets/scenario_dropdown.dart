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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'scenario_holder.dart';

/// Dropdown menu button for selecting the active scenario for [patientId].
/// The [onChanged] function will be called only after the active scenario
/// has been successfully updated in the app state and backend.
class ScenarioMenuDropdownButton extends StatefulWidget {
  final String patientId;
  final VoidCallback onChanged;

  const ScenarioMenuDropdownButton({
    super.key,
    required this.patientId,
    required this.onChanged,
  });

  @override
  _ScenarioMenuDropdownButtonState createState() =>
      _ScenarioMenuDropdownButtonState();
}

class _ScenarioMenuDropdownButtonState
    extends State<ScenarioMenuDropdownButton> {
  late ScenarioHolder _scenarioHolder;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scenarioHolder = ScenarioHolder.instanceFor(patientId: widget.patientId);
    _scenarioHolder.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
            builder: (context, state) {
              List<DropdownMenuItem<int>> menuItems;
              if (state.patientCases.isNotEmpty) {
                menuItems = state.patientCases
                    .map((patientCases) => DropdownMenuItem<int>(
                          value: patientCases.caseNum,
                          child: MmsText(patientCases.name),
                        ))
                    .toList();
              } else {
                menuItems = [
                  const DropdownMenuItem<int>(
                      value: -1, child: MmsText("<No Patient Case Available>"))
                ];
              }
              return BlocBuilder<PatientManagementBloc, PatientManagementState>(
                builder: (context, state) {
                  final selectedPatient = state.patients
                      .firstWhere((pat) => pat.id == widget.patientId);
                  final currentCaseNum = selectedPatient.patientCaseNum;

                  final patientCases =
                      context.read<PatientCaseBuilderBloc>().state.patientCases;
                  final hasCases = patientCases.isNotEmpty;

                  final caseNumInList =
                      patientCases.any((pc) => pc.caseNum == currentCaseNum);
                  final selectedValue = caseNumInList ? currentCaseNum : null;

                  List<DropdownMenuItem<int>> menuItems = hasCases
                      ? patientCases
                          .map((pc) => DropdownMenuItem<int>(
                                value: pc.caseNum,
                                child: MmsText(pc.name),
                              ))
                          .toList()
                      : [
                          const DropdownMenuItem<int>(
                            value: -1,
                            enabled: false,
                            child: MmsText("<No Patient Cases Available>"),
                          )
                        ];

                  return DropdownButton<int>(
                    value: selectedValue,
                    hint: MmsText(
                      hasCases
                          ? "<Select a Patient Case>"
                          : "<No Patient Cases Available>",
                      style: TextStyle(color: Theme.of(context).disabledColor),
                    ),
                    isExpanded: true,
                    items: menuItems,
                    onChanged: hasCases
                        ? (newValue) async {
                            if (newValue != null) {
                              setState(() => isLoading = true);

                              context.read<PatientCaseBuilderBloc>().add(
                                    PatientCaseBuilderEvent(
                                      PatientCaseBuilderAction
                                          .assignPatientCaseToPatient,
                                      patientId: widget.patientId,
                                      patientCaseNum: newValue,
                                      context: context,
                                    ),
                                  );

                              context.read<PatientManagementBloc>().add(
                                    PatientManagementEvent(
                                      PatientManagementAction.assignPatientCase,
                                      const [],
                                      patientId: widget.patientId,
                                      patientCaseNum: newValue,
                                      context: context,
                                    ),
                                  );

                              setState(() => isLoading = false);
                              widget.onChanged();
                            }
                          }
                        : null,
                  );
                },
              );
            },
          );
  }
}

/// Label widget to display the currently active scenario for [patientId].
/// The label updates automatically when the active scenario changes.
class MmsScenarioSelectionLabel extends StatefulWidget {
  final String patientId;
  final TextStyle? textStyle;

  const MmsScenarioSelectionLabel({
    super.key,
    required this.patientId,
    this.textStyle,
  });

  @override
  State<MmsScenarioSelectionLabel> createState() =>
      _MmsScenarioSelectionLabelState();
}

class _MmsScenarioSelectionLabelState extends State<MmsScenarioSelectionLabel> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientManagementBloc, PatientManagementState>(
      builder: (context, state) {
        final patientObj =
            state.patients.firstWhere((pat) => pat.id == widget.patientId);
        final patientCaseNum = patientObj.patientCaseNum;

        final patientCaseList =
            context.read<PatientCaseBuilderBloc>().state.patientCases;

        final matchingCase = patientCaseNum != null
            ? patientCaseList.firstWhereOrNull(
                (pc) => pc.caseNum == patientCaseNum,
              )
            : null;

        final patientCaseName = matchingCase?.name ?? 'None';

        return MmsText(
          patientCaseName,
          style: widget.textStyle,
        );
      },
    );
  }
}
