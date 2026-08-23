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
import 'package:flutter_ui/data/model/casualty_state/casualty_state.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_bloc.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_event.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_state.dart';
import 'package:flutter_ui/logic/facility/facility_bloc.dart';
import 'package:flutter_ui/logic/facility/facility_event.dart';
import 'package:flutter_ui/logic/facility/facility_state.dart';
import 'package:flutter_ui/presentation/screens/display_helpers.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger(
  "CasualtyStateDashboardWidget",
  debugging: true,
);

class CasualtyStateDashboardWidget extends StatefulWidget {
  final String patientId;
  const CasualtyStateDashboardWidget({required this.patientId, super.key});

  @override
  _CasualtyStateDashboardWidgetState createState() =>
      _CasualtyStateDashboardWidgetState();
}

class _CasualtyStateDashboardWidgetState
    extends State<CasualtyStateDashboardWidget> {
  @override
  void initState() {
    super.initState();
    context.read<FacilityBloc>().add(const LoadSavedFacilities());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CasualtyStateBloc>()
          .add(const StartWatchingCasualtyStates());
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final editorKey = GlobalKey<_CasualtyStateEditorScreenState>();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MmsDismissibleScreen(
            const ValueKey("CasualtyStateEditorScreenDismissible"),
            CasualtyStateEditorScreen(
                key: editorKey, patientId: widget.patientId),
            scrollable: true,
            onAttemptDismiss: () async =>
                await editorKey.currentState?.validateBeforeDismiss() ?? true,
          ),
        ));
      },
      child: MmsRoundedBarlessPanel(
        width: 300,
        caption: "Casualty State",
        widget: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: BlocBuilder<CasualtyStateBloc, CasualtyStateState>(
            builder: (context, state) {
              final casualty = state.getByPatientId(widget.patientId);

              if (state.isLoading && casualty == null) {
                return const CircularProgressIndicator();
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      'Evac: ${casualty != null ? evacuationPriorityMapper.toUi(casualty.evacuationPriority) : '-'}'),
                  const SizedBox(height: 4),
                  const Divider(thickness: 1, color: MmsColors.black),
                  const SizedBox(height: 4),

                  // Triage label tweak:
                  Text(
                      'Triage: ${casualty != null ? triageClassificationMapper.toUi(casualty.triageClassification) : '-'}'),
                  const SizedBox(height: 4),
                  const Divider(thickness: 1, color: MmsColors.black),
                  const SizedBox(height: 4),

                  // Facility with "unavailable" detection (uses FacilityBloc)
                  BlocBuilder<FacilityBloc, FacilityState>(
                    builder: (context, fState) {
                      final id = casualty?.facilityId ?? '';

                      // Consider only active facilities (remove the .where(...) if you want inactive to count as available)
                      final activeIds = fState.savedFacilities
                          .where((f) => f.active == true)
                          .map((f) => f.facilityId)
                          .toSet();

                      final hasValue = id.isNotEmpty;
                      final isMissing = hasValue && !activeIds.contains(id);

                      final display = !hasValue
                          ? '-'
                          : isMissing
                              ? '$id (unavailable)'
                              : id;

                      return Text(
                        'Facility: $display',
                        style: TextStyle(
                          color: isMissing ? Colors.red : null,
                          fontWeight: isMissing ? FontWeight.w600 : null,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CasualtyStateEditorScreen extends StatefulWidget {
  final String patientId;
  const CasualtyStateEditorScreen({required this.patientId, super.key});

  @override
  State<CasualtyStateEditorScreen> createState() =>
      _CasualtyStateEditorScreenState();
}

class _CasualtyStateEditorScreenState extends State<CasualtyStateEditorScreen> {
  // Local UI selections (nullable to enable hint text)
  String? _evacUi; // e.g., "Urgent"
  String? _triageUi; // e.g., "Immediate"
  String? _facilityUi; // e.g., "CSH"

  // Dirty flags: did the user change anything?
  bool _dirtyEvac = false;
  bool _dirtyTriage = false;
  bool _dirtyFacility = false;

  bool _saving = false; // prevent double-save while dismissing

  @override
  Widget build(BuildContext context) {
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
        child: BlocBuilder<CasualtyStateBloc, CasualtyStateState>(
          builder: (context, state) {
            final existing = state.getByPatientId(widget.patientId);
            final caption = 'Casualty State Editor - ${widget.patientId}';

            // Lazy-init UI values from existing once
            if (existing != null) {
              _evacUi ??=
                  evacuationPriorityMapper.toUi(existing.evacuationPriority);
              _triageUi ??= triageClassificationMapper
                  .toUi(existing.triageClassification);
              _facilityUi ??=
                  (existing.facilityId.isNotEmpty ? existing.facilityId : null);
            }

            if (state.isLoading && state.allCasualtyStates.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final isFirstTime = existing == null;

            return MmsRoundedBarlessPanel(
              caption: caption,
              widget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDropdownCard(
                        title: 'Evacuation Priority',
                        value: _safeValue(
                          _evacUi ??
                              (existing != null
                                  ? evacuationPriorityMapper
                                      .toUi(existing.evacuationPriority)
                                  : null),
                          evacuationPriorityMapper.uiValues,
                        ),
                        hint: const Text('Select a Priority'),
                        options: evacuationPriorityMapper.uiValues,
                        onChanged: (v) => setState(() {
                          _evacUi = v;
                          _dirtyEvac = true;
                        }),
                      ),
                      _buildDropdownCard(
                        title: 'Triage Classification',
                        value: _safeValue(
                          _triageUi ??
                              (existing != null
                                  ? triageClassificationMapper
                                      .toUi(existing.triageClassification)
                                  : null),
                          triageClassificationMapper.uiValues,
                        ),
                        hint: const Text('Select a Classification'),
                        options: triageClassificationMapper.uiValues,
                        onChanged: (v) => setState(() {
                          _triageUi = v;
                          _dirtyTriage = true;
                        }),
                      ),
                      BlocBuilder<FacilityBloc, FacilityState>(
                        builder: (context, fState) {
                          // Build the list of selectable facilityIds (filter to active if desired)
                          final facilityIds = fState.savedFacilities
                              .where((f) =>
                                  f.active ==
                                  true) // remove this filter if you want inactive too
                              .map((f) => f.facilityId)
                              .toList()
                            ..sort((a, b) =>
                                a.toLowerCase().compareTo(b.toLowerCase()));

                          // What should the dropdown try to show right now?
                          // Prefer the user’s local selection; fall back to the existing record’s facilityId.
                          final existing = context
                              .read<CasualtyStateBloc>()
                              .state
                              .getByPatientId(widget.patientId);
                          final current = _facilityUi ??
                              ((existing != null &&
                                      existing.facilityId.isNotEmpty)
                                  ? existing.facilityId
                                  : null);

                          final isMissing =
                              current != null && !facilityIds.contains(current);

                          // Build items, including a disabled "unavailable" entry if needed so there's exactly one match.
                          final items = <DropdownMenuItem<String>>[
                            if (isMissing)
                              DropdownMenuItem<String>(
                                value: current,
                                enabled: false,
                                child: Text('$current (unavailable)',
                                    style: const TextStyle(color: Colors.red)),
                              ),
                            ...facilityIds.map(
                              (id) => DropdownMenuItem<String>(
                                value: id,
                                child: Text(id),
                              ),
                            ),
                          ];

                          // The dropdown's value must exist in items exactly once.
                          final dropdownValue =
                              current; // works because we injected the missing item when needed

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            child: Container(
                              width: 220,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text('Facility',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  DropdownButton<String>(
                                    value: dropdownValue,
                                    isExpanded: true,
                                    hint: const Text('Select a Facility'),
                                    items: items,
                                    onChanged: (v) {
                                      // if user taps the disabled "(unavailable)" item, v==current but enabled=false prevents call
                                      setState(() {
                                        _facilityUi =
                                            v; // will be one of facilityIds
                                        _dirtyFacility = true;
                                      });
                                    },
                                  ),
                                  if (isMissing) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Previously selected facility is no longer available. Please choose another.',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFirstTime
                        ? 'Select required fields (Evacuation Priority + Triage Classification) before closing if you make changes.'
                        : 'Changes will be saved when you close.',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _safeValue(String? value, List<String> options) {
    if (value == null) return null;
    return options.contains(value) ? value : null;
  }

  /// Called by MmsDismissibleScreen.onAttemptDismiss via GlobalKey.
  Future<bool> validateBeforeDismiss() async {
    final state = context.read<CasualtyStateBloc>().state;
    final existing = state.getByPatientId(widget.patientId);

    final anyDirty = _dirtyEvac || _dirtyTriage || _dirtyFacility;

    // 1) No change => allow dismiss, no API calls
    if (!anyDirty) return true;

    // 2) Changed something => enforce required fields
    final evacOk = _evacUi != null || existing != null;
    final triageOk = _triageUi != null || existing != null;

    if (!evacOk || !triageOk) {
      _snack(
          'Please select Evacuation Priority and Triage Classification before closing.');
      return false;
    }

    // 3) Save once (POST first-time, PUT existing)
    if (_saving) return false;
    _saving = true;
    try {
      if (existing == null) {
        await _postFirstTime();
      } else {
        await _putOnce(existing);
      }
      return true;
    } finally {
      _saving = false;
    }
  }

  Future<void> _postFirstTime() async {
    // _evacUi and _triageUi are guaranteed non-null by validation
    final cs = CasualtyState(
      id: "", // server assigns
      patientId: widget.patientId,
      evacuationPriority: evacuationPriorityMapper.toBackend(_evacUi!),
      triageClassification: triageClassificationMapper.toBackend(_triageUi!),
      facilityId: _facilityUi ?? "",
    );
    context.read<CasualtyStateBloc>().add(CreateCasualtyState(cs));
    // Optionally wait for the bloc roundtrip; tiny delay is fine for UX smoothness
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _putOnce(CasualtyState existing) async {
    final merged = existing.copyWith(
      evacuationPriority: _evacUi != null
          ? evacuationPriorityMapper.toBackend(_evacUi!)
          : existing.evacuationPriority,
      triageClassification: _triageUi != null
          ? triageClassificationMapper.toBackend(_triageUi!)
          : existing.triageClassification,
      facilityId: _facilityUi ?? existing.facilityId,
    );
    context.read<CasualtyStateBloc>().add(UpdateCasualtyState(merged));
    await Future.delayed(const Duration(milliseconds: 50));
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Widget _buildDropdownCard({
    required String title,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? value,
    Widget? hint,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.grey),
      ),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: hint,
              items: options
                  .map((opt) => DropdownMenuItem(
                        value: opt,
                        child: Text(opt),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
