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

class MagicTransfer extends Equatable {
  final String patientId;
  final String facilityId;
  final bool local;
  final int receivedAtMillis;

  const MagicTransfer({
    required this.patientId,
    required this.facilityId,
    required this.local,
    required this.receivedAtMillis,
  });

  factory MagicTransfer.fromJson(Map<String, dynamic> json) {
    final m = CastUtils.cast<Map<String, dynamic>>(json, fallback: {});
    return MagicTransfer(
      patientId: CastUtils.cast(m['patientId'], fallback: ''),
      facilityId: CastUtils.cast(m['facilityId'], fallback: ''),
      local: CastUtils.cast(m['local'], fallback: false),
      receivedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'facilityId': facilityId,
        'local': local,
        'receivedAtMillis': receivedAtMillis,
      };

  @override
  List<Object?> get props => [patientId, facilityId, local];
}

class MagicTransferStore extends BaseDataStore {
  static const String dataType = "MagicTransfer";

  final Map<String, MagicTransfer> _byPatient = {};

  MagicTransferStore._private() {
    MmsDataRouter().registerStoreForDataType(dataType, this);
  }
  static final MagicTransferStore _instance = MagicTransferStore._private();
  factory MagicTransferStore() => _instance;

  Map<String, MagicTransfer> get byPatient => Map.unmodifiable(_byPatient);
  MagicTransfer? forPatient(String patientId) => _byPatient[patientId];
  List<MagicTransfer> get asList => _byPatient.values.toList(growable: false);

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
    final mt = MagicTransfer.fromJson(map);
    if (mt.patientId.isEmpty) return;

    _byPatient[mt.patientId] = mt;
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

class MagicTransferStoreAccess extends ChangeNotifier {
  final MagicTransferStore store = MagicTransferStore();
  MagicTransferStoreAccess() {
    store.addListener(notifyListeners);
  }
  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
