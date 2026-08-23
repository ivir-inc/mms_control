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

import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_ui/data/model/qr_code/network_interface_info.dart';

class QrCodeState extends Equatable {
  final List<NetworkInterfaceInfo> interfaces;
  final String? selectedIp;
  final Uint8List? qrImageBytes;
  final bool qrNotFound;
  final bool showOnStartup;
  final bool isLoading;
  // Set when a SelectInterface PUT fails. Distinct from qrNotFound: the
  // previous selection and its QR are still valid and are deliberately left
  // untouched, so this only drives a one-off error surface (e.g. a
  // SnackBar), never the main QR display.
  final bool updateFailed;

  const QrCodeState({
    this.interfaces = const [],
    this.selectedIp,
    this.qrImageBytes,
    this.qrNotFound = false,
    this.showOnStartup = true,
    this.isLoading = false,
    this.updateFailed = false,
  });

  QrCodeState copyWith({
    bool? showOnStartup,
    bool? isLoading,
    bool? updateFailed,
  }) {
    return QrCodeState(
      interfaces: interfaces,
      selectedIp: selectedIp,
      qrImageBytes: qrImageBytes,
      qrNotFound: qrNotFound,
      showOnStartup: showOnStartup ?? this.showOnStartup,
      isLoading: isLoading ?? this.isLoading,
      updateFailed: updateFailed ?? this.updateFailed,
    );
  }

  @override
  List<Object?> get props => [
        interfaces,
        selectedIp,
        qrImageBytes,
        qrNotFound,
        showOnStartup,
        isLoading,
        updateFailed,
      ];
}
