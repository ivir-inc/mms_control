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
import 'package:http/http.dart' as http;
import '../models/sim_model.dart';

class MmsSimService {
  static const String baseSimStatusRestUrl = "mms/sceneng";
  static const String baseSimControlRestUrl = "mms/sceneng/control";
  static const String baseClockControlRestUrl = "mms/clock/control";

  MmsSimService._private();

  static final MmsSimService _instance = MmsSimService._private();

  factory MmsSimService() => _instance;

  Future<bool> fetchSimScenEngStatus({
    String? patientId,
  }) async {
    String url = "${BaseUrlManager.baseUrl}/$baseSimStatusRestUrl";
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        dynamic jsonDecoded = json.decode(response.body);
        SimScenEngModelStore().loadFromJson(
          jsonDecoded as Map<String, Object>,
          simId: patientId,
        );
        return true;
      }
    } catch (e) {
      SimScenEngModelStore().putSimScenEngModel(
        SimScenEngModel.defModel,
        simId: patientId ?? "",
      );
    }
    return false;
  }

  Future<bool> postSimScenEngControl(
    String action, {
    String? patientId,
  }) async {
    String url = '${BaseUrlManager.baseUrl}/$baseSimControlRestUrl';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "controlCmd": action,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonDecoded = json.decode(response.body);
        SimScenEngModelStore().loadFromJson(
          jsonDecoded as Map<String, Object>,
          simId: patientId,
        );
        return true;
      }
    } catch (e) {
      throw Exception('Error posting sim scenario engine control');
    }
    return false;
  }

  Future<bool> postClockCommand(
    String controlCmd, {
    int? parameter,
    String? patientId,
  }) async {
    String url = '${BaseUrlManager.baseUrl}/$baseClockControlRestUrl';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "controlCmd": controlCmd,
          if (parameter != null) "parameter": parameter,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      throw Exception('Error posting clock command.');
    }
    return false;
  }

  Future<bool> postClockStart({
    String? patientId,
  }) async {
    return await postClockCommand(
      "start",
      patientId: patientId,
    );
  }

  Future<bool> postClockRate(
    int rate, {
    String? patientId,
  }) async {
    return await postClockCommand(
      "rate",
      parameter: rate,
      patientId: patientId,
    );
  }
}
