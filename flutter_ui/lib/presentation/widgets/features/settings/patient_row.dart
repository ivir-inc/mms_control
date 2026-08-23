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
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_type_toggle_buttons.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';

class PatientRow {
  final Patient patient;
  final BuildContext context;
  final void Function(Patient patient) onToggleVisibility;
  final void Function(Patient patient) onRemovePatient;

  PatientRow(
    this.patient,
    this.context, {
    required this.onToggleVisibility,
    required this.onRemovePatient,
  });

  List<Widget> buildChildren() {
    return [
      Text(patient.name),
      PatientTypeToggleButtons(
        patientId: patient.id,
        patientSource: patient.physiologySource,
      ),
      BlocSelector<PatientManagementBloc, PatientManagementState, bool?>(
        selector: (state) =>
            state.patientVisibility[patient.id] ?? patient.monitorPatient,
        builder: (context, isVisible) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Checkbox(
              value: isVisible,
              onChanged: (value) {
                if (value != null) {
                  onToggleVisibility(patient.copyWith(monitorPatient: value));
                }
              },
            ),
          );
        },
      ),
      MmsPaddedRaisedButton(
        top: 0,
        bottom: 20,
        left: 0,
        "Remove",
        onPressed: () => onRemovePatient(patient),
      ),
    ];
  }
}
