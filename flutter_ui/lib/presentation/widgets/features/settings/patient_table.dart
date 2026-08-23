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
import 'package:flutter_ui/presentation/widgets/features/settings/patient_row.dart';

class PatientTable extends StatelessWidget {
  final void Function(Patient patient) onToggleVisibility;
  final void Function(Patient patient) onRemovePatient;

  const PatientTable({
    super.key,
    required this.onToggleVisibility,
    required this.onRemovePatient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientManagementBloc, PatientManagementState>(
      builder: (context, state) {
        // Sort patients alphabetically by id (which is the same as name in this case)
        List<Patient> sortedPatients = List.from(state.patients);
        // case insensitive sort
        sortedPatients
            .sort((a, b) => a.id.toLowerCase().compareTo(b.id.toLowerCase()));

        return Table(
          columnWidths: const {
            0: FixedColumnWidth(150), // Adjusted width for the Name column
            1: FixedColumnWidth(250), // Physiology Control column width
            2: FixedColumnWidth(100), // Visibility column fixed width
            3: FixedColumnWidth(
                120), // Actions column width adjusted for button
          },
          children: [
            // Header Row
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Physiology Control',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Visibility',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Patient Rows
            ...sortedPatients.map((patient) {
              return TableRow(
                key: ValueKey(patient.id),
                children: PatientRow(
                  patient,
                  context,
                  onToggleVisibility: onToggleVisibility,
                  onRemovePatient: onRemovePatient,
                ).buildChildren(),
              );
            }),
          ],
        );
      },
    );
  }
}
