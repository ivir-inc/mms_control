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
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/presentation/widgets/features/mms_main_tabs/mms_tabbed_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_medications.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_treatments.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/modules/treatments/presentation/widgets/last_treatment_label_widget.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/icons/text_and_or_icon.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class TreatmentsDashboardWidget extends StatefulWidget {
  final String patientId;

  const TreatmentsDashboardWidget({required this.patientId, super.key});

  @override
  State<TreatmentsDashboardWidget> createState() =>
      _TreatmentsDashboardWidgetState();
}

class _TreatmentsDashboardWidgetState extends State<TreatmentsDashboardWidget> {
  int? patientCaseNum;
  String? patientCaseName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Use Patient Id to look up the associated Patient Case Number from
        // Patient object using the Patient Management Bloc
        final patientCaseNumber = context
            .read<PatientManagementBloc>()
            .state
            .patients
            .firstWhere((pat) => pat.id == widget.patientId)
            .patientCaseNum;

        // Look up the Patient Case Name using the Patient Case Number
        final patientCaseName = context
            .read<PatientCaseBuilderBloc>()
            .state
            .patientCases
            .firstWhere(((pc) => pc.caseNum == patientCaseNumber))
            .name;

        // Use the Patient Case Name to let PatientCaseMedications know which patient case to display
        context.read<PatientCaseBuilderBloc>().add(
              PatientCaseBuilderEvent(
                PatientCaseBuilderAction.editOrDisplayPatientCase,
                patientCaseName: patientCaseName,
                context: context,
              ),
            );

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MmsDismissibleScreen(
            const ValueKey("TreatmentsScreenDismissible"),
            MmsStylablePanel(
              panelBgColor: MmsColors.black,
              caption:
                  "Treatments/Medications${patientCaseName != null ? ' - $patientCaseName' : ''}",
              // "Treatments/Medications - $patientCaseName",
              widget: TreatmentsMedicationsTabbedWidget(
                  patientId: widget.patientId),
            ),
            scrollable: true,
          ),
        ));
      },
      child: MmsRoundedBarlessPanel(
        width: 300,
        caption: "Treatments/Medications",
        widget: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              const MmsText("Last Sent:"),
              LastTreatmentLabelWidget(widget.patientId),
            ],
          ),
        ),
      ),
    );
  }
}

class TreatmentsDetailScreen extends StatelessWidget {
  final String patientId;

  const TreatmentsDetailScreen({required this.patientId, super.key});

  @override
  Widget build(BuildContext context) {
    return MmsDismissibleScreen(
      const ValueKey("TreatmentsScreenDismissible"),
      MmsStylablePanel(
        panelBgColor: MmsColors.black,
        caption: "Treatments / Medications",
        widget: TreatmentsMedicationsTabbedWidget(patientId: patientId),
      ),
      scrollable: true,
    );
  }
}

class TreatmentsMedicationsTabbedWidget extends StatelessWidget {
  final String patientId;

  const TreatmentsMedicationsTabbedWidget({required this.patientId, super.key});

  @override
  Widget build(BuildContext context) {
    return MmsTabbedWidget(
      asScrollableContents: true,
      isVerticalTabLayout: false,
      tabBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      selectedTabBackgroundColor:
          Colors.white, // Ensure a contrasting background
      tabTextStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey,
      ),
      selectedTabTextStyle: const TextStyle(
        color:
            Colors.black, // Explicitly set the active tab text color to black
        fontWeight: FontWeight.bold,
      ),
      initialIndex: 0,
      tabLabels: TextAndOrIcon.convertTextList(["Treatments", "Medications"]),
      tabContents: [
        Container(
          color: Theme.of(context).canvasColor,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: PatientCaseTreatments(
              editMode: false,
              embeddedMode: true,
              patientId: patientId,
            ),
          ),
        ),
        Container(
          color: Theme.of(context).canvasColor,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: PatientCaseMedications(
              editMode: false,
              embeddedMode: true,
              patientId: patientId,
            ),
          ),
        ),
      ],
    );
  }
}
