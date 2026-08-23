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
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/casualty_state_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/injuries_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/initiate_handoff_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/onesaf_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/patient_case_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/sounds_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/treatments_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/labs_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/fluids_dashboard_widget.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/vitals_dashboard_widget.dart';
import 'package:flutter_ui/logic/patient_control_dashboard_widget_visibility/patient_control_dashboard_widget_visibility_bloc.dart';
import 'package:flutter_ui/logic/patient_control_dashboard_widget_visibility/patient_control_dashboard_widget_visibility_state.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/presentation/widgets/features/patient_control/tccc_status_widget.dart';
import 'package:flutter_ui/data/model/tccc/tccc_record.dart';

Logger _logger = Logger(
  "PatientControlScreen",
  debugging: true,
);

class PatientControlScreen extends StatelessWidget {
  final String patientId;

  const PatientControlScreen({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    //_logger.log(1, "Building PatientControlScreen for patientId: $patientId");

    // helper to wrap each dashboard widget with padding & width
    Widget paddedPanel(Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0), // space below each
          child: SizedBox(width: 300, child: child),
        );

    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(minHeight: 520),
        padding: const EdgeInsets.all(12), // consistent outer padding
        color: MmsColors.mainBodyBackgroundColor,
        child: BlocBuilder<PatientControlDashboardWidgetVisibilityBloc,
            PatientControlDashboardWidgetVisibilityState>(
          builder: (context, visibilityState) {
            // Example: resolve TCCC record for this patient
            final TcccRecord? tcccRecordForPatient = null;
            // TODO: wire to data store, e.g.
            // final tcccRecordForPatient = context.select<TcccStoreAccess, TcccRecord?>(
            //    (a) => a.store.getForPatient(patientId),
            // );
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First column
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (visibilityState.widgetVisibility['vitals'] ?? true)
                        paddedPanel(
                            VitalsDashboardWidget(patientId: patientId)),
                      if (visibilityState.widgetVisibility['onesaf'] ?? false)
                        paddedPanel(
                            OnesafDashboardWidget(patientId: patientId)),
                    ],
                  ),
                ),

                const SizedBox(width: 12), // space between columns

                // Second column
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (visibilityState.widgetVisibility['patient_cases'] ??
                          false)
                        paddedPanel(
                            PatientCaseDashboardWidget(patientId: patientId)),
                      if (visibilityState.widgetVisibility['casualty_state'] ??
                          false)
                        paddedPanel(
                            CasualtyStateDashboardWidget(patientId: patientId)),
                      if (visibilityState.widgetVisibility['injuries'] ?? true)
                        paddedPanel(
                            InjuriesDashboardWidget(patientId: patientId)),
                      if (visibilityState.widgetVisibility['sounds'] ?? false)
                        paddedPanel(
                            SoundsDashboardWidget(patientId: patientId)),
                    ],
                  ),
                ),

                const SizedBox(width: 12), // space between columns

                // Third column
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (visibilityState.widgetVisibility['treatments'] ??
                          true)
                        paddedPanel(
                            TreatmentsDashboardWidget(patientId: patientId)),
                      if (visibilityState.widgetVisibility['fluids'] ?? false)
                        paddedPanel(
                            FluidsDashboardWidget(patientId: patientId)),
                      if (visibilityState.widgetVisibility['labs'] ?? false)
                        paddedPanel(LabsDashboardWidget(patientId: patientId)),
                      if (visibilityState
                              .widgetVisibility['initiate_handoff'] ??
                          false)
                        paddedPanel(InitiateHandoffDashboardWidget(
                            patientId: patientId)),
                      if (visibilityState.widgetVisibility['tccc_dd1380'] ??
                          true)
                        paddedPanel(TcccDashboardWidget(patientId: patientId)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
