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
import 'package:http/http.dart' as http;
import '../models/enduvo_model.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("EnduvoService", debugging: false);

class MmsEnduvoService {
  static const String fetchSettingsUrl = "mms/enduvo/settings";
  static const String selectedSettingUrl = "mms/enduvo/settings/selected";

  Future<Settings> fetchSettings({String? patientId}) async {
    try {
      String url = "${BaseUrlManager.baseUrl}/$fetchSettingsUrl";
      if (patientId != null) {
        url = "$url?patientId=$patientId";
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Settings settings = Settings.fromJson(json.decode(response.body));
        return settings;
      }
    } catch (e) {
      _logger.log(0, e.toString());
    }
    return defaultSettings();
  }

  Future<SelectedSetting> fetchSelectedSetting({String? patientId}) async {
    try {
      String url = "${BaseUrlManager.baseUrl}/$selectedSettingUrl";
      if (patientId != null) {
        url = "$url?patientId=$patientId";
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        SelectedSetting selectedSetting =
            SelectedSetting.fromJson(json.decode(response.body));
        SelectedSettingStore()
            .putSelectedSetting(patientId ?? "", selectedSetting);
        return selectedSetting;
      }
    } catch (e) {
      throw Exception('Error fetching selected setting');
    }
    SelectedSetting errorSetting =
        const SelectedSetting(null, null, null, hasError: true);
    SelectedSettingStore().putSelectedSetting(patientId ?? "", errorSetting);
    return errorSetting;
  }

  Future<SelectedSetting> postSelectedSetting(
      String setName, int id, String label,
      {String? patientId}) async {
    try {
      String url = "${BaseUrlManager.baseUrl}/$selectedSettingUrl";
      if (patientId != null) {
        url = "$url?patientId=$patientId";
      }
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'setName': setName,
          'selection': {'id': id, 'label': label}
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        SelectedSetting selectedSetting =
            SelectedSetting.fromJson(json.decode(response.body));
        SelectedSettingStore()
            .putSelectedSetting(patientId ?? "", selectedSetting);
        return selectedSetting;
      }
    } catch (e) {
      throw Exception('Error posting selected setting.');
    }
    SelectedSetting errorSetting =
        const SelectedSetting(null, null, null, hasError: true);
    SelectedSettingStore().putSelectedSetting(patientId ?? "", errorSetting);
    return errorSetting;
  }

  Settings defaultSettings() {
    Settings settings = Settings(defaultSettingsList(), null);
    return settings;
  }

  List<Setting> defaultSettingsList() {
    List<Setting> settingsList = [];
    Setting shinglesSetting = Setting("Shingles", getDefaultShinglesOptions());
    settingsList.add(shinglesSetting);
    Setting scrubTyphusSetting =
        Setting("Scrub Typhus", getDefaultScrubTyphusOptions());
    settingsList.add(scrubTyphusSetting);
    return settingsList;
  }

  List<SettingOption> getDefaultShinglesOptions() {
    List<SettingOption> settingOptions = [];
    settingOptions.add(const SettingOption(1, "Unavailable"));
    // settingOptions.add(SettingOption(2, "Hour 24"));
    // settingOptions.add(SettingOption(3, "Hour 48"));
    return settingOptions;
  }

  List<SettingOption> getDefaultScrubTyphusOptions() {
    List<SettingOption> settingOptions = [];
    settingOptions.add(const SettingOption(2, "Unavailable"));
    // settingOptions.add(SettingOption(5, "Hour 24"));
    // settingOptions.add(SettingOption(6, "Hour 48"));
    return settingOptions;
  }
}
