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
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

final _logger = Logger("SoundsModel");

/// **Heart Sound Enum** (Matches v3 FOM)
enum HeartSoundEnum {
  notApplicable,
  normal,
  murmur,
  aorticStenosisEarly,
  aorticStenosisLate,
  mitralRegurgitation,
  mitralStenosis,
  pulmonicStenosis,
  aorticInsufficiency,
  atrialSeptalDefect,
  ventricularSeptalDefect,
  tricuspidRegurgitation,
  patentDuctusAsteriosus,
  s2,
  s3,
  s4,
  pericardialRub;

  /// Convert from JSON (Handles `null` and backend inconsistencies)
  static HeartSoundEnum? fromJson(String? value) {
    if (value == null) return null;
    String normalizedValue = value.toLowerCase().replaceAll("_", "");

    return HeartSoundEnum.values.firstWhere(
      (e) => e.name.toLowerCase() == normalizedValue,
      orElse: () => HeartSoundEnum.notApplicable,
    );
  }

  /// Convert to JSON (Ensures consistency with backend format)
  String toJson() => name.toUpperCase();
}

/// **Lung Sound Enum**
enum LungSoundEnum {
  notApplicable,
  normal,
  cracklesCoarse,
  cracklesFine,
  pleuralRub,
  rhonchi,
  stridor,
  wheeze;

  static LungSoundEnum? fromJson(String? value) {
    if (value == null) return null;
    String normalizedValue = value.toLowerCase().replaceAll("_", "");

    return LungSoundEnum.values.firstWhere(
      (e) => e.name.toLowerCase() == normalizedValue,
      orElse: () => LungSoundEnum.notApplicable,
    );
  }

  String toJson() => name.toUpperCase();
}

/// **Bowel Sound Enum**
enum BowelSoundEnum {
  notApplicable,
  normal,
  hyperactiveBowels,
  hypoactiveBowels;

  static BowelSoundEnum? fromJson(String? value) {
    if (value == null) return null;
    String normalizedValue = value.toLowerCase().replaceAll("_", "");

    return BowelSoundEnum.values.firstWhere(
      (e) => e.name.toLowerCase() == normalizedValue,
      orElse: () => BowelSoundEnum.notApplicable,
    );
  }

  String toJson() => name.toUpperCase();
}

/// **Cough Sound Enum**
enum CoughSoundEnum {
  notApplicable,
  dry,
  wetWithPhlegm,
  wetWithBlood,
  wetWithoutPhlegm,
  coughWithWheeze,
  paroxysmalCough,
  barkingCough,
  whoopingCough,
  choking;

  static CoughSoundEnum? fromJson(String? value) {
    if (value == null) return null;
    
    // 🔹 Handle `N_A` or spelling inconsistencies
    String normalizedValue = value.toLowerCase().replaceAll("_", "");
    if (normalizedValue == "na" || normalizedValue == "n_a") return CoughSoundEnum.notApplicable;

    return CoughSoundEnum.values.firstWhere(
      (e) => e.name.toLowerCase() == normalizedValue,
      orElse: () => CoughSoundEnum.notApplicable,
    );
  }

  String toJson() => name.toUpperCase();
}

/// **Patient Sound Assignments**
class SoundsInfo extends Equatable {
  final String? patientId;
  final HeartSoundEnum? heartSound;
  final LungSoundEnum? lungSound;
  final BowelSoundEnum? bowelSound;
  final CoughSoundEnum? coughSound;

  const SoundsInfo({
    this.patientId,
    this.heartSound,
    this.lungSound,
    this.bowelSound,
    this.coughSound,
  });

  @override
  List<Object?> get props => [patientId, heartSound, lungSound, bowelSound, coughSound];

  /// **Factory to convert API JSON response to `SoundsInfo`**
  factory SoundsInfo.fromJson(Map<String, dynamic> json) {
    return SoundsInfo(
      patientId: json["patientId"],
      heartSound: HeartSoundEnum.fromJson(json["heartSound"]),
      lungSound: LungSoundEnum.fromJson(json["lungSound"]),
      bowelSound: BowelSoundEnum.fromJson(json["bowelSound"]),
      coughSound: CoughSoundEnum.fromJson(json["coughSound"]),
    );
  }

  /// **Convert `SoundsInfo` to JSON for API**
  Map<String, dynamic> toJson() {
    return {
      "patientId": patientId,
      "heartSound": heartSound?.toJson(),
      "lungSound": lungSound?.toJson(),
      "bowelSound": bowelSound?.toJson(),
      "coughSound": coughSound?.toJson(),
    };
  }
}

/// **Data Store for SoundsInfo**
class SoundsInfoStore extends BaseDataStore {
  final Map<String, SoundsInfo> _soundsInfoMap = {};
  static const String _soundsDataType = "SoundsInfo";

  SoundsInfoStore._private() {
    MmsDataRouter().registerStoreForDataType(_soundsDataType, this);
  }

  static final SoundsInfoStore _instance = SoundsInfoStore._private();

  factory SoundsInfoStore() => _instance;

  @override
  void dispose() {
    MmsDataRouter().removeStoreForDataType(_soundsDataType, this);
    super.dispose();
  }

  void updateSoundsInfo(String patientId, SoundsInfo newSoundsInfo) {
    _soundsInfoMap[patientId] = newSoundsInfo;
    _logger.log(0, "✅ Updated SoundsInfo for patientId: $patientId -> $newSoundsInfo");
    notifyListeners();
  }

  SoundsInfo getSoundsInfo(String? patientId) {
    return _soundsInfoMap[patientId] ?? SoundsInfo(patientId: patientId);
  }

  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    if (dataType == _soundsDataType && payload is Map<String, dynamic>) {
      try {
        String patientId = payload["patientId"] as String;
        updateSoundsInfo(patientId, SoundsInfo.fromJson(payload));
      } catch (e, stacktrace) {
        if (kDebugMode) {
          print("Error parsing JSON for SoundsInfo: $e");
          print(stacktrace);
        }
      }
    }
  }

  @override
  bool acceptsJson() => true;
  @override
  bool acceptsRawString() => false;
  @override
  bool acceptsBool() => false;
  @override
  bool acceptsDouble() => false;
  @override
  bool acceptsInt() => false;
  @override
  void storeRawStringByDataType(String dataType, String identifier, String rawString) {}
  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {}
  @override
  void storeDoubleByDataType(String dataType, String identifier, double data) {}
  @override
  void storeIntByDataType(String dataType, String identifier, int data) {}
}

/// **Provider for SoundsInfo Store Access**
class SoundsInfoStoreAccess extends ChangeNotifier {
  final SoundsInfoStore store = SoundsInfoStore();

  SoundsInfoStoreAccess() {
    store.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    store.removeListener(_onDataChanged);
    super.dispose();
  }
}
