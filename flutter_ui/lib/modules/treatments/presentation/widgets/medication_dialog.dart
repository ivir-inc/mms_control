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
import 'package:flutter_ui/modules/treatments/presentation/widgets/scenario_holder.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import '../../data/services/scenario_services.dart';

class _DosageData {
  final int id;
  final String name;
  final String messageName;
  final Color color;

  _DosageData(this.id, this.name, this.messageName, this.color);
}

class MedicationDialog extends StatefulWidget {
  final MedicationSpecifics specifics;
  final String patientId;

  const MedicationDialog(this.specifics, this.patientId, {super.key});

  @override
  _MedicationDialogState createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<MedicationDialog> {
  static const _secondsDelay = 2;

  MedicationAdministrationRouteEnum? _selectedAdminRoute;
  int? _selectedDosage;

  bool _isSending = false;
  String? _statusMessage;

  final List<MedicationAdministrationRouteEnum> _adminRoutes =
      MedicationAdministrationRouteEnum.values
          .where((e) => e != MedicationAdministrationRouteEnum.notApplicable)
          .toList();

  final List<_DosageData> _dosages = [
    _DosageData(0, "Under-dose", "UNDER", Colors.black45),
    _DosageData(1, "Correct", "CORRECT", Colors.green),
    _DosageData(2, "Overdose", "OVER", Colors.red),
  ];

  Future<void> _submitMedication() async {
    setState(() {
      _isSending = true;
      _statusMessage = null;
    });

    bool succeeded = await TreatmentScenarioServices.postMedication(
      widget.specifics.name, // Pass the MedicationEnum directly
      _selectedAdminRoute!,
      _dosages[_selectedDosage!].messageName,
      patientId: widget.patientId,
    );

    if (succeeded) {
      setState(() {
        _statusMessage = "Sent successfully!";
      });
      await Future.delayed(const Duration(seconds: _secondsDelay));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _statusMessage = "Failed to send.";
      });
    }

    setState(() {
      _isSending = false;
    });
  }

  /// Builds a RadioListTile for administration routes
  Widget _buildAdminRouteTile(MedicationAdministrationRouteEnum route) {
    return SizedBox(
      width: 180,
      child: RadioListTile<MedicationAdministrationRouteEnum>(
        value: route,
        groupValue: _selectedAdminRoute,
        title: MmsText(route.toString().split('.').last),
        onChanged: (value) => setState(() => _selectedAdminRoute = value),
      ),
    );
  }

  /// Builds a RadioListTile for dosages
  Widget _buildDosageTile(_DosageData dosage) {
    return SizedBox(
      width: 180,
      child: RadioListTile<int>(
        value: dosage.id,
        groupValue: _selectedDosage,
        title: MmsText(
          dosage.name,
          style: TextStyle(color: dosage.color),
        ),
        onChanged: (value) => setState(() => _selectedDosage = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Panel(
        width: 600,
        height: 450, // Slightly increased height for better UI fit
        text: widget.specifics.name
            .toString()
            .split('.')
            .last, // Display name directly
        widget: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const MmsText(
                "Administration Route",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _adminRoutes.map(_buildAdminRouteTile).toList(),
              ),
              const Divider(thickness: 1, height: 24),
              const MmsText(
                "Dosage",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _dosages.map(_buildDosageTile).toList(),
              ),
              const Divider(thickness: 1, height: 24),
              if (_statusMessage != null)
                MmsText(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage == "Sent successfully!"
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isSending)
                    const CircularProgressIndicator(strokeWidth: 2)
                  else ...[
                    ElevatedButton(
                      onPressed: (_selectedAdminRoute == null ||
                              _selectedDosage == null ||
                              _isSending)
                          ? null
                          : _submitMedication,
                      child:
                          const MmsText("OK", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          _isSending ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      child: const MmsText("Cancel",
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
