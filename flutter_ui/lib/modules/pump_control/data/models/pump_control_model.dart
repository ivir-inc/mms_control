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

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class PumpControlScenario {
  final int id;
  final String name;
  final int neg;
  final int low;
  final int desired;
  final int high;
  final bool hasError;
  final Map<String, int> ratesMap = {};
  final Map<int, String> reverseRatesMap = {};
  PumpControlScenario(
      this.id, this.name, this.neg, this.low, this.desired, this.high,
      {this.hasError = false}) {
    ratesMap["neg"] = neg;
    ratesMap["low"] = low;
    ratesMap["desired"] = desired;
    ratesMap["high"] = high;
    reverseRatesMap[neg] = "neg";
    reverseRatesMap[low] = "low";
    reverseRatesMap[desired] = "desired";
    reverseRatesMap[high] = "high";
  }
  factory PumpControlScenario.fromJson(Map<String, dynamic> json,
      {bool hasError = false}) {
    return PumpControlScenario(json["id"], json["name"], json["neg"],
        json["low"], json["desired"], json["high"],
        hasError: hasError);
  }

  int? getRateValueForRateLabel(String rateLabel) {
    return ratesMap[rateLabel];
  }

  String? getRateLabelForRateValue(int rateValue) {
    return reverseRatesMap[rateValue];
  }
}

class PumpControlScenarios {
  final List<PumpControlScenario> scenarios;
  final String message;
  final bool hasError;
  PumpControlScenarios(this.scenarios,
      {this.message = "", this.hasError = false});

  void addPumpControlScenario(PumpControlScenario pumpControlScenario) {
    scenarios.add(pumpControlScenario);
  }

  factory PumpControlScenarios.fromJson(Map<String, dynamic> json,
      {bool hasError = false}) {
    List<PumpControlScenario> scenariosList = [];
    List scenarios = (json)["scenarios"] ?? [];
    for (var element in scenarios) {
      PumpControlScenario s = PumpControlScenario.fromJson(element);
      scenariosList.add(s);
    }
    return PumpControlScenarios(scenariosList,
        message: json["message"] ?? "", hasError: hasError);
  }

  PumpControlScenario? scenarioById(int? id) {
    for (PumpControlScenario s in scenarios) {
      if (s.id == id) {
        return s;
      }
    }
    return null;
  }

  bool isValidScenarioId(int? id) {
    if(id == null){
      return false;
    }
    PumpControlScenario? scenario = scenarioById(id);
    return scenario != null;
  }

  String? scenarioNameForId(int? id) {
    if(id == null){
      return null;
    }
    PumpControlScenario? scenario = scenarioById(id);
    return scenario?.name;
  }
}

class SelectedScenario {
  final int? id;
  final String? name;
  final String? rateName;
  final int? rateValue;
  final String? message;
  final bool? hasError;
  SelectedScenario(
      this.id, this.name, this.rateName, this.rateValue, this.message,
      {this.hasError = false});
  factory SelectedScenario.fromJson(Map<String, dynamic> json,
      {bool hasError = false}) {
    return SelectedScenario(json["id"], json["name"], json["rateName"],
        json["rateValue"], json["message"],
        hasError: hasError);
  }
}

class RuntimeStatus extends Equatable {
  final String? urinePumpLabel;
  final String? bloodPumpLabel;
  final String? catheterLabel;
  final bool? dispenseRestricted;
  final bool? emergencyStopped;
  final String? message;
  final bool hasError;
  const RuntimeStatus(this.urinePumpLabel, this.bloodPumpLabel, this.catheterLabel,
      this.dispenseRestricted, this.emergencyStopped, this.message,
      {this.hasError = false});
  factory RuntimeStatus.fromJson(Map<String, dynamic> json,
      {bool hasError = false}) {
    return RuntimeStatus(json["urinePump"], json["bloodPump"], json["catheter"],
        json["dispenseRestricted"], json["emergencyStopped"], json["message"],
        hasError: hasError);
  }

  @override
  List<Object?> get props => [
        urinePumpLabel,
        bloodPumpLabel,
        catheterLabel,
        dispenseRestricted,
        emergencyStopped,
        message,
        hasError
      ];
}

class RuntimeStatusStore extends ChangeNotifier {
  final Map<String, RuntimeStatus> _runtimeStatusesMap = {};

  RuntimeStatusStore._private();

  static final RuntimeStatusStore _instance = RuntimeStatusStore._private();

  factory RuntimeStatusStore() => _instance;

  void putRuntimeStatus(String? patientId, RuntimeStatus runtimeStatus) {
    RuntimeStatus? patientRuntimeStatus = _runtimeStatusesMap[patientId];
    if ((patientRuntimeStatus != runtimeStatus) && (patientId != null)) {
      _runtimeStatusesMap[patientId] = runtimeStatus;
      notifyListeners();
    }
  }

  RuntimeStatus? getRuntimeStatus(String patientId) =>
      _runtimeStatusesMap[patientId];
}

class RuntimeStatusStoreAccess extends ChangeNotifier {
  final RuntimeStatusStore store = RuntimeStatusStore();

  RuntimeStatusStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }

  void putRuntimeStatus(String patientId, RuntimeStatus runtimeStatus) =>
      store.putRuntimeStatus(patientId, runtimeStatus);

  RuntimeStatus? getRuntimeStatus(String? patientId) =>
      patientId == null? null : store.getRuntimeStatus(patientId);
}
