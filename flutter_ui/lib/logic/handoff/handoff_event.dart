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

abstract class HandoffEvent extends Equatable {
  const HandoffEvent();
  @override
  List<Object?> get props => [];
}

class HandoffLoad extends HandoffEvent {
  final String patientId;
  const HandoffLoad(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class HandoffDestinationSelected extends HandoffEvent {
  final String patientId;
  final String? destinationId;
  const HandoffDestinationSelected(this.patientId, this.destinationId);
  @override
  List<Object?> get props => [patientId, destinationId];
}

class HandoffResetLocal extends HandoffEvent {
  final String patientId;
  const HandoffResetLocal(this.patientId);
}

class HandoffEditorVisible extends HandoffEvent {
  final String patientId;
  final bool isVisible;
  const HandoffEditorVisible(this.patientId, this.isVisible);
}

class HandoffStartRequested extends HandoffEvent {
  final String patientId;
  const HandoffStartRequested(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

// internal: from repository stream
class _HandoffPhaseArrived extends HandoffEvent {
  final String patientId;
  final HandoffPhase phase;
  const _HandoffPhaseArrived(this.patientId, this.phase);
  @override
  List<Object?> get props => [patientId, phase];
}

class _HandoffDetailArrived extends HandoffEvent {
  final String patientId;
  final String message;
  const _HandoffDetailArrived(this.patientId, this.message);
  @override
  List<Object?> get props => [patientId, message];
}
