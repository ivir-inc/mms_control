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

// handoff_phase.dart
enum HandoffPhase { none, start, holding, complete }

extension HandoffPhaseX on HandoffPhase {
  String get asBackend => switch (this) {
        HandoffPhase.none => 'NONE',
        HandoffPhase.start => 'START',
        HandoffPhase.holding => 'HOLDING',
        HandoffPhase.complete => 'COMPLETE'
      };

  static HandoffPhase fromBackend(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'START':
        return HandoffPhase.start;
      case 'HOLDING':
        return HandoffPhase.holding;
      case 'COMPLETE':
        return HandoffPhase.complete;
      default:
        return HandoffPhase.none;
    }
  }
}
