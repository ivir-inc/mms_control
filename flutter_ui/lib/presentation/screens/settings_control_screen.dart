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
import 'package:flutter_ui/data/model/facility/facility.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/logic/facility/facility_bloc.dart';
import 'package:flutter_ui/logic/facility/facility_event.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/facilities_management/facility_management_panel.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/facility_update_panel.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_management_panel.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_builder_panel.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_control_dashboard_widget_visibility_settings_panel.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/treatment_page_customization_settings_panel.dart';
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';

class SettingsControlScreen extends StatefulWidget {
  const SettingsControlScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsControlScreenState();
}

class _SettingsControlScreenState extends State<SettingsControlScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _facilityManagementKey = GlobalKey();
  final GlobalKey _patientManagementKey = GlobalKey();
  final GlobalKey _patientCaseBuilderKey = GlobalKey();
  final GlobalKey _widgetVisibilityKey = GlobalKey();
  final GlobalKey _treatmentLayoutKey = GlobalKey();

  int _currentPatientCount = 0;

  @override
  void initState() {
    super.initState();
  }

  // Method to scroll the page and align the expanded panel to the top of the view
  void _scrollToPanel(GlobalKey panelKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box =
          panelKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final position = box.localToGlobal(Offset.zero).dy;

        final double targetScrollPosition =
            _scrollController.offset + position - 120;

        final double maxScrollExtent =
            _scrollController.position.maxScrollExtent;

        final double scrollPosition = targetScrollPosition > maxScrollExtent
            ? maxScrollExtent
            : targetScrollPosition;

        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Callback to handle editing a Facility
  void _onMarkFacilityEditing(Facility facility) {
    context.read<FacilityBloc>().add(EditFacility(facility.facilityId));
  }

  // Callback to handle removing a Facility
  void _onRemoveFacility(Facility facility) {
    _confirmDeleteFacility(context, facility);
  }

  // Callback to handle toggling patient visibility
  void _onToggleVisibility(Patient patient) {
    context.read<PatientManagementBloc>().add(
          PatientManagementEvent(
            PatientManagementAction.toggleVisibility,
            [patient],
          ),
        );
  }

  // Callback to handle removing a patient
  void _onRemovePatient(Patient patient) {
    _confirmDeletePatient(context, patient);
  }

  // Callback to handle editing a Patient Case
  void _onEditPatientCase(PatientCase patientCase) {
    context.read<PatientCaseBuilderBloc>().add(
          PatientCaseBuilderEvent(
            PatientCaseBuilderAction.editOrDisplayPatientCase,
            patientCaseName: patientCase.name,
            context: context,
          ),
        );
  }

  // Callback to handle removing a Patient Case
  void _onRemovePatientCase(PatientCase patientCase) {
    _confirmDeletePatientCase(context, patientCase);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientManagementBloc, PatientManagementState>(
      listener: (context, state) {
        int newPatientCount = state.patients.length;

        if (_currentPatientCount != newPatientCount) {
          setState(() {
            _currentPatientCount = newPatientCount;
          });
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              color: MmsColors.mainBodyBackgroundColor,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
              ),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FacilityManagementPanel(
                      key: _facilityManagementKey,
                      onMarkFacilityEditing: _onMarkFacilityEditing,
                      onRemoveFacility: _onRemoveFacility,
                      onToggleExpand: () =>
                          _scrollToPanel(_facilityManagementKey),
                    ),
                    const SizedBox(height: 20),
                    PatientManagementPanel(
                      key: _patientManagementKey,
                      onToggleVisibility: _onToggleVisibility,
                      onRemovePatient: _onRemovePatient,
                      onToggleExpand: () =>
                          _scrollToPanel(_patientManagementKey),
                    ),
                    const SizedBox(height: 20),
                    PatientCaseBuilderPanel(
                      key: _patientCaseBuilderKey,
                      onEditPatientCase: _onEditPatientCase,
                      onRemovePatientCase: _onRemovePatientCase,
                      onToggleExpand: () =>
                          _scrollToPanel(_patientCaseBuilderKey),
                    ),
                    const SizedBox(height: 20),
                    PatientControlDashboardWidgetVisibilitySettingsPanel(
                      key: _widgetVisibilityKey,
                      onToggleExpand: () =>
                          _scrollToPanel(_widgetVisibilityKey),
                    ),
                    const SizedBox(height: 20),
                    TreatmentPageCustomizationSettingsPanel(
                      key: _treatmentLayoutKey,
                      onToggleExpand: () =>
                          _scrollToPanel(_treatmentLayoutKey),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteFacility(
      BuildContext context, Facility facility) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Facility?'),
          content: const Text(
              'This action cannot be undone. Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Proceed with the deletion logic
      if (context.mounted) {
        context.read<FacilityBloc>().add(RemoveFacility(facility.facilityId));
      }
    }
  }

  Future<void> _confirmDeletePatient(
      BuildContext context, Patient patient) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Patient?'),
          content: const Text(
              'This action cannot be undone. Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Proceed with the deletion logic
      if (context.mounted) {
        context.read<PatientManagementBloc>().add(
              PatientManagementEvent(
                PatientManagementAction.deletePatients,
                [patient],
                context: context,
              ),
            );
      }
    }
  }

  Future<void> _confirmDeletePatientCase(
      BuildContext context, PatientCase patientCase) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Patient Case?'),
          content: const Text(
              'This action cannot be undone. Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Proceed with the deletion logic
      if (context.mounted) {
        context.read<PatientCaseBuilderBloc>().add(
              PatientCaseBuilderEvent(
                PatientCaseBuilderAction.removePatientCase,
                patientCaseNum: patientCase.caseNum,
                patientCaseName: patientCase.name,
                context: context,
              ),
            );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
