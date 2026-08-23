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

import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter_ui/data/storage/base_data_store.dart';
import 'package:flutter_ui/logic/utils/cast_utils.dart';
import 'package:flutter_ui/data/storage/data_backed_up_store.dart';

import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

Logger _logger = Logger("RecentEventsModel", debugging: false);

class RecentEventsModel extends Equatable {
  /// Wire-provided identifier (debug/display only; not used for dedupe/UI identity).
  final String id;
  final String instanceName;
  final String type;
  final String patientId;
  final String? notes;
  final String? description;
  final int? rawSimTime;
  final int? rawTime;
  final int receivedTime;
  final int? simTime;
  final int? time;
  final String timeStr;
  final bool isUpdated;
  final String? action;
  static const String kNoInstanceName = "<No Instance Name>";

  const RecentEventsModel(
    this.id,
    this.instanceName,
    this.patientId,
    this.type, {
    this.notes,
    this.description,
    this.rawSimTime,
    this.rawTime,
    this.simTime,
    this.time,
    this.receivedTime = 0,
    this.timeStr = "",
    this.isUpdated = false,
    this.action,
  });

  bool get _hasInstanceName =>
      instanceName.isNotEmpty && instanceName != kNoInstanceName;

  bool get _hasRawTime => rawTime != null && rawTime! >= 0;

  /// Stable identity for deduplication
  /// Note: falls back to `id` only if neither instanceName nor rawTime is usable.
  /// This may dedupe replays that reuse the same `id`.
  String get dedupeKey {
    if (_hasInstanceName) return "${patientId}|inst:${instanceName}";
    if (_hasRawTime) return "${patientId}|t:${rawTime}";
    // last-resort: top-level id (already synthesized in fromJson if needed)
    return "${patientId}|id:${id}";
  }

  /// Construct a RecentEventsModel from the raw wire payload.
  ///
  /// Identity vs display:
  /// - `id` is kept as a wire/debug field. It is **not** used for deduplication
  ///   or UI identity.
  /// - Event identity for dedupe/UI is provided by `dedupeKey`:
  ///   `patientId + (instanceName OR time)` reflecting the mutual exclusion.
  /// Field preferences:
  /// - Prefer `itemIdentifier.instanceName` when present; else top-level `instanceName`.
  /// - If top-level `id` is empty, synthesize a readable fallback from
  ///   `itemIdentifier`, otherwise use "<No Id>".
  factory RecentEventsModel.fromJson(Map<String, dynamic> json) {
    _logger.log(3000, "Converting json to recent events.");

    final Map<String, dynamic> mappedJson = CastUtils.cast(json, fallback: {});
    final Map<String, dynamic> itemIdentifier =
        CastUtils.cast(mappedJson["itemIdentifier"], fallback: {});

    final String instNameFromItem =
        CastUtils.cast(itemIdentifier["instanceName"], fallback: "");
    final int? itemId =
        CastUtils.cast(itemIdentifier["itemId"], fallback: null);

    // Wire/debug id only; not used for dedupe/UI identity.
    String id = CastUtils.cast(mappedJson["id"], fallback: "");
    if (id.isEmpty) {
      if (instNameFromItem.isNotEmpty && itemId != null) {
        id = "${instNameFromItem}_$itemId";
      } else {
        id = "<No Id>";
      }
    }

    // Prefer instanceName from nested itemIdentifier when available.
    final String instanceName = (instNameFromItem.isNotEmpty
            ? instNameFromItem
            : CastUtils.cast(mappedJson["instanceName"],
                fallback: "<No Instance Name>"))
        .trim();

    final String patientId =
        CastUtils.cast(mappedJson["patientId"], fallback: "<Unknown>");

    // Parse times
    final int receivedTime = json["receivedTime"] is int
        ? json["receivedTime"]
        : DateTime.now().millisecondsSinceEpoch;

    final int? rawTimeParsed =
        CastUtils.cast<int?>(mappedJson["time"], fallback: null);

    // IMPORTANT: Always derive timeStr from the same effective timestamp used for sorting.
    final String timeStr =
        displayTimeStr(rawTime: rawTimeParsed, receivedTime: receivedTime);

    return RecentEventsModel(
      id,
      instanceName,
      patientId,
      CastUtils.cast(mappedJson["type"], fallback: "<Unknown>"),
      notes: CastUtils.cast(mappedJson["notes"], fallback: "<No Notes>"),
      description: CastUtils.cast(mappedJson["description"], fallback: ""),
      rawSimTime: CastUtils.cast(mappedJson["simTime"], fallback: -1),
      rawTime: rawTimeParsed, // keep as null if absent
      receivedTime: receivedTime,
      timeStr: timeStr,
      action: CastUtils.cast(mappedJson["action"], fallback: null),
    );
  }

  static int simTimeInt(String? strTime) {
    if (strTime == null || strTime.isEmpty || strTime == "--") {
      return 0;
    }
    final parts = strTime.split(":");
    final hr = int.tryParse(parts.isNotEmpty ? parts[0] : "0", radix: 10) ?? 0;
    final min = int.tryParse(parts.length > 1 ? parts[1] : "0", radix: 10) ?? 0;
    return 60 * hr + min;
  }

  /// Display time used in the UI.
  /// Matches the sort rule: prefer rawTime when available, else receivedTime.
  static String displayTimeStr({int? rawTime, required int receivedTime}) {
    final int effective =
        (rawTime != null && rawTime >= 0) ? rawTime : receivedTime;
    return timeString(effective);
  }

  static String timeString(int epochMillis) {
    if (epochMillis < 0) return "--";
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMillis);
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:"
        "${dt.second.toString().padLeft(2, '0')}";
  }

  RecentEventsModel replica({
    String? id,
    String? instanceName,
    String? patientId,
    String? type,
    String? notes,
    String? description,
    int? rawSimTime,
    int? rawTime,
    int? simTime,
    int? time,
    int? receivedTime,
    String? timeStr,
    bool? isUpdated,
    String? action,
  }) =>
      RecentEventsModel(
        id ?? this.id,
        instanceName ?? this.instanceName,
        patientId ?? this.patientId,
        type ?? this.type,
        notes: notes ?? this.notes,
        description: description ?? this.description,
        rawSimTime: rawSimTime ?? this.rawSimTime,
        rawTime: rawTime ?? this.rawTime,
        simTime: simTime ?? this.simTime,
        time: time ?? this.time,
        receivedTime: receivedTime ?? this.receivedTime,
        timeStr: timeStr ?? this.timeStr,
        isUpdated: isUpdated ?? this.isUpdated,
        action: action ?? this.action,
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "instanceName": instanceName,
      "type": type,
      "patientId": patientId,
      "notes": notes,
      "description": description,
      "simTime": rawSimTime,
      "time": rawTime,
      "receivedTime": receivedTime,
      "timeStr": timeStr,
      "action": action,
    };
  }

  @override
  List<Object> get props => [
        dedupeKey, // identity for equality/sets
        instanceName,
        type,
        patientId,
        notes ?? "",
        description ?? "",
        rawSimTime ?? 0,
        rawTime ?? 0,
        timeStr,
        isUpdated,
        action ?? "",
      ];

  @override
  String toString() {
    return 'RecentEventsModel('
        'id: $id, '
        'instanceName: $instanceName, '
        'type: $type, '
        'patientId: $patientId, '
        'notes: ${notes ?? ""}, '
        'description: ${description ?? ""}, '
        'rawSimTime: $rawSimTime, '
        'rawTime: $rawTime, '
        'simTime: $simTime, '
        'time: $time, '
        'receivedTime: $receivedTime, '
        'timeStr: $timeStr, '
        'isUpdated: $isUpdated, '
        'action: ${action ?? ""}'
        ')';
  }
}

const Map<String, String> learnerActionDisplayMap = {
  "NOT_APPLICABLE": "Not Applicable",
  "PREPARE_EQUIPMENT": "Prepare Equipment",
  "DON_PPE": "Don PPE",
  "POSITION_PATIENT": "Position Patient",
  "EXPOSE_PATIENT": "Expose Patient",
  "RELOCATE_PATIENT": "Relocate Patient",
  "EXTRICATE_PATIENT_FROM_VEHICLE": "Extricate Patient From Vehicle",
  "LOCATE_ANATOMICAL_LANDMARKS": "Locate Anatomical Landmarks",
  "SUCTION_AIRWAY": "Suction Airway",
  "CATHETERIZE_PATIENT": "Catheterize Patient",
  "COMMUNICATE_WITH_PATIENT": "Communicate With Patient",
  "ASSESS_BLEEDING": "Assess Bleeding",
  "ASSESS_AIRWAY": "Assess Airway",
  "ASSESS_BREATHING": "Assess Breathing",
  "ASSESS_CIRCULATION": "Assess Circulation",
  "MONITOR_PATIENT": "Monitor Patient",
  "PERFORM_TRAUMA_EXAM": "Perform Trauma Exam",
  "MEASURE_PATIENT_RESPONSIVENESS": "Measure Patient Responsiveness",
  "COLLECT_BLOOD_SAMPLE": "Collect Blood Sample",
  "COLLECT_URINE_SAMPLE": "Collect Urine Sample",
  "PLACE_ECGLEADS": "Place ECG Leads",
  "CREATE_STERILE_FIELD": "Create Sterile Field",
};

extension RecentEventsModelExtensions on RecentEventsModel {
  String get notesOrLearnerAction {
    if (type == "LEARNER_ACTION") {
      final key = (action ?? "").toUpperCase();
      return learnerActionDisplayMap[key] ?? action ?? "";
    }
    return notes ?? "";
  }

  String get notesAndDescription {
    final n = notes ?? "";
    final d = description ?? "";
    if (n.isEmpty) return d;
    if (d.isEmpty) return n;
    return "$n - $d";
  }
}

class RecentEventsStore extends BaseDataStore {
  static const String _recentEventsDataType = "Event";
  static const String _startTimeDataType = "StartTime";
  final Map<String, int> _mapPatientStartTimes = {};
  bool _hasInit = false;
  late DataBackedUpStore db;
  static final List<RecentEventsModel> _eventsList = [];
  final Set<String> _seenKeys = <String>{};

  RecentEventsStore._private() {
    _init();
    MmsDataRouter().registerStoreForDataType(_recentEventsDataType, this);
  }

  static final RecentEventsStore _instance = RecentEventsStore._private();

  factory RecentEventsStore() => _instance;

  Future<void> _init() async {
    db = await DataBackedUpStore.instance();
    Map<String, int> mapPatientStartTimes =
        db.getIntDataForDataType(_startTimeDataType);
    for (String key in mapPatientStartTimes.keys) {
      int startTime = mapPatientStartTimes[key] ?? 0;
      _mapPatientStartTimes[key] = startTime;
      _logger.log(100, "Patient $key: Start time: $startTime");
    }
    _hasInit = true;
    notifyListeners();
  }

  Future<void> resetStartTimes() async {
    _hasInit = false;
    await _init();
  }

  int startTimeSecondsForPatient(String patientId) {
    int startTime = 0;
    if (_hasInit) {
      startTime = (_mapPatientStartTimes[patientId] ?? 0) ~/ 1000;
    }
    return startTime;
  }

  Future<void> persistEvents() async {
    List<Map<String, dynamic>> mapsList = eventsMapList;
    _logger.log(222, "Persisting ${mapsList.length} events to database.");
    await db.persistDynamicByDataType(_recentEventsDataType, mapsList, id: "");
    _logger.log(222, "Persisted recent events data to database.");
  }

  Future<void> clearEvents() async {
    int numEvents = _eventsList.length;
    _logger.log(234, "Clearing $numEvents events.");
    _eventsList.clear();
    _seenKeys.clear();
    await db.deleteObjectsByDataType(_recentEventsDataType);
    _logger.log(234, "Cleared recent events data from database.");
    notifyListeners();
  }

  List<Map<String, dynamic>> get eventsMapList {
    List<Map<String, dynamic>> list = [];
    for (RecentEventsModel event in _eventsList) {
      list.add(event.toJson());
    }
    return list;
  }

  void updateRecentEventsList(String patientId) {
    List<RecentEventsModel> updatedEventsList = [];
    for (RecentEventsModel model in _eventsList) {
      if (model.patientId == patientId) {
        updatedEventsList.add(_updateRecentEvent(model));
      }
    }
    _eventsList.removeWhere((event) => event.patientId == patientId);
    _eventsList.addAll(updatedEventsList);
    notifyListeners();
  }

  RecentEventsModel _updateRecentEvent(RecentEventsModel model) {
    if (model.isUpdated) return model;

    final String patientId = model.patientId;
    final int? currStartTime = _mapPatientStartTimes[patientId];
    if (currStartTime == null || !_hasInit) {
      _logger.log(1002, "Init? $_hasInit");
      return model;
    }

    int? simTime = model.simTime; // minutes from sim start, if provided
    String timeStr = model.timeStr; // already computed in factory

    if (simTime != null) {
      // If simTime exists, show wall-clock derived from sim start.
      timeStr = RecentEventsModel.timeString(
        currStartTime + (simTime * 60 * 1000),
      );
    } else {
      // No simTime: ensure display time is populated and consistent with sort rule.
      if (timeStr.isEmpty || timeStr == "--") {
        timeStr = RecentEventsModel.displayTimeStr(
          rawTime: model.rawTime,
          receivedTime: model.receivedTime,
        );
      }
    }

    return model.replica(
      simTime: simTime, // unchanged if null
      timeStr: timeStr, // recomputed if needed
      isUpdated: true,
    );
  }

  List<RecentEventsModel> get eventsList {
    final newList = List<RecentEventsModel>.from(_eventsList);

    newList.sort((a, b) {
      // Prefer rawTime when available; fallback to receivedTime.
      final int at =
          (a.rawTime != null && a.rawTime! >= 0) ? a.rawTime! : a.receivedTime;
      final int bt =
          (b.rawTime != null && b.rawTime! >= 0) ? b.rawTime! : b.receivedTime;

      return bt.compareTo(at); // descending: newest first
    });

    return newList;
  }

  void loadFromJson(Map<String, dynamic> jsonMap) {
    RecentEventsModel model = RecentEventsModel.fromJson(jsonMap);
    addRecentEvent(model, notifyOnChange: true);
  }

  bool addRecentEvent(
    RecentEventsModel singleEvent, {
    bool notifyOnChange = false,
  }) {
    // Ensure we have a start time for this patient (used for sim-time → wall-time)
    final String patientId = singleEvent.patientId;
    int? currStartTime = _mapPatientStartTimes[patientId];
    if (currStartTime == null) {
      currStartTime = DateTime.now().millisecondsSinceEpoch;
      _persistStartTime(patientId, currStartTime);
    }

    // O(1) dedupe via cached keys
    final String key = singleEvent.dedupeKey;
    if (_seenKeys.contains(key)) {
      debugPrint('Duplicate event skipped: ${singleEvent.toString()}');
      return false;
    }

    // Compute derived fields (simTime/timeStr) before storing
    final RecentEventsModel updatedEvent = _updateRecentEvent(singleEvent);

    _logger.log(4, "Adding event:");
    _logger.log(4, updatedEvent.toString());

    _eventsList.add(updatedEvent);
    _seenKeys.add(key); // <-- remember it

    if (notifyOnChange) {
      notifyListeners();
    }
    return true;
  }

  Future<void> _persistStartTime(String patientId, int startTime) async {
    if (!_hasInit) {
      return;
    }
    await db.persistIntByDataType(
      _startTimeDataType,
      patientId,
      startTime,
      willReplace: false,
    );
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
  void parseAndStoreJsonByDataType(String dataType, dynamic payload) {
    if (dataType == _recentEventsDataType) {
      Map<String, dynamic> jsonMap = CastUtils.cast(
        payload,
        fallback: {},
      );
      loadFromJson(jsonMap);
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

class RecentEventsStoreAccess extends ChangeNotifier {
  final RecentEventsStore store = RecentEventsStore();

  RecentEventsStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() async {
    store.removeListener(notifyListeners);
    await store.persistEvents();
    super.dispose();
  }
}
