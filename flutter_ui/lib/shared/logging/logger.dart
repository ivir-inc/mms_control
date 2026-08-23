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

class Logger {
  static const int error = 1;
  static const int warning = 2;
  static const int info = 3;
  static const int debug = 4;
  static const int trace = 5;

  bool debugging;
  final String tag;
  int _counter = 0;
  final int levelLimit;

  Logger(
    this.tag, {
    this.debugging = true,
    this.levelLimit = error,
  });

  void resetCounter() => _counter = 0;

  void log(
    int flag,
    String message, {
    int? counter,
    int logLevel = 3,
  }) {
    if (counter != null) {
      _counter = counter;
    } else {
      _counter++;
    }
    if (debugging || (logLevel <= levelLimit)) {
      if (kDebugMode) {
        print("$tag[$flag:$_counter] - $message");
      }
    }
  }

  void logError(int flag, String message) {
    log(flag, message, logLevel: error);
  }

  void logWarning(int flag, String message) {
    log(flag, message, logLevel: warning);
  }

  void logDebug(int flag, String message) {
    log(flag, message, logLevel: debug);
  }

  void logTrace(int flag, String message) {
    log(flag, message, logLevel: trace);
  }
}
