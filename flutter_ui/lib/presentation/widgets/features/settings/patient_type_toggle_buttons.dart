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
import 'package:flutter_ui/presentation/theme/common_colors.dart';

class PatientTypeToggleButtons extends StatefulWidget {
  const PatientTypeToggleButtons({
    super.key,
    required this.patientId,
    required this.patientSource,
  });

  final String patientId;
  final PatientSource patientSource;

  @override
  State<PatientTypeToggleButtons> createState() =>
      _PatientTypeToggleButtonsState();
}

class _PatientTypeToggleButtonsState extends State<PatientTypeToggleButtons> {
  late List<bool> selectedPatientSource;

  List<PatientSource> sourceList = [
    PatientSource.unknown,
    PatientSource.internal,
    PatientSource.external,
  ];

  @override
  void initState() {
    super.initState();
    selectedPatientSource = List.generate(sourceList.length, (index) => false);
    selectedPatientSource[_enumToIndex(widget.patientSource)] = true;
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) {
        // Directly update the patient's physiology source when toggled
        context.read<PatientManagementBloc>().add(
              PatientManagementEvent(
                PatientManagementAction.updatePhysiologySource,
                const [], // No need for patients list here
                patientId: widget.patientId,
                patientSource: _indexToEnum(index),
              ),
            );

        setState(() {
          for (int i = 0; i < selectedPatientSource.length; i++) {
            selectedPatientSource[i] = i == index;
          }
        });
      },
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      selectedBorderColor: MmsColors.dkBlue,
      selectedColor: MmsColors.buttonTextColor,
      fillColor: MmsColors.buttonColor,
      color: MmsColors.black,
      constraints: const BoxConstraints(minHeight: 30.0, minWidth: 60.0),
      isSelected: selectedPatientSource,
      children: sourceList
          .map((source) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(_toProperCase(source.toString().split('.').last)),
              ))
          .toList(),
    );
  }

  int _enumToIndex(PatientSource sourceEnum) => sourceList.indexOf(sourceEnum);

  PatientSource _indexToEnum(int givenIndex) => sourceList[givenIndex];

  // Helper function to convert to Proper Case
  String _toProperCase(String input) {
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}
