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

// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_ui/data/storage/base_data_store.dart';

import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'medevac_model.dart';

class InjuryDetails extends Equatable {
  final String instanceName;
  final String injuryId;
  final List<String> locations;
  final int time;
  final String description;
  final String injuryType;
  final int severity;

  const InjuryDetails({
    required this.description,
    required this.injuryType,
    required this.severity,
    required this.locations,
    this.instanceName = "",
    this.injuryId = "",
    this.time = 0,
  });

  factory InjuryDetails.fromJson(Map<String, dynamic> json) {
    String instanceName = json["instanceName"];
    String injuryId = json["injuryId"];
    List<String> locations = json["locations"];
    int time = json["time"];
    String description = json["description"];
    String injuryType = json["injuryType"];
    int severity = json["severity"];
    return InjuryDetails(
      description: description,
      injuryType: injuryType,
      severity: severity,
      locations: locations,
      instanceName: instanceName,
      injuryId: injuryId,
      time: time,
    );
  }

  factory InjuryDetails.copy(
    InjuryDetails? obj, {
    String? instanceName,
    String? injuryId,
    List<String>? locations,
    int? time,
    String? description,
    String? injuryType,
    int? severity,
  }) {
    return InjuryDetails(
      description: description ?? obj?.description ?? "",
      injuryType: injuryType ?? obj?.injuryType ?? "",
      severity: severity ?? obj?.severity ?? 0,
      locations: locations ?? obj?.locations ?? [],
      instanceName: instanceName ?? obj?.instanceName ?? "",
      injuryId: injuryId ?? obj?.injuryId ?? "",
      time: time ?? obj?.time ?? 0,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        description,
        injuryType,
        severity,
        locations,
        injuryId,
        instanceName,
        time,
      ];
}

class InjuryDetailsStore extends BaseDataStore {
  final Map<String, List<InjuryDetails>> _injuryDetailsMap = {};
  static const String _injuryDetailsDataType = "Injury";

  InjuryDetailsStore._private() {
    MmsDataRouter().registerStoreForDataType(_injuryDetailsDataType, this);
  }

  static final _instance = InjuryDetailsStore._private();

  factory InjuryDetailsStore() => _instance;

  InjuryDetails loadFromJson(String patientId, Map<String, dynamic> json) {
    InjuryDetails details = InjuryDetails.fromJson(json);
    addInjuryDetails(patientId, details);
    return details;
  }

  void addInjuryDetails(String patientId, InjuryDetails details) {
    List<InjuryDetails> patientDetailsList = _injuryDetailsMap[patientId] ?? [];
    if (!patientDetailsList.contains(details)) {
      patientDetailsList.add(details);
      _injuryDetailsMap[patientId] = patientDetailsList.toList();
      OnesafMedevacResponseStore().receivedInjuryDetailsForPatient(patientId);
      notifyListeners();
    }
  }

  List<InjuryDetails> getInjuryDetailsList(String patientId) =>
      _injuryDetailsMap[patientId] ?? [];

  bool hasInjuryDetailsList(String patientId) =>
      getInjuryDetailsList(patientId).isNotEmpty;

  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    if (dataType == _injuryDetailsDataType) {
      Map<String, dynamic> jsonMap = payload as Map<String, dynamic>;
      String patientId = jsonMap["patientId"] as String;
      loadFromJson(patientId, jsonMap);
    }
  }

  @override
  bool acceptsBool() => false;

  @override
  bool acceptsDouble() => false;

  @override
  bool acceptsInt() => false;

  @override
  bool acceptsJson() => true;

  @override
  bool acceptsRawString() => false;

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

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    // Intentionally empty.
  }
}

class InjuryDetailsStoreAccess extends ChangeNotifier {
  final InjuryDetailsStore store = InjuryDetailsStore();

  InjuryDetailsStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
