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

// tccc_rest.dart
import 'dart:convert';
import 'package:flutter_ui/data/model/tccc/tccc_record.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ui/data/services/base_url_manager.dart';

class TcccRest {
  Future<TcccRecord?> fetchForPatient(String patientId) async {
    final base = BaseUrlManager.baseUrl;
    final url =
        '${base.endsWith('/') ? base.substring(0, base.length - 1) : base}/mms/forms/dd1380/$patientId';

    final res =
        await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});

    // “Not available yet” cases -> null
    if (res.statusCode == 404 || res.statusCode == 204) return null;

    if (res.statusCode == 200) {
      final body = res.body.trim();
      if (body.isEmpty || body == 'null') return null;
      final j = json.decode(body);
      if (j is Map<String, dynamic>) return TcccRecord.fromApiJson(j);
      return null;
    }

    throw Exception('GET $url failed: ${res.statusCode} ${res.body}');
  }
}
