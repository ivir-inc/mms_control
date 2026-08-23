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

abstract class QrCodeEvent extends Equatable {
  const QrCodeEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the network interface list, current mask/IP preference, and QR
/// image in one shot. Call on screen init.
class LoadQrCodeData extends QrCodeEvent {
  const LoadQrCodeData();
}

/// User picked an interface's IP from the dropdown. Submits the full IP as
/// the mask, then refetches the QR image for it.
class SelectInterface extends QrCodeEvent {
  final String ip;

  const SelectInterface(this.ip);

  @override
  List<Object?> get props => [ip];
}

/// Toggles the "Show on startup" preference. Frontend-local only.
class SetShowOnStartup extends QrCodeEvent {
  final bool value;

  const SetShowOnStartup(this.value);

  @override
  List<Object?> get props => [value];
}
