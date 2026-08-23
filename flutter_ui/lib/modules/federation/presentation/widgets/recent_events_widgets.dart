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

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/config.dart';
import 'package:flutter_ui/data/model/patients/patients_model.dart';
import 'package:flutter_ui/data/model/recent_events/recent_events_model.dart';
import 'package:flutter_ui/data/services/unstructured_data_stores.dart';
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/presentation/state/source_color_cubit.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/icons/text_and_or_icon.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/presentation/widgets/layouts/sized_labeled_text_row.dart';
import 'package:provider/provider.dart'; // for Selector

class RecentEventsPanel extends StatefulWidget {
  const RecentEventsPanel({super.key});

  @override
  State<RecentEventsPanel> createState() => _RecentEventsPanelState();
}

class _RecentEventsPanelState extends State<RecentEventsPanel> {
  String selectedPatientId = "";
  int expandVersion = 0;
  bool expandAll = false;

  void setFilter(String id) {
    setState(() {
      selectedPatientId = id;
      expandAll = false; // Reset expansion state
      expandVersion++; // Force rebuild of ConfigurableExpansionTile
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<RecentEventsStoreAccess, List<RecentEventsModel>>(
      selector: (_, access) => access.store.eventsList,
      shouldRebuild: (prev, next) => !const ListEquality().equals(prev, next),
      builder: (context, eventsList, _) {
        // The set of allowed patient IDs (same logic as RecentEventsWidget)
        final allowedIds =
            context.select<PatientManagementBloc, Set<String>>((bloc) {
          final aarEnabled =
              PrimitivesStore().boolData(Config.aarParm, Config.appWideKey);
          return aarEnabled
              ? PatientInfoStore().patientIds.toSet()
              : bloc.state.patients.map((p) => p.id).toSet();
        });

        // Only include IDs that exist in PatientManagementBloc / PatientInfoStore
        final uniquePatientIds = eventsList
            .where((e) => allowedIds.contains(e.patientId))
            .map((e) => e.patientId)
            .toSet()
            .toList()
          ..sort();

        return MmsStylablePanel(
          rounding: 20,
          captionContent: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(width: 15),
                    IconButton(
                      padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.open_in_full,
                        size: 16,
                        color: Colors.black87,
                      ),
                      tooltip: "Expand All",
                      onPressed: () {
                        setState(() {
                          expandAll = true;
                          expandVersion++;
                        });
                      },
                    ),
                    IconButton(
                      padding: const EdgeInsets.fromLTRB(2, 8, 8, 8),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.close_fullscreen,
                        size: 16,
                        color: Colors.black87,
                      ),
                      tooltip: "Collapse All",
                      onPressed: () {
                        setState(() {
                          expandAll = false;
                          expandVersion++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: MmsText(
                  "Recent Events",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      alignment: Alignment.centerRight,
                      value:
                          selectedPatientId.isEmpty ? null : selectedPatientId,
                      hint: const Text(
                        "All",
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.black),
                      ),
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        setFilter(newValue ?? "");
                      },
                      items: [
                        const DropdownMenuItem(value: "", child: Text("All")),
                        ...uniquePatientIds.map(
                          (id) => DropdownMenuItem(value: id, child: Text(id)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    if (selectedPatientId.isNotEmpty)
                      GestureDetector(
                        onTap: () => setFilter(""),
                        child: const Icon(
                          Icons.filter_alt,
                          size: 20,
                          color: Colors.black87,
                        ),
                      )
                    else
                      const Icon(
                        Icons.filter_alt_outlined,
                        size: 20,
                        color: Colors.black87,
                      ),
                    const SizedBox(width: 25),
                  ],
                ),
              ),
            ],
          ),
          captionBarColor: MmsColors.white,
          captionTextColor: MmsColors.black,
          panelBgColor: MmsColors.white,
          widget: RecentEventsWidget(
            patientIdFilter: selectedPatientId,
            expandAll: expandAll,
            expandVersion: expandVersion,
          ),
        );
      },
    );
  }
}

class RecentEventsWidget extends StatefulWidget {
  final String patientIdFilter;
  final String typeFilter;
  final EdgeInsetsGeometry padding;
  final double? height;
  final bool expandAll;
  final int expandVersion;

  const RecentEventsWidget({
    super.key,
    this.patientIdFilter = "",
    this.typeFilter = "",
    this.height,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 8),
    this.expandAll = false,
    this.expandVersion = 0,
  });

  @override
  _RecentEventsWidgetState createState() => _RecentEventsWidgetState();
}

class _RecentEventsWidgetState extends State<RecentEventsWidget> {
  // Track which rows are expanded, keyed by the stable event.id (as String)
  final Set<String> _expanded = <String>{};

  // Detect presses of Expand All / Collapse All from the parent
  int _lastExpandVersion = -1;

  // Single source of truth for row identity (prevents the lock-up bug)
  String _rowKey(RecentEventsModel e) => e.dedupeKey;

  Widget _leadingChevron(bool open) {
    return Container(
      // same height as your header row, and a touch of left margin
      width: 24, height: 24, margin: const EdgeInsets.only(left: 6),
      alignment: Alignment.center,
      color: open ? MmsColors.ltGreen : MmsColors.white,
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 150),
        turns: open ? 0.5 : 0.0, // rotate 180° when open
        child: Icon(
          Icons.expand_more,
          size: 18,
          color: Theme.of(context).colorScheme.primary, // same blue as links
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use provided height if set, otherwise subtract padding or offset
          final containerHeight = widget.height ??
              (constraints.maxHeight - 12).clamp(200, double.infinity);

          return Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.zero,
            height: containerHeight,
            child: Selector<RecentEventsStoreAccess, List<RecentEventsModel>>(
              selector: (buildContext, access) => access.store.eventsList,
              shouldRebuild: (prev, next) =>
                  !const ListEquality().equals(prev, next),
              builder: (context, eventsList, _) {
                final patientBloc = context.read<PatientManagementBloc>();
                final aarEnabled = PrimitivesStore()
                    .boolData(Config.aarParm, Config.appWideKey);

                final List<String> patientIds = aarEnabled
                    ? PatientInfoStore().patientIds
                    : patientBloc.state.patients.map((p) => p.id).toList();

                // Filter once
                final filtered = <RecentEventsModel>[
                  for (final e in eventsList)
                    if (patientIds.contains(e.patientId) &&
                        (widget.patientIdFilter.isEmpty ||
                            widget.patientIdFilter == e.patientId) &&
                        (widget.typeFilter.isEmpty ||
                            widget.typeFilter == e.type))
                      e
                ];

                // Apply expand-all / collapse-all only when the panel buttons were pressed
                if (_lastExpandVersion != widget.expandVersion) {
                  final ids = filtered.map(_rowKey);
                  if (widget.expandAll) {
                    _expanded.addAll(ids); // expand all filtered rows
                  } else {
                    _expanded.removeAll(ids); // collapse just the filtered rows
                  }
                  _lastExpandVersion = widget.expandVersion;
                }

                return ListView.builder(
                  key: const PageStorageKey<String>("recent-events-list"),
                  padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final event = filtered[i];
                    final keyString = _rowKey(event);
                    final bool isOpen = _expanded.contains(keyString);
                    // constants that describe the space before the title
                    const double _padLeft = 6.0; // tilePadding left
                    const double _minLead =
                        16.0; // listTileTheme.minLeadingWidth
                    const double _titleGap =
                        6.0; // listTileTheme.horizontalTitleGap
                    const double _leadBleed = _padLeft + _minLead + _titleGap;

                    return KeyedSubtree(
                      key: ValueKey<String>(
                          "$keyString-${widget.expandVersion}"),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          visualDensity:
                              const VisualDensity(horizontal: -4, vertical: -4),
                          listTileTheme: const ListTileThemeData(
                            dense: true,
                            minLeadingWidth: 24,
                            horizontalTitleGap: 6,
                            minVerticalPadding: 0,
                          ),
                        ),
                        child: ExpansionTile(
                          // tie the storage bucket to the mass-toggle version
                          key: PageStorageKey<String>(
                              "exp-$keyString-v${widget.expandVersion}"),
                          maintainState: true,
                          initiallyExpanded: isOpen,

                          // we supply our own chevron and remove the default trailing one
                          leading: _leadingChevron(isOpen),
                          trailing: const SizedBox.shrink(),

                          // keep the tile surface white so nothing bleeds under the child
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          backgroundColor: MmsColors.white,
                          collapsedBackgroundColor: MmsColors.white,
                          shape: const RoundedRectangleBorder(
                              side: BorderSide.none),
                          collapsedShape: const RoundedRectangleBorder(
                              side: BorderSide.none),

                          // HEADER
                          title: Stack(
                            fit: StackFit.passthrough,
                            children: [
                              // color only the title area; chevron area is handled by `leading`
                              Positioned.fill(
                                child: ColoredBox(
                                  color: isOpen
                                      ? MmsColors.ltGreen
                                      : MmsColors.white,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double labelW =
                                        widget.patientIdFilter.isEmpty
                                            ? 120.0
                                            : 0.0;
                                    const double timeW = 70.0;
                                    const double typeW = 140.0;
                                    // tighter paddings so the row fits narrower widths
                                    const double padHLabel = 4.0;
                                    const double padHText = 4.0;
                                    const double paddingBudget =
                                        (padHLabel * 2) + (padHText * 2) * 3;

                                    final double remaining =
                                        (constraints.maxWidth -
                                                paddingBudget -
                                                labelW -
                                                timeW -
                                                typeW)
                                            .clamp(0.0, double.infinity);

                                    final neighborId = i > 0
                                        ? filtered[i - 1].patientId
                                        : null;
                                    final start = math.max(0, i - 24);
                                    final end =
                                        math.min(filtered.length, i + 24);
                                    final visibleIds = filtered
                                        .sublist(start, end)
                                        .map((e) => e.patientId)
                                        .toList();

                                    return MmsSizedLabeledTextRow(
                                      widget.patientIdFilter.isEmpty
                                          ? event.patientId
                                          : "",
                                      TextAndOrIcon.convertTextList([
                                        event.timeStr,
                                        widget.typeFilter.isNotEmpty
                                            ? ""
                                            : (event.type ==
                                                    "INSTRUCTOR_OBSERVATION"
                                                ? "OBSERVATION"
                                                : event.type),
                                        event.notesOrLearnerAction,
                                      ]),
                                      labelWidth: labelW,
                                      textWidths: <double>[
                                        timeW,
                                        typeW,
                                        remaining
                                      ],
                                      height: 24.0,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      overrideTextColor: context
                                          .read<SourceColorCubit>()
                                          .colorFor(
                                            event.patientId,
                                            neighborId: neighborId,
                                            visibleIds: visibleIds,
                                          ),
                                      labelPadding: const EdgeInsets.symmetric(
                                          horizontal: padHLabel),
                                      textPadding: const EdgeInsets.symmetric(
                                          horizontal: padHText),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          onExpansionChanged: (open) {
                            setState(() {
                              if (open) {
                                _expanded.add(keyString);
                              } else {
                                _expanded.remove(keyString);
                              }
                            });
                          },

                          // BODY stays white; no green hairline
                          children: [
                            Container(
                              color: MmsColors.white,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 12, 6, 12),
                                      child: MmsText(
                                        event.type == "LEARNER_ACTION"
                                            ? event.notesAndDescription
                                            : (event.description ?? ""),
                                        softWrap: true,
                                        maxLines: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
