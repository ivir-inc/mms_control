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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text_field.dart';

class AddPatientWidget extends StatefulWidget {
  AddPatientWidget({super.key});

  @override
  State<AddPatientWidget> createState() => _AddPatientWidgetState();
}

class _AddPatientWidgetState extends State<AddPatientWidget> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      final now = DateTime.now().toIso8601String();
      debugPrint('[$now] [Listener] Text changed: "${controller.text}"');
    });
  }

  void _addPatient(BuildContext context) {
    FocusScope.of(context).unfocus(); // Force commit from Android keyboard

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] _addPatient() invoked');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now().toIso8601String();
      debugPrint('[$now] [postFrameCallback] Reading controller.text');

      debugPrint('[$now] Platform: ${defaultTargetPlatform.name}');
      debugPrint(
          '[$now] TextField has focus: ${FocusScope.of(context).hasFocus}');
      debugPrint('[$now] Controller.hashCode: ${controller.hashCode}');
      debugPrint('[$now] Text before trim: "${controller.text}"');

      final patientId = controller.text.trim();

      final trimmedNow = DateTime.now().toIso8601String();
      debugPrint('[$trimmedNow] Text after trim: "$patientId"');

      if (patientId.isNotEmpty) {
        final patientManagementBloc = context.read<PatientManagementBloc>();
        final dispatchNow = DateTime.now().toIso8601String();

        debugPrint(
            '[$dispatchNow] Dispatching addPatient event with ID "$patientId"');

        patientManagementBloc.add(
          PatientManagementEvent(
            PatientManagementAction.addPatient,
            [Patient(patientId, patientId, PatientSource.internal, true)],
            context: context,
          ),
        );

        final clearNow = DateTime.now().toIso8601String();
        debugPrint('[$clearNow] Clearing controller');
        controller.clear();
      } else {
        final emptyNow = DateTime.now().toIso8601String();
        debugPrint('[$emptyNow] patientId is empty, showing error');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient ID cannot be blank.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MmsText("New Patient ID: "),
        MmsTextField(
          width: 240,
          textController: controller,
          height: 80,
          maxLines: 1,
          onSubmitted: (_) =>
              _addPatient(context), // Pressing Enter triggers this
        ),
        MmsPaddedRaisedButton(
          "Add",
          onPressed: () => _addPatient(context),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
