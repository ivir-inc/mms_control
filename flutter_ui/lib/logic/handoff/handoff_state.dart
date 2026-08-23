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

part of 'handoff_bloc.dart';

class HandoffView extends Equatable {
  final String? destinationId;
  final HandoffPhase phase;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final List<String> details;

  const HandoffView({
    this.destinationId,
    this.phase = HandoffPhase.none,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.details = const [],
  });

  HandoffView copyWith({
    String? destinationId,
    HandoffPhase? phase,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    List<String>? details,
  }) =>
      HandoffView(
        destinationId: destinationId ?? this.destinationId,
        phase: phase ?? this.phase,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
        details: details ?? this.details,
      );

  @override
  List<Object?> get props =>
      [destinationId, phase, isLoading, isSubmitting, error, details];
}

class HandoffState extends Equatable {
  final Map<String, HandoffView> byPatient; // patientId -> view
  const HandoffState({this.byPatient = const {}});

  HandoffView view(String patientId) =>
      byPatient[patientId] ?? const HandoffView();

  HandoffState updating(String patientId, HandoffView Function(HandoffView) f) {
    final cur = view(patientId);
    final next = f(cur);
    final newMap = Map<String, HandoffView>.from(byPatient)..[patientId] = next;
    return HandoffState(byPatient: newMap);
  }

  @override
  List<Object?> get props => [byPatient];
}
