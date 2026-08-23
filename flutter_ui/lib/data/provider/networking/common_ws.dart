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

import 'package:flutter/foundation.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/data/model/vitals/vitals_model.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

final Logger _logger = Logger("CommonWsNs");

class MmsWsClient {
  MmsWsClient._private();
  static final MmsWsClient _instance = MmsWsClient._private();
  factory MmsWsClient() => _instance;
  static final String _sessionId =
      DateTime.now().millisecondsSinceEpoch.toString();

  bool _started = false;
  int _restartCount = 0;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Completer<void>? _connectLock;
  Completer<void>? _dropLock;

  final StreamController<Patient> _patientStreamController =
      StreamController<Patient>.broadcast();

  // expose patientStream so that new patients that
  // arrive via the wire (Websocket) can be reacted
  // to by the Bloc and the UI updated to show them.

  Stream<Patient> get patientStream => _patientStreamController.stream;

  Future<bool> begin() async {
    _logger.log(0, "[WebSocket] session=$_sessionId starting...");
    _logger.log(0, "[WebSocket] begin(): entered");

    if (_subscription != null) {
      _logger.log(
          0,
          "[WebSocket] idempotent-guard: already listening "
          "(sub=${_subscription!.hashCode})");
      return true;
    }
    if (_dropLock != null && !_dropLock!.isCompleted) {
      _logger.log(
          1, "[WebSocket] Waiting for previous drop handler to finish...");
      await _dropLock!.future;
    }

    if (_connectLock != null && !_connectLock!.isCompleted) {
      _logger.log(1,
          "[WebSocket] connectLock: another begin() in progress; waiting...");
      await _connectLock!.future;
      _logger.log(
          0,
          _subscription == null
              ? "[WebSocket] connectLock: done waiting → not listening"
              : "[WebSocket] connectLock: done waiting → listening (sub=${_subscription!.hashCode})");
      return _subscription != null;
    }

    _connectLock = Completer<void>();

    if (_started) {
      _logger.log(0, "[WebSocket] Already started. Skipping.");
      _completeOnce(_connectLock);
      return true;
    }

    _logger.log(0, "[WebSocket] Connecting...");

    try {
      await _cleanup(); // ensure no duplicate connections
      final serviceUrl = "${BaseUrlManager.wsBaseUrl()}/ws/dataservice";

      /// comment above line and uncomment below line for websocket debug purposes

      // String serviceUrl = "ws://localhost:8081";

      // To provide a mock websocket server for testing:
      //
      //  mkdir mock-ws-server && cd mock-ws-server
      //  npm init -y
      //  npm install ws
      //  create file 'server.js'
      //  add the following to it, then run 'node server.js'

      // const WebSocket = require('ws');

      // const wss = new WebSocket.Server({ port: 8081 });
      // console.log('Mock WebSocket server running on ws://localhost:8081');

      // wss.on('connection', function connection(ws) {
      //   console.log('Client connected');

      //   // Send a test patient after 2 seconds
      //   setTimeout(() => {
      //     const newPatientMessage = {
      //       "dataType": "Patient",
      //       "dataPayload": {
      //         "id": "Krishen",
      //         "physiologySource": "EXTERNAL",
      //         "sourceLocked": null,
      //         "visible": true,
      //         "patientCaseNum": null
      //       }
      //     };
      //     ws.send(JSON.stringify(newPatientMessage));
      //     console.log('Sent mock patient');
      //   }, 2000);
      // });

      _channel = WebSocketChannel.connect(Uri.parse(serviceUrl));

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (error) {
          _logger.log(2, "[WebSocket] Error: $error");
          _handleSocketDrop();
        },
        onDone: () {
          _logger.log(1, "[WebSocket] Connection closed.");
          _handleSocketDrop();
        },
        cancelOnError: true,
      );
      _logger.log(
          0, "[WebSocket] attach-listener: sub=${_subscription!.hashCode}");

      _started = true;
      _restartCount++;
      _logger.log(0, "[WebSocket] Connected successfully.");
      _completeOnce(_connectLock);
      return true;
    } catch (e) {
      _logger.log(3, "[WebSocket] Connection failed: $e");
      _completeOnce(_connectLock);
      return false;
    }
  }

  void _completeOnce(Completer<void>? c) {
    if (c != null && !c.isCompleted) c.complete();
  }

  void _onMessage(dynamic rawData) {
    final subId = _subscription?.hashCode;
    _logger.log(0,
        "[WebSocket] session=$_sessionId Data received (sub=$subId): $rawData");

    try {
      final data = json.decode(rawData);
      final dataType = data["dataType"];
      final payload = data["dataPayload"];

      if (dataType == "Vitals") {
        final vitals = VitalsValues.fromJson(payload);
        final id = payload["patientId"];
        if (id != null) {
          VitalsValuesStore().putVitalsValues(id, vitals);
        }
      } else if (dataType == 'Patient') {
        _patientStreamController.add(Patient.fromWireJson(payload));
      } else if (dataType == 'Event') {
        MmsDataRouter().routeDataByNamedType('Event', payload);
      } else if (dataType == 'PatientTransfer') {
        MmsDataRouter().routeDataByNamedType('PatientTransfer', payload);
      } else if (dataType == 'MagicTransfer') {
        MmsDataRouter().routeDataByNamedType('MagicTransfer', payload);
      } else if (dataType == 'CasualtyState') {
        MmsDataRouter().routeDataByNamedType('CasualtyState', payload);
      } else if (dataType == 'FederationControl') {
        MmsDataRouter().routeDataByNamedType('FederationControl', payload);
      } else if (dataType == 'PatientDeleted') {
        MmsDataRouter().routeDataByNamedType('PatientDeleted', payload);
      } else if (dataType == 'DD1380' || dataType == 'Tccc') {
        MmsDataRouter().routeDataByNamedType('DD1380', payload);
      } else if (dataType == 'TcccReceived') {
        MmsDataRouter().routeDataByNamedType('TcccReceived', payload);
      }
    } catch (e) {
      _logger.log(3, "[WebSocket] Parse error: $e");
    }
  }

  Future<void> _handleSocketDrop() async {
    if (_dropLock != null && !_dropLock!.isCompleted) {
      _logger.log(1, "[WebSocket] Drop already being handled.");
      return;
    }

    _dropLock = Completer();
    _logger.log(1, "[WebSocket] Handling connection drop...");

    await _cleanup();
    _delayedRestart();

    _dropLock!.complete();
  }

  Future<void> _cleanup() async {
    _logger.log(0,
        "[WebSocket] cleanup: cancel sub=${_subscription?.hashCode}, close channel=${_channel != null}");

    try {
      if (_subscription != null) {
        await _subscription!.cancel();
        _subscription = null;
      }

      if (_channel != null) {
        // On web: 1000 or no code; Off web: 1001 is fine
        if (kIsWeb) {
          await _channel!.sink.close(1000); // normal closure
        } else {
          await _channel!.sink.close(status.goingAway); // 1001
        }
        _channel = null;
      }
    } catch (e) {
      _logger.log(2, "[WebSocket] Error during cleanup: $e");
    } finally {
      _started = false;
    }
  }

  void _delayedRestart() {
    if (_started) {
      _logger.log(1, "[WebSocket] Restart skipped: Connection already active.");
      return;
    }

    final delaySeconds = (1 << _restartCount).clamp(2, 60);
    _logger.log(
        1, "[WebSocket] Attempting to restart in $delaySeconds seconds...");

    Future.delayed(Duration(seconds: delaySeconds), () async {
      bool success = await begin();
      if (success) {
        _restartCount = 0;
        _logger.log(0, "[WebSocket] Restarted successfully.");
      } else {
        _restartCount++;
        _logger.log(2, "[WebSocket] Restart attempt failed. Will retry...");
        _delayedRestart();
      }
    });
  }

  void sendMessage(String message) {
    if (_channel == null || !_started) {
      _logger.log(2, "[WebSocket] Cannot send message: Not connected.");
      return;
    }

    try {
      _logger.log(0, "[WebSocket] Sending message: $message");
      _channel!.sink.add(message);
    } catch (e) {
      _logger.log(3, "[WebSocket] Failed to send message: $e");
    }
  }

  Future<void> dispose() async {
    _logger.log(1, "[WebSocket] dispose() called (hot-reload)");

    // IMPORTANT: do NOT cancel the subscription here — we want onDone to fire.
    try {
      if (_channel != null) {
        await _channel!.sink.close(kIsWeb ? 1000 : status.goingAway);
        // leave _channel non-null; _onDone → _handleSocketDrop → _cleanup will null it
      }
    } catch (e) {
      _logger.log(2, "[WebSocket] Error during hot-reload close: $e");
    }

    // don't touch locks; _handleSocketDrop/_cleanup will reset everything
  }

  int get restartCount => _restartCount;
}
