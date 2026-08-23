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
import 'package:flutter_ui/data/provider/networking/data_router.dart';

class PatientInjury extends Equatable {
  final String injuryId;
  final String injuryType;
  final String description;
  final String detail;
  final List<String> locations;
  final int severity;
  final double? hemorrhageRate;
  final double? burnTbsa;
  final Map<String, String> mechanism;

  const PatientInjury({
    required this.injuryId,
    required this.injuryType,
    required this.description,
    required this.detail,
    required this.locations,
    this.severity = 0,
    this.hemorrhageRate,
    this.burnTbsa,
    this.mechanism = const {},
  });

  factory PatientInjury.fromJson(Map<String, dynamic> json) {
    final loc = json['bodyLocation'] as Map<String, dynamic>?;
    final locations = <String>[];
    if (loc != null) {
      for (final key in ['sagittalPlane', 'coronalPlane', 'generalRegion']) {
        final val = loc[key]?.toString();
        if (val != null && val != 'NOT_APPLICABLE') {
          locations.add(_toTitleCase(val));
        }
      }
    }

    final mechRaw = json['mechanismOfInjury'] as Map<String, dynamic>?;
    final mechanism = <String, String>{};
    if (mechRaw != null) {
      mechRaw.forEach((key, value) {
        final val = value?.toString() ?? '';
        mechanism[key] = (val.isEmpty || val == 'NOT_APPLICABLE')
            ? 'Not Applicable'
            : _toTitleCase(val);
      });
    }

    return PatientInjury(
      injuryId: (json['injuryId'] ?? '').toString(),
      injuryType: json['injuryType'] != null
          ? _toTitleCase(json['injuryType'].toString())
          : 'Not Applicable',
      description: json['description'] != null
          ? _toTitleCase(json['description'].toString())
          : 'Not Applicable',
      detail: (json['detail'] ?? '').toString(),
      locations: locations,
      severity: (json['severity'] as int?) ?? 0,
      hemorrhageRate: (json['hemorrhageRate'] as num?)?.toDouble(),
      burnTbsa: (json['totalBodySurfaceArea'] as num?)?.toDouble(),
      mechanism: mechanism,
    );
  }

  static String _toTitleCase(String s) {
    if (s.isEmpty) return s;
    return s
        .split('_')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  List<Object?> get props => [
        injuryId, injuryType, description, detail, locations,
        severity, hemorrhageRate, burnTbsa, mechanism,
      ];
}

class PatientInjuryWireStore extends BaseDataStore {
  static const String _dataType = 'Injury';

  final void Function(String patientId, PatientInjury injury) onUpsert;

  PatientInjuryWireStore({required this.onUpsert}) {
    MmsDataRouter().registerStoreForDataType(_dataType, this);
  }

  void unregister() {
    MmsDataRouter().removeStoreForDataType(_dataType, this);
  }

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
    if (dataType != _dataType) return;
    if (payload is! Map<String, dynamic>) return;

    final patientId = (payload['patientId'] ?? '').toString();
    if (patientId.isEmpty) return;

    final injury = PatientInjury.fromJson(payload);
    onUpsert(patientId, injury);
  }

  @override
  void storeRawStringByDataType(String d, String i, String r) {}
  @override
  void storeBoolByDataType(String d, String i, bool v) {}
  @override
  void storeIntByDataType(String d, String i, int v) {}
  @override
  void storeDoubleByDataType(String d, String i, double v) {}
}
