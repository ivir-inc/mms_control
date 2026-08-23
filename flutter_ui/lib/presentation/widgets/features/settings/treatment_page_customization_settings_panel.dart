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
import 'package:flutter_ui/data/model/metadata/metadata_store_access.dart';
import 'package:flutter_ui/logic/treatment_layout/treatment_layout_bloc.dart';
import 'package:flutter_ui/logic/treatment_layout/treatment_layout_event.dart';
import 'package:flutter_ui/logic/treatment_layout/treatment_layout_state.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_medications.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_treatments.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'collapsible_settings_panel.dart';

class TreatmentPageCustomizationSettingsPanel extends StatefulWidget {
  final VoidCallback onToggleExpand;

  const TreatmentPageCustomizationSettingsPanel({
    super.key,
    required this.onToggleExpand,
  });

  @override
  State<TreatmentPageCustomizationSettingsPanel> createState() =>
      _TreatmentPageCustomizationSettingsPanelState();
}

class _TreatmentPageCustomizationSettingsPanelState
    extends State<TreatmentPageCustomizationSettingsPanel> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    widget.onToggleExpand();
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset to defaults?'),
        content: const Text(
            'This will restore the default treatment and medication layout.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<TreatmentLayoutBloc>().add(const ResetLayout());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TreatmentLayoutBloc, TreatmentLayoutState>(
      builder: (context, state) {
        final metadata =
            context.read<MetadataStoreAccess>().store.metadata;
        final treatmentKeys = <String>{
          for (final item in metadata?.physicalTreatmentType ?? [])
            if (item.name != null) item.name!,
        };
        final medicationKeys = <String>{
          for (final item in metadata?.medication ?? [])
            if (item.name != null) item.name!,
        };

        // Use metadata-aware visibility: a category with only backend items
        // that don't exist in the current metadata should not appear.
        final treatmentNames = state.config?.treatments
                .where((c) => treatmentKeys.isEmpty
                    ? !c.isEmpty
                    : c.allItems.any(treatmentKeys.contains))
                .map((c) => c.name.isEmpty ? '(unnamed)' : c.name)
                .join(', ') ??
            '—';
        final medicationNames = state.config?.medications
                .where((c) => medicationKeys.isEmpty
                    ? !c.isEmpty
                    : c.allItems.any(medicationKeys.contains))
                .map((c) => c.name.isEmpty ? '(unnamed)' : c.name)
                .join(', ') ??
            '—';

        return CollapsibleSettingsPanel(
          title: 'Treatment Page Customization',
          collapsedSummary:
              _buildContent(treatmentNames, medicationNames),
          expandedContent:
              _buildContent(treatmentNames, medicationNames, editMode: true),
          isExpanded: _isExpanded,
          onToggle: _toggleExpand,
        );
      },
    );
  }

  Widget _buildContent(String treatmentNames, String medicationNames,
      {bool editMode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: editMode
              ? const {0: FixedColumnWidth(160), 2: FixedColumnWidth(110)}
              : const {0: FixedColumnWidth(160)},
          children: [
            TableRow(children: [
              _headerCell('Page'),
              _headerCell('Categories'),
              if (editMode) _headerCell('Action'),
            ]),
            TableRow(children: [
              _dataCell('Treatment page:'),
              _dataCell(treatmentNames),
              if (editMode)
                _actionCell(() {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MmsDismissibleScreen(
                      ValueKey('TreatmentLayoutEdit'),
                      PatientCaseTreatments(layoutEditMode: true),
                      scrollable: true,
                    ),
                  ));
                }),
            ]),
            TableRow(children: [
              _dataCell('Medication page:'),
              _dataCell(medicationNames),
              if (editMode)
                _actionCell(() {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MmsDismissibleScreen(
                      ValueKey('MedicationLayoutEdit'),
                      PatientCaseMedications(layoutEditMode: true),
                      scrollable: true,
                    ),
                  ));
                }),
            ]),
          ],
        ),
        if (editMode) ...[
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: MmsPaddedRaisedButton(
              'Reset to defaults',
              buttonStyle:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _confirmReset(context),
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
            ),
          ),
        ],
      ],
    );
  }

  Widget _headerCell(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _dataCell(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(text),
      );

  Widget _actionCell(VoidCallback onPressed) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: MmsPaddedRaisedButton(
          'Edit',
          onPressed: onPressed,
          top: 4,
          bottom: 4,
          left: 0,
          right: 0,
        ),
      );
}
