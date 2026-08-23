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

// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:flutter_ui/data/services/base_url_manager.dart';

import 'package:http/http.dart' as http;
import '../models/medevac_model.dart';

class OneSafServices {
  OneSafServices._private();

  static final OneSafServices _instance = OneSafServices._private();

  factory OneSafServices() => _instance;

  static const String sendMedevacRequestUrl = "mms/patient/medevac";

  Future<bool> sendMedevacRequest(OnesafMedevacRequest request) async {
    String submissionUrl = "${BaseUrlManager.baseUrl}/$sendMedevacRequestUrl";
    try {
      final response = await http.post(
        Uri.parse(submissionUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
