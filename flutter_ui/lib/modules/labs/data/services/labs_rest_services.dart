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

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/data/services/recurring_services.dart';
import 'package:http/http.dart' as http;
import '../models/labs_model.dart';

//-----------------------------------------------------------------------------
//                  ExecutionLab Services
//-----------------------------------------------------------------------------

class MmsLabsExecutionService {
  MmsLabsExecutionService._private();

  static final _instance = MmsLabsExecutionService._private();

  factory MmsLabsExecutionService() => _instance;

  ExecutionList convertToExecutionListAndStore(
      String? patientId, String encodedJsonBody) {
    ExecutionList executionList =
        ExecutionList.fromJson(json.decode(encodedJsonBody));

    LabCardData hcgLabCardData = LabCardData.empty;
    if (executionList.hcgLab != null) {
      hcgLabCardData = _executionLabToLabData(
          executionList.hcgLab, hcgCardColor, LabCardType.hcg);
    }

    LabCardData eldonLabCardData = LabCardData.empty;
    if (executionList.eldonLab != null) {
      eldonLabCardData = _executionLabToLabData(
          executionList.eldonLab, eldonCardColor, LabCardType.eldon);
    }

    List<LabCardData> bloodLabCardArray = [];
    if (executionList.bloodLabs != null) {
      for (ExecutionLab exLab in executionList.bloodLabs ?? []) {
        bloodLabCardArray.add(
            _executionLabToLabData(exLab, bloodCardColor, LabCardType.blood));
      }
    }

    List<LabCardData> urinalysisLabCardArray = [];
    if (executionList.urineLabs != null) {
      for (ExecutionLab exLab in executionList.urineLabs ?? []) {
        urinalysisLabCardArray.add(_executionLabToLabData(
            exLab, urinalysisCardColor, LabCardType.urinalysis));
      }
    }
    LabCardDataSet labCardDataSet = LabCardDataSet(hcgLabCardData,
        eldonLabCardData, bloodLabCardArray, urinalysisLabCardArray);
    LabCardDataSetStore().putLabCardDataSet(patientId, labCardDataSet);

    return executionList;
  }

  final Map<String, Timer> timers = {};
  final Map<String, int> timerRequests = {};
  final Map<String, Stopwatch> stopwatches = {};

  void requireRecurringLabsExecutionFetch(
    String patientId, {
    required Function() callback,
  }) {
    MmsRecurringServices().requireRecurringFetch(
      patientId,
      timerRequests,
      timers,
      fetchLabsExecution,
      callback: callback,
    );
  }

  void releaseRecurringLabsExecutionFetch(
    String patientId,
  ) {
    MmsRecurringServices().releaseRecurringFetch(
      patientId,
      timerRequests,
      timers,
    );
  }

  /// Get the labs for this execution.  If there is no scenario under execution then return null
  Future<ExecutionList>? fetchLabsExecution({
    String? patientId,
    Function()? callback,
    bool forceCall = false,
  }) async {
    bool canCheck = false;
    if ((patientId != null) && (callback != null)) {
      canCheck = MmsRecurringServices().checkStopwatch(
        patientId,
        stopwatches,
        forceCall: forceCall,
        callback: callback,
      );
    }
    if (!canCheck) {
      LabCardDataSet currLabCardDataSet =
          LabCardDataSetStore().getLabCardDataSet(patientId);
      return currLabCardDataSet.toExecutionList();
    }
    String url = '${BaseUrlManager.baseUrl}/mms/truMonitor/labs/execution';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      ExecutionList executionList =
          convertToExecutionListAndStore(patientId, response.body);
      callback?.call();
      return executionList;
    }
    callback?.call();
    return ExecutionList();
  }

  LabCardData _executionLabToLabData(
          ExecutionLab? exLab, Color typeColor, LabCardType type) =>
      LabCardData(
          id: exLab?.id ?? "",
          displayText: exLab?.displayText ?? "",
          onTablet: exLab?.onLearnerTab ?? false,
          cardColor: typeColor,
          type: type);

  Future<ExecutionList> postLabsExecution(ExecutionList exList,
      {String? patientId}) async {
    String url = '${BaseUrlManager.baseUrl}/mms/truMonitor/labs/execution';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(exList.toJson()),
    );
    if ((response.statusCode == 201) || (response.statusCode == 200)) {
      ExecutionList executionList =
          convertToExecutionListAndStore(patientId, response.body);
      return executionList;
    } else {
      throw Exception('Failed to create ExecutionList.');
    }
  }
}

//-----------------------------------------------------------------------------
//                  Scenario Services
//-----------------------------------------------------------------------------

class MmsTruMonitorScenarioService {
  MmsTruMonitorScenarioService._private();

  static final _instance = MmsTruMonitorScenarioService._private();

  factory MmsTruMonitorScenarioService() => _instance;

  Future<List<Scenario>> fetchScenarios({
    String? patientId,
  }) async {
    String url = '${BaseUrlManager.baseUrl}/mms/truMonitor/scenarios';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<Scenario> returnVal = (json.decode(response.body) as List)
          .map((i) => Scenario.fromJson(i))
          .toList();
      return returnVal;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get Scenario');
    }
  }

  Future<Scenario?> fetchExecutionScenario({String? patientId}) async {
    String url = '${BaseUrlManager.baseUrl}/mms/truMonitor/scenarios/execute';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Scenario.fromJson(json.decode(response.body));
    } else if (response.statusCode == 204) {
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get Scenario');
    }
  }

  Future<Scenario?> postExecutionScenario(String? id,
      {String? patientId}) async {
    String url =
        '${BaseUrlManager.baseUrl}/mms/truMonitor/scenarios/execute?scenarioId=$id';
    if (patientId != null) {
      url = "$url&patientId=$patientId";
    }
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: "",
    );
    if ((response.statusCode == 201) || (response.statusCode == 200)) {
      return Scenario.fromJson(json.decode(response.body));
    } else if (response.statusCode == 204) {
      return null;
    } else {
      throw Exception('Failed to create Scenario.');
    }
  }
}
