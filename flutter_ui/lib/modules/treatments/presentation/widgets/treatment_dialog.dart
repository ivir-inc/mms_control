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

class TreatmentDialog extends StatefulWidget {
  final TreatmentSpecifics specifics;
  final String patientId;

  const TreatmentDialog(this.specifics, this.patientId, {super.key});

  @override
  _TreatmentDialogState createState() => _TreatmentDialogState();
}

class _TreatmentDialogState extends State<TreatmentDialog> {
  static const _secondsDelay = 2;
  bool _sending = false;
  bool _success = true;
  bool _delaying = false;
  String? _selectedInjury;

  void startSending() {
    setState(() {
      _sending = true;
      _success = false;
    });
  }

  void doneSending(bool succeeded) {
    if (mounted) {
      setState(() {
        _sending = false;
        _success = succeeded;
      });
    }
  }

  Future<void> sendTreatment() async {
    startSending();
    bool succeeded = await TreatmentScenarioServices.postTreatment(
      widget.specifics.name,
      widget.specifics.treatmentLocation,
      deviceUsed: widget.specifics.deviceUsed,
      injury: _selectedInjury, // Send raw device string
      patientId: widget.patientId,
    );
    doneSending(succeeded);

    if (succeeded) {
      setState(() => _delaying = true);
      await Future.delayed(const Duration(seconds: _secondsDelay));
      if (mounted) Navigator.pop(context);
    }
  }

    /// Builds a RadioListTile for 
  Widget _buildInjuryTile(injury) {
    return SizedBox(
      width: 180,
      child: RadioListTile<String>(
        value: injury,
        groupValue: _selectedInjury,
        title: MmsText(injury),
        onChanged: (value) => setState(() => _selectedInjury = injury),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Panel(
        width: 620,
        height: 320,
        text: widget.specifics.name, // Display treatmentName
        widget: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for ( var injury in widget.specifics.injuries) _buildInjuryTile(injury),
              const SizedBox(height: 12),
              const Divider(thickness: 1, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _sending || _delaying ? null : sendTreatment,
                    child: const MmsText("OK", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _sending || _delaying
                        ? null
                        : () => Navigator.pop(context),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child:
                        const MmsText("Cancel", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
