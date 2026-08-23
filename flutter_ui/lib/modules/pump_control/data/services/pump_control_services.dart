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

import 'dart:convert';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/modules/pump_control/data/models/pump_control_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ui/shared/logging/logger.dart';

// Logger instantiated for consistent use across the file
final _logger = Logger("PumpControlService");

// ========================== Scenarios =========================

class MmsPumpControlScenarioService {
  static const String fetchScenariosServiceUrl = "mms/pumpcontrol/scenarios";
  static const String selectedScenarioUrl =
      "mms/pumpcontrol/scenarios/selected";
  static const String setPumpControlRateUrl = "mms/pumpcontrol/scenarios/rate";

  Future<PumpControlScenarios> fetchScenarios({String? patientId}) async {
    String url = "${BaseUrlManager.baseUrl}/$fetchScenariosServiceUrl";
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return PumpControlScenarios.fromJson(json.decode(response.body));
      }
    } catch (e) {
      _logger.log(1, "Error fetching scenarios: $e");
    }
    return PumpControlScenarios([], hasError: true);
  }

  Future<SelectedScenario> fetchSelectedScenario({String? patientId}) async {
    String url = "${BaseUrlManager.baseUrl}/$selectedScenarioUrl";
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return SelectedScenario.fromJson(json.decode(response.body));
      }
    } catch (e) {
      _logger.log(1, "Error fetching selected scenario: $e");
    }
    return SelectedScenario(null, null, null, null, null, hasError: true);
  }

  Future<SelectedScenario> postSelectedScenario(int? id, String? name,
      {String? patientId}) async {
    String url = "${BaseUrlManager.baseUrl}/$selectedScenarioUrl";
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'id': id, 'name': name}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SelectedScenario.fromJson(json.decode(response.body));
      }
    } catch (e) {
      _logger.log(1, "Error posting selected scenario: $e");
    }
    return SelectedScenario(null, null, null, null, null, hasError: true);
  }

  Future<SelectedScenario> postSelectedRate(
      int id, String name, String rateName, int rateValue,
      {String? patientId}) async {
    String url = "${BaseUrlManager.baseUrl}/$setPumpControlRateUrl";
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'id': id,
          'name': name,
          'rateName': rateName,
          'rateValue': rateValue,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SelectedScenario.fromJson(json.decode(response.body));
      }
    } catch (e) {
      _logger.log(1, "Error posting selected rate: $e");
    }
    return SelectedScenario(null, null, null, null, null, hasError: true);
  }
}

// ========================= Runtime Status ======================

class MmsRuntimeStatusService {
  static const String fetchRuntimeStatusesUrl =
      "mms/pumpcontrol/runtime/status";
  static const String restrictDispenseUrl =
      "mms/pumpcontrol/runtime/restrictDispense";
  static const String controlUrl = "mms/pumpcontrol/runtime/control";

  Future<RuntimeStatus> fetchRuntimeStatuses({String? patientId}) async {
    String url = "${BaseUrlManager.baseUrl}/$fetchRuntimeStatusesUrl";
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        RuntimeStatus scenario =
            RuntimeStatus.fromJson(json.decode(response.body));
        RuntimeStatusStore().putRuntimeStatus(patientId, scenario);
        return scenario;
      }
    } catch (e) {
      _logger.log(1, "Error fetching runtime statuses: $e");
    }
    RuntimeStatus errStatus =
        const RuntimeStatus(null, null, null, null, null, null, hasError: true);
    RuntimeStatusStore().putRuntimeStatus(patientId, errStatus);
    return errStatus;
  }

  Future<RuntimeStatus> postDispenseRestriction(bool restrict,
      {String? patientId}) async {
    String url = "${BaseUrlManager.baseUrl}/$restrictDispenseUrl";
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'restrict': restrict}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        RuntimeStatus scenario =
            RuntimeStatus.fromJson(json.decode(response.body));
        RuntimeStatusStore().putRuntimeStatus(patientId, scenario);
        return scenario;
      }
    } catch (e) {
      _logger.log(1, "Error posting dispense restriction: $e");
    }
    RuntimeStatus errStatus =
        const RuntimeStatus(null, null, null, null, null, null, hasError: true);
    RuntimeStatusStore().putRuntimeStatus(patientId, errStatus);
    return errStatus;
  }

  Future<RuntimeStatus> postControlStop(String action,
      {String? patientId}) async {
    String url = "${BaseUrlManager.baseUrl}/$controlUrl";
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'controlAction': action}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        RuntimeStatus scenario =
            RuntimeStatus.fromJson(json.decode(response.body));
        RuntimeStatusStore().putRuntimeStatus(patientId, scenario);
        return scenario;
      }
    } catch (e) {
      _logger.log(1, "Error posting control stop: $e");
    }
    RuntimeStatus errStatus =
        const RuntimeStatus(null, null, null, null, null, null, hasError: true);
    RuntimeStatusStore().putRuntimeStatus(patientId, errStatus);
    return errStatus;
  }
}
