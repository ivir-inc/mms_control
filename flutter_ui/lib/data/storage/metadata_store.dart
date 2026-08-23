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

import 'package:flutter_ui/data/storage/base_data_store.dart';
import 'package:flutter_ui/data/services/metadata_rest_service.dart';
import 'package:flutter_ui/data/model/metadata/metadata.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("MetadataStore", debugging: true);

class MetadataStore extends BaseDataStore {
  static const String _metadataDataType = "Metadata";

  // Singleton instance
  static final MetadataStore _instance = MetadataStore._private();

  factory MetadataStore() => _instance;

  MetadataStore._private();

  Metadata? _metadata;

  Metadata? get metadata => _metadata;

  /// Loads metadata from the backend service
  Future<void> loadMetadata() async {
    _logger.log(1, "Fetching metadata...");
    try {
      final fetched = await MetadataServices().fetchMetadata();
      if (fetched != null) {
        _metadata = fetched;
        notifyListeners();
        _logger.log(1, "Metadata fetched and stored.");
      } else {
        _logger.log(2, "No metadata returned from service.");
      }
    } catch (e, stack) {
      _logger.log(3, "Failed to fetch metadata: $e\n$stack");
    }
  }

  /// Support for JSON routing (if ever received via WebSocket)
  @override
  void parseAndStoreJsonByDataType(String dataType, dynamic payload) {
    if (dataType == _metadataDataType) {
      try {
        final metadata = Metadata.fromJson(payload as Map<String, dynamic>);
        _metadata = metadata as Metadata?;
        notifyListeners();
        _logger.log(1, "Metadata updated via JSON payload.");
      } catch (e, stack) {
        _logger.log(3, "Error parsing metadata JSON: $e\n$stack");
      }
    }
  }

  @override
  bool acceptsJson() => true;

  @override
  bool acceptsRawString() => false;

  @override
  void storeRawStringByDataType(String dataType, String identifier, String rawString) {
    // Intentionally empty — Metadata doesn't use raw strings.
  }

  @override
  bool acceptsBool() => false;

  @override
  bool acceptsDouble() => false;

  @override
  bool acceptsInt() => false;

  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {
    // Intentionally empty — Metadata doesn't store bools.
  }

  @override
  void storeDoubleByDataType(String dataType, String identifier, double data) {
    // Intentionally empty — Metadata doesn't store doubles.
  }

  @override
  void storeIntByDataType(String dataType, String identifier, int data) {
    // Intentionally empty — Metadata doesn't store ints.
  }
}
