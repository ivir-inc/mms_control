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
import 'package:flutter_ui/logic/utils/string_utils.dart';

import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum OnesafTransportType {
  unknown,
  ground,
  air,
}

enum OnesafMedevacStatus {
  waiting,
  ready,
  requestEvac,
  informLoadPatient,
  notApplicable,
  acknowledgement,
  enroute,
  arrival,
  patientLoaded,
  dropoff,
  evacRequestSent,
  loadPatientSent,
}

class OnesafEnumUtils {
  final Map<String, OnesafTransportType> _transportTypesMap = {};
  final Map<String, OnesafMedevacStatus> _medevacStatusesMap = {};
  final Map<OnesafTransportType, String> _transportStringsMap = {};
  final Map<OnesafMedevacStatus, String> _medevacStringsMap = {};
  final List<OnesafMedevacStatus> _canMakeRequestStatuses = [
    OnesafMedevacStatus.ready,
    OnesafMedevacStatus.dropoff,
    OnesafMedevacStatus.notApplicable,
  ];
  final List<OnesafMedevacStatus> _canMakeReadyStatuses = [
    OnesafMedevacStatus.waiting,
    OnesafMedevacStatus.notApplicable,
  ];

  OnesafEnumUtils._private() {
    for (OnesafTransportType transportType in OnesafTransportType.values) {
      String underscoredTypeStr = StringUtils.dynaUnderscoredBreaks(
        transportType.name, // Updated
        upperCase: true,
      );
      _transportTypesMap[underscoredTypeStr] = transportType;
      _transportStringsMap[transportType] = underscoredTypeStr;
    }
    for (OnesafMedevacStatus medevacStatus in OnesafMedevacStatus.values) {
      String underscoredTypeStr = StringUtils.dynaUnderscoredBreaks(
        medevacStatus.name, // Updated
        upperCase: true,
      );
      _medevacStatusesMap[underscoredTypeStr] = medevacStatus;
      _medevacStringsMap[medevacStatus] = underscoredTypeStr;
    }
  }

  static final OnesafEnumUtils _instance = OnesafEnumUtils._private();

  factory OnesafEnumUtils() => _instance;

  OnesafTransportType getTransportType(String underscoredType) =>
      _transportTypesMap[underscoredType] ?? OnesafTransportType.unknown;

  OnesafMedevacStatus getMedevacStatus(String underscoredType) =>
      _medevacStatusesMap[underscoredType] ?? OnesafMedevacStatus.waiting;

  String getTransportString(OnesafTransportType transportType) =>
      _transportStringsMap[transportType] ?? "";

  String getMedevacString(OnesafMedevacStatus medevacStatus) =>
      _medevacStringsMap[medevacStatus] ?? "";

  String getHumanizedString(dynamic status) =>
      StringUtils.humanizedId(status.name); // Updated
}

class OnesafMedevacRequest extends Equatable {
  final String patientId;
  final OnesafMedevacStatus evacState;
  final OnesafTransportType transportType;
  final String? vehicleId;

  const OnesafMedevacRequest({
    required this.patientId,
    required this.evacState,
    this.transportType = OnesafTransportType.unknown,
    this.vehicleId,
  });

  Map<String, dynamic> toJson() {
    return {
      "patientId": patientId,
      "evacState": evacStateString,
      if (transportType != OnesafTransportType.unknown)
        "transportType": transportTypeString,
      "vehicleId": vehicleId,
    };
  }

  String get evacStateString => StringUtils.dynaUnderscoredBreaks(
        evacState.name, // Updated
        upperCase: true,
      );

  String get transportTypeString => StringUtils.dynaUnderscoredBreaks(
        transportType.name, // Updated
        upperCase: true,
      );

  @override
  List<Object?> get props => [
        patientId,
        evacState,
        transportType,
        vehicleId,
      ];
}

class OnesafMedevacResponse extends Equatable {
  final String patientId;
  final OnesafTransportType transportType;
  final String siteName;
  final String vehicleId;
  final OnesafMedevacStatus evacState;

  const OnesafMedevacResponse(
    this.patientId,
    this.transportType,
    this.evacState, {
    this.siteName = "",
    this.vehicleId = "",
  });

  factory OnesafMedevacResponse.fromJson(Map<String, dynamic> jsonMap) {
    return OnesafMedevacResponse(
      jsonMap["patientId"]?.toString() ?? "",
      OnesafEnumUtils().getTransportType(
        jsonMap["transportType"],
      ),
      OnesafEnumUtils().getMedevacStatus(
        jsonMap["evacState"],
      ),
      siteName: jsonMap["siteName"]?.toString() ?? "",
      vehicleId: jsonMap["vehicleId"]?.toString() ?? "",
    );
  }

  factory OnesafMedevacResponse.unknown(String patientId) =>
      OnesafMedevacResponse(
        patientId,
        OnesafTransportType.unknown,
        OnesafMedevacStatus.waiting,
      );

  factory OnesafMedevacResponse.ready(String patientId) =>
      OnesafMedevacResponse(
        patientId,
        OnesafTransportType.unknown,
        OnesafMedevacStatus.ready,
      );

  @override
  List<Object?> get props => [
        patientId,
        transportType,
        siteName,
        vehicleId,
        evacState,
      ];
}

class OnesafMedevacResponseStore extends BaseDataStore {
  final Map<String, OnesafMedevacResponse> _onesafMedevacResponseMap = {};
  static const String _onesafMedevacResponseDataType = "MedEvac";

  OnesafMedevacResponseStore._private() {
    MmsDataRouter()
        .registerStoreForDataType(_onesafMedevacResponseDataType, this);
  }

  static final _instance = OnesafMedevacResponseStore._private();

  factory OnesafMedevacResponseStore() => _instance;

  OnesafMedevacResponse loadFromJson(
      String patientId, Map<String, dynamic> json) {
    OnesafMedevacResponse response = OnesafMedevacResponse.fromJson(json);
    addOnesafMedevacResponse(patientId, response);
    return response;
  }

  void addOnesafMedevacResponse(
      String patientId, OnesafMedevacResponse response) {
    OnesafMedevacResponse lastPatientResponse = getLastResponse(patientId);
    if (response != lastPatientResponse) {
      _onesafMedevacResponseMap[patientId] = response;
      notifyListeners();
    }
  }

  void receivedInjuryDetailsForPatient(String patientId) {
    if (canMakeReady(patientId)) {
      addOnesafMedevacResponse(
          patientId, OnesafMedevacResponse.ready(patientId));
    }
  }

  OnesafMedevacResponse getLastResponse(String patientId) =>
      _onesafMedevacResponseMap[patientId] ??
      OnesafMedevacResponse.unknown(patientId);

  String getHumanizedLastMedevacStatus(String patientId) =>
      StringUtils.humanizedId(
          getLastResponse(patientId).evacState.name); // Updated

  bool readyToLoad(String patientId) =>
      getLastResponse(patientId).evacState == OnesafMedevacStatus.arrival;

  bool canMakeRequest(String patientId) => OnesafEnumUtils()
      ._canMakeRequestStatuses
      .contains(getLastResponse(patientId).evacState);

  bool canMakeReady(String patientId) => OnesafEnumUtils()
      ._canMakeReadyStatuses
      .contains(getLastResponse(patientId).evacState);

  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    if (dataType == _onesafMedevacResponseDataType) {
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

class OnesafMedevacResponseStoreAccess extends ChangeNotifier {
  final OnesafMedevacResponseStore store = OnesafMedevacResponseStore();

  OnesafMedevacResponseStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
