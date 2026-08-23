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
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_row.dart';

class PatientCaseTable extends StatelessWidget {
  final void Function(PatientCase patientCase) onEditPatientCase;
  final void Function(PatientCase patientCase) onRemovePatientCase;

  const PatientCaseTable({
    super.key,
    required this.onEditPatientCase,
    required this.onRemovePatientCase,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
      builder: (context, state) {
        if (state.patientCases.isNotEmpty) {
          // Sort Patient Cases alphabetically by name (case insensitive)
          List<PatientCase> sortedPatientCases = List.from(state.patientCases);
          sortedPatientCases.sort((a, b) => (a.name?.toLowerCase() ?? '')
              .compareTo(b.name?.toLowerCase() ?? ''));

          return Table(
            columnWidths: const {
              0: FixedColumnWidth(150), // Adjusted width for the Name column
              //1: FixedColumnWidth(250), // Injuries Control column width
              2: FixedColumnWidth(
                  220), // Actions column width adjusted for button
            },
            children: [
              // Header Row
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Case',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Injuries',
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
              // Patient case Rows
              ...sortedPatientCases.asMap().entries.map((entry) {
                final index = entry.key;
                final patientCase = entry.value;

                return PatientCaseRow(
                  patientCase,
                  context,
                  onEditPatientCase: onEditPatientCase,
                  onRemovePatientCase: onRemovePatientCase,
                ).build();
              })
            ],
          );
        } else {
          return const Text("No Patient Cases added.");
        }
      },
    );
  }
}
