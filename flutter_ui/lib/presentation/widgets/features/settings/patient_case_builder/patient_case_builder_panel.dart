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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/add_patient_case_widget.dart';
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_table.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/collapsible_settings_panel.dart';

class PatientCaseBuilderPanel extends StatefulWidget {
  const PatientCaseBuilderPanel({
    super.key,
    required this.onEditPatientCase,
    required this.onRemovePatientCase,
    required this.onToggleExpand,
  });

  final void Function(PatientCase patientCase) onEditPatientCase;
  final void Function(PatientCase patientCase) onRemovePatientCase;
  final VoidCallback onToggleExpand;

  @override
  _PatientCaseBuilderPanelState createState() =>
      _PatientCaseBuilderPanelState();
}

class _PatientCaseBuilderPanelState extends State<PatientCaseBuilderPanel>
    with AutomaticKeepAliveClientMixin {
  bool isExpanded = false; // Manage expanded/collapsed state locally

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded; // Toggle the expanded state
      widget.onToggleExpand(); // Notify parent of expansion (for scrolling)
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required when using AutomaticKeepAliveClientMixin
    return CollapsibleSettingsPanel(
      title: 'Patient Case Builder',
      collapsedSummary: _buildCollapsedSummary(context),
      expandedContent: _buildExpandedContent(),
      isExpanded: isExpanded, // Controlled by the local state
      onToggle: _toggleExpand,
    );
  }

  Widget _buildCollapsedSummary(BuildContext context) {
    return BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
      builder: (context, state) {
        if (state.patientCases.isEmpty) {
          return const Text("No Patient Cases added.");
        }

        // Sorting: by Patient Case name alphabetically
        List<PatientCase> sortedPatientCases = List.from(state.patientCases);

        // case insensitive sort
        sortedPatientCases.sort((a, b) => (a.name?.toLowerCase() ?? '')
            .compareTo(b.name?.toLowerCase() ?? ''));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedPatientCases.map((patientCase) {
            return Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 24,
                    child: Text(
                      patientCase.name ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddPatientCaseWidget(),
        const SizedBox(height: 20),
        PatientCaseTable(
          onEditPatientCase: widget.onEditPatientCase,
          onRemovePatientCase: widget.onRemovePatientCase,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true; // Ensures the widget's state is preserved
}
