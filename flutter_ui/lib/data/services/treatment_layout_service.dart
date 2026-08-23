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
import 'package:flutter_ui/data/model/treatment_layout/treatment_layout_config.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/data/services/http_helper.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

final _logger = Logger('TreatmentLayoutService');
const _path = '/mms/treatment/layout';

class TreatmentLayoutService {
  static Future<TreatmentLayoutConfig?> fetchLayout() async {
    final url = '${BaseUrlManager.baseUrl}$_path';
    try {
      final response = await http.get(
        Uri.parse(MmsHttpHelper.breakCacheGetUrl(url)),
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        return TreatmentLayoutConfig.fromJson(
            json.decode(response.body) as Map<String, dynamic>);
      }
      _logger.log(1, 'fetchLayout failed: ${response.statusCode}');
    } catch (e) {
      _logger.log(1, 'fetchLayout error: $e');
    }
    return null;
  }

  static Future<bool> saveLayout(TreatmentLayoutConfig config) async {
    final url = '${BaseUrlManager.baseUrl}$_path';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(config.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.log(1, 'saveLayout error: $e');
    }
    return false;
  }

  static Future<TreatmentLayoutConfig?> resetLayout() async {
    final url = '${BaseUrlManager.baseUrl}$_path/reset';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return TreatmentLayoutConfig.fromJson(
              json.decode(response.body) as Map<String, dynamic>);
        }
        return fetchLayout();
      }
      _logger.log(1, 'resetLayout failed: ${response.statusCode}');
    } catch (e) {
      _logger.log(1, 'resetLayout error: $e');
    }
    return null;
  }
}
