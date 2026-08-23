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
import 'package:flutter_ui/data/model/facility/facility.dart';
import 'package:flutter_ui/logic/facility/facility_bloc.dart';
import 'package:flutter_ui/logic/facility/facility_event.dart';
import 'package:flutter_ui/logic/facility/facility_state.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/collapsible_settings_panel.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/facilities_management/display_helpers.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/facilities_management/facility_editor.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';

class FacilityManagementPanel extends StatefulWidget {
  const FacilityManagementPanel({
    super.key,
    required this.onMarkFacilityEditing,
    required this.onRemoveFacility,
    required this.onToggleExpand,
  });

  final void Function(Facility facility) onMarkFacilityEditing;
  final void Function(Facility facility) onRemoveFacility;
  final VoidCallback onToggleExpand;

  @override
  State<FacilityManagementPanel> createState() =>
      _FacilityManagementPanelState();
}

class _FacilityManagementPanelState extends State<FacilityManagementPanel>
    with AutomaticKeepAliveClientMixin {
  bool isExpanded = false;

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      widget.onToggleExpand();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CollapsibleSettingsPanel(
      title: 'Facility Management',
      collapsedSummary: _buildCollapsedSummary(context),
      expandedContent: _buildExpandedContent(context),
      isExpanded: isExpanded,
      onToggle: _toggleExpand,
    );
  }

  Widget _buildCollapsedSummary(BuildContext context) {
    const double statusWidth = 79.0; // fixed width for the status area

    return BlocBuilder<FacilityBloc, FacilityState>(
      builder: (context, state) {
        if (state.savedFacilities.isEmpty) {
          return const Text("No Facilities added.");
        }

        final sorted = List.of(state.savedFacilities)
          ..sort((a, b) =>
              a.facilityId.toLowerCase().compareTo(b.facilityId.toLowerCase()));

        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sorted.map((facility) {
            final isActive = facility.active;
            final icon = isActive
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red);
            final label = isActive ? 'Active' : 'Inactive';
            final isMms = facility.controlledLocal;

            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  // Name + tiny micro-indicator if MMS Control
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              facility.facilityId,
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMms) const SizedBox(width: 8),
                          if (isMms)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'MMS Control',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontSize: 11,
                                  height: 1.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Status column (fixed width)
                  SizedBox(
                    width: statusWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        icon,
                        const SizedBox(width: 6),
                        const SizedBox(width: 0),
                        Text(label),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AddFacilityField(),
        const SizedBox(height: 20),
        BlocBuilder<FacilityBloc, FacilityState>(
          builder: (context, state) {
            return _FacilityTable(
              facilities: state.savedFacilities,
              onToggleMms: (id, on) {
                final fac =
                    state.savedFacilities.firstWhere((f) => f.facilityId == id);
                final updated = fac.copyWith(controlledLocal: on);
                context.read<FacilityBloc>().add(UpdateFacility(updated));
              },
              onMarkFacilityEditing: widget.onMarkFacilityEditing,
              onRemoveFacility: widget.onRemoveFacility,
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _AddFacilityField extends StatefulWidget {
  @override
  State<_AddFacilityField> createState() => _AddFacilityFieldState();
}

class _AddFacilityFieldState extends State<_AddFacilityField> {
  final _controller = TextEditingController();

  void _addFacility() {
    final facilityId = _controller.text.trim();
    if (facilityId.isNotEmpty) {
      context.read<FacilityBloc>().add(AddFacility(facilityId));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12.0, right: 2.0),
            child: Text("New Facility Name: "),
          ),
          SizedBox(
            width: 240,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _addFacility(),
            ),
          ),
          SizedBox(
            height: 48,
            child: MmsPaddedRaisedButton(
              "Add",
              onPressed: _addFacility,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityTable extends StatelessWidget {
  final List<Facility> facilities;
  final void Function(String id, bool on) onToggleMms;
  final void Function(Facility facility) onMarkFacilityEditing;
  final void Function(Facility facility) onRemoveFacility;

  const _FacilityTable({
    required this.facilities,
    required this.onToggleMms,
    required this.onMarkFacilityEditing,
    required this.onRemoveFacility,
  });

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) return const Text('No facilities to display.');

    const double kToggleColWidth = 72.0; // width for a switch
    const double kActionsColWidth = 240.0; // Edit (100) + Remove (120) + gaps
    final sortedFacilities = List.of(facilities)
      ..sort((a, b) =>
          a.facilityId.toLowerCase().compareTo(b.facilityId.toLowerCase()));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              horizontalMargin: 12,
              columnSpacing: 16,
              columns: const [
                DataColumn(
                  label: Text('Facility',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Role',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Type',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Capacity',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: SizedBox(
                    width: kToggleColWidth,
                    child: Text(
                      'MMS Control',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    child: Text(
                      '    Active',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: SizedBox(
                    width: kActionsColWidth,
                    child: Text('  Actions',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              rows: sortedFacilities.map((facility) {
                return DataRow(cells: [
                  // Facility
                  DataCell(
                    SizedBox(
                      child: Text(
                        facility.facilityId,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(displayRoleOfCare(facility.roleOfCare))),
                  DataCell(Text(displayFacilityType(facility.facilityType))),
                  DataCell(Text('${facility.capacity}')),
                  // MMS Control
                  DataCell(
                    SizedBox(
                      width: kToggleColWidth,
                      child: Switch(
                        value: facility.controlledLocal,
                        onChanged: (val) {
                          final updated =
                              facility.copyWith(controlledLocal: val);
                          context
                              .read<FacilityBloc>()
                              .add(UpdateFacility(updated));
                        },
                      ),
                    ),
                  ),
                  // Active (toggle)
                  DataCell(
                    SizedBox(
                      width: kToggleColWidth,
                      child: Switch(
                        value: facility.active,
                        onChanged: (val) {
                          final updated = facility.copyWith(active: val);
                          context
                              .read<FacilityBloc>()
                              .add(UpdateFacility(updated));
                        },
                      ),
                    ),
                  ),
                  // Actions
                  DataCell(
                    SizedBox(
                      width: kActionsColWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 100,
                            child: MmsPaddedRaisedButton(
                              "Edit",
                              left: 0,
                              top: 0,
                              bottom: 0,
                              onPressed: () {
                                final editorKey =
                                    GlobalKey<FacilityEditorState>();
                                onMarkFacilityEditing(facility);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MmsDismissibleScreen(
                                    const ValueKey(
                                        "FacilityEditorScreenDismissible"),
                                    FacilityEditor(key: editorKey),
                                    scrollable: true,
                                    onAttemptDismiss: () async =>
                                        await editorKey.currentState
                                            ?.validateBeforeDismiss() ??
                                        true,
                                  ),
                                ));
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: MmsPaddedRaisedButton(
                              "Remove",
                              top: 0,
                              bottom: 0,
                              onPressed: () => onRemoveFacility(facility),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
