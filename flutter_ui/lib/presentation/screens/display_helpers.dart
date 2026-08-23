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

class EnumMapper {
  final Map<String, String> _uiToBackend;
  late final Map<String, String> _backendToUi;

  EnumMapper(Map<String, String> uiToBackend)
      : _uiToBackend = Map.unmodifiable(uiToBackend) {
    _backendToUi = Map.unmodifiable({
      for (var entry in uiToBackend.entries) entry.value: entry.key,
    });
  }

  String toBackend(String uiValue) => _uiToBackend[uiValue] ?? uiValue;
  String toUi(String backendValue) =>
      _backendToUi[backendValue] ?? backendValue;

  List<String> get uiValues => _uiToBackend.keys.toList();
  List<String> get backendValues => _backendToUi.keys.toList();
}

final evacuationPriorityMapper = EnumMapper({
  'Urgent': 'URGENT',
  'Priority': 'PRIORITY',
  'Routine': 'ROUTINE',
  'Convenience': 'CONVENIENCE',
  'Urgent Surgical': 'URGENT_SURGICAL',
  'Not Applicable': 'NOT_APPLICABLE',
});

final triageClassificationMapper = EnumMapper({
  'Immediate': 'IMMEDIATE',
  'Delayed': 'DELAYED',
  'Minimal': 'MINIMAL',
  'Expectant': 'EXPECTANT',
});
