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

import 'package:hydrated_bloc/hydrated_bloc.dart';

const _showOnStartupKey = 'qr_code_show_on_startup';

/// Persists the "Show on startup" preference to the browser/device's local
/// storage. Frontend-local only — the backend has no concept of this
/// preference, it purely controls which tab the app selects on its own load.
class QrCodePreferencesRepository {
  final Storage storage;

  QrCodePreferencesRepository({required this.storage});

  bool loadShowOnStartup() {
    final data = storage.read(_showOnStartupKey);
    return data is bool ? data : true;
  }

  void saveShowOnStartup(bool value) {
    storage.write(_showOnStartupKey, value);
  }
}
