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

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_ui/data/model/visibility/patient_control_dashboard_widget_visibility_model.dart';

const Set<String> _allowedWidgetIds = {
  'vitals',
  'patient_cases',
  'casualty_state',
  'treatments',
  'augmented_reality',
  'fluids',
  'labs',
  'sounds',
  'onesaf',
  'initiate_handoff',
  'injuries',
  'tccc_dd1380',
};

Map<String, bool> _sanitize(Map<String, bool> raw, {String from = ''}) {
  final cleaned = Map.fromEntries(
    raw.entries.where((e) => _allowedWidgetIds.contains(e.key)),
  );

  // Optional: debug log to find unexpected keys
  assert(() {
    final unknown = raw.keys.toSet()..removeAll(_allowedWidgetIds);
    if (unknown.isNotEmpty) {
      // ignore: avoid_print
      print('Unknown widget ids from $from: $unknown');
    }
    return true;
  }());

  return cleaned;
}

class PatientControlDashboardWidgetVisibilityRepository {
  final Storage storage;

  PatientControlDashboardWidgetVisibilityRepository({required this.storage});

  PatientControlDashboardWidgetVisibilityModel loadVisibilityState() {
    final data =
        storage.read('patient_control_dashboard_widget_visibility_state') ?? {};
    final model = PatientControlDashboardWidgetVisibilityModel.fromMap(data);

    // Sanitize + auto-migrate persisted data
    final cleaned = _sanitize(model.widgetVisibility, from: 'local');
    if (cleaned.length != model.widgetVisibility.length ||
        !cleaned.entries.every(
          (e) => model.widgetVisibility[e.key] == e.value,
        )) {
      // write back the cleaned map so "scenario" disappears for good
      storage.write(
        'patient_control_dashboard_widget_visibility_state',
        PatientControlDashboardWidgetVisibilityModel(widgetVisibility: cleaned)
            .toMap(),
      );
    }

    return PatientControlDashboardWidgetVisibilityModel(
        widgetVisibility: cleaned);
  }

  void saveVisibilityState(PatientControlDashboardWidgetVisibilityModel state) {
    final cleaned = _sanitize(state.widgetVisibility, from: 'save');
    storage.write(
      'patient_control_dashboard_widget_visibility_state',
      PatientControlDashboardWidgetVisibilityModel(widgetVisibility: cleaned)
          .toMap(),
    );
  }

  Future<void> saveToBackend(
      PatientControlDashboardWidgetVisibilityModel state) async {
    final cleaned = _sanitize(state.widgetVisibility, from: 'saveToBackend');
    // TODO: send `cleaned` to your API
  }

  Future<PatientControlDashboardWidgetVisibilityModel>
      fetchFromBackend() async {
    // TODO: Fetch from the backend API
    final backend = <String, bool>{}; // replace with fetched map
    final cleaned = _sanitize(backend, from: 'backend');
    return PatientControlDashboardWidgetVisibilityModel(
        widgetVisibility: cleaned);
  }
}
