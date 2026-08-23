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
import 'package:http/http.dart' as http;
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';

final _log = Logger("HandoffRest");

class HandoffRest {
  // New base path per patient transfer API
  static const String basePath = "mms/patientXfer";

  String _u(String base, String endpoint) {
    base = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    endpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return "$base/$endpoint";
  }

  // Map server transferState -> handoff phase string expected by the bloc
  String _phaseFromTransferState(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'AT_ORIGIN':
      case 'TRANSITING_FROM_ORIGIN':
        return 'START';
      case 'IN_HOLDING':
      case 'REQUEST_FOR_TRANSFER':
      case 'TRANSITING_TO_DESTINATION':
        return 'HOLDING';
      case 'AT_DESTINATION':
        return 'COMPLETE';
      default:
        return 'NONE';
    }
  }

  /// GET /mms/patientXfer/all → find the entry for [patientId] and return START|HOLDING|COMPLETE|NONE
  Future<String?> fetchCurrentPhase(String patientId) async {
    final url = _u(BaseUrlManager.baseUrl, "$basePath/all");
    http.Response resp;
    try {
      resp = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
      });
    } catch (e) {
      _log.logError(1, 'GET all failed (network): $e');
      return null; // repo will map null -> HandoffPhase.none
    }

    if (resp.statusCode != 200) {
      _log.logError(1, 'GET all failed: ${resp.statusCode} body: ${resp.body}');
      return null;
    }

    dynamic jsonBody;
    try {
      jsonBody = json.decode(resp.body);
    } catch (e) {
      _log.logError(1, 'GET all parse error: $e body: ${resp.body}');
      return null;
    }

    if (jsonBody is! List) {
      _log.logError(1, 'GET all shape unexpected (not a list).');
      return null;
    }

    Map<String, dynamic>? row;
    for (final e in jsonBody) {
      if (e is Map<String, dynamic> &&
          (e['patientId']?.toString() ?? '') == patientId) {
        row = e;
        break;
      }
    }

    if (row == null) {
      // No entry for this patient in the snapshot
      return null; // lets repo treat as NONE
    }

    final transferState = row['transferState'] as String?;
    return _phaseFromTransferState(transferState);
  }

  /// POST /mms/patientXfer/initiate/{patientId} with {"destinationId": "..."}
  Future<void> startHandoff({
    required String patientId,
    required String destinationFacilityId,
  }) async {
    final url = _u(BaseUrlManager.baseUrl, "$basePath/initiate");
    final body = json.encode({
      "patientId": patientId,
      "destinationFacilityId": destinationFacilityId
    });

    http.Response resp;
    try {
      resp = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: body,
      );
    } catch (e) {
      _log.logError(1, 'POST initiate failed (network): $e');
      throw Exception('Failed to start handoff');
    }

    if (resp.statusCode == 200 ||
        resp.statusCode == 202 ||
        resp.statusCode == 204) {
      _log.logTrace(
          1, "Start handoff accepted for $patientId → $destinationFacilityId");
      return;
    }

    _log.logError(
        1, 'POST initiate failed: ${resp.statusCode} body: ${resp.body}');
    throw Exception('Failed to start handoff');
  }
}
