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

import 'package:flutter_ui/data/storage/base_data_store.dart';

/// Listens to {"dataType":"PatientDeleted","dataPayload":{"patientId":"..."}}
class PatientDeletedWireStore extends BaseDataStore {
  final void Function(String patientId) onDeleted;

  PatientDeletedWireStore({required this.onDeleted});

  @override
  bool acceptsJson() => true;
  @override
  bool acceptsRawString() => false;
  @override
  bool acceptsBool() => false;
  @override
  bool acceptsInt() => false;
  @override
  bool acceptsDouble() => false;

  @override
  void parseAndStoreJsonByDataType(String dataType, dynamic payload) {
    if (dataType != 'PatientDeleted') return;

    void handle(Map<String, dynamic> p) {
      final id = (p['patientId'] ?? '').toString();
      if (id.isNotEmpty) onDeleted(id);
    }

    if (payload is List) {
      for (final e in payload) {
        if (e is Map<String, dynamic>) handle(e);
      }
    } else if (payload is Map<String, dynamic>) {
      handle(payload);
    }
  }

  // Unused
  @override
  void storeRawStringByDataType(String d, String i, String r) {}
  @override
  void storeBoolByDataType(String d, String i, bool v) {}
  @override
  void storeIntByDataType(String d, String i, int v) {}
  @override
  void storeDoubleByDataType(String d, String i, double v) {}
}
