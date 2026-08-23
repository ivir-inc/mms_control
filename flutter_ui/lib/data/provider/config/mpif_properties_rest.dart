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

import 'package:flutter_ui/data/model/config/mpif_properties.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("MpifPropertiesRest");

class MpifPropertiesRest {
  static const String facilityUrl = "mms/facility";

  Future<MpifProperties> fetchPatientsInfo() async {
    String getFullUrl = "${BaseUrlManager.baseUrl}/$facilityUrl";
    try {
      final response = await http.get(Uri.parse(getFullUrl));
      if (response.statusCode == 200) {
        dynamic jsonDecoded = json.decode(response.body);
        return MpifProperties.fromJson(jsonDecoded);
      } else {
        throw Exception('Failed to get MpifProperties');
      }
    } catch (e) {
      _logger.logError(1, e.toString());
      throw Exception("Error attempting to get MpifProperties");
    }
  }
}
