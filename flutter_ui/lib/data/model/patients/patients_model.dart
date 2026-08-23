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

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter_ui/data/storage/base_data_store.dart';
import 'package:flutter_ui/logic/utils/cast_utils.dart';
import 'package:flutter_ui/logic/utils/string_utils.dart';
import 'package:flutter_ui/logic/utils/connector_status.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("PatientsModel", debugging: false);

class ConnectorStateInfo extends Equatable {
  final String connectorStateName;
  final String connectorState;
  const ConnectorStateInfo(this.connectorStateName, this.connectorState);

  factory ConnectorStateInfo.copy(ConnectorStateInfo connectorStateInfo) {
    return ConnectorStateInfo(connectorStateInfo.connectorStateName,
        connectorStateInfo.connectorState);
  }

  factory ConnectorStateInfo.fromJson(Map<String, dynamic> json) {
    return ConnectorStateInfo(
        json["name"].toString(), json["status"].toString());
  }

  ConnectorStatus? get connectorStatus =>
      ConnectorStatus.ofType(connectorState);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [connectorStateName, connectorState];
}

enum PatientSource {
  federation,
  scenarioEngine,
  unknown;

  @override
  String toString() => name;
}

class SinglePatientInfo extends Equatable {
  final String patientId;
  final String patientName;
  final PatientSource? patientSource;
  final bool? monitorPatient;
  final List<ConnectorStateInfo> _connectorStates = [];

  SinglePatientInfo(
    this.patientId,
    this.patientName, {
    this.patientSource,
    this.monitorPatient,
    List<ConnectorStateInfo> connectorStates = const [],
  }) {
    for (ConnectorStateInfo connectorState in connectorStates) {
      _connectorStates.add(ConnectorStateInfo.copy(connectorState));
    }
  }

  factory SinglePatientInfo.fromJson(Map<String, dynamic> json) {
    String patientId = json["patientId"]?.toString() ?? "";
    String patientName = json["patientName"]?.toString() ?? "";
    String patientSourceStr = json["patientSource"] ?? "UNKNOWN";
    bool monitorPatient = json["monitorPatient"] ?? false;
    PatientSource? patientSource = PatientSource.values.firstWhere(
        (e) => e.toString() == patientSourceStr,
        orElse: () => PatientSource.unknown);

    List<ConnectorStateInfo> connectorStatesList = <ConnectorStateInfo>[];
    dynamic connectorInfoListSpec = json["connectorInfoList"];
    List<Map<String, dynamic>> converted =
        List<Map<String, dynamic>>.from(connectorInfoListSpec ?? []);
    for (Map<String, dynamic> conversion in converted) {
      ConnectorStateInfo connectorStateInfo =
          ConnectorStateInfo.fromJson(conversion);
      connectorStatesList.add(connectorStateInfo);
    }
    _logger.log(1, "$patientId, $connectorStatesList");
  return SinglePatientInfo(
      patientId,
      patientName,
      patientSource: patientSource,
      monitorPatient: monitorPatient,
      connectorStates: connectorStatesList,
    );
  }

  UnmodifiableListView<ConnectorStateInfo> get connectorStates =>
      UnmodifiableListView(_connectorStates);

  String get humanizedPatientId {
    return StringUtils.humanizedId(patientId);
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        patientId,
        patientName,
        patientSource,
        monitorPatient,
        connectorStates,
      ];
}

class PatientInfoStore extends BaseDataStore {
  final HashMap<String, SinglePatientInfo> _patientMap =
      HashMap<String, SinglePatientInfo>();
  final List<String> _orderedPatientIds = <String>[];
  bool _isMultipatientDisplayEnabled = false;
  String? _mainPatientId;
  bool hasLoadedFromJson = false;
  static const String _wsPatientSummaryDataType = "PatientSummary";

  PatientInfoStore._private() {
    _logger.log(0, "In PatientInfoStore constructor");
    MmsDataRouter().registerStoreForDataType(
      _wsPatientSummaryDataType,
      this,
    );
  }

  static final PatientInfoStore _instance = PatientInfoStore._private();

  factory PatientInfoStore() => _instance;

  @override
  void dispose() {
    MmsDataRouter().removeStoreForDataType(_wsPatientSummaryDataType, this);
    super.dispose();
  }

  void loadSinglePatientFromJson(
    String patientId,
    Map<String, dynamic> jsonMap,
  ) {
    SinglePatientInfo patientInfo = SinglePatientInfo.fromJson(jsonMap);
    _logger.log(2, "$patientInfo");
    storePatient(
      patientInfo,
      notifyOnChange: true,
    );
  }

  void loadFromJson(
    List<Map<String, dynamic>> json, {
    bool isMain = false,
  }) {
    _logger.log(3, "$isMain: $json");
    hasLoadedFromJson = true;
    bool hasChanges = false;
    Set<String> receivedPatientIds = {};
    bool first = true;
    for (Map<String, dynamic> jsonMap in json) {
      SinglePatientInfo patientInfo = SinglePatientInfo.fromJson(jsonMap);
      _logger.log(3, "$patientInfo");
      bool changed = storePatient(
        patientInfo,
        isMain: isMain && first,
      );
      first = false;
      receivedPatientIds.add(patientInfo.patientId);
      hasChanges = hasChanges || changed;
    }
    Iterable<String> allStoredKeys = _patientMap.keys;
    List<String> newKeys = <String>[];
    for (String storedKey in allStoredKeys) {
      if (!receivedPatientIds.contains(storedKey)) {
        newKeys.add(storedKey);
      }
    }
    if (hasChanges || newKeys.isNotEmpty) {
      _logger.log(3, "$hasChanges - ${newKeys.length}");
      notifyListeners();
    }
  }

  /// Returns true if calling this method resulted in changed data, else
  /// returns false.
  bool storePatient(
    SinglePatientInfo singlePatientInfo, {
    bool notifyOnChange = false,
    bool isMain = false,
  }) {
    _logger.log(4, "$singlePatientInfo", counter: 0);
    String pId = singlePatientInfo.patientId;
    if (isMain) {
      _logger.log(4, "$pId, $isMain +");
      setMainPatientId(pId, force: isMain);
      _logger.log(4, "$pId, $isMain -", counter: 3);
    }
    bool hasChanges = false;
    SinglePatientInfo? pIdPatientInfo = patientInfo(pId);
    _logger.log(4, "$pIdPatientInfo", counter: 4);
    bool alreadyHasPatient = pIdPatientInfo != null;
    _patientMap[pId] = singlePatientInfo;
    if (!alreadyHasPatient) {
      _orderedPatientIds.add(pId);
      hasChanges = true;
    } else {
      hasChanges = pIdPatientInfo != singlePatientInfo;
    }
    _logger.log(
        4, "In storePatient, number of patients: ${_orderedPatientIds.length}");
    _logger.log(4, "Has changes: $hasChanges");
    _logger.log(4, "New Patient: $singlePatientInfo");
    if (notifyOnChange) {
      _logger.log(4, "Notify listeners +");
      notifyListeners();
      _logger.log(4, "Notify listeners -");
    }
    return hasChanges;
  }

  /// Returns a list of all stored patients.
  List<SinglePatientInfo> allPatients() {
    return _patientMap.values.toList();
  }

  /// Filters patients based on their monitor status.
  List<SinglePatientInfo> patientsMonitorStatus(bool monitorStatus) {
    return _patientMap.values
        .where((patient) => patient.monitorPatient == monitorStatus)
        .toList();
  }

  List<String> get patientIds {
    List<String> uiPatientIds = [];
    _logger.log(5, "${uiPatientIds.length} $uiPatientIds", counter: 0);
    if (_isMultipatientDisplayEnabled) {
      uiPatientIds = UnmodifiableListView(_orderedPatientIds);
      _logger.log(8, "${uiPatientIds.length} $uiPatientIds");
    } else if (mainPatientId != null) {
      uiPatientIds.add(mainPatientId!);
      _logger.log(9, "${uiPatientIds.length} $uiPatientIds");
    }
    _logger.log(5, "${uiPatientIds.length} $uiPatientIds");
    return uiPatientIds;
  }

  SinglePatientInfo? patientInfo(String patientId) => _patientMap[patientId];

  String? get mainPatientId => _mainPatientId;

  void setMainPatientId(
    String id, {
    bool force = false,
  }) {
    _logger.log(6, "$id - $force");
    if (force || _mainPatientId == null) {
      _mainPatientId = id;
    }
  }

  int get patientsCount => patientIds.length;

  bool get isMultipatientDisplayEnabled => _isMultipatientDisplayEnabled;

  set isMultipatientDisplayEnabled(bool isMultipatientDisplayEnabled) {
    bool isChanged =
        _isMultipatientDisplayEnabled != isMultipatientDisplayEnabled;
    _isMultipatientDisplayEnabled = isMultipatientDisplayEnabled;
    _logger.log(7, "$_isMultipatientDisplayEnabled");
    if (isChanged) {
      notifyListeners();
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
  void parseAndStoreJsonByDataType(String dataType, payload) {
    _logger.log(
        10001, "In Parse And Store JSON by Data Type, Patient Info Version");
    _logger.log(10001, "$dataType *******************************************");
    if (dataType == _wsPatientSummaryDataType) {
      _logger.log(10, dataType);
      _logger.log(10, "$payload");
      Map<String, dynamic> jsonMap = CastUtils.cast(payload, fallback: {});
      String patientId = (jsonMap["patientId"] as String?) ?? "";
      _logger.log(10, patientId);
      loadSinglePatientFromJson(patientId, jsonMap);
      _logger.log(10, "Loaded patient.");
    }
  }

  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {
    // Intentionally empty
  }

  @override
  void storeDoubleByDataType(String dataType, String identifier, double data) {
    // Intentionally empty
  }

  @override
  void storeIntByDataType(String dataType, String identifier, int data) {
    // Intentionally empty
  }

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    // Intentionally empty
  }
}

class PatientInfoStoreAccess extends ChangeNotifier {
  final PatientInfoStore store = PatientInfoStore();

  PatientInfoStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
