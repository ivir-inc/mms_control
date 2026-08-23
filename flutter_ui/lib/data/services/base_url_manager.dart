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

import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb

class BaseUrlManager {
  static const String defaultBaseUrl = "https://localhost:6544";
  static const String envBaseUrl =
      String.fromEnvironment("baseUrl", defaultValue: defaultBaseUrl);

  static String get baseUrl {
    if (kIsWeb) {
      if(kDebugMode){
        return "https://localhost:6544";
      }
      // Web environment
      return Uri.base.origin.toString();
    } else if (Platform.isAndroid) {
      // Android Emulator needs to connect via 10.0.2.2 to refer to localhost
      return "http://10.0.2.2:6544";
    } else if (Platform.isIOS) {
      // iOS Simulator can use localhost
      return "http://localhost:6544";
    } else {
      // Fallback to default
      return envBaseUrl;
    }
  }

  static String? _wsBaseUrl;

  static String wsBaseUrl() {
    if (_wsBaseUrl != null) {
      return _wsBaseUrl!;
    }
    String wsBaseUrl = baseUrl;
    if (baseUrl.startsWith("https:")) {
      wsBaseUrl = "wss${baseUrl.substring(5)}";
    } else {
      wsBaseUrl = "ws://localhost:6544"; // Default WebSocket URL
    }
    _wsBaseUrl = wsBaseUrl;
    return _wsBaseUrl ?? "wss://localhost:6544";
  }
}
