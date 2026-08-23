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
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/data/services/two_state_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ui/shared/logging/logger.dart';

// Logger instantiated for consistent use
final _logger = Logger("LabsMonitorConnectionsService");

class LabsOnlyModeService extends MmsTwoStateService {
  static const String _stateKey = "labsOnlyMode";
  static const String _restUrl = 'mms/truMonitor/labsMonitorConfig';
  LabsOnlyModeService() : super(_restUrl, stateKey: _stateKey);
}

class InstructorControlService extends MmsTwoStateService {
  static const String _stateKey = "instructorControl";
  static const String _restUrl = 'mms/truMonitor/labsMonitorConfig';
  InstructorControlService() : super(_restUrl, stateKey: _stateKey);
}

class AllowVitalsChangeService extends MmsTwoStateService {
  static const String _stateKey = "vitalsListenerActive";
  static const String _restUrl = 'mms/truMonitor/hlaListenerConfig';
  AllowVitalsChangeService() : super(_restUrl, stateKey: _stateKey);
}

class AllowSoundsChangeService extends MmsTwoStateService {
  static const String _stateKey = "vitalsListenerActive";
  static const String _restUrl = 'mms/simscope/hlaListenerConfig';
  AllowSoundsChangeService() : super(_restUrl, stateKey: _stateKey);
}

class LabsAndInstructorStatuses {
  final bool labsOnly;
  final bool instructorControl;
  final bool isError;

  LabsAndInstructorStatuses(
    this.labsOnly,
    this.instructorControl, {
    this.isError = false,
  });

  factory LabsAndInstructorStatuses.fromJson(Map<String, dynamic> json) {
    return LabsAndInstructorStatuses(
      json['labsOnly'],
      json['instructorControl'],
    );
  }
}

class LabsMonitorConnectionsService {
  static const String restUrl = 'mms/truMonitor/labsMonitorConfig';

  LabsMonitorConnectionsService();

  Future<LabsAndInstructorStatuses> fetchConnectionStatuses() async {
    try {
      final response =
          await http.get(Uri.parse("${BaseUrlManager.baseUrl}/$restUrl"));
      if (response.statusCode == 200) {
        return LabsAndInstructorStatuses.fromJson(json.decode(response.body));
      }
    } catch (e) {
      _logger.log(1, "Error fetching connection statuses: $e");
    }
    return LabsAndInstructorStatuses(true, true, isError: true);
  }
}
