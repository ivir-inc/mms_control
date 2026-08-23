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

import 'package:flutter/foundation.dart';
import 'package:flutter_ui/data/storage/base_data_store.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:idb_shim/idb_io.dart';

import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("CommonDataPersist");

class DataPersistenceStore extends BaseDataStore {
  static const String path = "data/persistent/db";
  static const String dbName = "mms_ui.db";
  static const String storeNameBool = "bool";
  static const String storeNameDouble = "double";
  static const String storeNameInt = "int";
  static const String storeNameString = "string";
  static const String storeNameJson = "json";
  static IdbFactory? _idbFactory;
  Database? _db;
  final Map<String, String Function(dynamic)?> _idFnsMap = {};

  DataPersistenceStore._private();

  static final DataPersistenceStore _instance = DataPersistenceStore._private();

  /// Returns the singleton instance of DataPersistenceStore.
  static Future<DataPersistenceStore> instance() async {
    if (kIsWeb) {
      _idbFactory ??= getIdbFactory();
    } else {
      _idbFactory ??= getIdbFactoryPersistent(path);
    }
    _instance._db ??= await _idbFactory?.open(dbName, version: 1,
        onUpgradeNeeded: (VersionChangeEvent event) {
      final db = event.database;
      db.createObjectStore(storeNameBool);
      db.createObjectStore(storeNameDouble);
      db.createObjectStore(storeNameInt);
      db.createObjectStore(storeNameString);
      db.createObjectStore(storeNameJson);
    });
    return _instance;
  }

  void registerDataType(
    String dataType,
    String Function(dynamic)? idFn,
  ) {
    String prevMsg =
        "This data type was previously registered with a non-null idFn.";
    if (_idFnsMap.containsKey(dataType)) {
      _logger.log(1, prevMsg, counter: 0, logLevel: 0);
      return;
    }
    if (dataType.contains("|")) {
      String msg = "Data type may not contain | symbol.";
      _logger.log(2, msg, counter: 0, logLevel: 0);
      throw msg;
    }
    if (idFn != null) {
      _idFnsMap[dataType] = idFn;
    }
    MmsDataRouter().registerStoreForDataType(dataType, this);
  }

  // database operations

  String get dbKeyDelim => "||";

  String dbKey(String dataType, String identifier) =>
      "$dataType$dbKeyDelim$identifier";

  String dbKeyPrefix(String dataType) => "$dataType$dbKeyDelim";

  Future<void> dbSaveDynamicByDataType(
    String dataType,
    dynamic payload, {
    String? id,
  }) async {
    String identifier = id ?? _idFnsMap[dataType]?.call(payload) ?? "";
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameJson, idbModeReadWrite);
    ObjectStore? store = txn?.objectStore(storeNameJson);
    await store?.put(payload, key);
    await txn?.completed;
    notifyListeners();
  }

  @override
  void parseAndStoreJsonByDataType(String dataType, dynamic payload) {
    dbSaveDynamicByDataType(dataType, payload);
  }

  Future<void> dbSaveDynamicData(
      Map<String, Map<String, dynamic>> dynamicData) async {
    for (String dataType in dynamicData.keys) {
      Map<String, dynamic>? dynamicDataForDataType = dynamicData[dataType];
      for (String id in dynamicDataForDataType?.keys ?? []) {
        await dbSaveDynamicByDataType(
          dataType,
          dynamicDataForDataType?[id] ?? {},
          id: id,
        );
      }
    }
  }

  Future<void> dbSaveBoolByDataType(
      String dataType, String identifier, bool data) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameBool, idbModeReadWrite);
    ObjectStore? store = txn?.objectStore(storeNameBool);
    await store?.put(data, key);
    await txn?.completed;
    notifyListeners();
  }

  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {
    dbSaveBoolByDataType(dataType, identifier, data);
  }

  Future<void> dbSaveBoolData(Map<String, Map<String, bool>> boolData) async {
    for (String dataType in boolData.keys) {
      Map<String, bool>? boolDataForDataType = boolData[dataType];
      for (String id in boolDataForDataType?.keys ?? []) {
        await dbSaveBoolByDataType(
          dataType,
          id,
          boolDataForDataType?[id] ?? false,
        );
      }
    }
  }

  Future<void> dbSaveDoubleByDataType(
      String dataType, String identifier, double data) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameDouble, idbModeReadWrite);
    ObjectStore? store = txn?.objectStore(storeNameDouble);
    await store?.put(data, key);
    await txn?.completed;
    notifyListeners();
  }

  @override
  void storeDoubleByDataType(String dataType, String identifier, double data) {
    dbSaveDoubleByDataType(dataType, identifier, data);
  }

  Future<void> dbSaveDoubleData(
      Map<String, Map<String, double>> doubleData) async {
    for (String dataType in doubleData.keys) {
      Map<String, double>? doubleDataForDataType = doubleData[dataType];
      for (String id in doubleDataForDataType?.keys ?? []) {
        await dbSaveDoubleByDataType(
          dataType,
          id,
          doubleDataForDataType?[id] ?? 0,
        );
      }
    }
  }

  Future<void> dbSaveIntByDataType(
      String dataType, String identifier, int data) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameInt, idbModeReadWrite);
    ObjectStore? store = txn?.objectStore(storeNameInt);
    await store?.put(data, key);
    await txn?.completed;
    notifyListeners();
  }

  @override
  void storeIntByDataType(String dataType, String identifier, int data) {
    dbSaveIntByDataType(dataType, identifier, data);
  }

  Future<void> dbSaveIntData(Map<String, Map<String, int>> intData) async {
    for (String dataType in intData.keys) {
      Map<String, int>? intDataForDataType = intData[dataType];
      for (String id in intDataForDataType?.keys ?? []) {
        await dbSaveIntByDataType(
          dataType,
          id,
          intDataForDataType?[id] ?? 0,
        );
      }
    }
  }

  Future<void> dbSaveRawStringByDataType(
      String dataType, String identifier, String data) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameString, idbModeReadWrite);
    ObjectStore? store = txn?.objectStore(storeNameString);
    await store?.put(data, key);
    await txn?.completed;
    notifyListeners();
  }

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    dbSaveRawStringByDataType(dataType, identifier, rawString);
  }

  Future<void> dbSaveRawStringData(
      Map<String, Map<String, String>> stringData) async {
    for (String dataType in stringData.keys) {
      Map<String, String>? stringDataForDataType = stringData[dataType];
      for (String id in stringDataForDataType?.keys ?? []) {
        await dbSaveRawStringByDataType(
          dataType,
          id,
          stringDataForDataType?[id] ?? "",
        );
      }
    }
  }

  Future<bool?> dbGetBoolByDataType(String dataType, String identifier) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameBool, idbModeReadOnly);
    ObjectStore? store = txn?.objectStore(storeNameBool);
    final bool? value = await store?.getObject(key) as bool?;
    await txn?.completed;
    return value;
  }

  Future<double?> dbGetDoubleByDataType(
      String dataType, String identifier) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameDouble, idbModeReadOnly);
    ObjectStore? store = txn?.objectStore(storeNameDouble);
    final double? value = await store?.getObject(key) as double?;
    await txn?.completed;
    return value;
  }

  Future<int?> dbGetIntByDataType(String dataType, String identifier) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameInt, idbModeReadOnly);
    ObjectStore? store = txn?.objectStore(storeNameInt);
    final int? value = await store?.getObject(key) as int?;
    await txn?.completed;
    return value;
  }

  Future<String?> dbGetRawStringByDataType(
      String dataType, String identifier) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameString, idbModeReadOnly);
    ObjectStore? store = txn?.objectStore(storeNameString);
    final String? value = await store?.getObject(key) as String?;
    await txn?.completed;
    return value;
  }

  Future<dynamic> dbGetObjectByDataType(
      String dataType, String identifier) async {
    String key = dbKey(dataType, identifier);
    Transaction? txn = _db?.transaction(storeNameJson, idbModeReadOnly);
    ObjectStore? store = txn?.objectStore(storeNameJson);
    final dynamic value = await store?.getObject(key);
    await txn?.completed;
    return value;
  }

  Future<List<String>> _allKeys(String storeName) async {
    Transaction? txn = _db?.transaction(storeName, idbModeReadOnly);
    ObjectStore? store = txn?.objectStore(storeName);
    List<Object>? allObjKeys = await store?.getAllKeys();
    await txn?.completed;
    List<String> allKeys = [];
    for (Object objKey in allObjKeys ?? []) {
      allKeys.add(objKey.toString());
    }
    return allKeys;
  }

  Future<List<String>> _allIdsForDataType(
    String storeName,
    String dataType,
  ) async {
    List<String> allKeys = await _allKeys(storeName);
    List<String> allIdsForDataType = [];
    for (String key in allKeys) {
      if (key.startsWith(dbKeyPrefix(dataType))) {
        int idIdx = dataType.length + 2;
        String id = key.substring(idIdx);
        allIdsForDataType.add(id);
      }
    }
    return allIdsForDataType;
  }

  Future<Map<String, bool>> dbGetAllBoolsByDataType(String dataType) async {
    List<String> allIdsForDataType =
        await _allIdsForDataType(storeNameBool, dataType);
    Map<String, bool> allBools = {};
    for (String id in allIdsForDataType) {
      bool? data = await dbGetBoolByDataType(dataType, id);
      if (data != null) {
        allBools[id] = data;
      }
    }
    return allBools;
  }

  Future<Map<String, double>> dbGetAllDoublesByDataType(String dataType) async {
    List<String> allIdsForDataType =
        await _allIdsForDataType(storeNameDouble, dataType);
    Map<String, double> allDoubles = {};
    for (String id in allIdsForDataType) {
      double? data = await dbGetDoubleByDataType(dataType, id);
      if (data != null) {
        allDoubles[id] = data;
      }
    }
    return allDoubles;
  }

  Future<Map<String, int>> dbGetAllIntsByDataType(String dataType) async {
    List<String> allIdsForDataType =
        await _allIdsForDataType(storeNameInt, dataType);
    Map<String, int> allInts = {};
    for (String id in allIdsForDataType) {
      int? data = await dbGetIntByDataType(dataType, id);
      if (data != null) {
        allInts[id] = data;
      }
    }
    return allInts;
  }

  Future<Map<String, String>> dbGetAllRawStringsByDataType(
      String dataType) async {
    List<String> allIdsForDataType =
        await _allIdsForDataType(storeNameString, dataType);
    Map<String, String> allStrings = {};
    for (String id in allIdsForDataType) {
      String? data = await dbGetRawStringByDataType(dataType, id);
      if (data != null) {
        allStrings[id] = data;
      }
    }
    return allStrings;
  }

  Future<Map<String, dynamic>> dbGetAllObjectsByDataType(
      String dataType) async {
    List<String> allIdsForDataType =
        await _allIdsForDataType(storeNameJson, dataType);
    Map<String, dynamic> allDynamics = {};
    for (String id in allIdsForDataType) {
      dynamic data = await dbGetObjectByDataType(dataType, id);
      if (data != null) {
        allDynamics[id] = data;
      }
    }
    return allDynamics;
  }

  Future<Map<String, List<String>>> _allDataTypesAndIds(
      String storeName) async {
    List<String> allKeys = await _allKeys(storeName);
    Map<String, List<String>> allDataTypesAndIds = {};
    for (String key in allKeys) {
      List<String> keyParts = key.split(dbKeyDelim);
      if (keyParts.length > 1) {
        String dataType = keyParts[0];
        String id = keyParts[1];
        allDataTypesAndIds.putIfAbsent(dataType, () => []).add(id);
      }
    }
    return allDataTypesAndIds;
  }

  Future<Map<String, Map<String, bool>>> dbGetAllBools() async {
    Map<String, Map<String, bool>> allBools = {};
    Map<String, List<String>> allDataTypesAndIds =
        await _allDataTypesAndIds(storeNameBool);
    List<String> dataTypes = allDataTypesAndIds.keys.toList();
    for (String dataType in dataTypes) {
      List<String>? idList = allDataTypesAndIds[dataType];
      for (String id in idList ?? []) {
        bool? value = await dbGetBoolByDataType(dataType, id);
        if (value != null) {
          allBools.putIfAbsent(dataType, () => {})[id] = value;
        }
      }
    }
    return allBools;
  }

  Future<Map<String, Map<String, double>>> dbGetAllDoubles() async {
    Map<String, Map<String, double>> allDoubles = {};
    Map<String, List<String>> allDataTypesAndIds =
        await _allDataTypesAndIds(storeNameDouble);
    List<String> dataTypes = allDataTypesAndIds.keys.toList();
    for (String dataType in dataTypes) {
      List<String>? idList = allDataTypesAndIds[dataType];
      for (String id in idList ?? []) {
        double? value = await dbGetDoubleByDataType(dataType, id);
        if (value != null) {
          allDoubles.putIfAbsent(dataType, () => {})[id] = value;
        }
      }
    }
    return allDoubles;
  }

  Future<Map<String, Map<String, int>>> dbGetAllInts() async {
    Map<String, Map<String, int>> allInts = {};
    Map<String, List<String>> allDataTypesAndIds =
        await _allDataTypesAndIds(storeNameInt);
    List<String> dataTypes = allDataTypesAndIds.keys.toList();
    for (String dataType in dataTypes) {
      List<String>? idList = allDataTypesAndIds[dataType];
      for (String id in idList ?? []) {
        int? value = await dbGetIntByDataType(dataType, id);
        if (value != null) {
          allInts.putIfAbsent(dataType, () => {})[id] = value;
        }
      }
    }
    return allInts;
  }

  Future<Map<String, Map<String, String>>> dbGetAllRawStrings() async {
    Map<String, Map<String, String>> allStrings = {};
    Map<String, List<String>> allDataTypesAndIds =
        await _allDataTypesAndIds(storeNameString);
    List<String> dataTypes = allDataTypesAndIds.keys.toList();
    for (String dataType in dataTypes) {
      List<String>? idList = allDataTypesAndIds[dataType];
      for (String id in idList ?? []) {
        String? value = await dbGetRawStringByDataType(dataType, id);
        if (value != null) {
          allStrings.putIfAbsent(dataType, () => {})[id] = value;
        }
      }
    }
    return allStrings;
  }

  Future<Map<String, Map<String, dynamic>>> dbGetAllObjects() async {
    Map<String, Map<String, dynamic>> allObjects = {};
    Map<String, List<String>> allDataTypesAndIds =
        await _allDataTypesAndIds(storeNameJson);
    List<String> dataTypes = allDataTypesAndIds.keys.toList();
    for (String dataType in dataTypes) {
      List<String>? idList = allDataTypesAndIds[dataType];
      for (String id in idList ?? []) {
        dynamic value = await dbGetObjectByDataType(dataType, id);
        if (value != null) {
          allObjects.putIfAbsent(dataType, () => {})[id] = value;
        }
      }
    }
    return allObjects;
  }

  Future<void> _dbClearSpecificData(
      String storeName, String dataType, String identifier) async {
    Transaction? txn = _db?.transaction(storeName, idbModeReadWrite);
    ObjectStore? store = txn?.objectStore(storeName);
    String key = dbKey(dataType, identifier);
    await store?.delete(key);
    await txn?.completed;
  }

  Future<void> dbClearSpecificBool(String dataType, String identifier) async {
    await _dbClearSpecificData(storeNameBool, dataType, identifier);
  }

  Future<void> dbClearSpecificDouble(String dataType, String identifier) async {
    await _dbClearSpecificData(storeNameDouble, dataType, identifier);
  }

  Future<void> dbClearSpecificInt(String dataType, String identifier) async {
    await _dbClearSpecificData(storeNameInt, dataType, identifier);
  }

  Future<void> dbClearSpecificRawString(
      String dataType, String identifier) async {
    await _dbClearSpecificData(storeNameString, dataType, identifier);
  }

  Future<void> dbClearSpecificObject(String dataType, String identifier) async {
    await _dbClearSpecificData(storeNameJson, dataType, identifier);
  }

  Future<void> _dbClearAllInStoreByDataType(
      String storeName, String dataType) async {
    List<String>? allIdsForDataType =
        await _allIdsForDataType(storeName, dataType);
    for (String id in allIdsForDataType) {
      await _dbClearSpecificData(storeName, dataType, id);
    }
  }

  Future<void> dbClearBoolsByDataType(String dataType) async {
    await _dbClearAllInStoreByDataType(storeNameBool, dataType);
  }

  Future<void> dbClearDoublesByDataType(String dataType) async {
    await _dbClearAllInStoreByDataType(storeNameDouble, dataType);
  }

  Future<void> dbClearIntsByDataType(String dataType) async {
    await _dbClearAllInStoreByDataType(storeNameInt, dataType);
  }

  Future<void> dbClearRawStringsByDataType(String dataType) async {
    await _dbClearAllInStoreByDataType(storeNameString, dataType);
  }

  Future<void> dbClearObjectsByDataType(String dataType) async {
    await _dbClearAllInStoreByDataType(storeNameJson, dataType);
  }

  Future<void> _dbClearAllInStore(String storeName) async {
    Transaction? txn = _db?.transaction(storeName, idbModeReadWrite);
    ObjectStore? store = txn?.objectStore(storeName);
    List<Object>? allObjKeys = await store?.getAllKeys();
    for (var objKey in allObjKeys ?? []) {
      await store?.delete(objKey);
    }
    await txn?.completed;
  }

  Future<void> dbClearAllBools() async {
    await _dbClearAllInStore(storeNameBool);
  }

  Future<void> dbClearAllDoubles() async {
    await _dbClearAllInStore(storeNameDouble);
  }

  Future<void> dbClearAllInts() async {
    await _dbClearAllInStore(storeNameInt);
  }

  Future<void> dbClearAllRawStrings() async {
    await _dbClearAllInStore(storeNameString);
  }

  Future<void> dbClearAllObjects() async {
    await _dbClearAllInStore(storeNameJson);
  }

  Future<void> dbClearAll() async {
    await dbClearAllBools();
    await dbClearAllDoubles();
    await dbClearAllInts();
    await dbClearAllRawStrings();
    await dbClearAllObjects();
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
}
