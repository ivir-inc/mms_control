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

import 'dart:async';
import 'dart:convert';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/logic/utils/connector_status.dart';
import 'package:http/http.dart' as http;
import '../models/federation_connection_models.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

final _logger = Logger("FederationService");

class FederationService {
  FederationService._private();

  static final _instance = FederationService._private();

  factory FederationService() => _instance;

  static const int federationTimerSeconds = 10;
  static const int federatesTimerSeconds = 10;
  static const int federationThrottle = 5000;
  static const int federatesThrottle = 5000;

  Stopwatch federatesStopwatch = Stopwatch();
  Stopwatch federationStopwatch = Stopwatch();
  Timer? federatesTimer;
  Timer? federationTimer;
  int federatesTimerRequests = 0;
  int federationTimerRequests = 0;

  static final String fetchFederatesDataRestUrl =
      "${BaseUrlManager.baseUrl}/mms/federation";
  static final String fetchConnectorsDataRestUrl =
      "${BaseUrlManager.baseUrl}/mms/federation/connectors";
  static final String postFederationControlRestUrl =
      "${BaseUrlManager.baseUrl}/mms/federation/control";
  static final String postFederationConnectionRequestRestUrl =
      "${BaseUrlManager.baseUrl}/mms/federation/connection/request";

  void requireRecurringFederatesFetch({Function()? callback}) {
    federatesTimerRequests++;
    if (federatesTimerRequests == 1) {
      fetchFederatesData(callback: callback, forceCall: true);
      federatesTimer = Timer.periodic(
        const Duration(seconds: federatesTimerSeconds),
        (_) => fetchFederatesData(),
      );
    }
  }

  void releaseRecurringFederatesFetch() {
    federatesTimerRequests--;
    if (federatesTimerRequests <= 0) {
      federatesTimerRequests = 0;
      federatesTimer?.cancel();
      federatesTimer = null;
    }
  }

  void requireRecurringFederationFetch({Function()? callback}) {
    ++federationTimerRequests;
    fetchFederationData(callback: callback, forceCall: true);
    federationTimer ??=
        Timer.periodic(const Duration(seconds: federationTimerSeconds), (_) {
      fetchFederationData();
    });
  }

  void releaseRecurringFederationFetch() {
    --federationTimerRequests;
    if (federationTimerRequests <= 0) {
      federationTimer?.cancel();
      federationTimer = null;
    }
  }

  void fetchFederatesData(
      {Function()? callback, bool forceCall = false}) async {
    bool canCheck = false;
    if (!federatesStopwatch.isRunning) {
      canCheck = true;
      federatesStopwatch.start();
    }
    if (forceCall ||
        federatesStopwatch.elapsedMilliseconds > federatesThrottle) {
      canCheck = true;
      federatesStopwatch.reset();
    }
    if (!canCheck) {
      callback?.call();
      return;
    }
    bool isValid = false;
    try {
      final response = await http.get(Uri.parse(fetchFederatesDataRestUrl));
      if (response.statusCode == 200) {
        FederationInfoStoreAccess()
            .loadFederatesModelFromJson(json.decode(response.body));
        isValid = true;
        callback?.call();
      }
    } catch (e) {
      _logger.log(1, "Error fetching federates data: $e");
    }
    if (!isValid) {
      FederationInfoStoreAccess().federatesModelError();
      callback?.call();
    }
  }

  void fetchFederationData(
      {Function()? callback, bool forceCall = false}) async {
    bool canCheck = false;
    if (!federationStopwatch.isRunning) {
      canCheck = true;
      federationStopwatch.start();
    }
    if (forceCall ||
        federationStopwatch.elapsedMilliseconds > federationThrottle) {
      canCheck = true;
      federationStopwatch.reset();
    }
    if (!canCheck) {
      callback?.call();
      return;
    }
    bool isValid = false;
    try {
      final response = await http.get(Uri.parse(fetchConnectorsDataRestUrl));
      if (response.statusCode == 200) {
        FederationInfoStoreAccess()
            .loadFederationComboModelFromJson(json.decode(response.body));
        isValid = true;
        callback?.call();
      }
    } catch (e) {
      _logger.log(1, "Error fetching federation data: $e");
    }
    if (!isValid) {
      FederationInfoStoreAccess().federationComboModelError();
      callback?.call();
    }
  }

  Future<FederationActionModel> postFederationControlAction(String action,
      {String? patientId}) async {
    try {
      await http.post(
        Uri.parse(postFederationControlRestUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'action': action,
          if (patientId != null) 'patientId': patientId,
        }),
      );
    } catch (e) {
      _logger.log(1, "Error posting federation control action: $e");
    }
    fetchFederationData(forceCall: true);
    fetchFederatesData(forceCall: true);
    return FederationActionModel(null, null, null, isError: true);
  }

  void postFederationConnectionRequest(String action,
      {Function()? callback}) async {
    bool isValid = false;
    try {
      final response = await http.post(
        Uri.parse(postFederationConnectionRequestRestUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'requestAction': action}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);

        final model = FederationConnectionModel.fromJson(body);

        // Update the store first — this might clear federates if disconnected
        FederationInfoStoreAccess().loadFederationConnectionModelFromJson(body);

        if (model.connectorStatus == ConnectorStatus.connected) {
          fetchFederatesData(forceCall: true);
        }

        fetchFederationData(forceCall: true); // This is okay either way

        isValid = true;
        callback?.call();
      }
    } catch (e) {
      _logger.log(1, "Error posting federation connection request: $e");
    }

    if (!isValid) {
      FederationInfoStoreAccess().federationComboModelAutoDisconnect();

      // Cancel the federates polling loop explicitly
      releaseRecurringFederatesFetch();

      callback?.call();
    }
  }
}

class DeviceConnectionServices {
  final String connectionRestUrl;
  final String connectorName;
  static final _logger = Logger("DeviceConnectionServices");

  DeviceConnectionServices(this.connectionRestUrl, this.connectorName);

  void fetchDeviceConnectorData({Function()? callback}) async {
    bool isValid = false;
    try {
      final response = await http.get(Uri.parse(connectionRestUrl));
      if (response.statusCode == 200) {
        FederationInfoStoreAccess().loadConnectorConnectionModelFromJson(
            connectorName, json.decode(response.body));
        isValid = true;
        callback?.call();
      }
    } catch (e) {
      _logger.log(1, "Error fetching device connector data: $e");
    }
    if (!isValid) {
      FederationInfoStoreAccess().connectorConnectionError(connectorName);
      callback?.call();
    }
  }

  void postDeviceConnectTypeRequest(String type, {Function()? callback}) async {
    bool isValid = false;
    try {
      final response = await http.post(
        Uri.parse('$connectionRestUrl/request'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({'requestAction': type}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        FederationInfoStoreAccess().loadConnectorConnectionModelFromJson(
            connectorName, json.decode(response.body));
        isValid = true;
        callback?.call();
      }
    } catch (e) {
      _logger.log(1, "Error posting $type request: $e");
    }
    if (!isValid) {
      FederationInfoStoreAccess().connectorConnectionError(connectorName);
      callback?.call();
    }
  }

  void postDeviceConnectRequest({Function()? callback}) async {
    postDeviceConnectTypeRequest("connect", callback: callback);
  }

  void postDeviceDisconnectRequest({Function()? callback}) async {
    postDeviceConnectTypeRequest("disconnect", callback: callback);
  }
}

class TruMonitorConnectionService extends DeviceConnectionServices {
  static final String myConnectionRestUrl =
      "${BaseUrlManager.baseUrl}/mms/truMonitor/connection";
  TruMonitorConnectionService()
      : super(myConnectionRestUrl, FederationComboModel.truMonitorName);
}

class EnduvoConnectionService extends DeviceConnectionServices {
  static final String myConnectionRestUrl =
      "${BaseUrlManager.baseUrl}/mms/enduvo/connection";
  EnduvoConnectionService()
      : super(myConnectionRestUrl, FederationComboModel.enduvoName);
}

class SimScopeConnectionService extends DeviceConnectionServices {
  static final String myConnectionRestUrl =
      "${BaseUrlManager.baseUrl}/mms/simscope/connection";
  SimScopeConnectionService()
      : super(myConnectionRestUrl, FederationComboModel.simScopeName);
}

class PumpControlConnectionService extends DeviceConnectionServices {
  static final String myConnectionRestUrl =
      "${BaseUrlManager.baseUrl}/mms/pumpcontrol/connection";
  PumpControlConnectionService()
      : super(myConnectionRestUrl, FederationComboModel.pumpControlName);
}
