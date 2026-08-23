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

import 'package:flutter_ui/data/storage/base_data_store.dart';

import 'package:flutter/foundation.dart';

class RawStringStore extends BaseDataStore {
  final Map<String, Map<String, List<String>>> _rawStringsMap = {};
  final Map<String, Map<String, bool>> _multiplesAllowedMap = {};

  RawStringStore._private();

  static final RawStringStore _instance = RawStringStore._private();

  factory RawStringStore() => _instance;

  /// Limit the number of raw strings that can be stored for [dataType]
  /// and [identifier] to one, if [limit] is true; otherwise multiples
  /// are allowed, as they are by default. Calling this method will throw
  /// an exception if any data is currently stored for [dataType] and
  /// [identifier] (as a pair) if [failSilently] is passed as false, or
  /// return without effecting any change and without an exception if
  /// [failSilently] is passed as true (as it is by default).
  void limitOne(
    String dataType,
    String identifier, {
    bool limit = true,
    bool failSilently = true,
  }) {
    if (hasData(dataType, identifier)) {
      if (failSilently) {
        return;
      }
      throw Exception(
          "May not call limitOne for $dataType/$identifier after storing data for the pair.");
    }
    Map<String, bool>? boolsForIdMap = _multiplesAllowedMap[identifier];
    if (boolsForIdMap == null) {
      boolsForIdMap = {};
      _multiplesAllowedMap[identifier] = boolsForIdMap;
    }
    boolsForIdMap[dataType] = !limit;
  }

  bool allowMultiples(String dataType, String identifier) {
    Map<String, bool> infoForIdMap = _multiplesAllowedMap[identifier] ?? {};
    return infoForIdMap[dataType] ?? true;
  }

  @override
  bool acceptsJson() => false;

  @override
  bool acceptsRawString() => true;

  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    // Intentionally empty.
  }

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    Map<String, List<String>>? dataForIdMap = _rawStringsMap[identifier];
    if (dataForIdMap == null) {
      dataForIdMap = {};
      _rawStringsMap[identifier] = dataForIdMap;
    }
    List<String>? dataTypeStrings = dataForIdMap[dataType];
    if (dataTypeStrings == null) {
      dataTypeStrings = [];
      dataForIdMap[dataType] = dataTypeStrings;
    }
    if (!allowMultiples(dataType, identifier)) {
      if (dataTypeStrings.isNotEmpty && dataTypeStrings[0] == rawString) {
        return;
      }
      dataTypeStrings.clear();
    }
    dataTypeStrings.add(rawString);
    _refreshDataList(dataType, identifier);
    notifyListeners();
  }

  void _refreshDataList(
    String dataType,
    String identifier,
  ) {
    Map<String, List<String>>? dataForIdMap = _rawStringsMap[identifier];
    if (dataForIdMap == null) {
      dataForIdMap = {};
      _rawStringsMap[identifier] = dataForIdMap;
    }
    List<String> dataTypeStrings = dataForIdMap[dataType] ?? [];
    List<String> newList = List.from(dataTypeStrings, growable: true);
    // List<String> newList = [];
    // for (String data in dataTypeStrings) {
    //   newList.add(data);
    // }
    dataTypeStrings.clear();
    dataForIdMap[dataType] = newList;
  }

  void clearData(String dataType, String identifier) {
    Map<String, List<String>>? dataForIdMap = _rawStringsMap[identifier];
    if (dataForIdMap == null) {
      return;
    }
    List<String>? dataTypeStrings = dataForIdMap.remove(dataType);
    if (dataTypeStrings?.isNotEmpty ?? false) {
      dataTypeStrings?.clear();
      notifyListeners();
    }
  }

  String? remove(String dataType, String identifier, int index) {
    Map<String, List<String>>? dataForIdMap = _rawStringsMap[identifier];
    if (dataForIdMap == null) {
      return null;
    }
    List<String>? dataTypeStrings = dataForIdMap[dataType];
    if (dataTypeStrings == null || dataTypeStrings.isEmpty) {
      return null;
    }
    String removed = dataTypeStrings.removeAt(index);
    _refreshDataList(dataType, identifier);
    notifyListeners();
    return removed;
  }

  bool hasData(String dataType, String identifier) {
    Map<String, List<String>>? dataForIdMap = _rawStringsMap[identifier];
    if (dataForIdMap == null) {
      return false;
    }
    List<String>? dataTypeStrings = dataForIdMap[dataType];
    if (dataTypeStrings == null || dataTypeStrings.isEmpty) {
      return false;
    }
    return true;
  }

  /// The list stored for [dataType] and [identifier]. Attempts to
  /// modify the list will have no effect on the stored list, and may
  /// throw an exception.
  List<String>? dataList(String dataType, String identifier) {
    Map<String, List<String>>? dataForIdMap = _rawStringsMap[identifier];
    if (dataForIdMap == null) {
      return null;
    }
    List<String>? dataTypeStrings = dataForIdMap[dataType];
    if (dataTypeStrings == null || dataTypeStrings.isEmpty) {
      return null;
    }
    return UnmodifiableListView(dataTypeStrings);
  }

  String? first(
    String dataType,
    String identifier, {
    String? def,
  }) {
    List<String>? datList = dataList(dataType, identifier);
    return datList?.first ?? def;
  }

  String? last(
    String dataType,
    String identifier, {
    String? def,
  }) {
    List<String>? datList = dataList(dataType, identifier);
    return datList?.last ?? def;
  }

  double totalLength({String? dataType, String? identifier}) {
    double totalLen = 0;
    _rawStringsMap.forEach((id, idMap) {
      if (identifier == null || id == identifier) {
        idMap.forEach((datType, rawStringsList) {
          if (dataType == null || datType == dataType) {
            for (var rawString in rawStringsList) {
              totalLen += rawString.length;
            }
          }
        });
      }
    });
    return totalLen;
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

/// A disposable object allowing access to the nondisposable RawStringStore
/// singleton, for use with ChangeNotifierProvider in the provider package.
class RawStringStoreAccess extends ChangeNotifier {
  final RawStringStore store = RawStringStore();

  RawStringStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}

class PrimitivesStore extends BaseDataStore {
  // Typical usage: Outer key = patient id, inner key = field id
  final Map<String, Map<String, int>> intDataMap = {};
  final Map<String, Map<String, double>> doubleDataMap = {};
  final Map<String, Map<String, bool>> boolDataMap = {};

  PrimitivesStore._private();

  static final PrimitivesStore _instance = PrimitivesStore._private();

  factory PrimitivesStore() => _instance;

  bool hasBoolData(String dataType, String identifier) {
    Map<String, bool>? boolMap = boolDataMap[identifier];
    return boolMap?.containsKey(dataType) ?? false;
  }

  bool boolData(
    String dataType,
    String identifier, {
    bool defaultValue = false,
  }) {
    Map<String, bool>? boolMap = boolDataMap[identifier];
    return boolMap?[dataType] ?? defaultValue;
  }

  bool hasDoubleData(String dataType, String identifier) {
    Map<String, double>? doubleMap = doubleDataMap[identifier];
    return doubleMap?.containsKey(dataType) ?? false;
  }

  double doubleData(
    String dataType,
    String identifier, {
    double defaultValue = 0,
  }) {
    Map<String, double>? doubleMap = doubleDataMap[identifier];
    return doubleMap?[dataType] ?? defaultValue;
  }

  bool hasIntData(String dataType, String identifier) {
    Map<String, int>? intMap = intDataMap[identifier];
    return intMap?.containsKey(dataType) ?? false;
  }

  int intData(
    String dataType,
    String identifier, {
    int defaultValue = 0,
  }) {
    Map<String, int>? intMap = intDataMap[identifier];
    return intMap?[dataType] ?? defaultValue;
  }

  @override
  bool acceptsBool() => true;

  @override
  bool acceptsDouble() => true;

  @override
  bool acceptsInt() => true;

  @override
  bool acceptsJson() => false;

  @override
  bool acceptsRawString() => false;

  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    // Intentionally empty.
  }

  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {
    if (!boolDataMap.containsKey(identifier)) {
      Map<String, bool> newMap = <String, bool>{};
      boolDataMap[identifier] = newMap;
    }
    Map<String, bool>? dataMap = boolDataMap[identifier];
    dataMap?[dataType] = data;
  }

  @override
  void storeDoubleByDataType(String dataType, String identifier, double data) {
    if (!doubleDataMap.containsKey(identifier)) {
      Map<String, double> newMap = <String, double>{};
      doubleDataMap[identifier] = newMap;
    }
    Map<String, double>? dataMap = doubleDataMap[identifier];
    dataMap?[dataType] = data;
  }

  @override
  void storeIntByDataType(String dataType, String identifier, int data) {
    if (!intDataMap.containsKey(identifier)) {
      Map<String, int> newMap = <String, int>{};
      intDataMap[identifier] = newMap;
    }
    Map<String, int>? dataMap = intDataMap[identifier];
    dataMap?[dataType] = data;
  }

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    // Intentionally empty.
  }
}

/// A disposable object allowing access to the nondisposable PrimitivesStore
/// singleton, for use with ChangeNotifierProvider in the provider package.
class PrimitivesStoreAccess extends ChangeNotifier {
  final PrimitivesStore store = PrimitivesStore();

  PrimitivesStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
