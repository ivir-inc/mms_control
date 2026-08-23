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

abstract class SimpleNumericRangeDisplayWidget extends StatefulWidget {
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextOverflow textOverflow;
  final int maxLines;
  final String? units;
  final int fractionDigits;
  final bool dispLoFirst;
  const SimpleNumericRangeDisplayWidget({super.key, 
    required this.textStyle,
    required this.textAlign,
    required this.textOverflow,
    required this.maxLines,
    this.units,
    this.fractionDigits = 0,
    this.dispLoFirst = true,
  });

  double valueLo();

  double valueHi();

  String displayString() {
    String dispLo = valueLo().toStringAsFixed(fractionDigits);
    String dispHi = valueHi().toStringAsFixed(fractionDigits);
    String sep = (maxLines > 1) ? "\n" : " ";
    String unitsPortion = (units == null) ? "" : '$sep$units';
    String sep1 = dispLoFirst ? " - " : "/";
    String sep2 = (maxLines > 2) ? "\n" : "";
    String disp1 = dispLoFirst ? dispLo : dispHi;
    String disp2 = dispLoFirst ? dispHi : dispLo;
    String disp = "$disp1$sep1$sep2$disp2";
    if (disp1 != "--" && disp2 != "--") {
      disp = "$disp$unitsPortion";
    }
    return disp;
  }
}
