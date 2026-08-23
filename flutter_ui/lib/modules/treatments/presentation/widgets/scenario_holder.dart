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

import '../../data/services/scenario_services.dart';

import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:collection/collection.dart'; // Add this import for firstWhereOrNull

Logger _logger = Logger(
  "ScenarioHolder",
  debugging: true,
);

// Define the MedicationEnum based on the new FOM v3 XML
enum MedicationEnum {
  notApplicable,
  saline09,
  saline3,
  morphine,
  ketamine,
  epinephrine,
  dextrose,
  lactatedRingers,
  oxygen,
  aspirin,
  calciumGluconate,
  sodiumChloride,
  midazolamHydrochloride,
  diphenhydramine,
  acetaminophen,
  moxifloxacin,
  ertapenem,
  meloxicam,
  ondansetron,
  fentanylCitrate,
  methylprednisolone,
  naloxone,
  tranexamicAcid,
  atropine,
  lidocaine,
  adenosine,
  hextend,
  freshWholeBlood,
  plasma,
  redBloodCells,
  plasmalyteA,
  clindamycin,
  acyclovir,
  narcan,
  ibuprofen,
}

// Define MedicationAdministrationRouteEnum for administration routes
enum MedicationAdministrationRouteEnum {
  notApplicable,
  IV,
  IM,
  PO,
  IO,
  TM,
  SL,
  IN,
}

enum TreatmentDeviceEnum {
  notApplicable,
  cervicalCollar,
  extremityTourniquet,
  junctionalTourniquet,
  spineBoard,
  litter,
  bandage,
  gauze,
  ventedOcclusiveDressing,
  occlusiveDressing,
  mylarBlanket,
  chestTube,
  chestNeedleDecompression,
  foleyCatheter,
  oropharyngealAirway,
  nasopharyngealAirway,
  endotrachealTube,
  laryngealTube,
  supraglotticDevice,
  laryngoscope,
  endovascularBalloon,
  eyeShield,
  splint,
  oxygenMask,
  isopropylAlcoholPad,
  cricothyroidotomyKit,
}

TreatmentDeviceEnum treatmentDeviceEnumFromString(String? value) {
  if (value == null) {
    return TreatmentDeviceEnum.notApplicable;
  }

  // Normalize the input string to lowercase for case-insensitive matching
  String normalizedValue = value.toLowerCase();

  return TreatmentDeviceEnum.values.firstWhere(
    (e) => e.toString().split('.').last == normalizedValue,
    orElse: () => TreatmentDeviceEnum.notApplicable,
  );
}

// TreatmentSpecifics class with additional attributes for handling devices
class TreatmentSpecifics {
  String name;
  String deviceUsed; // This should directly store the string from JSON
  String treatmentLocation;
  List<String> injuries;

  TreatmentSpecifics(
      {required this.name,
      required this.deviceUsed,
      required this.treatmentLocation,
      required this.injuries});

  factory TreatmentSpecifics.fromJson(Map<String, dynamic> json) {
    Logger logger = Logger("TreatmentSpecifics");

    // logger.log(1, "Raw JSON for TreatmentSpecifics: $json");

    // Extract the 'name' field
    String treatmentName = (json['name']?.toString() ?? "").trim();
    if (treatmentName.isEmpty) {
      treatmentName = "Unnamed Treatment";
    }
    // logger.log(1, "Parsed treatment name: $treatmentName");

    List<String>? injuryList =
        (json['injuries'] as List?)?.map((i) => i.toString()).toList();

    // Since 'device' is missing in the JSON, default to "Unknown Device"
    String deviceUsedRaw = "Unknown Device";

    // Since 'location' is missing in the JSON, default to "N/A"
    String treatmentLocation = "N/A";

    // logger.log(1, "Parsed device used: $deviceUsedRaw");
    // logger.log(1, "Parsed treatment location: $treatmentLocation");

    return TreatmentSpecifics(
        name: treatmentName,
        deviceUsed: deviceUsedRaw,
        treatmentLocation: treatmentLocation,
        injuries: injuryList ?? []);
  }

  Map<String, dynamic> toJson() => {
        'treatmentName': name,
        'deviceUsed': deviceUsed,
        'treatmentLocation': treatmentLocation,
        'injuries': injuries.map((i) => i.toString()).toList(),
      };
}

class TreatmentDetailsBySubType {
  String subType;
  List<TreatmentSpecifics>? specifics;

  TreatmentDetailsBySubType({required this.subType, this.specifics});

  factory TreatmentDetailsBySubType.fromJson(Map<String, dynamic> json) {
    Logger logger = Logger("TreatmentDetailsBySubType");
    // logger.log(1, "Raw specifics list: ${json['specifics']}");

    return TreatmentDetailsBySubType(
      subType: json['subType'] ?? "",
      specifics: (json['specifics'] as List?)
          ?.map((i) => TreatmentSpecifics.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'subType': subType,
        'specifics': specifics?.map((i) => i.toJson()).toList(),
      };
}

class TreatmentsByType {
  String type;
  List<TreatmentDetailsBySubType>? detailsList;

  TreatmentsByType({required this.type, this.detailsList});

  factory TreatmentsByType.fromJson(Map<String, dynamic> json) {
    return TreatmentsByType(
      type: json['type'] ?? "",
      detailsList: (json['details'] as List?)
          ?.map((i) => TreatmentDetailsBySubType.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'details': detailsList?.map((i) => i.toJson()).toList(),
      };
}

class MedicationSpecifics {
  String name; // Change from MedicationEnum to String
  bool allowed;

  MedicationSpecifics({required this.name, required this.allowed});

  factory MedicationSpecifics.fromJson(Map<String, dynamic> json) {
    return MedicationSpecifics(
      name:
          json['name'] ?? "Unknown", // Directly use the string from the backend
      allowed: json['allowed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name, // No need to split enum name, as it is now a string
        'allowed': allowed,
      };
}

class MedicationDetails {
  String subType;
  List<MedicationSpecifics>? specifics;

  MedicationDetails({required this.subType, this.specifics});

  factory MedicationDetails.fromJson(Map<String, dynamic> json) {
    return MedicationDetails(
      subType: json['subType'] ?? "",
      specifics: (json['specifics'] as List?)
          ?.map((i) => MedicationSpecifics.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'subType': subType,
        'specifics': specifics?.map((i) => i.toJson()).toList(),
      };
}

class Medication {
  String type;
  List<MedicationDetails>? detailsList;

  Medication({required this.type, this.detailsList});

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      type: json['type'] ?? "",
      detailsList: (json['details'] as List?)
          ?.map((i) => MedicationDetails.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'details': detailsList?.map((i) => i.toJson()).toList(),
      };
}

// ScenarioSpecs class for t// ScenarioSpecs class for treatments and medication
class ScenarioSpecs {
  List<TreatmentsByType>? treatments;
  List<Medication>? medication;

  ScenarioSpecs({this.treatments, this.medication});

  factory ScenarioSpecs.fromJson(Map<String, dynamic> json) {
    return ScenarioSpecs(
      treatments: (json['treatments'] as List?)
          ?.map((i) => TreatmentsByType.fromJson(i))
          .toList(),
      medication: (json['medication'] as List?)
          ?.map((i) => Medication.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'treatments': treatments?.map((i) => i.toJson()).toList(),
        'medication': medication?.map((i) => i.toJson()).toList(),
      };
}

// Scenario class for representing a single scenario
class Scenario {
  int id;
  String scenarioName;
  ScenarioSpecs? specs;

  Scenario({required this.id, required this.scenarioName, this.specs});

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'] ?? -1,
      scenarioName: json['scenarioName'] ?? "<empty>",
      specs:
          json['specs'] != null ? ScenarioSpecs.fromJson(json['specs']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'scenarioName': scenarioName,
        'specs': specs?.toJson(),
      };
}

// ScenarioList class for holding a list of scenarios
class ScenarioList {
  List<Scenario>? scenarios;

  ScenarioList({this.scenarios});

  factory ScenarioList.fromJson(List<Map<String, dynamic>> json) {
    return ScenarioList(
      scenarios: json.map((i) => Scenario.fromJson(i)).toList(),
    );
  }

  List<Map<String, dynamic>>? toJson() =>
      scenarios?.map((i) => i.toJson()).toList();
}

// ScenarioHolder manages scenarios and updates listeners
class ScenarioHolder {
  static final Map<String, ScenarioHolder> _scenarioHolderMap = {};

  /// Get the instance of `ScenarioHolder` for a given `patientId`.
  static ScenarioHolder instanceFor({
    required String patientId,
    Function? onChangeActiveScenario,
    bool refresh = false,
  }) {
    // Remove the instance only if refresh is explicitly set to true
    if (refresh) {
      _scenarioHolderMap.remove(patientId);
    }

    if (!_scenarioHolderMap.containsKey(patientId)) {
      _scenarioHolderMap[patientId] = ScenarioHolder._(patientId);
    }

    ScenarioHolder holder = _scenarioHolderMap[patientId]!;

    if (onChangeActiveScenario != null &&
        !holder._onChangeActiveScenarioFunctions
            .contains(onChangeActiveScenario)) {
      holder._onChangeActiveScenarioFunctions.add(onChangeActiveScenario);
    }

    if (refresh) {
      holder._initialized = false;
      // holder._initialize();
    }

    return holder;
  }

  bool _initialized = false;
  bool _initializing = false;
  int _activeScenario = -1;
  ScenarioList? scenarioList;
  final List<Function> _onChangeActiveScenarioFunctions = [];
  final String patientId;

  /// ValueNotifier to notify listeners when the active scenario changes.
  final ValueNotifier<int> activeScenarioNotifier = ValueNotifier<int>(-1);

  ScenarioHolder._(this.patientId);

  /// Getter for the active scenario ID.
  int get activeScenario => _activeScenario;

  /// Public method to initialize or refresh the `ScenarioHolder`.
  Future<void> initialize() async {
    _initialized =
        true; // don't call initialization anymore, scenarios are deprecated.
    if (_initialized) return; // Avoid re-initializing if already initialized
    await _initialize();
  }

  /// Internal method to initialize the `ScenarioHolder`.
  Future<void> _initialize() async {
    if (_initializing || _initialized) return;
    _initializing = true;

    try {
      // _logger.log(1, "Initializing ScenarioHolder for patient: $patientId");

      Scenario? activeScenario =
          await TreatmentScenarioServices.fetchActiveScenario(
        patientId: patientId,
      );

      _activeScenario = activeScenario?.id ?? -1;
      // _logger.log(1, "Fetched active scenario ID: $_activeScenario");
      activeScenarioNotifier.value = _activeScenario;

      await _fetchAvailableScenarios();
    } catch (e) {
      _logger.log(1, "Error during ScenarioHolder initialization: $e");
    } finally {
      _initialized = true;
      _initializing = false;
      _notifyListeners();
    }
  }

  /// Fetch available scenarios for the patient.
  Future<void> _fetchAvailableScenarios() async {
    // _logger.log(1, "Fetching all available scenarios for patient: $patientId");

    try {
      scenarioList = await TreatmentScenarioServices.fetchTreatmentScenarios();
      // _logger.log(
      //   1,
      //   "Fetched scenarios: ${scenarioList?.scenarios?.map((s) => s.id).toList()}",
      // );
    } catch (e) {
      _logger.log(1, "Error fetching available scenarios: $e");
    } finally {
      _notifyListeners();
    }
  }

  /// Notify all listeners when the active scenario changes.
  void _notifyListeners() {
    // _logger.log(
    //   1,
    //   "Notifying listeners for patient: $patientId with active scenario ID: $_activeScenario",
    // );

    for (var callback in List.of(_onChangeActiveScenarioFunctions)) {
      callback();
    }
  }

  /// Remove a listener callback.
  void removeOnChangeActiveScenario(Function callback) {
    _onChangeActiveScenarioFunctions.remove(callback);
    _logger.log(
      1,
      "Removed a listener. Remaining listeners: ${_onChangeActiveScenarioFunctions.length}",
    );
  }

  /// Get the current active scenario.
  Scenario? currentScenario() {
    if (!_initialized) {
      _logger.log(1, "ScenarioHolder not initialized for patient: $patientId");
      return null;
    }

    return scenarioList?.scenarios
        ?.firstWhereOrNull((s) => s.id == _activeScenario);
  }

  // TODO: Unused
  /// Set a new active scenario by its ID.
  Future<void> setActiveScenario(int caseNum) async {
    _logger.log(
      1,
      "Setting active patient case to ID: $caseNum for patient: $patientId",
    );

    bool success = await TreatmentScenarioServices.postActiveScenario(
      caseNum,
      patientId: patientId,
    );

    if (success) {
      _activeScenario = caseNum;
      activeScenarioNotifier.value = _activeScenario; // Notify listeners

      await _fetchAvailableScenarios();
      _notifyListeners();
    } else {
      _logger.log(1, "Failed to set active scenario.");
    }
  }

  // TODO: Unused
  /// Clear the active scenario by setting it to -1.
  Future<void> clearActiveScenario() async {
    // _logger.log(1, "Clearing active scenario for patient: $patientId");

    bool success = await TreatmentScenarioServices.postActiveScenario(
      -1,
      patientId: patientId,
    );

    if (success) {
      _activeScenario = -1;
      activeScenarioNotifier.value = _activeScenario;
      _notifyListeners();

      _logger.log(1, "Active scenario cleared successfully.");
    } else {
      _logger.log(1, "Failed to clear active scenario.");
    }
  }
}
