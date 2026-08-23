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

import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Model for the web socket simulation time data.
class SimDateTimeModel extends Equatable {
  final int rate;
  final int elapsedTimeMs;
  final int? simTimeMs;
  final int? wallClockMs;
  const SimDateTimeModel({
    required this.rate,
    required this.elapsedTimeMs,
    this.simTimeMs,
    this.wallClockMs,
  });

  static const SimDateTimeModel defModel = SimDateTimeModel(
    rate: 1,
    elapsedTimeMs: 0,
  );

  static const SimDateTimeModel errModel = SimDateTimeModel(
    rate: 0,
    elapsedTimeMs: 0,
  );

  factory SimDateTimeModel.fromJson(Map<String, dynamic> json) {
    int jRate = json["rate"];
    int jElapsedTimeMs = json["elapsedTimeMs"];
    int jSimTimeMs = json["simTimeMs"];
    int jWallClockMs = json["wallClockMs"];
    return SimDateTimeModel(
        rate: jRate,
        elapsedTimeMs: jElapsedTimeMs,
        simTimeMs: jSimTimeMs,
        wallClockMs: jWallClockMs);
  }

  String hrMinSec(int ms) {
    int sec = (ms / 1000).floor();
    int min = (sec / 60).floor();
    int hr = (min / 60).floor();
    sec = sec % 60;
    min = min % 60;
    return "$hr:$min:$sec";
  }

  String elapsedHrMinSec() {
    return hrMinSec(elapsedTimeMs);
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        rate,
        elapsedTimeMs,
        simTimeMs,
        wallClockMs,
      ];
}

class SimDateTimeModelStore extends BaseDataStore {
  final Map<String, SimDateTimeModel> _modelMap = {};
  static const String _simDataType = "DateTime";

  SimDateTimeModelStore._private() {
    MmsDataRouter().registerStoreForDataType(_simDataType, this);
  }

  static final _instance = SimDateTimeModelStore._private();

  factory SimDateTimeModelStore() => _instance;

  SimDateTimeModel loadFromJson(
    Map<String, dynamic> json, {
    String? simId,
  }) {
    SimDateTimeModel simDateTimeModel = SimDateTimeModel.fromJson(json);
    putSimDateTimeModel(
      simDateTimeModel,
      simId: simId,
    );
    return simDateTimeModel;
  }

  /// The [simId] could be a patient id, if there is one.
  void putSimDateTimeModel(
    SimDateTimeModel simDateTimeModel, {
    String? simId,
  }) {
    String useSimId = simId ?? "";
    SimDateTimeModel useSimDateTimeModel = simDateTimeModel;
    SimDateTimeModel? simDateTimeModelById = _modelMap[useSimId];
    if (useSimDateTimeModel != simDateTimeModelById) {
      _modelMap[useSimId] = useSimDateTimeModel;
      notifyListeners();
    }
  }

  SimDateTimeModel? simDateTimeModel(
    String simId,
  ) =>
      _modelMap[simId];

  @override
  bool acceptsJson() => true;

  @override
  bool acceptsRawString() => false;

  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    if (dataType == "DateTime") {
      Map<String, dynamic> jsonMap = payload as Map<String, dynamic>;
      loadFromJson(
        jsonMap,
      ); // Currently no sort of id is provided.
    }
  }

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {
    // Intentionally empty.
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

/// Use this to get access to the store. This object may be disposed without
/// affecting the store itself.
class SimDateTimeModelStoreAccess extends ChangeNotifier {
  final SimDateTimeModelStore store = SimDateTimeModelStore();

  SimDateTimeModelStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Model for the scenario engine status and control REST data.
class SimScenEngModel extends Equatable {
  final bool running;
  final String hrMinSec;
  final String? scenario;
  final String? stage;
  const SimScenEngModel({
    required this.running,
    required this.hrMinSec,
    this.scenario,
    this.stage,
  });

  static const SimScenEngModel defModel = SimScenEngModel(
    running: false,
    hrMinSec: "-:--:--",
  );

  factory SimScenEngModel.fromJson(Map<String, dynamic> json) {
    bool jRunning = json["running"];
    String jHrMinSec = json["time"];
    String jScenario = json["scenario"];
    String jStage = json["stage"];
    return SimScenEngModel(
      running: jRunning,
      hrMinSec: jHrMinSec,
      scenario: jScenario,
      stage: jStage,
    );
  }

  @override
  List<Object?> get props => [
        running,
        hrMinSec,
        scenario,
        stage,
      ];
}

class SimScenEngModelStore extends ChangeNotifier {
  final Map<String, SimScenEngModel> _modelMap = {};

  SimScenEngModelStore._private();

  static final _instance = SimScenEngModelStore._private();

  factory SimScenEngModelStore() => _instance;

  /// The [simId] could be a patient id, if there is one.
  SimScenEngModel loadFromJson(
    Map<String, dynamic> json, {
    String? simId,
  }) {
    SimScenEngModel simDateTimeModel = SimScenEngModel.fromJson(json);
    putSimScenEngModel(
      simDateTimeModel,
      simId: simId ?? "",
    );
    return simDateTimeModel;
  }

  /// The [simId] could be a patient id, if there is one.
  void putSimScenEngModel(
    SimScenEngModel simDateTimeModel, {
    String simId = "",
  }) {
    SimScenEngModel? simDateTimeModelById = _modelMap[simId];
    if (simDateTimeModel != simDateTimeModelById) {
      SimScenEngModel useSimScenEngModel = simDateTimeModel;
      _modelMap[simId] = useSimScenEngModel;
      notifyListeners();
    }
  }
}

/// Use this to get access to the store in situations where the store might
/// be disposed otherwise.
class SimScenEngModelStoreAccess extends ChangeNotifier {
  final SimScenEngModelStore store = SimScenEngModelStore();

  SimScenEngModelStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
