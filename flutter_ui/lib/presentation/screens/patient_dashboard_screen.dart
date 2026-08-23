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
import 'package:flutter_ui/data/model/vitals/vitals_model.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_event.dart';
import 'package:flutter_ui/logic/facility/facility_bloc.dart';
import 'package:flutter_ui/logic/facility/facility_event.dart';
import 'package:flutter_ui/logic/facility/facility_state.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/modules/treatments/presentation/widgets/last_treatment_label_widget.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_bloc.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_state.dart';
import 'package:flutter_ui/presentation/screens/display_helpers.dart';
import 'package:provider/provider.dart';

// Sizing constants
const double cardWidth = 165.0;
const double cardHeight = 210.0;
const double cardSpacing = 14.0;
const int maxColumns = 3;
const double panelHorizontalPadding = 18.0;
const double facilitiesPanelWidth = 240.0;
const double patientsPanelPanelPadding = 12.0;

// Panel heights (adjust as needed)
const double patientsPanelMaxHeight = 2 * cardHeight +
    cardSpacing +
    2 * patientsPanelPanelPadding -
    20; // 2 rows + 1 spacing + top/bottom padding
const double facilitiesPanelMaxHeight = patientsPanelMaxHeight;

class PatientDashboardScreen extends StatefulWidget {
  final List<Patient> patientList;
  final Function(String) onPatientTap;

  /// Call this to navigate to Settings from the empty state.
  final VoidCallback? onAddPatientsTap;

  const PatientDashboardScreen(
    this.patientList,
    this.onPatientTap, {
    super.key,
    this.onAddPatientsTap,
  });

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  late final _patientsCtrl = ScrollController();
  late final _facilitiesCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fire once after first frame so context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacilityBloc>().add(const LoadHlaFacilities());
      // kicks off a polling loop at the repository layer to get new facilities and priorities from the backend
      // UI will update automatically when/if repository layer is modified
      context.read<CasualtyStateBloc>().add(const StartWatchingCasualtyStates(
            interval: Duration(seconds: 5),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patientList.isEmpty) {
      return Scaffold(
        backgroundColor: MmsColors.mainBodyBackgroundColor,
        body: Center(
          child: _EmptyPatientsPlaceholder(
            onAddPatientsTap: widget.onAddPatientsTap,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MmsColors.mainBodyBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final totalHeight = constraints.maxHeight;

            // Ensure columns never reads patientList.length when empty
            final int maxColsPossible =
                widget.patientList.isEmpty ? 1 : widget.patientList.length;

            // quantized patients panel width
            int columns = ((totalWidth - facilitiesPanelWidth - 12) /
                    (cardWidth + cardSpacing))
                .floor()
                .clamp(1, maxColsPossible);

            double patientsPanelWidth;

            while (true) {
              patientsPanelWidth = (columns * cardWidth) +
                  ((columns - 1) * cardSpacing) +
                  (panelHorizontalPadding * 2) +
                  8;

              final totalUsed = patientsPanelWidth + 12 + facilitiesPanelWidth;

              if (totalUsed <= totalWidth || columns == 1) {
                break;
              }

              columns--;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Patients Panel
                SizedBox(
                  width: patientsPanelWidth,
                  child: MmsRoundedBarlessPanel(
                    caption: "Patients",
                    padding: const EdgeInsets.all(12),
                    widget: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: totalHeight,
                      ),
                      child: Scrollbar(
                        controller: _patientsCtrl,
                        child: SingleChildScrollView(
                          controller: _patientsCtrl,
                          child: _PatientCardsGridResponsive(
                            patients: widget.patientList,
                            onPatientTap: widget.onPatientTap,
                            columns: columns,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// Facilities Panel
                SizedBox(
                  width: facilitiesPanelWidth,
                  child: MmsRoundedBarlessPanel(
                    caption: "Facilities",
                    padding: const EdgeInsets.all(12),
                    widget: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: totalHeight,
                      ),
                      child: Scrollbar(
                        controller: _facilitiesCtrl,
                        child: SingleChildScrollView(
                            controller: _facilitiesCtrl,
                            child: BlocBuilder<FacilityBloc, FacilityState>(
                              builder: (context, facilityState) {
                                return BlocBuilder<CasualtyStateBloc,
                                    CasualtyStateState>(
                                  builder: (context, csState) {
                                    // Patients visible on this screen (only count these)
                                    final onScreen = widget.patientList
                                        .map((p) => p.id)
                                        .toSet();

                                    // Count patients per facilityId using casualtyState
                                    final counts = <String, int>{};
                                    final assignedPatients = <String>{};

                                    for (final cs
                                        in csState.allCasualtyStates) {
                                      if (!onScreen.contains(cs.patientId)) {
                                        continue;
                                      }
                                      final fid = (cs.facilityId ?? '').trim();
                                      if (fid.isEmpty) {
                                        continue; // treat empty as unassigned
                                      }
                                      counts[fid] = (counts[fid] ?? 0) + 1;
                                      assignedPatients.add(cs.patientId);
                                    }

                                    final unassignedCount = (onScreen.length -
                                            assignedPatients.length)
                                        .clamp(0, 1 << 31);

                                    // Sort HLA facilities by id for display
                                    final hla =
                                        List.of(facilityState.hlaFacilities)
                                          ..sort((a, b) => a.facilityId
                                              .toLowerCase()
                                              .compareTo(
                                                  b.facilityId.toLowerCase()));

                                    final children = <Widget>[];

                                    if (facilityState.isLoadingHla) {
                                      children.add(const Center(
                                          child: CircularProgressIndicator()));
                                    } else if (hla.isEmpty) {
                                      children.add(
                                          const Text('No HLA facilities.'));
                                    } else {
                                      for (final f in hla) {
                                        children.addAll([
                                          FacilityCard(
                                            name: f
                                                .facilityId, // or f.instanceName ?? f.facilityId
                                            count: counts[f.facilityId] ?? 0,
                                          ),
                                          const SizedBox(height: 12),
                                        ]);
                                      }
                                      if (children.isNotEmpty &&
                                          children.last is SizedBox) {
                                        children
                                            .removeLast(); // trim trailing spacer
                                      }
                                    }

                                    if (children.isNotEmpty) {
                                      children.add(const SizedBox(height: 12));
                                    }
                                    // Unassigned LAST
                                    children.add(FacilityCard(
                                        name: 'Unassigned',
                                        count: unassignedCount));

                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: children);
                                  },
                                );
                              },
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _patientsCtrl.dispose();
    _facilitiesCtrl.dispose();
    super.dispose();
  }
}

/// Simple, brand-friendly placeholder for the empty state.
/// Includes a button to navigate to Settings to add patients.
class _EmptyPatientsPlaceholder extends StatelessWidget {
  final VoidCallback? onAddPatientsTap;

  const _EmptyPatientsPlaceholder({this.onAddPatientsTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'No patients',
      hint: 'Press Add patients to open Settings',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 72, color: Colors.white70),
          const SizedBox(height: 16),
          const Text(
            'No patients available',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add patients in Settings to get started.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 20),
          MmsPaddedRaisedButton(
            'Add patients',
            onPressed: onAddPatientsTap, // navigates to Settings
          ),
        ],
      ),
    );
  }
}

// Responsive, fixed-size patient grid, up to 3 columns, no resizing
class _PatientCardsGridResponsive extends StatelessWidget {
  final List<Patient> patients;
  final Function(String) onPatientTap;
  final int columns;

  const _PatientCardsGridResponsive({
    required this.patients,
    required this.onPatientTap,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    // Make a sorted copy of patients (case-insensitive by name)
    final sortedPatients = [...patients]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    // Build rows: split patients into groups of [columns]
    List<List<Patient>> rows = [];
    for (int i = 0; i < sortedPatients.length; i += columns) {
      rows.add(sortedPatients.sublist(
        i,
        (i + columns > sortedPatients.length)
            ? sortedPatients.length
            : i + columns,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int r = 0; r < rows.length; r++)
          Padding(
            padding:
                EdgeInsets.only(bottom: r == rows.length - 1 ? 0 : cardSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < rows[r].length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                        right: i < rows[r].length - 1 ? cardSpacing : 0),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: InkWell(
                        onTap: () => onPatientTap(rows[r][i].id),
                        child: PatientCard(patient: rows[r][i]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    const double gap = 7.0;

    return Card(
      color: MmsColors.mainBodyBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 3),
              // Displays patient name and optional case name
              BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
                builder: (context, caseState) {
                  final caseName = caseState.patientCases
                      .firstWhereOrNull(
                          (pc) => pc.caseNum == patient.patientCaseNum)
                      ?.name;

                  final displayName = caseName != null
                      ? '${patient.name} ($caseName)'
                      : patient.name;

                  return Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  );
                },
              ),
              const SizedBox(height: gap),
              const _SectionDivider(),
              const SizedBox(height: gap + 3),
              // Vital signs row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: _VitalsSection(patient.id),
              ),
              const SizedBox(height: gap + 3),
              const _SectionDivider(),
              const SizedBox(height: gap),
              BlocBuilder<CasualtyStateBloc, CasualtyStateState>(
                builder: (context, csState) {
                  final cs = csState.getByPatientId(patient.id);

                  // Facility label (fallback to Unassigned)
                  final facilityLabel =
                      (cs?.facilityId?.trim().isNotEmpty == true)
                          ? cs!.facilityId
                          : 'Unassigned';

                  // Map backend enum -> UI string via mapper
                  final evacUi = evacuationPriorityMapper
                      .toUi((cs?.evacuationPriority ?? '').toString());
                  final evacLabel = evacUi.trim().isEmpty ? '--' : evacUi;

                  return Column(
                    children: [
                      // Facility
                      Text(
                        facilityLabel,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      const SizedBox(height: 7.0),
                      const _SectionDivider(),
                      const SizedBox(height: 7.0),

                      // Evacuation priority (only)
                      Text(
                        evacLabel,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: gap),
              const _SectionDivider(),
              const SizedBox(height: gap),
              // Last treatment info
              LastTreatmentLabelWidget(patient.id,
                  textAlign: TextAlign.center,
                  textStyle:
                      const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalsSection extends StatelessWidget {
  final String patientId;

  const _VitalsSection(this.patientId);

  @override
  Widget build(BuildContext context) {
    return Selector<VitalsValuesStoreAccess, VitalsValues>(
        selector: (_, access) => access.store.getVitalsValues(patientId),
        shouldRebuild: (prev, next) => prev != next,
        builder: (context, vitals, _) {
          final ekg = vitals.ekg?.toStringAsFixed(0) ?? '--';
          final rr = vitals.rr?.toStringAsFixed(0) ?? '--';
          final hi = vitals.bpHi?.toStringAsFixed(0);
          final lo = vitals.bpLo?.toStringAsFixed(0);
          final bp = (hi != null && lo != null) ? '$hi/$lo' : '--';

          // converts C→F when temp < 50
          final temp =
              vitals.tempFahrenheitForDisplay?.toStringAsFixed(1) ?? '--';

          // Converts fractional SpO2 (0 < value < 1) to percent (0 < value < 100),
          // then we format (round) to 0 decimals.
          final spo2 = vitals.spo2ForDisplay?.toStringAsFixed(0) ?? '--';

          final etco2 = vitals.etco2?.toStringAsFixed(0) ?? '--';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            child: Column(
              children: [
                _vitalRow(
                  Text(
                    '$ekg bpm',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF399A1D),
                    ),
                  ),
                  Text(
                    'RR $rr',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFEA3B),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                _vitalRow(
                  Text(
                    bp,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF0000),
                    ),
                  ),
                  Text(
                    '$temp F',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC964FA),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                _vitalRow(
                  Text(
                    '$spo2%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F4),
                    ),
                  ),
                  Text(
                    'EtCO2 $etco2',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5D00),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _vitalRow(Widget left, Widget right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        left,
        right,
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.white.withAlpha((0.15 * 255).round()), // ≈ 38
    );
  }
}

class FacilityCard extends StatelessWidget {
  final String name;
  final int count;

  const FacilityCard({super.key, required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MmsColors.mainBodyBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            const _SectionDivider(),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "$count Patient${count != 1 ? 's' : ''}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
