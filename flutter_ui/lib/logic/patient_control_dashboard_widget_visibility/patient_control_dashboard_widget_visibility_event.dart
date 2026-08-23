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

import 'package:equatable/equatable.dart';

abstract class PatientControlDashboardWidgetVisibilityEvent extends Equatable {
  const PatientControlDashboardWidgetVisibilityEvent();

  @override
  List<Object> get props => [];
}

// Event for toggling widget visibility
class ToggleWidgetVisibility
    extends PatientControlDashboardWidgetVisibilityEvent {
  final String widgetId;

  const ToggleWidgetVisibility(this.widgetId);

  @override
  List<Object> get props => [widgetId];
}

// Event for fetching visibility settings from the backend
class FetchWidgetVisibilityFromBackend
    extends PatientControlDashboardWidgetVisibilityEvent {
  const FetchWidgetVisibilityFromBackend();

  @override
  List<Object> get props => [];
}
