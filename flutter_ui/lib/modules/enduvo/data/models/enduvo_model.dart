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

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class SettingOption extends Equatable {
  final int id;
  final String label;
  const SettingOption(this.id, this.label);
  factory SettingOption.fromJson(Map<String, dynamic> json) {
    return SettingOption(json["id"], json["label"]);
  }

  @override
  List<Object> get props => [id, label];
}

class Setting {
  final String setName;
  final List<SettingOption> settingOptions;
  Setting(this.setName, this.settingOptions);
  factory Setting.fromJson(Map<String, dynamic> json) {
    List<SettingOption> optionsList = [];
    List settingOptions = (json)["options"] ?? [];
    for (var element in settingOptions) {
      SettingOption s = SettingOption.fromJson(element);
      optionsList.add(s);
    }
    return Setting(json["setName"], optionsList);
  }
}

class Settings {
  final List<Setting> settings;
  final String? message;
  final bool hasError;
  Settings(this.settings, this.message, {this.hasError = false});
  factory Settings.fromJson(Map<String, dynamic> json,
      {bool hasError = false}) {
    List<Setting> settingList = [];
    List settings = (json)["settings"] ?? [];
    for (var element in settings) {
      Setting s = Setting.fromJson(element);
      settingList.add(s);
    }
    return Settings(settingList, json["message"], hasError: hasError);
  }
}

class SelectedSetting extends Equatable {
  final String? setName;
  final SettingOption? selection;
  final String? message;
  final bool hasError;
  const SelectedSetting(this.setName, this.selection, this.message,
      {this.hasError = false});

  factory SelectedSetting.fromJson(Map<String, dynamic> json,
      {bool hasError = false}) {
    SettingOption selection = SettingOption.fromJson(json["selection"]);
    return SelectedSetting(json["setName"], selection, json["message"],
        hasError: hasError);
  }

  @override
  List<Object?> get props => [
        setName,
        selection,
        message,
        hasError,
      ];
}

class SelectedSettingStore extends ChangeNotifier {
  final Map<String, SelectedSetting> _selectedSettingsMap = {};

  SelectedSettingStore._private();

  static final SelectedSettingStore _instance = SelectedSettingStore._private();

  factory SelectedSettingStore() => _instance;

  void putSelectedSetting(String patientId, SelectedSetting selectedSetting) {
    SelectedSetting? patientSelectedSetting = _selectedSettingsMap[patientId];
    if (patientSelectedSetting != selectedSetting) {
      _selectedSettingsMap[patientId] = selectedSetting;
      notifyListeners();
    }
  }

  SelectedSetting? getSelectedSetting(String patientId) =>
      _selectedSettingsMap[patientId];
}

class SelectedSettingStoreAccess extends ChangeNotifier {
  final SelectedSettingStore store = SelectedSettingStore();

  SelectedSettingStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }

  void putSelectedSetting(String patientId, SelectedSetting selectedSetting) =>
      store.putSelectedSetting(patientId, selectedSetting);

  SelectedSetting? getSelectedSetting(String patientId) =>
      store.getSelectedSetting(patientId);
}
