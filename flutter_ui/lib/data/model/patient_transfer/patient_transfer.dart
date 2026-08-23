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
import 'package:flutter_ui/logic/utils/cast_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter_ui/data/storage/base_data_store.dart';
import 'transfer_state.dart';

class PatientTransfer extends Equatable {
  final String patientId;
  final TransferState transferState;
  final String? originFacilityId;
  final String? destinationFacilityId;
  final int receivedAtMillis;

  const PatientTransfer({
    required this.patientId,
    required this.transferState,
    required this.originFacilityId,
    required this.destinationFacilityId,
    required this.receivedAtMillis,
  });

  factory PatientTransfer.fromJson(Map<String, dynamic> json) {
    final m = CastUtils.cast<Map<String, dynamic>>(json, fallback: {});
    return PatientTransfer(
      patientId: CastUtils.cast(m['patientId'], fallback: ''),
      transferState: TransferStateWire.fromWire(
          CastUtils.cast(m['transferState'], fallback: null)),
      originFacilityId: CastUtils.cast(m['originFacilityId'], fallback: null),
      destinationFacilityId:
          CastUtils.cast(m['destinationFacilityId'], fallback: null),
      receivedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'transferState': transferState.wireValue,
        'originFacilityId': originFacilityId,
        'destinationFacilityId': destinationFacilityId,
        'receivedAtMillis': receivedAtMillis,
      };

  @override
  List<Object?> get props =>
      [patientId, transferState, originFacilityId, destinationFacilityId];
}

class PatientTransferStore extends BaseDataStore {
  static const String dataType = "PatientTransfer";

  // Latest transfer state per patient
  final Map<String, PatientTransfer> _byPatient = {};

  PatientTransferStore._private() {
    // Subscribe this store to websocket messages of type "PatientTransfer"
    MmsDataRouter().registerStoreForDataType(dataType, this);
  }
  static final PatientTransferStore _instance = PatientTransferStore._private();
  factory PatientTransferStore() => _instance;

  Map<String, PatientTransfer> get byPatient => Map.unmodifiable(_byPatient);
  PatientTransfer? forPatient(String patientId) => _byPatient[patientId];
  List<PatientTransfer> get asList => _byPatient.values.toList(growable: false);

  // ---- BaseDataStore contract ----
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
  void parseAndStoreJsonByDataType(String dt, dynamic payload) {
    if (dt != dataType) return;
    final map = CastUtils.cast<Map<String, dynamic>>(payload, fallback: {});
    final transfer = PatientTransfer.fromJson(map);
    if (transfer.patientId.isEmpty) return;

    _byPatient[transfer.patientId] = transfer;
    notifyListeners();
  }

  @override
  void storeRawStringByDataType(String dt, String id, String raw) {}
  @override
  void storeBoolByDataType(String dt, String id, bool data) {}
  @override
  void storeIntByDataType(String dt, String id, int data) {}
  @override
  void storeDoubleByDataType(String dt, String id, double data) {}
}

/// Convenience ChangeNotifier that mirrors `RecentEventsStoreAccess`.
class PatientTransferStoreAccess extends ChangeNotifier {
  final PatientTransferStore store = PatientTransferStore();
  PatientTransferStoreAccess() {
    store.addListener(notifyListeners);
  }
  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
