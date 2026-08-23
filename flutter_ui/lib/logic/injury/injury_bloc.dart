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
import 'package:flutter_ui/data/model/patient_injury/patient_injury.dart';
import 'package:flutter_ui/data/repositories/injury/injury_repository.dart';
import 'package:flutter_ui/logic/injury/injury_event.dart';
import 'package:flutter_ui/logic/injury/injury_state.dart';

class InjuryBloc extends Bloc<InjuryEvent, InjuryState> {
  final InjuryRepository repository;

  InjuryBloc(this.repository) : super(const InjuryState()) {
    on<LoadPatientInjuries>(_onLoad);
  }

  Future<void> _onLoad(
    LoadPatientInjuries event,
    Emitter<InjuryState> emit,
  ) async {
    final injuries = await repository.fetchInjuriesForPatient(event.patientId);
    final updated = Map<String, List<PatientInjury>>.from(state.byPatient)
      ..[event.patientId] = injuries;
    emit(state.copyWith(byPatient: updated));
  }
}
