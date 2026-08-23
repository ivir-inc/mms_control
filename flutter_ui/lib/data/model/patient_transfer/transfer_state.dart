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

/// Client-side enum for server `TransferState`.
/// Includes helpers to convert to/from the server's UPPER_SNAKE_CASE strings.
enum TransferState {
  atOrigin,
  transitingFromOrigin,
  inHolding,
  requestForTransfer,
  transitingToDestination,
  atDestination,

  /// Fallback if the server ever sends a new/unknown state.
  unknown,
}

extension TransferStateWire on TransferState {
  /// Convert enum -> server string
  String get wireValue {
    switch (this) {
      case TransferState.atOrigin:
        return 'AT_ORIGIN';
      case TransferState.transitingFromOrigin:
        return 'TRANSITING_FROM_ORIGIN';
      case TransferState.inHolding:
        return 'IN_HOLDING';
      case TransferState.requestForTransfer:
        return 'REQUEST_FOR_TRANSFER';
      case TransferState.transitingToDestination:
        return 'TRANSITING_TO_DESTINATION';
      case TransferState.atDestination:
        return 'AT_DESTINATION';
      case TransferState.unknown:
        return 'UNKNOWN';
    }
  }

  /// Convert server string -> enum (null/unknown-safe)
  static TransferState fromWire(String? value) {
    switch (value) {
      case 'AT_ORIGIN':
        return TransferState.atOrigin;
      case 'TRANSITING_FROM_ORIGIN':
        return TransferState.transitingFromOrigin;
      case 'IN_HOLDING':
        return TransferState.inHolding;
      case 'REQUEST_FOR_TRANSFER':
        return TransferState.requestForTransfer;
      case 'TRANSITING_TO_DESTINATION':
        return TransferState.transitingToDestination;
      case 'AT_DESTINATION':
        return TransferState.atDestination;
      default:
        return TransferState.unknown;
    }
  }

  /// Handy helpers (optional)
  bool get isTerminal => this == TransferState.atDestination;
  int get sortOrder {
    switch (this) {
      case TransferState.atOrigin:
        return 0;
      case TransferState.transitingFromOrigin:
        return 1;
      case TransferState.inHolding:
        return 2;
      case TransferState.requestForTransfer:
        return 3;
      case TransferState.transitingToDestination:
        return 4;
      case TransferState.atDestination:
        return 5;
      case TransferState.unknown:
        return 999;
    }
  }
}
