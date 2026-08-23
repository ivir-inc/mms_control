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

import 'package:flutter/material.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("IconHelper");

class IconHelper {
  static Map<String, IconData> iconsMap = {
    "pending": Icons.pending,
    "person": Icons.person,
    "more_horiz": Icons.more_horiz,
    "volume_up": Icons.volume_up,
    "timer": Icons.timer,
    "check": Icons.check,
    "do_not_disturb": Icons.do_not_disturb,
  };

  /// Returns the named material icon.
  static Icon? materialIconByName(String materialIconName) {
    String trimName = materialIconName.trim();
    if (trimName.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
      );
    }
    if (!iconsMap.containsKey(trimName)) {
      return const Icon(
        Icons.image_not_supported,
      );
    }
    try {
      Icon icon = Icon(iconsMap[trimName]);
      return icon;
    } catch (e) {
      _logger.log(1, 'Error creating icon for $materialIconName: $e');
    }
    return null;
  }
}
