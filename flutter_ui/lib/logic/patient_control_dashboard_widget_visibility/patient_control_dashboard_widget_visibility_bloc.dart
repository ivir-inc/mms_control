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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_control_dashboard_widget_visibility_event.dart';
import 'patient_control_dashboard_widget_visibility_state.dart';
import 'package:flutter_ui/data/model/visibility/patient_control_dashboard_widget_visibility_model.dart';
import 'package:flutter_ui/data/repositories/patient_control_dashboard_widget_visibility/patient_control_dashboard_widget_visibility_repository.dart';

// Define default visibility settings
const Map<String, bool> defaultWidgetVisibility = {
  'vitals': true,
  'patient_cases': true,
  'casualty_state': true,
  'treatments': true,
  'initiate_handoff': true,
  'injuries': true,
  // Hidden until updated for federation (COM-6):
  'fluids': false,
  'labs': false,
  'sounds': false,
  'onesaf': false,
  'tccc_dd1380': false,
};

class PatientControlDashboardWidgetVisibilityBloc extends Bloc<
    PatientControlDashboardWidgetVisibilityEvent,
    PatientControlDashboardWidgetVisibilityState> {
  final PatientControlDashboardWidgetVisibilityRepository repository;

  PatientControlDashboardWidgetVisibilityBloc({required this.repository})
      : super(_initializeVisibilityState(repository)) {
    on<ToggleWidgetVisibility>((event, emit) {
      final currentVisibility = state.widgetVisibility[event.widgetId] ?? true;
      final updatedVisibility = {
        ...state.widgetVisibility,
        event.widgetId: !currentVisibility
      };

      // Save the updated visibility state to storage
      repository.saveVisibilityState(
        PatientControlDashboardWidgetVisibilityModel(
          widgetVisibility: updatedVisibility,
        ),
      );

      emit(state.copyWith(widgetVisibility: updatedVisibility));
    });

    on<FetchWidgetVisibilityFromBackend>((event, emit) async {
      final visibilityState = await repository.fetchFromBackend();

      // Merge backend settings with current state
      final updatedVisibility = {
        ...state.widgetVisibility,
        ...visibilityState.widgetVisibility,
      };

      emit(state.copyWith(widgetVisibility: updatedVisibility));
    });
  }

  // Initialize visibility state based on defaults, local storage, and backend
  static PatientControlDashboardWidgetVisibilityState
      _initializeVisibilityState(
          PatientControlDashboardWidgetVisibilityRepository repository) {
    final localVisibilityState =
        repository.loadVisibilityState().widgetVisibility;

    // Merge local settings with defaults
    final initialVisibility = {
      ...defaultWidgetVisibility,
      ...localVisibilityState,
    };

    return PatientControlDashboardWidgetVisibilityState(
      widgetVisibility: initialVisibility,
    );
  }

  Future<void> saveToBackend() async {
    await repository.saveToBackend(
      PatientControlDashboardWidgetVisibilityModel(
        widgetVisibility: state.widgetVisibility,
      ),
    );
  }

  void fetchFromBackend() {
    add(const FetchWidgetVisibilityFromBackend());
  }
}
