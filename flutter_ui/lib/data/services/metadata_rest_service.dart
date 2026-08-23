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
import 'package:flutter_ui/data/model/metadata/metadata.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:http/http.dart' as http;

class MetadataServices {
  MetadataServices._private();

  static final MetadataServices _instance = MetadataServices._private();

  factory MetadataServices() => _instance;

  Future<Metadata?> fetchMetadata() async {
    String url = '${BaseUrlManager.baseUrl}/mms/patient-case/metadata';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Metadata.fromJson(json.decode(response.body));
    } else if (response.statusCode == 204) {
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get Metadata');
    }
  }
}
