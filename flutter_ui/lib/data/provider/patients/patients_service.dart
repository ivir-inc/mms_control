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

import 'package:flutter_ui/data/services/base_url_manager.dart';

import 'package:flutter_ui/data/model/patients/patients_model.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("MmsPatientsService");

class MmsPatientsService {
  static const String basePatientsInfoRestUrl = "mms/patients";

  MmsPatientsService._private();

  static final MmsPatientsService _instance = MmsPatientsService._private();

  factory MmsPatientsService() => _instance;

  Future<void> fetchPatientsInfo({Function()? callback}) async {
    String fetchPatientsInfoRestUrl =
        "${BaseUrlManager.baseUrl}/$basePatientsInfoRestUrl";
    try {
      final response = await http.get(Uri.parse(fetchPatientsInfoRestUrl));
      if (response.statusCode == 200) {
        dynamic jsonDecoded = json.decode(response.body);
        if ((response.body).trimLeft().startsWith("[")) {
          // If response is a JSON array.
          List<Map<String, dynamic>> converted =
              List<Map<String, dynamic>>.from(jsonDecoded);
          PatientInfoStore().loadFromJson(converted, isMain: true);
        } else if ((response.body).trimLeft().startsWith("{")) {
          // If response is a JSON object.
          Map<String, dynamic> convertedMap =
              jsonDecoded as Map<String, dynamic>;

          // Check for multipatient display setting.
          PatientInfoStore().isMultipatientDisplayEnabled =
              convertedMap["multipatientDisplayEnabled"] ?? false;

          dynamic dynamicList = convertedMap["patientSummary"];
          List<Map<String, dynamic>> converted =
              List<Map<String, dynamic>>.from(dynamicList);
          PatientInfoStore().loadFromJson(
            converted,
            isMain: !PatientInfoStore().isMultipatientDisplayEnabled,
          );
        }
      }
    } catch (e) {
      _logger.logError(1, e.toString());
      // Optional: Uncomment if you have a fallback mechanism
      // MmsFakePatientsService().fetchIdsForPatients();
    }
    callback?.call();
  }
}
