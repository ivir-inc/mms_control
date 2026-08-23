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
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/add_patient_widget.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_table.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/collapsible_settings_panel.dart';

class PatientManagementPanel extends StatefulWidget {
  const PatientManagementPanel({
    super.key,
    required this.onToggleVisibility,
    required this.onRemovePatient,
    required this.onToggleExpand,
  });

  final void Function(Patient patient) onToggleVisibility;
  final void Function(Patient patient) onRemovePatient;
  final VoidCallback onToggleExpand;

  @override
  _PatientManagementPanelState createState() => _PatientManagementPanelState();
}

class _PatientManagementPanelState extends State<PatientManagementPanel>
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
      title: 'Patient Management',
      collapsedSummary: _buildCollapsedSummary(context),
      expandedContent: _buildExpandedContent(),
      isExpanded: isExpanded, // Controlled by the local state
      onToggle: _toggleExpand,
    );
  }

  Widget _buildCollapsedSummary(BuildContext context) {
    return BlocBuilder<PatientManagementBloc, PatientManagementState>(
      builder: (context, state) {
        if (state.patients.isEmpty) {
          return const Text("No patients added.");
        }

        // Sorting: hidden patients first, then by patient name alphabetically
        List<Patient> sortedPatients = List.from(state.patients);
        sortedPatients.sort((a, b) {
          final isVisibleA = state.patientVisibility[a.id] ?? a.monitorPatient;
          final isVisibleB = state.patientVisibility[b.id] ?? b.monitorPatient;

          // First, prioritize hidden patients (false) over visible (true)
          if (isVisibleA != isVisibleB) {
            return isVisibleA ? 1 : -1;
          }

          // If both are the same visibility, sort alphabetically by patient name (case-insensitive)
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedPatients.map((patient) {
            final isVisible =
                state.patientVisibility[patient.id] ?? patient.monitorPatient;
            final visibilityIcon = isVisible
                ? const Icon(Icons.visibility, color: Colors.green)
                : const Icon(Icons.visibility_off, color: Colors.red);

            return Row(
              children: [
                Expanded(
                  child: Text(
                    '${patient.name} (${_physiologySourceToText(patient.physiologySource)})',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Row(
                  children: [
                    visibilityIcon,
                    const SizedBox(width: 5),
                    Text(isVisible ? "Visible" : "Hidden"),
                  ],
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
        AddPatientWidget(),
        const SizedBox(height: 20),
        PatientTable(
          onToggleVisibility: widget.onToggleVisibility,
          onRemovePatient: widget.onRemovePatient,
        ),
      ],
    );
  }

  String _physiologySourceToText(PatientSource source) {
    switch (source) {
      case PatientSource.internal:
        return "Internal";
      case PatientSource.external:
        return "External";
      case PatientSource.unknown:
      default:
        return "Unknown";
    }
  }

  @override
  bool get wantKeepAlive => true; // Ensures the widget's state is preserved
}
