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

import 'package:flutter/foundation.dart';

class LastTreatmentStore extends ChangeNotifier {
  final Map<String, String> _lastTreatmentNamesMap = {};

  LastTreatmentStore._private();

  static final LastTreatmentStore _instance = LastTreatmentStore._private();

  factory LastTreatmentStore() => _instance;

  void putLastTreatment(String patientId, String lastTreatmentName) {
    String? patientLastTreatment = _lastTreatmentNamesMap[patientId];
    if (patientLastTreatment != lastTreatmentName) {
      _lastTreatmentNamesMap[patientId] = lastTreatmentName;
      notifyListeners();
    }
  }

  String? getLastTreatment(String patientId) =>
      _lastTreatmentNamesMap[patientId];
}

class LastTreatmentStoreAccess extends ChangeNotifier {
  final LastTreatmentStore store = LastTreatmentStore();

  LastTreatmentStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }

  putLastTreatment(String patientId, String lastTreatmentName) =>
      store.putLastTreatment(patientId, lastTreatmentName);

  String? getLastTreatment(String patientId) =>
      store.getLastTreatment(patientId);
}
