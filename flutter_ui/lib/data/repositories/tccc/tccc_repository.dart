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

// tccc_repository.dart
import 'dart:async';
import 'package:flutter_ui/data/model/tccc/tccc_record.dart';
import 'package:flutter_ui/data/provider/tccc/tccc_rest.dart';
import 'package:flutter_ui/data/provider/tccc/tccc_wire_store.dart';

class TcccRepository {
  final TcccRest rest;
  final TcccWireStore wire; // <— inject
  TcccRepository(this.rest, this.wire);

  Stream<TcccRecord?> watchOne(
    String patientId, {
    Duration interval = const Duration(seconds: 5),
    Duration initialDelay = const Duration(milliseconds: 300),
  }) {
    final c = StreamController<TcccRecord?>.broadcast();

    Timer? timer;
    bool fetching = false;
    bool first = true;
    TcccRecord? last;
    StreamSubscription<String>? receivedSub;
    StreamSubscription<TcccRecord>? fullRecordSub;

    bool _same(TcccRecord? a, TcccRecord? b) => identical(a, b) || a == b;

    Future<void> poll() async {
      if (fetching) return;
      fetching = true;
      try {
        final rec = await rest.fetchForPatient(patientId); // may be null
        if (first) {
          first = false;
          last = rec;
          c.add(rec); // ensure UI stops any “loading” assumptions
        } else if (!_same(rec, last)) {
          last = rec;
          c.add(rec);
        }
      } catch (e, st) {
        c.addError(e, st);
      } finally {
        fetching = false;
      }
    }

    c.onListen = () {
      // Debounce initial poll so a WS push can win the race.
      if (initialDelay > Duration.zero) {
        Future.delayed(initialDelay, poll);
      } else {
        poll();
      }

      // Keep polling as a fallback
      timer = Timer.periodic(interval, (_) => poll());

      // Nudge: when WS says "TcccReceived" for *this* patient, poll immediately.
      receivedSub =
          wire.received$.where((id) => id == patientId).listen((_) => poll());

      // Optional fast-path: if you ever receive full DD1380 over WS, emit directly.
      fullRecordSub =
          wire.record$.where((rec) => rec.patientId == patientId).listen((rec) {
        last = rec;
        first = false;
        c.add(rec);
      });
    };

    c.onCancel = () {
      timer?.cancel();
      receivedSub?.cancel();
      fullRecordSub?.cancel();
    };

    return c.stream;
  }
}
