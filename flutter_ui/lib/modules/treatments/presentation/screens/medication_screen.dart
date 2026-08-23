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
import '../widgets/medication_dialog.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("MedicationScreen");

class MedicationScreen extends StatefulWidget {
  final String patientId;
  final bool includeDropdown;

  const MedicationScreen({
    super.key,
    this.patientId = "",
    this.includeDropdown = true,
  });

  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  late Function updateCallback;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _logger.log(
        1, "Initializing MedicationScreen for patient: ${widget.patientId}");
    updateCallback = updateScreenState;

    ScenarioHolder.instanceFor(
      patientId: widget.patientId,
      onChangeActiveScenario: updateCallback,
      refresh: true, // Force refresh to ensure the correct data is loaded
    ).initialize().then((_) => updateScreenState());
  }

  @override
  void dispose() {
    _logger.log(
        1, "Disposing MedicationScreen for patient: ${widget.patientId}");
    ScenarioHolder.instanceFor(patientId: widget.patientId)
        .removeOnChangeActiveScenario(updateCallback);
    super.dispose();
  }

  void updateScreenState() {
    _logger.log(1, "Updating screen state for patient: ${widget.patientId}");
    setState(() {
      isLoading =
          false; // Mark loading as complete when the scenario is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            color: Theme.of(context).canvasColor, // Set the background color
            height: MediaQuery.of(context).size.height, // Extend to full height
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align contents to the start
              children: <Widget>[
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment
                          .start, // Align Wrap contents to the start
                      spacing: 12, // Add spacing between items
                      runSpacing: 12, // Add spacing between rows
                      children: buildMedicationPanels(),
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
                  patientId: widget.patientId,
                  onChanged: updateScreenState,
                )
              : MmsScenarioSelectionLabel(
                  patientId: widget.patientId,
                  textStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 16,
                  ),
                ),
        ),
      ],
    );
  }

  List<Widget> buildMedicationPanels() {
    ScenarioHolder scenarioHolder =
        ScenarioHolder.instanceFor(patientId: widget.patientId);
    final scenario = scenarioHolder.currentScenario();

    if (scenario == null ||
        scenario.specs?.medication == null ||
        scenario.specs!.medication!.isEmpty) {
      _logger.log(
          2, "No medications available for patient: ${widget.patientId}");
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: MmsText(
              "No medications available.",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ];
    }

    _logger.log(1,
        "Medications found: ${scenario.specs!.medication!.length} for patient: ${widget.patientId}");
    return scenario.specs!.medication!.map((medication) {
      return buildMedicationPanel(medication);
    }).toList();
  }

  Panel buildMedicationPanel(Medication medication) {
    String typeText =
        medication.type.isNotEmpty ? medication.type : "Unknown Type";

    _logger.log(1, "Building panel for medication type: $typeText");

    medication.detailsList?.forEach((details) {
      _logger.log(1, "SubType: ${details.subType}");

      details.specifics?.forEach((specific) {
        _logger.log(1, "MedicationSpecifics name: ${specific.name}");
        _logger.log(1, "Allowed: ${specific.allowed}");
      });
    });

    List<Widget> columnWidgets = medication.detailsList?.map((details) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MmsText(
                details.subType.isNotEmpty
                    ? details.subType
                    : "Unknown Subtype",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (details.specifics != null && details.specifics!.isNotEmpty)
                ...details.specifics!.map((specific) {
                  return MedicationButton(specific, widget.patientId);
                })
              else
                const MmsText(
                  "No specifics available.",
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          );
        }).toList() ??
        [
          const MmsText("No details available.",
              style: TextStyle(color: Colors.grey)),
        ];

    return Panel(
      width: 400.0,
      height: 200.0,
      text: typeText,
      widget: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: columnWidgets,
        ),
      ),
    );
  }
}

class MedicationButton extends StatelessWidget {
  final MedicationSpecifics specifics;
  final String patientId;

  const MedicationButton(this.specifics, this.patientId, {super.key});

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger("MedicationButton");

    final bool isEnabled = specifics.allowed;
    final String buttonText = specifics.name; // Directly use the string name

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 180.0,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  logger.log(1,
                      "Medication button pressed: $buttonText for patient: $patientId");
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) =>
                        MedicationDialog(specifics, patientId),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled ? Theme.of(context).primaryColor : Colors.grey,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
            disabledForegroundColor: Colors.white70,
          ),
          child: MmsText(
            buttonText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
