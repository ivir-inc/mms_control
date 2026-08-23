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
import 'package:flutter_ui/logic/utils/value_string_mapper.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'handoff_image_details_model.dart';

Logger _logger = Logger(
  "HandoffReadyChecksModel",
  debugging: true,
);

enum HandoffReadyChecks {
  initiated,
  received,
  waiting,
}

class MmsIncludeHandshakeConfig {
  static const bool includeHandshakeInit = false;
  static const bool includeSaveIcs = true;
  static const bool includeHandoffRetrieval = true;
  static const bool includeHandoffReceiveGalleryDismissal = false;
}

class HandoffReadyChecksModel extends Equatable {
  final String patientId;
  final String? facilityId;
  final HandoffReadyChecks readyCheck;

  const HandoffReadyChecksModel(
    this.patientId,
    this.facilityId,
    this.readyCheck,
  );

  factory HandoffReadyChecksModel.copy(
    HandoffReadyChecksModel model,
    String? patientId,
    String? facilityId,
    HandoffReadyChecks? readyChecks,
  ) =>
      model.replica(patientId, facilityId, readyChecks);

  HandoffReadyChecksModel replica(
    String? patientId,
    String? facilityId,
    HandoffReadyChecks? readyCheck,
  ) =>
      HandoffReadyChecksModel(
        patientId ?? this.patientId,
        facilityId ?? this.facilityId,
        readyCheck ?? this.readyCheck,
      );

  @override
  List<Object?> get props => [
        patientId,
        facilityId,
        readyCheck,
      ];
}

class HandoffReadyChecksStore extends BaseDataStore {
  static const _handoffReadyChecksDataType = "HandoffStatus";
  static StdValStrMapper handoffReadyChecksMapper = StdValStrMapper();

  final Map<String, bool> _patientInitiatedReadyChecks = {};
  final Map<String, bool> _patientReceivedReadyChecks = {};
  final Map<String, Map<String, bool>> _patientFacilityInitMap = {};
  final Map<String, Map<String, bool>> _patientFacilityReceiveMap = {};

  HandoffReadyChecksStore._private() {
    handoffReadyChecksMapper.registerValues(HandoffReadyChecks.values);
    MmsDataRouter().registerStoreForDataType(
      _handoffReadyChecksDataType,
      this,
    );
  }

  static final HandoffReadyChecksStore _instance =
      HandoffReadyChecksStore._private();

  factory HandoffReadyChecksStore() => _instance;

  @override
  void dispose() {
    MmsDataRouter().removeStoreForDataType(
      _handoffReadyChecksDataType,
      this,
    );
    super.dispose();
  }

  List<String> get patientsInitList =>
      _patientInitiatedReadyChecks.keys.toList(growable: false);

  List<String> get patientsReceiveList =>
      _patientReceivedReadyChecks.keys.toList(growable: false);

  List<String> get allPatientsList {
    List<String> patientsList = List.of(_patientInitiatedReadyChecks.keys);
    for (String patient in _patientReceivedReadyChecks.keys) {
      if (!patientsList.contains(patient)) {
        patientsList.add(patient);
      }
    }
    return patientsList;
  }

  bool getInitForPatient(String patientId) =>
      _patientInitiatedReadyChecks[patientId] ?? false;

  bool getInitForPatientAndFacility(
    String patientId,
    String? facilityId,
  ) =>
      (_patientFacilityInitMap[patientId] ?? {})[facilityId ?? ""] ?? false;

  bool getReceiveForPatient(String patientId) =>
      _patientReceivedReadyChecks[patientId] ?? false;

  bool getReceiveForPatientAndFacility(
    String patientId,
    String? facilityId,
  ) =>
      (_patientFacilityReceiveMap[patientId] ?? {})[facilityId ?? ""] ?? false;

  bool setInitForPatient(
    String patientId,
    bool isInit, {
    bool notifyOnChange = false,
  }) {
    _logger.log(
      0,
      "Setting init $isInit for patient $patientId",
      counter: 0,
    );
    bool isAlreadyInit = getInitForPatient(patientId);
    bool hasChange = isAlreadyInit != isInit;
    if (hasChange) {
      _logger.log(1, "Init was changed.");
      _patientInitiatedReadyChecks[patientId] = isInit;
      if (notifyOnChange) {
        _logger.log(2, "Notifying listeners.");
        notifyListeners();
      }
    }
    return hasChange;
  }

  bool setInitForPatientAndFacility(
    String patientId,
    String facilityId,
    bool isInit, {
    bool notifyOnChange = false,
  }) {
    Map<String, bool>? facilityMap = _patientFacilityInitMap[patientId];
    if (facilityMap == null) {
      facilityMap = {};
      _patientFacilityInitMap[patientId] = facilityMap;
    }
    bool isAlreadyInit = facilityMap[facilityId] ?? false;
    facilityMap[facilityId] = isInit;
    bool hasChange = isAlreadyInit != isInit;
    if (hasChange && notifyOnChange) {
      notifyListeners();
    }
    return hasChange;
  }

  bool setReceiveForPatient(
    String patientId,
    bool isReceived, {
    bool notifyOnChange = false,
  }) {
    _logger.log(
      10,
      "Setting receive $isReceived for patient $patientId",
      counter: 0,
    );
    bool isAlreadyReceived = _patientReceivedReadyChecks[patientId] ?? false;
    bool hasChange = isAlreadyReceived != isReceived;
    if (hasChange) {
      _logger.log(11, "Receive was changed.");
      _patientReceivedReadyChecks[patientId] = isReceived;
      if (notifyOnChange) {
        _logger.log(12, "Notifying listeners.");
        notifyListeners();
      }
    }
    return hasChange;
  }

  bool setReceiveForPatientAndFacility(
    String patientId,
    String facilityId,
    bool isReceive, {
    bool notifyOnChange = false,
  }) {
    Map<String, bool>? facilityMap = _patientFacilityReceiveMap[patientId];
    if (facilityMap == null) {
      facilityMap = {};
      _patientFacilityReceiveMap[patientId] = facilityMap;
    }
    bool isAlreadyReceive = facilityMap[facilityId] ?? false;
    facilityMap[facilityId] = isReceive;
    bool hasChange = isAlreadyReceive != isReceive;
    if (hasChange && notifyOnChange) {
      notifyListeners();
    }
    return hasChange;
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
    if (dataType == _handoffReadyChecksDataType) {
      _logger.log(20, "Parse and store json", counter: 0);
      bool hasChange = false;
      Map<String, dynamic> jsonMap = payload as Map<String, dynamic>;
      String patientId = jsonMap["patientId"] as String;
      String statusStr = jsonMap["status"] as String;
      String facilityId = jsonMap["facilityId"] as String;
      _logger.log(21, "Storing patientId: $patientId");
      _logger.log(22, "Storing status: $statusStr");
      _logger.log(23, "Storing facilityId: $facilityId");
      if (statusStr ==
          handoffReadyChecksMapper
              .stdStringForVal(HandoffReadyChecks.initiated)) {
        bool hasChange1 =
            setInitForPatientAndFacility(patientId, facilityId, true);
        bool hasChange2 = setInitForPatient(
          patientId,
          true,
        );
        hasChange = hasChange1 || hasChange2;
      } else if (statusStr ==
          handoffReadyChecksMapper
              .stdStringForVal(HandoffReadyChecks.received)) {
        bool hasChange1 =
            setReceiveForPatientAndFacility(patientId, facilityId, true);
        bool hasChange2 = setReceiveForPatient(
          patientId,
          true,
        );
        hasChange = hasChange1 || hasChange2;
      }
      if (hasChange) {
        _logger.log(24, "Status changed for patient and/or facility.");
        notifyListeners();
      }
    }
  }

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

class HandoffReadyChecksStoreAccess extends ChangeNotifier {
  final HandoffReadyChecksStore store = HandoffReadyChecksStore();
  HandoffReadyChecksStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}

enum MmsHandoffInitStatus {
  waiting,
  initOnly,
  initAndReceive,
  imagesSubmitted,
}

class MmsHandoffStatusForInitiatorStore extends ChangeNotifier {
  final Map<String, MmsHandoffInitStatus> _patientInitStatusMap = {};
  final HandoffReadyChecksStore store = HandoffReadyChecksStore();

  MmsHandoffStatusForInitiatorStore._private() {
    store.addListener(statusChanged);
  }

  static final MmsHandoffStatusForInitiatorStore _instance =
      MmsHandoffStatusForInitiatorStore._private();

  factory MmsHandoffStatusForInitiatorStore() => _instance;

  MmsHandoffInitStatus patientInitStatus(String patientId) {
    _logger.log(30, "Get initiator status for patient $patientId", counter: 0);
    MmsHandoffInitStatus status = _patientInitStatusMap[patientId] ??
        (MmsIncludeHandshakeConfig.includeHandshakeInit
            ? MmsHandoffInitStatus.waiting
            : MmsHandoffInitStatus.initAndReceive);
    _logger.log(31, status.name);
    return status;
  }

  void imagesSubmitted(String patientId) {
    _logger.log(
        40, "Tracking that images were submitted for patient $patientId",
        counter: 0);
    MmsHandoffInitStatus? currentPatientInitStatus =
        _patientInitStatusMap[patientId];
    _logger.log(41, "Current status:");
    _logger.log(42, currentPatientInitStatus?.name ?? "String.none");
    bool hasChanges =
        currentPatientInitStatus != MmsHandoffInitStatus.imagesSubmitted;
    _patientInitStatusMap[patientId] = MmsHandoffInitStatus.imagesSubmitted;
    if (hasChanges) {
      _logger.log(44, "Initiator Status Map changed.");
      notifyListeners();
    }
  }

  void statusChanged() {
    _logger.log(50, "Initiator Status may have changed.", counter: 0);
    bool hasChanges = false;
    List<String> patientsList = store.allPatientsList;
    for (String patientInit in patientsList) {
      _logger.log(51, "Check status for patient $patientInit");
      MmsHandoffInitStatus? patientInitStatus =
          _patientInitStatusMap[patientInit];
      _logger.log(52, "Current initiator status:");
      _logger.log(53, patientInitStatus?.name ?? "String.none");
      MmsHandoffInitStatus modInitStatus = initStatusModForPatient(
        patientInit,
        patientInitStatus,
      );
      _logger.log(54, "Modified initiator status:");
      _logger.log(55, modInitStatus.name);
      if (patientInitStatus != modInitStatus) {
        _patientInitStatusMap[patientInit] = modInitStatus;
        hasChanges = true;
      }
    }
    if (hasChanges) {
      _logger.log(56, "Notifying listeners");
      notifyListeners();
    }
  }

  MmsHandoffInitStatus initStatusModForPatient(
    String patientId,
    MmsHandoffInitStatus? currentStatus,
  ) {
    if (currentStatus == MmsHandoffInitStatus.imagesSubmitted) {
      return MmsHandoffInitStatus.imagesSubmitted;
    }
    bool isInit = store.getInitForPatient(patientId);
    bool isReceive = store.getReceiveForPatient(patientId);
    if (isInit) {
      if (isReceive) {
        return MmsHandoffInitStatus.initAndReceive;
      } else {
        return MmsHandoffInitStatus.initOnly;
      }
    }
    return MmsHandoffInitStatus.waiting;
  }

  @override
  void dispose() {
    store.removeListener(statusChanged);
    super.dispose();
  }
}

class MmsHandoffStatusForInitiatorStoreAccess extends ChangeNotifier {
  final MmsHandoffStatusForInitiatorStore store =
      MmsHandoffStatusForInitiatorStore();

  MmsHandoffStatusForInitiatorStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}

enum MmsHandoffReceiveStatus {
  waiting,
  initOnly,
  initOnlyReceiveSent,
  initAndReceive,
  imagesReceived,
  dismissed,
}

class MmsHandoffStatusForReceiverStore extends ChangeNotifier {
  final Map<String, MmsHandoffReceiveStatus> _patientReceiveStatusMap = {};
  final HandoffReadyChecksStore store = HandoffReadyChecksStore();
  final HandoffImageDetailsStore imageDetailsStore = HandoffImageDetailsStore();

  MmsHandoffStatusForReceiverStore._private() {
    store.addListener(statusChanged);
    imageDetailsStore.addListener(imageDetailsChanged);
  }

  static final MmsHandoffStatusForReceiverStore _instance =
      MmsHandoffStatusForReceiverStore._private();

  factory MmsHandoffStatusForReceiverStore() => _instance;

  MmsHandoffReceiveStatus patientReceiveStatus(String patientId) {
    _logger.log(60, "Get receiver status for patient $patientId", counter: 0);
    MmsHandoffReceiveStatus status =
        _patientReceiveStatusMap[patientId] ?? MmsHandoffReceiveStatus.waiting;
    _logger.log(61, status.name);
    return status;
  }

  void _setStatus(
    String patientId,
    MmsHandoffReceiveStatus newStatus,
  ) {
    _logger.log(70, "New receiver status:", counter: 0);
    _logger.log(71, newStatus.name);
    MmsHandoffReceiveStatus? currentPatientReceiveStatus =
        _patientReceiveStatusMap[patientId];
    _logger.log(72, "Original receiver status:");
    _logger.log(73, currentPatientReceiveStatus?.name ?? "String.none");
    bool hasChanges = currentPatientReceiveStatus != newStatus;
    if (hasChanges) {
      _logger.log(74, "Status changed. Save and notify listeners.");
      _patientReceiveStatusMap[patientId] = newStatus;
      notifyListeners();
    }
  }

  void receiveSent(String patientId) => _setStatus(
        patientId,
        MmsHandoffReceiveStatus.initOnlyReceiveSent,
      );

  void imagesReceived(String patientId) => _setStatus(
        patientId,
        MmsHandoffReceiveStatus.imagesReceived,
      );

  void dismissed(String patientId) => _setStatus(
        patientId,
        MmsHandoffReceiveStatus.dismissed,
      );

  void statusChanged() {
    _logger.log(80, "Receiver Status may have changed.", counter: 0);
    bool hasChanges = false;
    List<String> patientsReceiveList = store.allPatientsList;
    for (String patientReceive in patientsReceiveList) {
      _logger.log(81, "Check status for patient $patientReceive");
      MmsHandoffReceiveStatus? patientReceiveStatus =
          _patientReceiveStatusMap[patientReceive];
      _logger.log(82, "Current receiver status:");
      _logger.log(83, patientReceiveStatus?.name ?? "String.none");
      MmsHandoffReceiveStatus modReceiveStatus = receiveStatusModForPatient(
        patientReceive,
        patientReceiveStatus,
      );
      _logger.log(84, "Modified receiver status:");
      _logger.log(85, modReceiveStatus.name);
      if (patientReceiveStatus != modReceiveStatus) {
        _patientReceiveStatusMap[patientReceive] = modReceiveStatus;
        hasChanges = true;
      }
    }
    if (hasChanges) {
      _logger.log(86, "Notifying listeners");
      notifyListeners();
    }
  }

  void imageDetailsChanged() {
    Set<String> allPatientIds = imageDetailsStore.allPatientIds();
    for (String patientId in allPatientIds) {
      if (imageDetailsStore.patientImagesList(patientId).isNotEmpty) {
        imagesReceived(patientId);
      }
    }
  }

  MmsHandoffReceiveStatus receiveStatusModForPatient(
    String patientId,
    MmsHandoffReceiveStatus? currentStatus,
  ) {
    if (currentStatus == MmsHandoffReceiveStatus.dismissed) {
      return MmsHandoffReceiveStatus.dismissed;
    }
    if (currentStatus == MmsHandoffReceiveStatus.imagesReceived) {
      return MmsHandoffReceiveStatus.imagesReceived;
    }
    bool isInit = store.getInitForPatient(patientId);
    bool isReceive = store.getReceiveForPatient(patientId);
    if (isInit) {
      if (isReceive) {
        return MmsHandoffReceiveStatus.initAndReceive;
      } else {
        return MmsHandoffReceiveStatus.initOnly;
      }
    }
    return MmsHandoffReceiveStatus.waiting;
  }

  @override
  void dispose() {
    store.removeListener(statusChanged);
    imageDetailsStore.removeListener(imageDetailsChanged);
    super.dispose();
  }
}

class MmsHandoffStatusForReceiverStoreAccess extends ChangeNotifier {
  final MmsHandoffStatusForReceiverStore store =
      MmsHandoffStatusForReceiverStore();

  MmsHandoffStatusForReceiverStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}

class HandoffImagesModel {
  final String patientId;
  final String? facilityId;
  final int pageNum;
  final int pageTotal;
  final String pageName;
  final String dataUrl;
  HandoffImagesModel({
    required this.patientId,
    this.facilityId,
    required this.pageNum,
    required this.pageTotal,
    required this.pageName,
    required this.dataUrl,
  });

  Map<String, dynamic> toJson() => {
        "patientId": patientId,
        "facilityId": facilityId,
        "pageNum": pageNum,
        "pageTotal": pageTotal,
        "pageName": pageName,
        "dataUrl": dataUrl,
      };
}
