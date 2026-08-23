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
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text_field.dart';

class AddPatientCaseWidget extends StatelessWidget {
  AddPatientCaseWidget({super.key});

  void _handleSubmitAddPatientCase(String value, BuildContext context) {
    final patientCaseName = value;

    if (patientCaseName.isNotEmpty) {
      // Access the PatientCaseBuilderBloc from the context
      final patientCaseBuilderBloc = context.read<PatientCaseBuilderBloc>();

      // Dispatch an add Patient Case event to the bloc
      patientCaseBuilderBloc.add(
        PatientCaseBuilderEvent(PatientCaseBuilderAction.addPatientCase,
            patientCaseName: patientCaseName, context: context),
      );

      // Clear the text field after adding the patient
      controller.clear();
    } else {
      // Show a Snackbar if the input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient Case name cannot be blank.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MmsText("New Case Name: "),
        MmsTextField(
          width: 240,
          textController: controller,
          height: 80,
          maxLines: 1,
          onSubmitted: (value) => _handleSubmitAddPatientCase(value, context),
        ),
        MmsPaddedRaisedButton(
          "Add",
          onPressed: () {
            _handleSubmitAddPatientCase(controller.text.trim(), context);
          },
        ),
      ],
    );
  }
}
