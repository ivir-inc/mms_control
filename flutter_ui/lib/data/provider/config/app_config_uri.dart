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

import 'package:flutter_ui/config.dart';

import 'package:flutter_ui/data/model/config/app_config.dart';

class AppConfigUri {
  AppConfig createFromUri() {
    AppConfig appConfig = AppConfig();
    Uri base = Uri.base;

    appConfig.includeSpeedControl =
        getBooleanFrom(base.queryParameters, Config.speedControlParm) ??
            appConfig.includeSpeedControl;
    appConfig.includeEnduvo =
        getBooleanFrom(base.queryParameters, Config.enduvoParm) ??
            appConfig.includeEnduvo;
    appConfig.includePumpControl =
        getBooleanFrom(base.queryParameters, Config.pumpControlParm) ??
            appConfig.includePumpControl;
    appConfig.includeHummodInit =
        getBooleanFrom(base.queryParameters, Config.hummodInitParm) ??
            appConfig.includeHummodInit;
    appConfig.includeScope =
        getBooleanFrom(base.queryParameters, Config.scopeParm) ??
            appConfig.includeScope;
    appConfig.includeRecentEvents =
        getBooleanFrom(base.queryParameters, Config.recentEventsParm) ??
            appConfig.includeRecentEvents;
    appConfig.includeOnesaf =
        getBooleanFrom(base.queryParameters, Config.onesafParm) ??
            appConfig.includeOnesaf;
    appConfig.includeAar =
        getBooleanFrom(base.queryParameters, Config.aarParm) ??
            appConfig.includeAar;
    appConfig.includeWsTestTab =
        getBooleanFrom(base.queryParameters, Config.wsTestTabParm) ??
            appConfig.includeWsTestTab;
    appConfig.allowHandoffInit =
        getBooleanFrom(base.queryParameters, Config.handoffInitParm) ??
            appConfig.allowHandoffInit;
    appConfig.allowHandoffReceive =
        getBooleanFrom(base.queryParameters, Config.handoffReceiveParm) ??
            appConfig.allowHandoffReceive;
    appConfig.allowLabs =
        getBooleanFrom(base.queryParameters, Config.labsParm) ??
            appConfig.allowLabs;
    appConfig.includePatientDashboard =
        getBooleanFrom(base.queryParameters, Config.patientDashboardParm) ??
            appConfig.includePatientDashboard;

    return appConfig;
  }

  bool? getBooleanFrom(Map<String, String> queryParameters, String key) {
    String? value = queryParameters[key];
    if (value == null) {
      return null;
    }
    return value.toLowerCase() != Config.off;
  }
}
