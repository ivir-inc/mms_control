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

class MmsRecurringServices {
  MmsRecurringServices._private();
  static final _instance = MmsRecurringServices._private();
  factory MmsRecurringServices() => _instance;

  static const int defaultSeconds = 30;
  static const int defaultThrottleMs = 5000;

  void incrementTimerRequests(
    String patientId,
    Map<String, int> timerRequests,
  ) {
    int patientTimerRequests = timerRequests[patientId] ?? 0;
    timerRequests[patientId] = ++patientTimerRequests;
  }

  bool decrementTimerRequests(
    String patientId,
    Map<String, int> timerRequests,
  ) {
    int patientTimerRequests = timerRequests[patientId] ?? 0;
    timerRequests[patientId] = --patientTimerRequests;
    if (patientTimerRequests == 0) {
      return true;
    } else if (patientTimerRequests < 0) {
      throw "Timer requests decremented more than incremented.";
    }
    return false;
  }

  void requireRecurringFetch(
    String patientId,
    Map<String, int> timerRequests,
    Map<String, Timer> timers,
    Function({
      String patientId,
      Function() callback,
      bool forceCall,
    }) fetch, {
    required Function() callback,
    int timerSeconds = defaultSeconds,
  }) {
    try {
      incrementTimerRequests(patientId, timerRequests);
      fetch(
        patientId: patientId,
        callback: callback,
        forceCall: true,
      );
    } catch (e) {
      throw Exception("Error in requiring recurring fetch.");
    }
    if (!timers.containsKey(patientId)) {
      timers[patientId] = Timer.periodic(Duration(seconds: timerSeconds), (_) {
        fetch(
          patientId: patientId,
        );
      });
    }
  }

  void releaseRecurringFetch(
    String patientId,
    Map<String, int> timerRequests,
    Map<String, Timer> timers,
  ) {
    if (decrementTimerRequests(
      patientId,
      timerRequests,
    )) {
      timers[patientId]?.cancel();
      timers.remove(patientId);
    }
  }

  bool checkStopwatch(
    String patientId,
    Map<String, Stopwatch> stopwatches, {
    bool forceCall = false,
    required Function() callback,
    int throttle = defaultThrottleMs,
  }) {
    bool canCheck = false;
    if (!stopwatches.containsKey(patientId)) {
      stopwatches[patientId] = Stopwatch();
    }
    if (!stopwatches[patientId]!.isRunning) {
      canCheck = true;
      stopwatches[patientId]?.start();
    }
    if (forceCall || stopwatches[patientId]!.elapsedMilliseconds > throttle) {
      canCheck = true;
      stopwatches[patientId]?.reset();
    }
    if (!canCheck) {
      callback.call();
    }
    return canCheck;
  }
}
