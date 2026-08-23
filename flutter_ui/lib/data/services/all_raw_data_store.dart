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
import 'package:flutter_ui/data/model/raw_data/raw_data_model.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';

class AllRawDataStore extends BaseDataStore {
  AllRawDataStore._private() {
    MmsDataRouter().registerStoreForAllRawData(this);
  }

  static final AllRawDataStore _instance = AllRawDataStore._private();

  factory AllRawDataStore() => _instance;

  @override
  void dispose() {
    MmsDataRouter().removeStoreForAllRawData(this);
    super.dispose();
  }

  RawDataModel? _lastRawData;

  RawDataModel get lastData => _lastRawData ?? RawDataModel.unknown;

  @override
  bool acceptsBool() => false;

  @override
  bool acceptsDouble() => false;

  @override
  bool acceptsInt() => false;

  @override
  bool acceptsJson() => false;

  @override
  bool acceptsRawString() => true;

  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    // Intentionally empty.
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
    RawDataModel newModel = RawDataModel(dataType, identifier, rawString);
    bool hasChanged = newModel != _lastRawData;
    if (hasChanged) {
      _lastRawData = newModel;
      // print(newModel);
      notifyListeners();
    }
  }
}
