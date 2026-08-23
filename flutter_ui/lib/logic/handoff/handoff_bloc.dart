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
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/repositories/handoff/handoff_repository.dart';
import 'package:flutter_ui/logic/handoff/handoff_phase.dart';

part 'handoff_event.dart';
part 'handoff_state.dart';

class HandoffBloc extends Bloc<HandoffEvent, HandoffState> {
  final HandoffRepository repo;

  // Per-patient subscriptions (phase + detail)
  final Map<String, StreamSubscription<HandoffPhase>> _subs = {};
  final Map<String, StreamSubscription<String>> _detailSubs = {};
  final Map<String, bool> _editorOpen = {};
  final void Function()? onRefreshCasualtyStates;
  final void Function()? onRefreshPatientList;

  HandoffBloc(this.repo,
      {this.onRefreshCasualtyStates, this.onRefreshPatientList})
      : super(const HandoffState()) {
    on<HandoffLoad>(_onLoad);
    on<HandoffDestinationSelected>(_onDestination);
    on<HandoffStartRequested>(_onStart);
    on<_HandoffPhaseArrived>(_onPhaseArrived);
    on<_HandoffDetailArrived>(_onDetailArrived);
    on<HandoffResetLocal>(_onResetLocal);
    on<HandoffEditorVisible>(_onEditorVisible);
  }

  // Public: a stream of just one patient's phase (auto-wires subscriptions).
  Stream<HandoffPhase> phaseStreamFor(String patientId) {
    _ensureStreams(patientId);
    return stream.map((s) => s.view(patientId).phase).distinct();
  }

  // Ensure we are listening to repo streams for this patient (idempotent).
  void _ensureStreams(String pid) {
    _subs.putIfAbsent(
        pid,
        () => repo
            .connectPhaseStream(pid)
            .listen((p) => add(_HandoffPhaseArrived(pid, p))));
    _detailSubs.putIfAbsent(
        pid,
        () => repo
            .connectDetailStream(pid)
            .listen((m) => add(_HandoffDetailArrived(pid, m))));
  }

  Future<void> _onLoad(HandoffLoad e, Emitter<HandoffState> emit) async {
    _ensureStreams(e.patientId);

    emit(state.updating(e.patientId, (v) => v.copyWith(isLoading: true)));

    int _rank(HandoffPhase p) {
      switch (p) {
        case HandoffPhase.none:
          return 0;
        case HandoffPhase.start:
          return 1;
        case HandoffPhase.holding:
          return 2;
        case HandoffPhase.complete:
          return 3;
      }
    }

    HandoffPhase _maxPhase(HandoffPhase a, HandoffPhase b) =>
        _rank(a) >= _rank(b) ? a : b;

    try {
      // Phase is async (REST); detail history is local/sync.
      final phaseFuture = repo.fetchCurrentPhase(e.patientId);
      final List<String> history =
          List.unmodifiable(repo.fetchDetailHistory(e.patientId));

      final fetched = await phaseFuture;

      // do not regress: keep whichever is further along
      final current = state.view(e.patientId).phase;
      final phase = _maxPhase(current, fetched);

      final seededDetails = switch (phase) {
        HandoffPhase.start => <String>[],
        HandoffPhase.holding => <String>[],
        HandoffPhase.complete => <String>[],
        _ => history,
      };

      emit(state.updating(
        e.patientId,
        (v) => v.copyWith(
          phase: phase,
          details: seededDetails,
          isLoading: false,
        ),
      ));
    } catch (err) {
      emit(state.updating(
        e.patientId,
        (v) => v.copyWith(isLoading: false, error: '$err'),
      ));
    }
  }

  void _onDestination(
      HandoffDestinationSelected e, Emitter<HandoffState> emit) {
    emit(state.updating(
      e.patientId,
      (v) => v.copyWith(destinationId: e.destinationId),
    ));
  }

  Future<void> _onStart(
      HandoffStartRequested e, Emitter<HandoffState> emit) async {
    final view = state.view(e.patientId);
    final dest = view.destinationId;
    if (dest == null) return;

    emit(state.updating(
      e.patientId,
      (v) => v.copyWith(isSubmitting: true, error: null),
    ));

    try {
      await repo.startHandoff(
          patientId: e.patientId, destinationFacilityId: dest);
      emit(state.updating(
        e.patientId,
        (v) => v.copyWith(isSubmitting: false),
      ));
      // Phase will update via websocket → _HandoffPhaseArrived
    } catch (err) {
      emit(state.updating(
        e.patientId,
        (v) => v.copyWith(isSubmitting: false, error: '$err'),
      ));
    }
  }

  void _onPhaseArrived(_HandoffPhaseArrived e, Emitter<HandoffState> emit) {
    final currentView = state.view(e.patientId);
    if (currentView.phase == e.phase) return;

    final shouldClearDetails = currentView.details.isNotEmpty &&
        (e.phase == HandoffPhase.start ||
            e.phase == HandoffPhase.holding ||
            e.phase == HandoffPhase.complete);

    emit(state.updating(
      e.patientId,
      (v) => v.copyWith(
        phase: e.phase,
        details: shouldClearDetails ? const <String>[] : v.details,
      ),
    ));

    if (e.phase == HandoffPhase.complete) {
      // 1) Requery casualty state ALWAYS (editor open or closed)
      onRefreshCasualtyStates?.call();
      // Need to refresh the patient list here as well.
      onRefreshPatientList?.call();

      // 2) Reset ONLY if the editor isn't open
      if (_editorOpen[e.patientId] != true) {
        Future.microtask(() => add(HandoffResetLocal(e.patientId)));
      }
    }
  }

  void _appendDetail(String pid, String msg, Emitter<HandoffState> emit) {
    final view = state.view(pid);

    // Once COMPLETE, don't mutate details anymore.
    if (view.phase == HandoffPhase.complete) return;

    final current = view.details;
    if (current.isNotEmpty && current.last == msg) return; // ignore dup tail
    final next = (List<String>.from(current)..add(msg)).take(50).toList();
    emit(state.updating(pid, (v) => v.copyWith(details: next)));
  }

  void _onDetailArrived(_HandoffDetailArrived e, Emitter<HandoffState> emit) =>
      _appendDetail(e.patientId, e.message, emit);

  void _onResetLocal(HandoffResetLocal e, Emitter<HandoffState> emit) {
    emit(state.updating(
        e.patientId,
        (v) => v.copyWith(
              phase: HandoffPhase.none, // ready to start a new transfer
              details: const <String>[], // clear detail panel
              destinationId: null, // force the user to pick again
              isSubmitting: false,
              error: null,
            )));
  }

  void _onEditorVisible(HandoffEditorVisible e, Emitter<HandoffState> emit) {
    _editorOpen[e.patientId] = e.isVisible;
  }

  @override
  Future<void> close() async {
    for (final s in _subs.values) {
      await s.cancel();
    }
    for (final s in _detailSubs.values) {
      await s.cancel();
    }
    await repo.disposeAll();
    return super.close();
  }
}
