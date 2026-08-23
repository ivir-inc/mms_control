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

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/casualty_state/casualty_state.dart';
import 'package:flutter_ui/data/repositories/casualty_states/casualty_state_repository.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_event.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_state.dart';

class CasualtyStateBloc extends Bloc<CasualtyStateEvent, CasualtyStateState> {
  final CasualtyStateRepository repository;
  StreamSubscription<List<CasualtyState>>? _watchSub;

  CasualtyStateBloc(this.repository) : super(const CasualtyStateState()) {
    on<LoadCasualtyStates>(_onLoadAll);
    on<CreateCasualtyState>(_onCreate);
    on<UpdateCasualtyState>(_onUpdate);

    on<StartWatchingCasualtyStates>(_onStartWatching);
    on<StopWatchingCasualtyStates>(_onStopWatching);

    on<_CasualtyStatesPushed>(_onCasualtyStatesPushed);
    on<_CasualtyStatesErrored>(_onCasualtyStatesErrored);
  }

  Future<void> _onStartWatching(
    StartWatchingCasualtyStates event,
    Emitter<CasualtyStateState> emit,
  ) async {
    await _watchSub?.cancel();
    emit(state.copyWith(isLoading: true, error: null));

    _watchSub = repository
        .watchCasualtyStates(
      interval: event.interval ?? const Duration(seconds: 5),
    )
        .listen(
      (list) {
        add(_CasualtyStatesPushed(list));
      },
      onError: (e, [st]) {
        add(_CasualtyStatesErrored(e.toString()));
      },
    );
  }

  Future<void> _onStopWatching(
    StopWatchingCasualtyStates event,
    Emitter<CasualtyStateState> emit,
  ) async {
    await _watchSub?.cancel();
    _watchSub = null;
  }

  @override
  Future<void> close() async {
    await _watchSub?.cancel();
    return super.close();
  }

  Future<void> _onLoadAll(
      LoadCasualtyStates event, Emitter<CasualtyStateState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final allStates = await repository.getCasualtyStates();
      emit(state.copyWith(allCasualtyStates: allStates, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onCreate(
      CreateCasualtyState event, Emitter<CasualtyStateState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.addCasualtyState(event.casualtyState);
      final allStates = await repository.getCasualtyStates();
      emit(state.copyWith(allCasualtyStates: allStates, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onUpdate(
      UpdateCasualtyState event, Emitter<CasualtyStateState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.updateCasualtyState(event.casualtyState);
      final allStates = await repository.getCasualtyStates();
      emit(state.copyWith(allCasualtyStates: allStates, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onCasualtyStatesPushed(
    _CasualtyStatesPushed e,
    Emitter<CasualtyStateState> emit,
  ) {
    emit(state.copyWith(
      allCasualtyStates: e.list,
      isLoading: false,
      error: null,
    ));
  }

  void _onCasualtyStatesErrored(
    _CasualtyStatesErrored e,
    Emitter<CasualtyStateState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      error: e.message,
    ));
  }
}

class _CasualtyStatesPushed extends CasualtyStateEvent {
  final List<CasualtyState> list;
  const _CasualtyStatesPushed(this.list);
  @override
  List<Object?> get props => [list];
}

class _CasualtyStatesErrored extends CasualtyStateEvent {
  final String message;
  const _CasualtyStatesErrored(this.message);
  @override
  List<Object?> get props => [message];
}
