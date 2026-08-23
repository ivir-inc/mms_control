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

abstract class SimpleNumberDisplayWidget extends StatefulWidget {
  final int maxLines;
  final String? units;
  final int fractionDigits;
  const SimpleNumberDisplayWidget({
    super.key,
    required this.maxLines,
    this.units,
    this.fractionDigits = 0,
  });

  double value();

  String displayString() {
    String display = value().toStringAsFixed(fractionDigits);
    String sep = (maxLines > 1) ? "\n" : " ";
    String unitsPortion = (units == null) ? "" : '$sep$units';
    if (display != "--") {
      display = "$display$unitsPortion";
    }
    return display;
  }
}
