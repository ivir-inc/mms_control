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
import 'package:flutter_ui/data/model/patient_injury/patient_injury.dart';
import 'package:flutter_ui/logic/injury/injury_bloc.dart';
import 'package:flutter_ui/logic/injury/injury_event.dart';
import 'package:flutter_ui/logic/injury/injury_state.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_injury_editor.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';

class InjuriesDashboardWidget extends StatefulWidget {
  final String patientId;
  const InjuriesDashboardWidget({required this.patientId, super.key});

  @override
  State<InjuriesDashboardWidget> createState() =>
      _InjuriesDashboardWidgetState();
}

class _InjuriesDashboardWidgetState extends State<InjuriesDashboardWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InjuryBloc>().add(LoadPatientInjuries(widget.patientId));
    });
  }

  @override
  void didUpdateWidget(covariant InjuriesDashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<InjuryBloc>().add(LoadPatientInjuries(widget.patientId));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MmsDismissibleScreen(
            ValueKey('InjuriesScreenDismissible-${widget.patientId}'),
            PatientInjuriesScreen(patientId: widget.patientId),
            scrollable: true,
          ),
        ));
      },
      child: MmsRoundedBarlessPanel(
        width: 300,
        height: 95,
        caption: 'Injuries',
        widget: BlocBuilder<InjuryBloc, InjuryState>(
          builder: (context, state) {
            final injuries = state.forPatient(widget.patientId);
            return Center(
              child: Text(
                injuries.isEmpty
                    ? 'None assigned'
                    : 'Patient Injuries: ${injuries.length}',
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Screen 2: Scrollable table of patient injuries ────────────────────────

class PatientInjuriesScreen extends StatelessWidget {
  final String patientId;
  const PatientInjuriesScreen({required this.patientId, super.key});

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
        child: BlocBuilder<InjuryBloc, InjuryState>(
          builder: (context, state) {
            final injuries = state.forPatient(patientId);
            return MmsRoundedBarlessPanel(
              caption: 'Injuries — $patientId',
              widget: injuries.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('None assigned'),
                    )
                  : _InjuryTable(patientId: patientId, injuries: injuries),
            );
          },
        ),
      ),
    );
  }
}

class _InjuryTable extends StatelessWidget {
  final String patientId;
  final List<PatientInjury> injuries;
  const _InjuryTable({required this.patientId, required this.injuries});

  @override
  Widget build(BuildContext context) {
    const headerStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.black87);
    const cellStyle = TextStyle(color: Colors.black87);

    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(3),
          3: FlexColumnWidth(2),
          4: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header row
          TableRow(
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.black26, width: 1)),
            ),
            children: [
              _cell('Injury ID', headerStyle),
              _cell('Injury Type', headerStyle),
              _cell('Description', headerStyle),
              _cell('Body Location', headerStyle),
              _cell('', headerStyle),
            ],
          ),
          ...injuries.asMap().entries.map(
            (entry) {
              final injury = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: entry.key.isEven ? Colors.white : Colors.grey.shade50,
                  border: const Border(
                      bottom: BorderSide(color: Colors.black12, width: 1)),
                ),
                children: [
                  _cell(injury.injuryId, cellStyle),
                  _cell(injury.injuryType, cellStyle),
                  _cell(injury.description, cellStyle),
                  _cell(
                    injury.locations.isNotEmpty
                        ? injury.locations.join(' ')
                        : '—',
                    cellStyle,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MmsDismissibleScreen(
                            ValueKey(
                                'InjuryDetailDismissible-${injury.injuryId}'),
                            InjuryDetailScreen(injury: injury),
                            scrollable: true,
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                      child: const Text('View Details',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, TextStyle style) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Text(text, style: style, overflow: TextOverflow.ellipsis),
      );
}

// ── Screen 3: Read-only injury detail view ────────────────────────────────

class InjuryDetailScreen extends StatelessWidget {
  final PatientInjury injury;
  const InjuryDetailScreen({required this.injury, super.key});

  @override
  Widget build(BuildContext context) {
    return PatientCaseInjuryEditor(readOnly: true, readOnlyData: injury);
  }
}
