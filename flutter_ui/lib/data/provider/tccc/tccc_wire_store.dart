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

// lib/data/provider/tccc/tccc_wire_store.dart
import 'dart:async';
import 'package:flutter_ui/data/model/tccc/tccc_record.dart';
import 'package:flutter_ui/data/storage/base_data_store.dart';

class TcccWireStore extends BaseDataStore {
  TcccWireStore._();
  static final TcccWireStore instance = TcccWireStore._();

  final _receivedCtrl = StreamController<String>.broadcast(); // patientId
  Stream<String> get received$ => _receivedCtrl.stream;

  final _recordCtrl =
      StreamController<TcccRecord>.broadcast(); // full record (optional)
  Stream<TcccRecord> get record$ => _recordCtrl.stream;

  // --- BaseDataStore overrides used by MmsDataRouter ---

  @override
  bool acceptsJson() => true;
  @override
  void parseAndStoreJsonByDataType(String dataType, dynamic payload) {
    try {
      // TcccReceived dataType value in use right now
      if (dataType == 'TcccReceived') {
        final id = payload?['patientId']?.toString();
        if (id != null && id.isNotEmpty) _receivedCtrl.add(id);
        return;
      }

      // DD1380 and Tccc dataType values unused at the moment; may be used in future
      if (dataType == 'DD1380' || dataType == 'Tccc') {
        if (payload is Map<String, dynamic>) {
          final rec = TcccRecord.fromApiJson(payload);
          _recordCtrl.add(rec);
        }
        return;
      }
    } catch (_) {
      // swallow bad payloads (or log if you prefer)
    }
  }

  // The router may call these; we can just refuse them.
  @override
  bool acceptsRawString() => false;
  @override
  void storeRawStringByDataType(String dt, String id, String raw) {}
  @override
  bool acceptsBool() => false;
  @override
  void storeBoolByDataType(String dt, String id, bool v) {}
  @override
  bool acceptsInt() => false;
  @override
  void storeIntByDataType(String dt, String id, int v) {}
  @override
  bool acceptsDouble() => false;
  @override
  void storeDoubleByDataType(String dt, String id, double v) {}

  @override
  void dispose() {
    super.dispose();
    _receivedCtrl.close();
    _recordCtrl.close();
  }
}
