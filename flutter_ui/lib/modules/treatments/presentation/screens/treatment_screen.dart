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
import 'package:flutter_ui/presentation/widgets/general/panels/panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import '../widgets/scenario_holder.dart';
import '../widgets/scenario_dropdown.dart';
import '../widgets/treatment_dialog.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("TreatmentScreen");

class TreatmentScreen extends StatefulWidget {
  final String? patientId;
  final bool includeDropdown;

  const TreatmentScreen({
    super.key,
    this.patientId,
    this.includeDropdown = true,
  });

  @override
  _TreatmentScreenState createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  late Function updateCallback;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _logger.log(
        1, "Initializing TreatmentScreen for patient: ${widget.patientId}");

    updateCallback = updateScreenState;

    ScenarioHolder.instanceFor(
      patientId: widget.patientId ?? "",
      onChangeActiveScenario: updateCallback,
      refresh: true,
    ).initialize().then((_) => updateScreenState());
  }

  @override
  void dispose() {
    _logger.log(
        1, "Disposing TreatmentScreen for patient: ${widget.patientId}");
    ScenarioHolder.instanceFor(patientId: widget.patientId ?? "")
        .removeOnChangeActiveScenario(updateCallback);
    super.dispose();
  }

  void updateScreenState() {
    _logger.log(1, "Updating screen state for patient: ${widget.patientId}");
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 12,
                          runSpacing: 12,
                          children: buildTreatmentPanels(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
          child: MmsFieldLabelText(text: "Patient Case:"),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            widget.includeDropdown ? 0 : 16,
            widget.includeDropdown ? 0 : 12,
            widget.includeDropdown ? 0 : 16,
          ),
          child: widget.includeDropdown
              ? ScenarioMenuDropdownButton(
                  patientId: widget.patientId ?? "",
                  onChanged: updateScreenState,
                )
              : MmsScenarioSelectionLabel(
                  patientId: widget.patientId ?? "",
                  textStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 16,
                  ),
                ),
        ),
      ],
    );
  }

  List<Widget> buildTreatmentPanels() {
    ScenarioHolder scenarioHolder =
        ScenarioHolder.instanceFor(patientId: widget.patientId ?? "");
    final scenario = scenarioHolder.currentScenario();

    if (scenario == null || scenario.specs?.treatments == null) {
      return [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: MmsText(
            "No treatments available for this scenario.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ];
    }

    // Create a panel for each treatment type
    return scenario.specs!.treatments!.map((treatment) {
      return buildTreatmentPanel(treatment);
    }).toList();
  }

  Panel buildTreatmentPanel(TreatmentsByType treatment) {
    String typeText =
        treatment.type.isNotEmpty ? treatment.type : "Unknown Type";

    List<Widget> columnWidgets = treatment.detailsList?.map((details) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (details.subType.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: MmsText(
                    details.subType,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              if (details.specifics != null && details.specifics!.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 12,
                  runSpacing: 12,
                  children: details.specifics!
                      .map((specific) =>
                          TreatmentButton(specific, widget.patientId ?? ""))
                      .toList(),
                )
              else
                const MmsText(
                  "No specifics available.",
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          );
        }).toList() ??
        [
          const MmsText(
            "No details available.",
            style: TextStyle(color: Colors.grey),
          ),
        ];

    return Panel(
      width: 400.0,
      text: typeText,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnWidgets,
      ),
    );
  }
}

class TreatmentButton extends StatelessWidget {
  final TreatmentSpecifics specifics;
  final String patientId;

  const TreatmentButton(this.specifics, this.patientId, {super.key});

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger("TreatmentButton");

    // Construct the button text
    String buttonText =
        specifics.name.isNotEmpty ? specifics.name : "Unnamed Treatment";

    // Construct the device text
    String deviceText = specifics.deviceUsed.isNotEmpty &&
            specifics.deviceUsed != "Unknown Device"
        ? specifics.deviceUsed
        : "";

    // Full button label
    String fullButtonLabel =
        deviceText.isNotEmpty ? "$buttonText ($deviceText)" : buttonText;

    logger.log(1, "TreatmentButton - fullLabel: $fullButtonLabel");

    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: 180.0,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => TreatmentDialog(specifics, patientId),
            );
          },
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: MmsText(
            fullButtonLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
