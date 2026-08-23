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

class PatientControlDashboardWidgetVisibilityModel {
  final Map<String, bool> widgetVisibility;

  PatientControlDashboardWidgetVisibilityModel(
      {required this.widgetVisibility});

  factory PatientControlDashboardWidgetVisibilityModel.fromMap(
      Map<dynamic, dynamic> map) {
    final raw = (map['widgetVisibility'] as Map?) ?? const <String, bool>{};
    final casted = Map<String, bool>.from(raw);
    return PatientControlDashboardWidgetVisibilityModel(
        widgetVisibility: casted);
  }

  Map<String, dynamic> toMap() {
    return {'widgetVisibility': widgetVisibility};
  }
}
