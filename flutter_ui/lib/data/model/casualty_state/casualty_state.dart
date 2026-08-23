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

import 'package:equatable/equatable.dart';
import 'package:flutter_ui/data/storage/base_data_store.dart';

class CasualtyState extends Equatable {
  final String id;
  final String patientId;
  final String evacuationPriority; // backend values (e.g., ROUTINE)
  final String triageClassification; // backend values (e.g., DELAYED)
  final String facilityId; // String; same on front and backend

  const CasualtyState({
    required this.id,
    required this.patientId,
    required this.evacuationPriority,
    required this.triageClassification,
    required this.facilityId,
  });

  CasualtyState copyWith({
    String? id,
    String? patientId,
    String? evacuationPriority,
    String? triageClassification,
    String? facilityId,
  }) {
    return CasualtyState(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      evacuationPriority: evacuationPriority ?? this.evacuationPriority,
      triageClassification: triageClassification ?? this.triageClassification,
      facilityId: facilityId ?? this.facilityId,
    );
  }

  @override
  List<Object?> get props =>
      [id, patientId, evacuationPriority, triageClassification, facilityId];
}

class CasualtyStateWireStore extends BaseDataStore {
  final void Function(CasualtyState cs) onUpsert;

  CasualtyStateWireStore({
    required this.onUpsert,
  });

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
    if (dataType != 'CasualtyState') return;
    _ingest(payload);
  }

  void _ingest(dynamic payload) {
    if (payload is List) {
      for (final item in payload) _ingest(item);
      return;
    }
    if (payload is! Map<String, dynamic>) return;

    final patientId = (payload['patientId'] ?? '').toString();
    if (patientId.isEmpty) return;

    // Optional extras we currently don't persist (available if you want them later)
    final bool isLocal = payload['local'] == true; // true
    final String? instanceName = payload['instanceName'] as String?; // null

    // Map only the fields your model has today
    final cs = CasualtyState(
      id: (payload['id'] ?? 'ws-$patientId').toString(), // "0"
      patientId: patientId,
      evacuationPriority:
          (payload['evacuationPriority'] ?? '').toString(), // "ROUTINE"
      triageClassification:
          (payload['triageClassification'] ?? '').toString(), // "MINIMAL"
      facilityId:
          (payload['facilityId'] ?? '').toString(), // "" → Unassigned in UI
    );

    // You can log/use isLocal/instanceName here if you ever need to.
    onUpsert(cs);
  }

  // Unused for this store
  @override
  void storeRawStringByDataType(String d, String i, String r) {}
  @override
  void storeBoolByDataType(String d, String i, bool v) {}
  @override
  void storeIntByDataType(String d, String i, int v) {}
  @override
  void storeDoubleByDataType(String d, String i, double v) {}
}
