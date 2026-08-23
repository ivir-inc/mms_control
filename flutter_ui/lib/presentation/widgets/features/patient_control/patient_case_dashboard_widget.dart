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
import 'package:flutter_ui/logic/injury/injury_bloc.dart';
import 'package:flutter_ui/logic/injury/injury_event.dart';
import 'package:flutter_ui/modules/treatments/presentation/widgets/scenario_dropdown.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/modules/federation/data/services/federation_connection_services.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/modules/treatments/presentation/widgets/scenario_holder.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger(
  "ScenarioDashboardWidget",
  debugging: true,
);

class PatientCaseDashboardWidget extends StatefulWidget {
  final String patientId;

  const PatientCaseDashboardWidget({required this.patientId, super.key});

  @override
  _PatientCaseDashboardWidgetState createState() =>
      _PatientCaseDashboardWidgetState();
}

class _PatientCaseDashboardWidgetState
    extends State<PatientCaseDashboardWidget> {
  late ScenarioHolder _scenarioHolder;

  @override
  void initState() {
    super.initState();
    _scenarioHolder = ScenarioHolder.instanceFor(
      patientId: widget.patientId,
      refresh: true,
    );
    _scenarioHolder.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh ScenarioHolder when dependencies change (e.g., switching tabs)
    _scenarioHolder = ScenarioHolder.instanceFor(
      patientId: widget.patientId,
      refresh: true,
    );
    _scenarioHolder.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _scenarioHolder.activeScenarioNotifier,
      builder: (context, activeScenarioId, _) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  SelectPatientCaseScreen(patientId: widget.patientId),
            ));
          },
          child: MmsRoundedBarlessPanel(
            width: 300,
            caption: "Patient Case",
            widget: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  MmsScenarioSelectionLabel(
                    patientId: widget.patientId,
                    textStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // MmsText(widget.patientId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SelectPatientCaseScreen extends StatelessWidget {
  final String patientId;

  const SelectPatientCaseScreen({required this.patientId, super.key});

  @override
  Widget build(BuildContext context) {
    double panelWidth = 328;

    return MmsDismissibleScreen(
      ValueKey("SelectPatientCaseScreenDismissible_$patientId"),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.start,
        direction: Axis.vertical,
        children: [
          MmsStylablePanel(
            width: panelWidth,
            caption: "Select Patient Case",
            widget: ScenarioMenuDropdownButton(
              patientId: patientId,
              onChanged: () {
                // Add appropriate callback functionality
              },
            ),
          ),
          MmsStylablePanel(
            width: panelWidth,
            caption: "Patient Controls",
            widget: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PatientCaseActionWidget(
                      action: "Start",
                      patientId: patientId,
                      federationPatientAction: "patientStart",
                      top: 4,
                      bottom: 4,
                      left: 4,
                      right: 4,
                      expanded: true,
                    ),
                    PatientCaseActionWidget(
                      action: "Stop",
                      patientId: patientId,
                      federationPatientAction: "patientStop",
                      top: 4,
                      bottom: 4,
                      left: 4,
                      right: 4,
                      expanded: true,
                    ),
                  ],
                ),
                MmsPaddedRaisedButton(
                  "Send Initialize Message",
                  onPressed: () {
                    FederationService()
                        .postFederationControlAction("initialize");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      scrollable: true,
    );
  }
}

class PatientCaseActionWidget extends StatelessWidget {
  final String action;
  final String patientId;
  final String federationPatientAction;
  final double top;
  final double bottom;
  final double left;
  final double right;
  final bool expanded;

  const PatientCaseActionWidget({
    required this.action,
    required this.patientId,
    required this.federationPatientAction,
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
    this.expanded = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: ElevatedButton(
        onPressed: () {
          FederationService().postFederationControlAction(
            federationPatientAction,
            patientId: patientId,
          );
          if (federationPatientAction == 'patientStart') {
            final bloc = context.read<InjuryBloc>();
            Future.delayed(const Duration(milliseconds: 500), () {
              bloc.add(LoadPatientInjuries(patientId));
            });
          }
        },
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(expanded ? 150 : 100, 40)),
        ),
        child: Text(action),
      ),
    );
  }
}
