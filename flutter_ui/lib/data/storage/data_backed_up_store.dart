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
import 'package:flutter_ui/data/storage/data_persistence_store.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';

import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("CommonDataPersist");

class DataBackedUpStore extends BaseDataStore {
  final Map<String, String Function(dynamic)?> _idFnsMap = {};
  static DataPersistenceStore? _dataPersistenceStore;
  static final Map<String, Map<String, bool>> _boolDataInMem = {};
  static final Map<String, Map<String, int>> _intDataInMem = {};
  static final Map<String, Map<String, double>> _doubleDataInMem = {};
  static final Map<String, Map<String, String>> _rawStringDataInMem = {};
  static final Map<String, Map<String, dynamic>> _jsonDataInMem = {};
  static bool _isLoading = false;
  static bool _hasLoaded = false;

  DataBackedUpStore._private();

  static final DataBackedUpStore _instance = DataBackedUpStore._private();

  static Future<DataBackedUpStore> instance({void Function()? listener}) async {
    _dataPersistenceStore ??= await DataPersistenceStore.instance();
    if (!_hasLoaded && !_isLoading) {
      _isLoading = true;
      try {
        await _load();
        _hasLoaded = true;
      } catch (e) {
        _isLoading = false;
      }
    }
    if (_hasLoaded && listener != null) {
      _logger.log(21, "Adding listener");
      _instance.addListener(listener);
    }
    return _instance;
  }

  DataPersistenceStore? get db => _dataPersistenceStore;
  bool get hasLoaded => _hasLoaded;

  static Future<void> _load() async {
    Map<String, Map<String, bool>> boolStore =
        await _dataPersistenceStore?.dbGetAllBools() ?? {};
    Map<String, Map<String, double>> doubleStore =
        await _dataPersistenceStore?.dbGetAllDoubles() ?? {};
    Map<String, Map<String, int>> intStore =
        await _dataPersistenceStore?.dbGetAllInts() ?? {};
    _logger.log(102, "*************************");
    _logger.log(102, "$intStore");
    _logger.log(102, "*************************");
    Map<String, Map<String, String>> rawStringStore =
        await _dataPersistenceStore?.dbGetAllRawStrings() ?? {};
    Map<String, Map<String, dynamic>> jsonStore =
        await _dataPersistenceStore?.dbGetAllObjects() ?? {};
    _boolDataInMem.addAll(boolStore);
    _doubleDataInMem.addAll(doubleStore);
    _intDataInMem.addAll(intStore);
    _rawStringDataInMem.addAll(rawStringStore);
    _jsonDataInMem.addAll(jsonStore);
    return;
  }

  Future<void> persist() async {
    await db?.dbClearAll();
    await db?.dbSaveBoolData(_boolDataInMem);
    await db?.dbSaveDoubleData(_doubleDataInMem);
    await db?.dbSaveIntData(_intDataInMem);
    await db?.dbSaveRawStringData(_rawStringDataInMem);
    await db?.dbSaveDynamicData(_jsonDataInMem);
  }

  void clearInMemoryData() {
    _boolDataInMem.clear();
    _doubleDataInMem.clear();
    _intDataInMem.clear();
    _rawStringDataInMem.clear();
    _jsonDataInMem.clear();
  }

  Future<void> clearDbData() async {
    await db?.dbClearAll();
  }

  /// Clears both the database and in-memory data.
  Future<void> clean() async {
    clearInMemoryData();
    clearDbData();
  }

  void registerDataType(
    String dataType,
    String Function(dynamic)? idFn,
  ) {
    String prevMsg =
        "This data type was previously registered with a non-null idFn.";
    if (_idFnsMap.containsKey(dataType)) {
      _logger.log(11, prevMsg, counter: 0, logLevel: 0);
      return;
    }
    if (dataType.contains("|")) {
      String msg = "Data type may not contain | symbol.";
      _logger.log(12, msg, counter: 0, logLevel: 0);
      throw msg;
    }
    if (idFn != null) {
      _idFnsMap[dataType] = idFn;
    }
    MmsDataRouter().registerStoreForDataType(dataType, this);
  }

  @override
  bool acceptsBool() => true;

  @override
  bool acceptsDouble() => true;

  @override
  bool acceptsInt() => true;

  @override
  bool acceptsJson() => true;

  @override
  bool acceptsRawString() => true;

  dynamic getDynamicData(String dataType, String identifier) {
    Map<String, dynamic> dataMap = _jsonDataInMem[dataType] ?? {};
    return dataMap[identifier];
  }

  Map<String, dynamic> getDynamicDataForDataType(String dataType) {
    Map<String, dynamic> map = _jsonDataInMem[dataType] ?? {};
    Map<String, dynamic> newMap = Map.of(map);
    return newMap;
  }

  void inMemSetDynamicByDataType(
    String dataType,
    dynamic payload, {
    String? id,
  }) {
    String identifier = id ?? _idFnsMap[dataType]?.call(payload) ?? "";
    Map<String, dynamic> dynMap = _jsonDataInMem[dataType] ?? {};
    dynamic origPayload = dynMap[identifier];
    bool hasChanged = origPayload != payload;
    if (hasChanged) {
      dynMap[identifier] = payload;
      notifyListeners();
    }
  }

  Future<void> persistDynamicByDataType(
    String dataType,
    dynamic payload, {
    String? id,
  }) async {
    _logger.log(888, "persist payload for [$dataType] and [$id]");
    inMemSetDynamicByDataType(dataType, payload, id: id);
    dynamic data = getDynamicData(dataType, id ?? "");
    _logger.log(888, "pull payload back from in memory.");
    _logger.log(888, data?.toString() ?? "");
    await db?.dbSaveDynamicByDataType(dataType, payload, id: id);
    data = await db?.dbGetObjectByDataType(dataType, id ?? "");
    _logger.log(888, "Persisted data and pulled back from db.");
    _logger.log(889, data?.toString() ?? "");
  }

  @override
  void parseAndStoreJsonByDataType(String dataType, dynamic payload) {
    persistDynamicByDataType(dataType, payload);
  }

  Future<void> deleteSpecificObject(String dataType, String identifier) async {
    Map<String, dynamic> dataMap = _jsonDataInMem[dataType] ?? {};
    dataMap.remove(identifier);
    await db?.dbClearSpecificObject(dataType, identifier);
  }

  Future<void> deleteObjectsByDataType(String dataType) async {
    Map<String, dynamic> dataMap = _jsonDataInMem[dataType] ?? {};
    dataMap.clear();
    await db?.dbClearObjectsByDataType(dataType);
  }

  bool? getBoolData(String dataType, String identifier) {
    Map<String, bool> dataMap = _boolDataInMem[dataType] ?? {};
    return dataMap[identifier];
  }

  Map<String, bool> getBoolDataForDataType(String dataType) {
    Map<String, bool> map = _boolDataInMem[dataType] ?? {};
    Map<String, bool> newMap = Map.of(map);
    return newMap;
  }

  void inMemSetBoolByDataType(String dataType, String identifier, bool data) {
    Map<String, bool> boolMap = _boolDataInMem.putIfAbsent(dataType, () => {});
    bool? origVal = boolMap[identifier];
    bool hasChanged = origVal != data;
    if (hasChanged) {
      boolMap[identifier] = data;
      notifyListeners();
    }
  }

  Future<void> persistBoolByDataType(
      String dataType, String identifier, bool data) async {
    inMemSetBoolByDataType(dataType, identifier, data);
    await db?.dbSaveBoolByDataType(dataType, identifier, data);
  }

  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {
    persistBoolByDataType(dataType, identifier, data);
  }

  Future<void> deleteSpecificBool(String dataType, String identifier) async {
    Map<String, bool> dataMap = _boolDataInMem[dataType] ?? {};
    dataMap.remove(identifier);
    await db?.dbClearSpecificBool(dataType, identifier);
  }

  Future<void> deleteBoolsByDataType(String dataType) async {
    Map<String, bool> dataMap = _boolDataInMem[dataType] ?? {};
    dataMap.clear();
    await db?.dbClearBoolsByDataType(dataType);
  }

  double? getDoubleData(String dataType, String identifier) {
    Map<String, double> dataMap = _doubleDataInMem[dataType] ?? {};
    return dataMap[identifier];
  }

  Map<String, double> getDoubleDataForDataType(String dataType) {
    Map<String, double> map = _doubleDataInMem[dataType] ?? {};
    Map<String, double> newMap = Map.of(map);
    return newMap;
  }

  void inMemSetDoubleByDataType(
      String dataType, String identifier, double data) {
    Map<String, double> dblMap =
        _doubleDataInMem.putIfAbsent(dataType, () => {});
    double? origVal = dblMap[identifier];
    bool hasChanged = origVal != data;
    if (hasChanged) {
      dblMap[identifier] = data;
      notifyListeners();
    }
  }

  Future<void> persistDoubleByDataType(
      String dataType, String identifier, double data) async {
    inMemSetDoubleByDataType(dataType, identifier, data);
    await db?.dbSaveDoubleByDataType(dataType, identifier, data);
  }

  @override
  void storeDoubleByDataType(
      String dataType, String identifier, double data) async {
    await persistDoubleByDataType(dataType, identifier, data);
  }

  Future<void> deleteSpecificDouble(String dataType, String identifier) async {
    Map<String, double> dataMap = _doubleDataInMem[dataType] ?? {};
    dataMap.remove(identifier);
    await db?.dbClearSpecificDouble(dataType, identifier);
  }

  Future<void> deleteDoublesByDataType(String dataType) async {
    Map<String, double> dataMap = _doubleDataInMem[dataType] ?? {};
    dataMap.clear();
    await db?.dbClearDoublesByDataType(dataType);
  }

  int? getIntData(String dataType, String identifier) {
    Map<String, int> dataMap = _intDataInMem[dataType] ?? {};
    return dataMap[identifier];
  }

  Map<String, int> getIntDataForDataType(String dataType) {
    Map<String, int> map = _intDataInMem[dataType] ?? {};
    Map<String, int> newMap = Map.of(map);
    return newMap;
  }

  void inMemSetIntByDataType(String dataType, String identifier, int data) {
    Map<String, int> intMap = _intDataInMem.putIfAbsent(dataType, () => {});
    int? origVal = intMap[identifier];
    bool hasChanged = origVal != data;
    if (hasChanged) {
      intMap[identifier] = data;
      notifyListeners();
    }
  }

  Future<void> persistIntByDataType(
    String dataType,
    String identifier,
    int data, {
    bool willReplace = true,
  }) async {
    int? currData = getIntData(dataType, identifier);
    if (willReplace || currData == null) {
      _logger.log(101, "****************");
      _logger.log(
          101, "Replace? $willReplace, curr data: $currData, new data: $data");
      _logger.log(101, "****************");
      inMemSetIntByDataType(dataType, identifier, data);
      await db?.dbSaveIntByDataType(dataType, identifier, data);
    }
  }

  @override
  void storeIntByDataType(String dataType, String identifier, int data) {
    persistIntByDataType(dataType, identifier, data);
  }

  Future<void> deleteSpecificInt(String dataType, String identifier) async {
    Map<String, int> dataMap = _intDataInMem[dataType] ?? {};
    dataMap.remove(identifier);
    await db?.dbClearSpecificInt(dataType, identifier);
  }

  Future<void> deleteIntsByDataType(String dataType) async {
    Map<String, int> dataMap = _intDataInMem[dataType] ?? {};
    dataMap.clear();
    await db?.dbClearIntsByDataType(dataType);
  }

  String? getRawStringData(String dataType, String identifier) {
    Map<String, String> dataMap = _rawStringDataInMem[dataType] ?? {};
    return dataMap[identifier];
  }

  Map<String, String> getRawStringDataForDataType(String dataType) {
    Map<String, String> map = _rawStringDataInMem[dataType] ?? {};
    Map<String, String> newMap = Map.of(map);
    return newMap;
  }

  void inMemSetRawStringByDataType(
      String dataType, String identifier, String rawString) {
    Map<String, String> strMap =
        _rawStringDataInMem.putIfAbsent(dataType, () => {});
    String? origVal = strMap[identifier];
    bool hasChanged = origVal != rawString;
    if (hasChanged) {
      strMap[identifier] = rawString;
      notifyListeners();
    }
  }

  Future<void> persistStringByDataType(
      String dataType, String identifier, String rawString) async {
    inMemSetRawStringByDataType(dataType, identifier, rawString);
    await db?.dbSaveRawStringByDataType(dataType, identifier, rawString);
  }

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    persistStringByDataType(dataType, identifier, rawString);
  }

  Future<void> deleteSpecificRawString(
      String dataType, String identifier) async {
    Map<String, String> dataMap = _rawStringDataInMem[dataType] ?? {};
    dataMap.remove(identifier);
    await db?.dbClearSpecificRawString(dataType, identifier);
  }

  Future<void> deleteRawStringsByDataType(String dataType) async {
    Map<String, String> dataMap = _rawStringDataInMem[dataType] ?? {};
    dataMap.clear();
    await db?.dbClearRawStringsByDataType(dataType);
  }
}
