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

import 'package:collection/collection.dart';
import 'package:flutter_ui/data/model/casualty_state/casualty_state.dart';
import 'package:flutter_ui/data/provider/casualty_state/casualty_state_rest.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter_ui/data/provider/patients/patient_deleted_wire_store.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("CasualtyStateRepository");

class CasualtyStateRepository {
  final CasualtyStateRest casualtyStateRest;
  final Map<String, CasualtyState> _casualtyStateMap = {};

  CasualtyStateRepository(this.casualtyStateRest);

  CasualtyState? getCasualtyState(String patientId) =>
      _casualtyStateMap[patientId];

  Future<void> addCasualtyState(CasualtyState cs) async {
    _logger.logDebug(
        1, 'Adding new casualty state for patient ${cs.patientId}');
    final posted = await casualtyStateRest.createCasualtyState(cs);
    _casualtyStateMap[posted.patientId] = posted;
  }

  Future<List<CasualtyState>> getCasualtyStates() async {
    final list = await casualtyStateRest.fetchCasualtyStates();
    for (final cs in list) {
      _casualtyStateMap[cs.patientId] = cs;
    }
    _logger.logDebug(1, "Total casualty states fetched: ${list.length}");
    return _casualtyStateMap.values.toList();
  }

  Future<void> removeCasualtyState(String patientId) async {
    _logger.logDebug(1, 'Removing casualty state for patient: $patientId');
    await casualtyStateRest.deleteCasualtyState(patientId);
    _casualtyStateMap.remove(patientId);
  }

  Future<void> updateCasualtyState(CasualtyState cs) async {
    _logger.logDebug(1, 'Updating casualty state for patient: ${cs.patientId}');
    final updated = await casualtyStateRest.putUpdateCasualtyState(cs);
    _casualtyStateMap[updated.patientId] = updated;
  }

  /// Stream-of-truth for all casualty states.
  /// Starts with an immediate fetch, then polls at [interval].
  /// Emits only when the ordered payload meaningfully changes.
  Stream<List<CasualtyState>> watchCasualtyStates({
    Duration interval = const Duration(seconds: 5),
  }) {
    final controller = StreamController<List<CasualtyState>>.broadcast();
    Timer? pollTimer;
    bool fetching = false;
    List<CasualtyState>? lastEmitted;
    final eq = const DeepCollectionEquality.unordered().equals;

    CasualtyStateWireStore? wireStore;
    PatientDeletedWireStore? delStore;

    void emitIfChanged() {
      final list = _casualtyStateMap.values.toList()
        ..sort((a, b) => a.patientId.compareTo(b.patientId));
      if (lastEmitted == null || !eq(lastEmitted, list)) {
        lastEmitted = List.of(list);
        controller.add(lastEmitted!);
      }
    }

    Future<void> pollOnce() async {
      if (fetching) return;
      fetching = true;
      try {
        final list = await casualtyStateRest.fetchCasualtyStates();
        final byPid = {for (final cs in list) cs.patientId: cs};
        _casualtyStateMap
          ..clear()
          ..addAll(byPid); // drops entries missing from the server
        emitIfChanged();
      } catch (e, st) {
        controller.addError(e, st);
      } finally {
        fetching = false;
      }
    }

    void start() {
      // Prefer WS
      wireStore = CasualtyStateWireStore(
        onUpsert: (cs) {
          _casualtyStateMap[cs.patientId] = cs;
          emitIfChanged();
        },
      );
      MmsDataRouter().registerStoreForDataType('CasualtyState', wireStore!);

      // WS deletions
      delStore = PatientDeletedWireStore(onDeleted: (pid) {
        if (_casualtyStateMap.remove(pid) != null) {
          emitIfChanged();
        }
      });
      MmsDataRouter().registerStoreForDataType('PatientDeleted', delStore!);

      // Poll fallback / correction
      pollOnce(); // initial snapshot
      pollTimer?.cancel();
      pollTimer = Timer.periodic(interval, (_) => pollOnce());
    }

    void stop() {
      pollTimer?.cancel();
      pollTimer = null;
      if (wireStore != null) {
        MmsDataRouter().removeStoreForDataType('CasualtyState', wireStore!);
        wireStore = null;
      }

      if (delStore != null) {
        MmsDataRouter().removeStoreForDataType('PatientDeleted', delStore!);
        delStore = null;
      }
    }

    controller.onListen = start;
    controller.onCancel = stop;
    return controller.stream;
  }
}
