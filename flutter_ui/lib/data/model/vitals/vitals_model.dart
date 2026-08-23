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
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

Logger _logger = Logger("VitalsModel", debugging: true);

enum VitalsOwnershipState {
  unknown,
  discovered,
  acquiringOwnership,
  ownershipAcquired,
  created,
  releaseOwnershipRequested,
  ownershipReleased,
  ownershipOffered,
}

VitalsOwnershipState? vitalsOwnershipStateFromWire(String? s) {
  switch (s) {
    case 'UNKNOWN':
      return VitalsOwnershipState.unknown;
    case 'DISCOVERED':
      return VitalsOwnershipState.discovered;
    case 'ACQUIRING_OWNERSHIP':
      return VitalsOwnershipState.acquiringOwnership;
    case 'OWNERSHIP_ACQUIRED':
      return VitalsOwnershipState.ownershipAcquired;
    case 'CREATED':
      return VitalsOwnershipState.created;
    case 'RELEASE_OWNERSHIP_REQUESTED':
      return VitalsOwnershipState.releaseOwnershipRequested;
    case 'OWNERSHIP_RELEASED':
      return VitalsOwnershipState.ownershipReleased;
    case 'OWNERSHIP_OFFERED':
      return VitalsOwnershipState.ownershipOffered;
    default:
      return null;
  }
}

String? vitalsOwnershipStateToWire(VitalsOwnershipState? s) {
  switch (s) {
    case VitalsOwnershipState.unknown:
      return 'UNKNOWN';
    case VitalsOwnershipState.discovered:
      return 'DISCOVERED';
    case VitalsOwnershipState.acquiringOwnership:
      return 'ACQUIRING_OWNERSHIP';
    case VitalsOwnershipState.ownershipAcquired:
      return 'OWNERSHIP_ACQUIRED';
    case VitalsOwnershipState.created:
      return 'CREATED';
    case VitalsOwnershipState.releaseOwnershipRequested:
      return 'RELEASE_OWNERSHIP_REQUESTED';
    case VitalsOwnershipState.ownershipReleased:
      return 'OWNERSHIP_RELEASED';
    case VitalsOwnershipState.ownershipOffered:
      return 'OWNERSHIP_OFFERED';
    default:
      return null;
  }
}

class VitalsValues extends Equatable {
  final double? bpHi;
  final double? bpLo;
  final double? ekg;

  /// Raw temperature *as received* from the wire (field name `temp`).
  /// Some federates incorrectly send this in °C instead of °F.
  final double? temp;
  final double? rr;
  final double? etco2;
  final double? spo2;
  final VitalsOwnershipState? ownershipState;

  static const VitalsValues allUnavailable = VitalsValues(
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  );

  const VitalsValues(
    this.bpHi,
    this.bpLo,
    this.ekg,
    this.temp,
    this.rr,
    this.etco2,
    this.spo2, {
    this.ownershipState,
  });

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        bpHi,
        bpLo,
        ekg,
        temp,
        rr,
        etco2,
        spo2,
        ownershipState,
      ];

  /// UI-only helper: returns a Fahrenheit value suitable for display.
  /// If the incoming raw value is below 50, assume it's Celsius and convert to °F.
  /// Otherwise, treat it as already in °F.
  double? get tempFahrenheitForDisplay {
    final t = temp;
    if (t == null) return null;
    if (t < 50 && t != 0) {
      // Likely °C → convert to °F
      return (t * 9 / 5) + 32;
    }
    return t; // Already °F
  }

  /// Expose whether we *assumed* a Celsius input for UI affordances (e.g., tooltip).
  bool get tempLikelyCelsius => (temp != null && temp! < 50 && temp != 0);

  /// UI-only SpO2 helper: if value looks like a fraction (0–1), convert to %.
  double? get spo2ForDisplay {
    final s = spo2;
    if (s == null) return null;
    if (s > 0 && s < 1) return s * 100; // e.g., 0.97 → 97
    return s; // already a percentage
  }

  /// Flag for UI affordances (tooltip/icon).
  bool get spo2LikelyFraction => spo2 != null && spo2! > 0 && spo2! < 1;

  factory VitalsValues.fromJson(Map<String, dynamic> json) {
    double? bpHi = json["systolicBp"]?.toDouble();
    double? bpLo = json["diastolicBp"]?.toDouble();
    double? ekg = json["heartRate"]?.toDouble();
    double? temp = json["temp"]?.toDouble();
    double? rr = json["respiratoryRate"]?.toDouble();
    double? etco2 = json["etco2"]?.toDouble();
    double? spo2 = json["spO2"]?.toDouble();
    // NEW: parse ownershipState (string → enum)
    final VitalsOwnershipState? own =
        vitalsOwnershipStateFromWire(json["ownershipState"] as String?);

    return VitalsValues(
      bpHi,
      bpLo,
      ekg,
      temp,
      rr,
      etco2,
      spo2,
      ownershipState: own,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "systolicBp": bpHi,
      "diastolicBp": bpLo,
      "heartRate": ekg,
      "temp": temp,
      "respiratoryRate": rr,
      "etco2": etco2,
      "spO2": spo2,
      "ownershipState": vitalsOwnershipStateToWire(ownershipState),
    };
  }

  // Non-breaking copy factory (adds optional ownershipState override)
  factory VitalsValues.copy(
    VitalsValues obj, {
    double? bpHi,
    double? bpLo,
    double? ekg,
    double? temp,
    double? rr,
    double? etco2,
    double? spo2,
    VitalsOwnershipState? ownershipState,
  }) {
    return VitalsValues(
      bpHi ?? obj.bpHi,
      bpLo ?? obj.bpLo,
      ekg ?? obj.ekg,
      temp ?? obj.temp,
      rr ?? obj.rr,
      etco2 ?? obj.etco2,
      spo2 ?? obj.spo2,
      ownershipState: ownershipState ?? obj.ownershipState,
    );
  }
}

class VitalsValuesStore extends BaseDataStore {
  final Map<String, VitalsValues> _vitalsMap = {};
  static const String _vitalsDataType = "Vitals";

  VitalsValuesStore._private() {
    MmsDataRouter().registerStoreForDataType(_vitalsDataType, this);
    _logger.log(1, "Registered VitalsValuesStore with MmsDataRouter");
    _logger.log(1, "Data type: $_vitalsDataType");
  }

  static final VitalsValuesStore _instance = VitalsValuesStore._private();

  factory VitalsValuesStore() => _instance;

  String get vitalsDataType => _vitalsDataType;

  /// Returns a list of patient IDs currently in the store
  List<String> get patientIds => _vitalsMap.keys.toList();

  /// Load vitals from JSON for a specific patient
  VitalsValues loadFromJson(String patientId, Map<String, dynamic> json) {
    VitalsValues vitals = VitalsValues.fromJson(json);
    putVitalsValues(patientId, vitals);
    return vitals;
  }

  /// Updates or adds vital signs for a patient
  void putVitalsValues(String patientId, VitalsValues? vitals) {
    VitalsValues? existingVitals = _vitalsMap[patientId];
    if (vitals != existingVitals) {
      VitalsValues useVitals = vitals ?? VitalsValues.allUnavailable;
      _vitalsMap[patientId] = useVitals;
      notifyListeners();
      //_logger.log(1, "Updated vitals for patient: $patientId");
    }
  }

  /// Retrieve vital signs for a specific patient
  VitalsValues getVitalsValues(String patientId) =>
      _vitalsMap[patientId] ?? VitalsValues.allUnavailable;

  /// Remove all vitals for a patient and notify listeners.
  bool removeVitalsForPatient(String patientId) {
    final removed = _vitalsMap.remove(patientId);
    if (removed != null) {
      notifyListeners();
      _logger.log(1, "Cleared vitals for patient: $patientId (deleted)");
      return true;
    }
    return false;
  }

  /// Batch helper (no-op if none removed).
  void removeVitalsForPatients(Iterable<String> ids) {
    var any = false;
    for (final id in ids) {
      any = _vitalsMap.remove(id) != null || any;
    }
    if (any) notifyListeners();
  }

  /// Parse and store incoming JSON data for a specific data type
  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    if (dataType == _vitalsDataType) {
      try {
        Map<String, dynamic> jsonMap = payload as Map<String, dynamic>;
        String? patientId = jsonMap["patientId"] as String?;

        if (patientId == null) {
          _logger.log(3, "Vitals data missing 'patientId': $jsonMap");
          return; // Skip storing invalid data
        }

        loadFromJson(patientId, jsonMap);
      } catch (e, stacktrace) {
        _logger.log(3, "Failed to parse Vitals JSON: $e\n$stacktrace");
      }
    }
  }

  /// Check if this store accepts JSON data
  @override
  bool acceptsJson() => true;

  /// Check if this store accepts raw string data
  @override
  bool acceptsRawString() => false;

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    // Intentionally empty.
  }

  @override
  bool acceptsBool() => false;

  @override
  bool acceptsDouble() => false;

  @override
  bool acceptsInt() => false;

  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {
    // Intentionally empty.
  }

  @override
  void storeDoubleByDataType(String dataType, String identifier, double data) {
    // Intentionally empty.
  }

  @override
  void storeIntByDataType(String dataType, String identifier, int data) {
    // Intentionally empty.
  }
}

class VitalsValuesStoreAccess extends ChangeNotifier {
  final VitalsValuesStore store = VitalsValuesStore();

  VitalsValuesStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
