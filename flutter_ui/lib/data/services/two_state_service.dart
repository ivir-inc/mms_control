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
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:http/http.dart' as http;

class MmsTwoStateServiceData {
  final bool state;
  final bool error;
  static const String defKey = 'state';

  MmsTwoStateServiceData({required this.state, required this.error});

  factory MmsTwoStateServiceData.fromJson(Map<String, dynamic> json,
      {String key = defKey}) {
    return MmsTwoStateServiceData(
      state: json[key],
      error: false,
    );
  }
}

class MmsTwoStateService {
  final String restUrl;
  final String stateKey;
  MmsTwoStateService(this.restUrl,
      {this.stateKey = MmsTwoStateServiceData.defKey});

  Future<MmsTwoStateServiceData> fetchState({bool currentState = false}) async {
    try {
      var url = Uri.parse("${BaseUrlManager.baseUrl}/$restUrl");
      final response =
          await http.get(url, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        // If the server returned a 200 OK response,
        // then parse the JSON.
        return MmsTwoStateServiceData.fromJson(json.decode(response.body),
            key: stateKey);
      }
    } catch (e) {
      throw Exception("Error fetching state for two state service.");
    }
    return MmsTwoStateServiceData(
      state: false,
      error: true,
    );
  }

  Future<MmsTwoStateServiceData> postState(bool state) async {
    try {
      var url = Uri.parse("${BaseUrlManager.baseUrl}/$restUrl");
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          stateKey: state,
        }),
      );
      if ((response.statusCode == 201) || (response.statusCode == 200)) {
        return MmsTwoStateServiceData.fromJson(json.decode(response.body),
            key: stateKey);
      }
    } catch (e) {
      throw Exception("Error posting state for two state service.");
    }
    return MmsTwoStateServiceData(
      state: false,
      error: true,
    );
  }
}
