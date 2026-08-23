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
import 'package:flutter_ui/data/model/tccc/tccc_record.dart';

class TcccState extends Equatable {
  final Map<String, TcccRecord?> byPatientId; // null == no card yet
  final bool isLoading;
  final String? error;

  const TcccState({
    this.byPatientId = const {},
    this.isLoading = false,
    this.error,
  });

  TcccRecord? forPatient(String patientId) => byPatientId[patientId];

  TcccState copyWith({
    Map<String, TcccRecord?>? byPatientId,
    bool? isLoading,
    String? error,
  }) =>
      TcccState(
        byPatientId: byPatientId ?? this.byPatientId,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [byPatientId, isLoading, error];
}
