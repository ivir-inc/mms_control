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

import 'package:flutter/material.dart';
import 'package:flutter_ui/data/storage/base_data_store.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'dart:convert';

Logger _logger = Logger("Common Data Router ");

class MmsDataRouter {
  MmsDataRouter._private();
  static final MmsDataRouter _instance = MmsDataRouter._private();
  factory MmsDataRouter() => _instance;
  final Map<String, Set<BaseDataStore>> _baseDataStoreMap = {};
  final Map<String, int> _storeCounts = {};
  static const String _allRawDataType = "__ALL__RAW__";
  static const String allRawIdentifier = "ALL_RAW";

  void registerStoreForDataType(String dataType, BaseDataStore store) {
    _logger.log(999, "Registering data type $dataType in BaseDataStore");
    Set<BaseDataStore> storeSet = _baseDataStoreMap[dataType] ?? {};
    storeSet.add(store);
    _baseDataStoreMap[dataType] = storeSet;
    String storeId = store.runtimeType.toString();
    int prevCount = _storeCounts[storeId] ?? 0;
    int newCount = 1 + prevCount;
    _storeCounts[storeId] = newCount;
  }

  void removeStoreForDataType(String dataType, BaseDataStore store) {
    String storeId = store.runtimeType.toString();
    int count = _storeCounts[storeId] ?? 0;
    if (count > 1) {
      _storeCounts[storeId] = count - 1;
    } else {
      _storeCounts.remove(storeId);
      Set<BaseDataStore> storeSet = _baseDataStoreMap[dataType] ?? {};
      storeSet.remove(store);
    }
  }

  void registerStoreForAllRawData(BaseDataStore store) =>
      registerStoreForDataType(_allRawDataType, store);

  void removeStoreForAllRawData(BaseDataStore store) =>
      removeStoreForDataType(_allRawDataType, store);

  void routeDataByContainedType(String rawJson) {
    if (rawJson.trimLeft().startsWith("{")) {
      Map<String, dynamic> parsedJson = json.decode(rawJson);
      String dataType = parsedJson["dataType"] as String;
      dynamic payload = parsedJson["dataPayload"];
      Set<BaseDataStore>? dataStoreSet = _baseDataStoreMap[dataType];
      _logger.log(100, "Data type: $dataType");
      dataStoreSet?.forEach((store) {
        if (store.acceptsJson()) {
          store.parseAndStoreJsonByDataType(dataType, payload);
        }
      });
      routeRawDataToAllRawDataSetStores(dataType, "json", rawJson);
    }
  }

  void routeRawDataToAllRawDataSetStores(
      String dataType, String identifier, String rawData) {
    Set<BaseDataStore>? allRawDataStoreSet = _baseDataStoreMap[_allRawDataType];
    allRawDataStoreSet?.forEach((store) {
      if (store.acceptsRawString()) {
        store.storeRawStringByDataType(dataType, identifier, rawData);
      }
    });
  }

  void routeDataByNamedType(String dataType, dynamic rawJson) {
    dynamic payload;

    if (rawJson is String) {
      payload = json.decode(rawJson);
    } else if (rawJson is Map<String, dynamic>) {
      payload = rawJson;
    } else {
      debugPrint("ERROR: Unexpected type for rawJson: ${rawJson.runtimeType}");
      return;
    }

    Set<BaseDataStore>? dataStoreSet = _baseDataStoreMap[dataType];
    dataStoreSet?.forEach((store) {
      if (store.acceptsJson()) {
        store.parseAndStoreJsonByDataType(dataType, payload);
      }
    });

    if (rawJson is String) {
      routeRawDataToAllRawDataSetStores(dataType, "json", rawJson);
    } else {
      routeRawDataToAllRawDataSetStores(dataType, "json", json.encode(rawJson));
    }
  }

  void routeRawStringByNamedType(
    String dataType,
    String identifier,
    String rawString,
  ) {
    Set<BaseDataStore>? dataStoreSet = _baseDataStoreMap[dataType];
    dataStoreSet?.forEach((store) {
      if (store.acceptsRawString()) {
        store.storeRawStringByDataType(dataType, identifier, rawString);
      }
    });
    routeRawDataToAllRawDataSetStores(dataType, identifier, rawString);
  }

  void routeBoolByNamedType(
    String dataType,
    String identifier,
    bool data,
  ) {
    Set<BaseDataStore>? dataStoreSet = _baseDataStoreMap[dataType];
    dataStoreSet?.forEach((store) {
      if (store.acceptsBool()) {
        store.storeBoolByDataType(dataType, identifier, data);
      }
    });
    routeRawDataToAllRawDataSetStores(dataType, identifier, "$data");
  }

  void routeIntByNamedType(
    String dataType,
    String identifier,
    int data,
  ) {
    Set<BaseDataStore>? dataStoreSet = _baseDataStoreMap[dataType];
    dataStoreSet?.forEach((store) {
      if (store.acceptsInt()) {
        store.storeIntByDataType(dataType, identifier, data);
      }
    });
    routeRawDataToAllRawDataSetStores(dataType, identifier, "$data");
  }

  void routeDoubleByNamedType(
    String dataType,
    String identifier,
    double data,
  ) {
    Set<BaseDataStore>? dataStoreSet = _baseDataStoreMap[dataType];
    dataStoreSet?.forEach((store) {
      if (store.acceptsDouble()) {
        store.storeDoubleByDataType(dataType, identifier, data);
      }
    });
    routeRawDataToAllRawDataSetStores(dataType, identifier, "$data");
  }
}
