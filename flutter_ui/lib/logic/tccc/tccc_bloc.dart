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
import 'package:flutter_ui/data/model/tccc/tccc_record.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter_ui/data/provider/tccc/tccc_wire_store.dart';
import 'package:flutter_ui/data/repositories/tccc/tccc_repository.dart';
import 'package:flutter_ui/logic/tccc/tccc_event.dart';
import 'package:flutter_ui/logic/tccc/tccc_state.dart';

class _TcccPushed extends TcccEvent {
  final String patientId;
  final TcccRecord? record; // null = no DD1380 yet
  const _TcccPushed(this.patientId, this.record);
}

class _TcccErrored extends TcccEvent {
  final String message;
  const _TcccErrored(this.message);
}

class TcccBloc extends Bloc<TcccEvent, TcccState> {
  final TcccRepository repo;
  StreamSubscription<TcccRecord?>? _watchSub;
  String? _watchingPatientId;

  TcccBloc(this.repo) : super(const TcccState()) {
    on<StartWatchingTccc>(_onStart);
    on<StopWatchingTccc>(_onStop);
    on<_TcccPushed>(_onPushed);
    on<_TcccErrored>(_onErrored);

    final router = MmsDataRouter();
    router.registerStoreForDataType('TcccReceived', TcccWireStore.instance);
  }

  Future<void> _onStart(StartWatchingTccc e, Emitter<TcccState> emit) async {
    if (_watchingPatientId == e.patientId && _watchSub != null) return;

    await _watchSub?.cancel();
    _watchingPatientId = e.patientId;

    // show spinner for the initial fetch only
    emit(state.copyWith(isLoading: true, error: null));

    _watchSub = repo
        .watchOne(e.patientId,
            interval: e.interval ?? const Duration(seconds: 5),
            initialDelay: Duration.zero)
        .listen(
      // repo should yield `TcccRecord?` where `null` represents 404
      (recOrNull) => add(_TcccPushed(e.patientId, recOrNull)),
      onError: (err, st) {
        // defensively map 404-style errors to "not available"
        final s = err.toString();
        if (s.contains('404') || s.contains('Not Found')) {
          add(_TcccPushed(e.patientId, null));
        } else {
          add(_TcccErrored(s));
        }
      },
    );
  }

  Future<void> _onStop(StopWatchingTccc e, Emitter<TcccState> emit) async {
    await _watchSub?.cancel();
    _watchSub = null;
    _watchingPatientId = null;
  }

  void _onPushed(_TcccPushed e, Emitter<TcccState> emit) {
    final byId = Map<String, TcccRecord?>.from(state.byPatientId);
    byId[e.patientId] = e.record;
    emit(state.copyWith(byPatientId: byId, isLoading: false, error: null));
  }

  void _onErrored(_TcccErrored e, Emitter<TcccState> emit) {
    emit(state.copyWith(isLoading: false, error: e.message));
  }

  @override
  Future<void> close() async {
    await _watchSub?.cancel();
    return super.close();
  }
}
