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

import 'package:flutter_ui/data/model/patient_injury/patient_injury.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:http/http.dart' as http;

Logger _logger = Logger("InjuryRest");

class InjuryRest {
  static const String _injuryBaseUrl = 'mms/injury/patient';

  String _combineUrl(String baseUrl, String endpoint) {
    baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    endpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseUrl/$endpoint';
  }

  Future<List<PatientInjury>> fetchInjuriesForPatient(String patientId) async {
    final url =
        _combineUrl(BaseUrlManager.baseUrl, '$_injuryBaseUrl/$patientId');
    try {
      final res = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List<dynamic>;
        return list
            .map((e) => PatientInjury.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _logger.logError(1, 'GET $url failed: ${res.statusCode} ${res.body}');
      return [];
    } catch (e) {
      _logger.logError(1, 'GET $url error: $e');
      return [];
    }
  }
}
