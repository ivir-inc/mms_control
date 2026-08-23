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
import 'package:flutter_ui/logic/patient_control_dashboard_widget_visibility/patient_control_dashboard_widget_visibility_bloc.dart';
import 'package:flutter_ui/logic/patient_control_dashboard_widget_visibility/patient_control_dashboard_widget_visibility_event.dart';
import 'package:flutter_ui/logic/patient_control_dashboard_widget_visibility/patient_control_dashboard_widget_visibility_state.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/visibility_toggle_widget.dart';
import 'collapsible_settings_panel.dart';

class PatientControlDashboardWidgetVisibilitySettingsPanel
    extends StatefulWidget {
  const PatientControlDashboardWidgetVisibilitySettingsPanel({
    super.key,
    required this.onToggleExpand,
  });

  final VoidCallback onToggleExpand;

  @override
  _PatientControlDashboardWidgetVisibilitySettingsPanelState createState() =>
      _PatientControlDashboardWidgetVisibilitySettingsPanelState();
}

class _PatientControlDashboardWidgetVisibilitySettingsPanelState
    extends State<PatientControlDashboardWidgetVisibilitySettingsPanel> {
  bool isExpanded = false; // Manage expanded/collapsed state locally

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded; // Toggle the expanded state
      widget.onToggleExpand(); // Notify parent of expansion (for scrolling)
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientControlDashboardWidgetVisibilityBloc,
        PatientControlDashboardWidgetVisibilityState>(
      builder: (context, visibilityState) {
        const managedKeys = {
          'vitals', 'patient_cases', 'casualty_state',
          'treatments', 'initiate_handoff', 'injuries',
        };

        final visibleWidgets = visibilityState.widgetVisibility.entries
            .where((entry) => managedKeys.contains(entry.key) && entry.value)
            .map((entry) => _toProperCase(entry.key))
            .toList();

        final visibleWidgetsCount = visibleWidgets.length;
        final hiddenWidgetsCount = managedKeys.length - visibleWidgetsCount;

        // Collapsed summary content for when the panel is not expanded
        final collapsedSummary = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var widget in visibleWidgets)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  widget,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            if (hiddenWidgetsCount > 0)
              Text(
                '+ $hiddenWidgetsCount hidden ${hiddenWidgetsCount == 1 ? 'widget' : 'widgets'}',
                style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
          ],
        );

        // Expanded content showing all toggle widgets
        final expandedContent = Column(
          children: [
            VisibilityToggleWidget(
              title: 'Vitals',
              isVisible: visibilityState.widgetVisibility['vitals']!,
              widgetId: 'vitals',
              onChanged: (bool value) {
                context
                    .read<PatientControlDashboardWidgetVisibilityBloc>()
                    .add(const ToggleWidgetVisibility('vitals'));
              },
            ),
            VisibilityToggleWidget(
              title: 'Patient Cases',
              isVisible: visibilityState.widgetVisibility['patient_cases']!,
              widgetId: 'patient_cases',
              onChanged: (bool value) {
                context
                    .read<PatientControlDashboardWidgetVisibilityBloc>()
                    .add(const ToggleWidgetVisibility('patient_cases'));
              },
            ),
            VisibilityToggleWidget(
              title: 'Casualty State',
              isVisible: visibilityState.widgetVisibility['casualty_state']!,
              widgetId: 'casualty_state',
              onChanged: (bool value) {
                context
                    .read<PatientControlDashboardWidgetVisibilityBloc>()
                    .add(const ToggleWidgetVisibility('casualty_state'));
              },
            ),
            VisibilityToggleWidget(
              title: 'Treatments',
              isVisible: visibilityState.widgetVisibility['treatments']!,
              widgetId: 'treatments',
              onChanged: (bool value) {
                context
                    .read<PatientControlDashboardWidgetVisibilityBloc>()
                    .add(const ToggleWidgetVisibility('treatments'));
              },
            ),
            VisibilityToggleWidget(
              title: 'Initiate Handoff',
              isVisible: visibilityState.widgetVisibility['initiate_handoff']!,
              widgetId: 'initiate_handoff',
              onChanged: (bool value) {
                context
                    .read<PatientControlDashboardWidgetVisibilityBloc>()
                    .add(const ToggleWidgetVisibility('initiate_handoff'));
              },
            ),
            VisibilityToggleWidget(
              title: 'Injuries',
              isVisible: visibilityState.widgetVisibility['injuries']!,
              widgetId: 'injuries',
              onChanged: (bool value) {
                context
                    .read<PatientControlDashboardWidgetVisibilityBloc>()
                    .add(const ToggleWidgetVisibility('injuries'));
              },
            ),
          ],
        );

        return CollapsibleSettingsPanel(
          title: 'Patient Controls Visibility Panel',
          collapsedSummary: collapsedSummary,
          expandedContent: expandedContent,
          isExpanded: isExpanded,
          onToggle: _toggleExpand, // Use local toggle function
        );
      },
    );
  }

  String _toProperCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
