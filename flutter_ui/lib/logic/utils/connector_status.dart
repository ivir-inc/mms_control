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

import 'package:flutter/material.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';

class ConnectorStatus {
  final String statusLabel;
  final Color stateColor;
  const ConnectorStatus._private(this.statusLabel, this.stateColor);

  static const String connectedKey = "CONNECTED";
  static const String connectedLabel = "Connected";
  static const String disconnectedKey = "DISCONNECTED";
  static const String disconnectedLabel = "Disconnected";
  static const String errorKey = "ERROR";
  static const String errorLabel = "Error";
  static const String idleKey = "IDLE";
  static const String idleLabel = "Idle";
  static const String pendingKey = "PENDING";
  static const String pendingLabel = "Pending";
  static const String submittedKey = "SUBMITTED";
  static const String submittedLabel = "Waiting...";

  static const ConnectorStatus connected =
      ConnectorStatus._private(connectedLabel, MmsColors.green);
  static const ConnectorStatus disconnected =
      ConnectorStatus._private(disconnectedLabel, MmsColors.mdkGrey);
  static const ConnectorStatus error =
      ConnectorStatus._private(errorLabel, MmsColors.red);
  static const ConnectorStatus idle =
      ConnectorStatus._private(idleLabel, MmsColors.yellow);
  static const ConnectorStatus pending =
      ConnectorStatus._private(pendingLabel, MmsColors.orange);
  static const ConnectorStatus submitted =
      ConnectorStatus._private(submittedLabel, MmsColors.aqua);

  static const Map<String, ConnectorStatus> _connectorMap =
      <String, ConnectorStatus>{
    connectedKey: connected,
    disconnectedKey: disconnected,
    errorKey: error,
    idleKey: idle,
    pendingKey: pending,
    submittedKey: submitted,
  };

  /// Supported [statusType] String values are CONNECTED, DISCONNECTED, ERROR,
  /// IDLE, PENDING, or SUBMITTED. Case doesn't matter. If you pass some other
  /// status type (e.g., an empty string), then the returned object is as
  /// specified by [def], which may be null.
  static ConnectorStatus? ofType(String? statusType, {ConnectorStatus? def}) {
    return _connectorMap[statusType?.toUpperCase() ?? "ERROR"] ?? def;
  }

  bool get isConnected => statusLabel == connected.statusLabel;
  bool get isDisconnected => statusLabel == disconnected.statusLabel;
  bool get isError => statusLabel == error.statusLabel;
  bool get isIdle => statusLabel == idle.statusLabel;
  bool get isPending => statusLabel == pending.statusLabel;
  bool get isSubmitted => statusLabel == submitted.statusLabel;
}
