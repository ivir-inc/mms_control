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
import 'package:flutter_ui/data/model/casualty_state/casualty_state.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';

Logger _logger = Logger("CasualtyStateRest");

class CasualtyStateRest {
  static const String casualtyStatesUrl = "mms/casualtyState";

  String _combineUrl(String baseUrl, String endpoint) {
    baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    endpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return "$baseUrl/$endpoint";
  }

  // --- mapping ---
  Map<String, dynamic> _toApiJson(CasualtyState cs) => {
        "facilityId": cs.facilityId,
        "patientId": cs.patientId,
        "evacuationPriority":
            cs.evacuationPriority, // e.g., ROUTINE (UPPER_SNAKE)
        "triageClassification": cs.triageClassification,
      };

  CasualtyState _fromApiJson(Map<String, dynamic> j) => CasualtyState(
        id: (j["id"] ?? "").toString(),
        patientId: (j["patientId"] ?? "").toString(),
        evacuationPriority: (j["evacuationPriority"] ?? "").toString(),
        triageClassification: (j["triageClassification"] ?? "").toString(),
        facilityId: (j["facilityId"] ?? "").toString(),
      );

  List<CasualtyState> _listFromApiJson(String body) {
    final list = json.decode(body) as List<dynamic>;
    return list.map((e) => _fromApiJson(e as Map<String, dynamic>)).toList();
  }

  // GET /mms/casualtyState/all
  Future<List<CasualtyState>> fetchCasualtyStates() async {
    final url = _combineUrl(BaseUrlManager.baseUrl, '$casualtyStatesUrl/all');
    try {
      final res = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      if (res.statusCode == 200) return _listFromApiJson(res.body);
      _logger.logError(1, "GET $url failed: ${res.statusCode} ${res.body}");
      return [];
    } catch (e) {
      _logger.logError(1, "GET $url error: $e");
      return [];
    }
  }

  // POST /mms/casualtyState
  Future<CasualtyState> postNewCasualtyState(CasualtyState cs) async {
    final url = _combineUrl(BaseUrlManager.baseUrl, casualtyStatesUrl);
    final body = jsonEncode(_toApiJson(cs));
    _logger.logTrace(1, "POST $url $body");
    final res = await http.post(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=UTF-8"
        },
        body: body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return _fromApiJson(json.decode(res.body) as Map<String, dynamic>);
    }
    _logger.logError(1, "POST $url failed: ${res.statusCode} ${res.body}");
    throw Exception("Failed to create CasualtyState");
  }

  // PUT /mms/casualtyState
  Future<CasualtyState> putUpdateCasualtyState(CasualtyState cs) async {
    final url = _combineUrl(BaseUrlManager.baseUrl, casualtyStatesUrl);
    final body = jsonEncode(_toApiJson(cs));
    _logger.logTrace(1, "PUT $url $body");
    final res = await http.put(Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=UTF-8"
        },
        body: body);

    if (res.statusCode == 200 || res.statusCode == 204) {
      if (res.body.isNotEmpty) {
        return _fromApiJson(json.decode(res.body) as Map<String, dynamic>);
      }
      return cs; // tolerate 204 with no body
    }
    _logger.logError(1, "PUT $url failed: ${res.statusCode} ${res.body}");
    throw Exception("Failed to update CasualtyState");
  }

  Future<void> deleteCasualtyState(String patientId) async {
    final url =
        _combineUrl(BaseUrlManager.baseUrl, '$casualtyStatesUrl/$patientId');
    final res = await http
        .delete(Uri.parse(url), headers: {"Accept": "application/json"});
    if (res.statusCode != 200) {
      _logger.logError(1, "DELETE $url failed: ${res.statusCode} ${res.body}");
      throw Exception("Failed to delete CasualtyState");
    }
  }

  Future<CasualtyState> createCasualtyState(CasualtyState cs) =>
      postNewCasualtyState(cs);
}
