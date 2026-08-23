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
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_editor.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';

class PatientCaseRow {
  final PatientCase patientCase;
  final BuildContext context;
  final void Function(PatientCase patientCase) onRemovePatientCase;
  final void Function(PatientCase patientCase) onEditPatientCase;

  PatientCaseRow(
    this.patientCase,
    this.context, {
    required this.onEditPatientCase,
    required this.onRemovePatientCase,
  });

  TableRow build() {
    final String injuryList;
    if ((patientCase.injuries?.isNotEmpty ?? false)) {
      injuryList = patientCase.injuries!.join(', ');
    } else {
      injuryList = "None";
    }

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(patientCase.name ?? ''),
        ),
        Padding(
            // Injury list
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(injuryList)),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 100,
                child: MmsPaddedRaisedButton(
                  "Edit",
                  left: 0,
                  top: 0,
                  bottom: 0,
                  onPressed: () {
                    onEditPatientCase(patientCase);

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MmsDismissibleScreen(
                              const ValueKey(
                                  "PatientCaseEditorScreenDismissible"),
                              PatientCaseEditor(),
                              scrollable: true,
                            )));
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 120,
                child: MmsPaddedRaisedButton(
                  "Remove",
                  top: 0,
                  bottom: 0,
                  onPressed: () {
                    onRemovePatientCase(patientCase);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
