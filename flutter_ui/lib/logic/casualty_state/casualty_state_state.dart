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

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/data/model/casualty_state/casualty_state.dart';

class CasualtyStateState extends Equatable {
  final List<CasualtyState> allCasualtyStates;
  final bool isLoading;
  final String? error;

  const CasualtyStateState({
    this.allCasualtyStates = const [],
    this.isLoading = false,
    this.error,
  });

  CasualtyStateState copyWith({
    List<CasualtyState>? allCasualtyStates,
    bool? isLoading,
    String? error,
  }) {
    return CasualtyStateState(
      allCasualtyStates: allCasualtyStates ?? this.allCasualtyStates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  CasualtyState? getByPatientId(String patientId) {
    return allCasualtyStates.firstWhereOrNull(
      (cs) => cs.patientId == patientId,
    );
  }

  @override
  List<Object?> get props => [allCasualtyStates, isLoading, error];
}
