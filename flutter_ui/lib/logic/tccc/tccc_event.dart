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

abstract class TcccEvent extends Equatable {
  const TcccEvent();
  @override
  List<Object?> get props => [];
}

class StartWatchingTccc extends TcccEvent {
  final String patientId;
  final Duration? interval;
  const StartWatchingTccc(this.patientId, {this.interval});
  @override
  List<Object?> get props => [patientId, interval];
}

class StopWatchingTccc extends TcccEvent {
  final String patientId;
  const StopWatchingTccc(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class RefreshTcccNow extends TcccEvent {
  final String patientId;
  const RefreshTcccNow(this.patientId);
  @override
  List<Object?> get props => [patientId];
}
