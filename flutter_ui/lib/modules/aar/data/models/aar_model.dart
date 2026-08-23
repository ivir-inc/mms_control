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

import 'package:flutter_ui/data/model/vitals/vitals_model.dart';
import 'package:flutter_ui/data/storage/base_data_store.dart';
import 'package:flutter_ui/data/storage/data_backed_up_store.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

Logger _logger = Logger(
  "VitalsAarStore",
  debugging: false,
);

class TimestampedVitalsValues extends Equatable {
  final VitalsValues vitalsValues;
  final int timestamp;
  final int seconds;
  const TimestampedVitalsValues(
    this.vitalsValues,
    this.timestamp,
  ) : seconds = timestamp ~/ 1000;

  factory TimestampedVitalsValues.nowValues(VitalsValues values) {
    return TimestampedVitalsValues(
      values,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory TimestampedVitalsValues.fromJson(Map<String, dynamic> json) {
    VitalsValues values = VitalsValues.fromJson(json);
    if (json.containsKey("timestamp")) {
      dynamic ts = json["timestamp"];
      if (ts is int) {
        return TimestampedVitalsValues(values, ts);
      }
    }
    return TimestampedVitalsValues.nowValues(values);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> vitalsJson = vitalsValues.toJson();
    vitalsJson["timestamp"] = timestamp;
    return vitalsJson;
  }

  int secondsOffset(int startSeconds) => seconds - startSeconds;

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        vitalsValues,
        timestamp,
      ];
}

class VitalsAarStore extends BaseDataStore {
  static DataBackedUpStore? _backedUpStore;
  static bool _hasLoaded = false;
  static bool _hasLoadedDb = false;
  static final Map<String, List<Map<String, dynamic>>> _vitalsMap = {};
  static final Map<String, VitalsValues> _lastVitalsMap = {};
  static final String _vitalsDataType = VitalsValuesStore().vitalsDataType;

  VitalsAarStore._private() {
    // Register VitalsValuesStore with MmsDataRouter and add listener.
    VitalsValuesStore().addListener(pullLatestVitals);
  }

  static final VitalsAarStore _instance = VitalsAarStore._private();

  static Future<VitalsAarStore> instance() async {
    _logger.log(1, "Getting instance");
    bool hasBackedUpStoreNsAlready = _backedUpStore != null;
    _logger.log(1, "Has Backed Up Store Ns Already?");
    _logger.log(1, "$hasBackedUpStoreNsAlready");
    _backedUpStore ??= await DataBackedUpStore.instance();
    _hasLoadedDb = _backedUpStore?.hasLoaded ?? false;
    _logger.log(1, "Db has loaded? $_hasLoadedDb");
    if (_hasLoadedDb && !_hasLoaded) {
      Map<String, dynamic>? savedData =
          _backedUpStore?.getDynamicDataForDataType(_vitalsDataType);
      _logger.log(3, "Saved data pulled for vitals AAR:");
      _logger.log(3, savedData.toString());
      List<String>? patientIds = savedData?.keys.toList();
      for (String patientId in patientIds ?? []) {
        dynamic data = savedData?[patientId];
        _logger.log(4, "Saved vitals AAR data for patient $patientId:");
        _logger.log(4, data?.toString() ?? "<null>");
        List<Map<String, dynamic>> parsedList = [];

        if (data is List) {
          for (dynamic listElem in data) {
            Map<String, dynamic> constructMap = {};
            parsedList.add(constructMap);
            _logger.log(40, "List element:");
            _logger.log(40, listElem);
            if (listElem is Map) {
              _logger.log(41, "element is Map");
              Iterable<dynamic> keys = listElem.keys;
              for (dynamic key in keys) {
                if (key is String) {
                  _logger.log(42, "key is String:");
                  _logger.log(42, key);
                  dynamic value = listElem[key];
                  if (value is num) {
                    constructMap[key] = value;
                    _logger.log(43, "value is num");
                    _logger.log(43, value.toString());
                  } else {
                    _logger.log(43, "value is NOT num");
                  }
                } else {
                  _logger.log(42, "key is NOT String");
                  _logger.log(42, key.toString());
                }
              }
            } else {
              _logger.log(41, "element is NOT Map");
            }
          }
          //if (data is List<Map<String, dynamic>>) {
          _logger.log(5, "Parsed data:");
          _logger.log(5, parsedList.toString());
          List<Map<String, dynamic>> dataAlreadyHave =
              _vitalsMap[patientId] ?? [];
          List<Map<String, dynamic>> mergedList =
              sortAndMergeLists(parsedList, dataAlreadyHave);
          if (mergedList.isNotEmpty) {
            _logger.log(6, "Merged vitals list for patient $patientId:");
            _logger.log(6, mergedList.toString());
            _lastVitalsMap[patientId] = VitalsValues.fromJson(mergedList.last);
            _logger.log(7, "Last vitals for patient $patientId:");
            _logger.log(7, _lastVitalsMap[patientId].toString());
          }
        }
        // } else if (data is List<String>) {
        //   _logger.log(5, "Loaded data is of type List<String>");
        // } else if (data is List<Map>) {
        //   _logger.log(5, "Loaded data is of type List<Map>");
        // } else if (data is List<List>) {
        //   _logger.log(5, "Loaded data is of type List<List>");
        // } else {
        //   _logger.log(5, "Loaded data IS NOT of expected type.");
        // }
      }
      _hasLoaded = true;
      Future.delayed(const Duration(milliseconds: 400), () {
        _instance.notifyListeners();
      });
    }
    return _instance;
  }

  bool get hasLoaded => _hasLoaded;

  List<Map<String, dynamic>> patientVitalsList(String patientId) =>
      (_vitalsMap[patientId] ?? []).toList();

  int firstSecondsForPatient(String patientId) {
    List<Map<String, dynamic>> modPatientList = _vitalsMap[patientId] ?? [];
    if (modPatientList.isNotEmpty) {
      Map<String, dynamic> json = modPatientList.first;
      dynamic ts = json["timestamp"];
      if (ts is int) {
        return ts ~/ 1000;
      }
    }
    return 0;
  }

  int lastSecondsForPatient(String patientId) {
    List<Map<String, dynamic>> modPatientList = _vitalsMap[patientId] ?? [];
    if (modPatientList.isNotEmpty) {
      Map<String, dynamic> json = modPatientList.last;
      dynamic ts = json["timestamp"];
      if (ts is int) {
        return ts ~/ 1000;
      }
    }
    return 0;
  }

  int lastSecondsOffsetForPatient(String patientId) {
    List<Map<String, dynamic>> modPatientList = _vitalsMap[patientId] ?? [];
    int first = 0;
    int last = 0;
    if (modPatientList.isNotEmpty) {
      Map<String, dynamic> json = modPatientList.last;
      dynamic ts = json["timestamp"];
      if (ts is int) {
        last = ts ~/ 1000;
      }
      json = modPatientList.first;
      ts = json["timestamp"];
      if (ts is int) {
        first = ts ~/ 1000;
      }
    }
    return last - first;
  }

  void pullLatestVitals() {
    VitalsValuesStore vitalsValuesStore = VitalsValuesStore();
    List<String> patientIds = vitalsValuesStore.patientIds;
    List<String> changedPatients = [];
    for (String patientId in patientIds) {
      VitalsValues? patientVitals =
          vitalsValuesStore.getVitalsValues(patientId);
      VitalsValues? lastPatientVitals = _lastVitalsMap[patientId];
      if (patientVitals != lastPatientVitals) {
        _lastVitalsMap[patientId] = patientVitals;
        TimestampedVitalsValues tsVitals =
            TimestampedVitalsValues.nowValues(patientVitals);
        addMapToPatientList(patientId, tsVitals.toJson());
        changedPatients.add(patientId);
      }
    }
    if (_hasLoaded && changedPatients.isNotEmpty) {
      for (String patientId in changedPatients) {
        _logger.log(2, "Persist Vitals data for patient $patientId");
        _logger.log(2, (_vitalsMap[patientId] ?? []).toString());
        _backedUpStore?.persistDynamicByDataType(
          _vitalsDataType,
          _vitalsMap[patientId] ?? [],
          id: patientId,
        );
      }
      notifyListeners();
    }
  }

  void addMapToPatientList(
    String patientId,
    Map<String, dynamic> map, {
    bool notify = false,
  }) {
    List<Map<String, dynamic>> modPatientList = _vitalsMap[patientId] ?? [];
    modPatientList.add(map);
    _vitalsMap[patientId] = modPatientList.toList();
    if (notify) {
      notifyListeners();
    }
  }

  /// Sorts both lists of patient vitals maps and then merges them, dropping
  /// any maps from the second list that, in sort order, comes before the last
  /// map in the first list.
  static List<Map<String, dynamic>> sortAndMergeLists(
      List<Map<String, dynamic>> first, List<Map<String, dynamic>> second) {
    List<Map<String, dynamic>> sortedFirst = sortedList(first);
    List<Map<String, dynamic>> sortedSecond = sortedList(second);
    if (sortedFirst.isEmpty) {
      return sortedSecond;
    }
    Map<String, dynamic> lastFirst = sortedFirst.last;
    for (Map<String, dynamic> secMap in sortedSecond) {
      if (comp(lastFirst, secMap) < 0) {
        sortedFirst.add(secMap);
      }
    }
    return sortedFirst;
  }

  /// Returns sorted list of patient vitals maps without altering source list.
  static List<Map<String, dynamic>> sortedList(
      List<Map<String, dynamic>> unsortedList) {
    List<Map<String, dynamic>> sortedList = unsortedList.toList();
    return sortListInPlace(sortedList);
  }

  /// Sort list of patient vitals maps in place. Returns sorted list, that is,
  /// returns the function parameter.
  static List<Map<String, dynamic>> sortListInPlace(
      List<Map<String, dynamic>> listToSort) {
    listToSort.sort((a, b) => comp(a, b));
    return listToSort;
  }

  /// Comparison function for sorting the patient vitals maps. Assumes each map
  /// has an int "timestamp" property, which defaults to 0 if missing.
  static int comp(Map<String, dynamic> a, Map<String, dynamic> b) =>
      ((a["timestamp"] ?? 0) as int).compareTo((b["timestamp"] ?? 0) as int);

  @override
  void dispose() {
    VitalsValuesStore().removeListener(pullLatestVitals);
    super.dispose();
  }

  @override
  bool acceptsBool() => false;

  @override
  bool acceptsDouble() => false;

  @override
  bool acceptsInt() => false;

  @override
  bool acceptsJson() => false;

  @override
  bool acceptsRawString() => false;

  @override
  void parseAndStoreJsonByDataType(String dataType, dynamic payload) {
    // Nothing to implement.
  }

  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {
    // Nothing to implement.
  }

  @override
  void storeDoubleByDataType(String dataType, String identifier, double data) {
    // Nothing to implement.
  }

  @override
  void storeIntByDataType(String dataType, String identifier, int data) {
    // Nothing to implement.
  }

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    // Nothing to implement.
  }
}

class VitalsAarStoreAccess extends ChangeNotifier {
  VitalsAarStore? store;
  bool hasStore = false;
  bool hasDisposed = false;

  VitalsAarStoreAccess() {
    init();
  }

  Future<void> init() async {
    store = await VitalsAarStore.instance();
    store?.addListener(notifyListeners);
    hasStore = store != null;
    if (hasDisposed) {
      store?.removeListener(notifyListeners);
    }
  }

  @override
  void dispose() {
    if (hasStore) {
      store?.removeListener(notifyListeners);
    }
    hasDisposed = true;
    hasStore = false;
    store = null;
    super.dispose();
  }
}
