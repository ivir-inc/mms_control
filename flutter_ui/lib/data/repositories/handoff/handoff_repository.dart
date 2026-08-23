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

// handoff_repository.dart
import 'dart:async';
import 'package:flutter_ui/data/model/magic_transfer/magic_transfer.dart';
import 'package:flutter_ui/data/model/patient_transfer/patient_transfer.dart';
import 'package:flutter_ui/data/model/patient_transfer/transfer_state.dart';
import 'package:flutter_ui/data/model/vitals/vitals_model.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/provider/handoff/handoff_rest.dart';
import 'package:flutter_ui/logic/handoff/handoff_phase.dart';
import 'package:flutter_ui/logic/handoff/transfer_state_mapping.dart';

final _log = Logger("HandoffRepository");

class HandoffRepository {
  final HandoffRest rest;
  HandoffRepository(this.rest) {
    // Start listening to PatientTransfer websocket updates
    _ptStore.addListener(_onPatientTransferUpdated);
    // listen to Vitals + MagicTransfer stores for detail side-channel
    _vitalsStore.addListener(_onVitalsUpdated);
    _magicStore.addListener(_onMagicTransferUpdated);
  }

  final Map<String, StreamController<HandoffPhase>> _streams = {};
  final Map<String, StreamController<String>> _detailStreams = {};

  // keep latest transfer we’ve forwarded (by patient)
  final PatientTransferStore _ptStore = PatientTransferStore();
  final Map<String, int> _lastSeenMillis = {};

  // ───── detail stream state ─────
  final Map<String, StreamController<String>> _detailCtrls = {};
  final Map<String, List<String>> _detailHistory = {};

  // stores  dedupe caches for detail sources
  final VitalsValuesStore _vitalsStore = VitalsValuesStore();
  final MagicTransferStore _magicStore = MagicTransferStore();
  final Map<String, VitalsOwnershipState?> _lastOwnershipByPid = {};
  final Map<String, int> _lastMagicMillisByPid = {};

  StreamController<String> _detailControllerFor(String pid) {
    return _detailCtrls.putIfAbsent(
        pid, () => StreamController<String>.broadcast());
  }

  void _emitDetail(String pid, String message) {
    // Keep a small history (last 50) and de-dupe tail
    final hist = _detailHistory.putIfAbsent(pid, () => <String>[]);
    if (hist.isNotEmpty && hist.last == message) return;
    hist.add(message);
    if (hist.length > 50) hist.removeAt(0);

    _detailControllerFor(pid).add(message);
  }

// Public API used by Bloc
  Stream<String> connectDetailStream(String patientId) =>
      _detailControllerFor(patientId).stream;

  List<String> fetchDetailHistory(String patientId) => _isComplete(patientId)
      ? const <String>[]
      : List.unmodifiable(_detailHistory[patientId] ?? const <String>[]);

// (Optional) ensure you close these from your existing disposeAll()
  Future<void> _disposeDetailControllers() async {
    for (final c in _detailCtrls.values) {
      await c.close();
    }
    _detailCtrls.clear();
  }

// PatientTransfer → detail (only the transit/request states)
  void handlePatientTransferForDetails(PatientTransfer t) {
    switch (t.transferState) {
      case TransferState.transitingFromOrigin:
      case TransferState.requestForTransfer:
      case TransferState.transitingToDestination:
        // Use the *wire* value so it matches your uppercase spec exactly
        _emitDetail(t.patientId, t.transferState.wireValue);
        break;
      default:
        // Phase-related states are handled elsewhere; no detail emission
        break;
    }
  }

  void handleMagicTransferForDetails(MagicTransfer m) {
    if (_isComplete(m.patientId)) return; // ignore after complete
    _emitDetail(m.patientId, "Magic Transfer in progress");
  }

  void handleVitalsForDetails(String patientId, VitalsValues v) {
    if (_isComplete(patientId)) return; // ignore after complete
    final wire = vitalsOwnershipStateToWire(v.ownershipState);
    if (wire != null) _emitDetail(patientId, wire);
  }

// ── helpers ────────────────────────────────────────────────────────────────
  bool _isPhaseClearingState(TransferState s) =>
      s == TransferState.atOrigin ||
      s == TransferState.inHolding ||
      s == TransferState.atDestination;

  bool _isComplete(String pid) =>
      _lastSeenState[pid] == TransferState.atDestination;

  void _clearDetailsHistoryFor(String pid) {
    final hist = _detailHistory[pid];
    if (hist != null && hist.isNotEmpty) hist.clear();
  }

// Seed helper: get the latest known phase for a patient from the store.
  HandoffPhase? _latestPhaseFor(String patientId) {
    final t = _ptStore.forPatient(patientId);
    return t == null ? null : t.transferState.toHandoffPhase();
  }

// For widgets: stream of phases (now seeds on connect)
  Stream<HandoffPhase> connectPhaseStream(String patientId) {
    final controller = _streams.putIfAbsent(
      patientId,
      () => StreamController<HandoffPhase>.broadcast(sync: true),
    );

    // Seed immediately with the latest known value (if any).
    final latest = _latestPhaseFor(patientId);
    if (latest != null) {
      // Use a microtask so we don’t emit during map mutation or build.
      scheduleMicrotask(() => pushPhaseFromSocket(patientId, latest));
    } else {
      // Optional: also seed from backend if we don’t have a local event yet.
      // This prevents “stuck at none” when opening a patient before any WS event.
      fetchCurrentPhase(patientId).then((phase) {
        // Only emit if the stream still exists and we haven’t emitted something newer.
        final c = _streams[patientId];
        if (c != null && !c.isClosed) {
          pushPhaseFromSocket(patientId, phase);
        }
      }).catchError((_) {/* ignore in UI */});
    }

    return controller.stream;
  }

  void pushPhaseFromSocket(String patientId, HandoffPhase phase) {
    final c = _streams[patientId];
    if (c != null && !c.isClosed) c.add(phase);
  }

  void pushDetailFromSocket(String patientId, String message) {
    final c = _detailStreams[patientId];
    if (c != null && !c.isClosed) c.add(message);
  }

  Future<HandoffPhase> fetchCurrentPhase(String patientId) async {
    try {
      final s = await rest.fetchCurrentPhase(patientId);
      return HandoffPhaseX.fromBackend(s); // use the extension from logic/...
    } catch (e) {
      _log.logError(1, 'fetchCurrentPhase error: $e');
      return HandoffPhase.none;
    }
  }

  Future<void> startHandoff({
    required String patientId,
    required String destinationFacilityId,
  }) async {
    await rest.startHandoff(
        patientId: patientId, destinationFacilityId: destinationFacilityId);
  }

  Future<void> disposePatient(String patientId) async {
    await _streams[patientId]?.close();
    _streams.remove(patientId);
    await _detailStreams[patientId]?.close();
    _detailStreams.remove(patientId);
  }

  Future<void> disposeAll() async {
    _ptStore.removeListener(_onPatientTransferUpdated);
    _vitalsStore.removeListener(_onVitalsUpdated);
    _magicStore.removeListener(_onMagicTransferUpdated);

    for (final s in _streams.values) {
      await s.close();
    }
    _streams.clear();

    for (final s in _detailStreams.values) {
      await s.close();
    }
    _detailStreams.clear();

    await _disposeDetailControllers();
  }

  // === INTERNAL =============================================================

  final Map<String, TransferState> _lastSeenState = {};

  void _onPatientTransferUpdated() {
    for (final PatientTransfer t in _ptStore.asList) {
      final pid = t.patientId;
      final prevMillis = _lastSeenMillis[pid] ?? 0;
      final prevState = _lastSeenState[pid];

      final isNewer = t.receivedAtMillis > prevMillis;
      final stateChanged = t.transferState != prevState;

      if (isNewer || stateChanged) {
        _lastSeenMillis[pid] = t.receivedAtMillis;
        _lastSeenState[pid] = t.transferState;

        final phase = t.transferState.toHandoffPhase();
        pushPhaseFromSocket(pid, phase);
        _log.log(50,
            'WS PatientTransfer -> phase: $pid ${t.transferState} → $phase');

        // Clear repo-side history so reopen can't reseed stale messages
        if (_isPhaseClearingState(t.transferState)) {
          _clearDetailsHistoryFor(pid);
        }

        // also emit detail for transit/request states
        handlePatientTransferForDetails(t);
      }
    }
  }

  // emit detail on ownershipState changes (ignore nulls)
  void _onVitalsUpdated() {
    for (final pid in _vitalsStore.patientIds) {
      final v = _vitalsStore.getVitalsValues(pid);
      final curr = v.ownershipState;
      final prev = _lastOwnershipByPid[pid];
      if (curr != null && curr != prev) {
        _lastOwnershipByPid[pid] = curr;
        final wire = vitalsOwnershipStateToWire(curr);
        if (wire != null) _emitDetail(pid, wire);
      }
    }
  }

  // emit detail when a new MagicTransfer arrives (use its millis)
  void _onMagicTransferUpdated() {
    for (final m in _magicStore.asList) {
      final pid = m.patientId;
      final millis = m.receivedAtMillis;
      final prev = _lastMagicMillisByPid[pid] ?? 0;
      if (millis > prev) {
        _lastMagicMillisByPid[pid] = millis;
        handleMagicTransferForDetails(m);
      }
    }
  }
}
