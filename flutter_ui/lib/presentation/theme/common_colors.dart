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

/// Standardizes colors for MMS widgets.
///
/// If any color needs to be changed for MMS use, even if it be black
/// or white, the definition of the colors can be made here and will then
/// propagate everywhere [MmsColors] is used.
class MmsColors {
  static const Color ltGreen = Color.fromRGBO(212, 232, 212, 1);
  static const Color ltYellow = Color.fromRGBO(255, 242, 204, 1);
  static const Color ltGrey = Color.fromRGBO(232, 232, 232, 1);
  static const Color mdGrey = Color.fromRGBO(164, 164, 164, 1);
  static const Color mdkGrey = Color.fromRGBO(96, 96, 96, 1);
  static const Color dkBlue = Color.fromRGBO(24, 49, 76, 1);
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color green = Colors.green;
  static const Color red = Colors.red;
  static const Color pink = Color.fromRGBO(255, 200, 200, 1);
  static const Color orange = Colors.orange;
  static const Color yellow = Colors.yellow;
  static const Color aqua = Color.fromRGBO(100, 255, 255, 1);
  static const Color ltPurple = Color.fromRGBO(200, 100, 250, 1);
  static const Color transparent = Color.fromRGBO(0, 0, 0, 0);
  static const Color translucentBlack = Color.fromRGBO(0, 0, 0, 0.7);
  static const Color translucentWhite = Color.fromRGBO(255, 255, 255, 0.2);

  static const Color appBackgroundColor = black;
  static const mainBodyBackgroundColor = dkBlue;
  static const Color buttonColor = Color.fromRGBO(33, 150, 243, 1);
  static const Color buttonTextColor = Color.fromRGBO(255, 255, 255, 1);

  static const List<Color> patientColors = [
    Colors.blue, // #2196F3
    Colors.orange, // #FF9800
    Colors.purple, // #9C27B0
    Colors.teal, // #009688
    Colors.indigo, // #3F51B5
    Colors.brown, // #795548
    Colors.pink, // #E91E63
    Colors.deepPurple, // #673AB7
    Colors.deepOrange, // #FF5722
    Color(0xFF00695C), // teal[800] — dark but distinguishable
    Color(0xFF1E88E5), // blue[600] — brighter than regular blue
    Color(0xFF8E24AA), // purple[600] — richer than standard
  ];

  static Color getPatientColorOrdered(
      List<String> orderedPatientIds, String patientId) {
    final index = orderedPatientIds.indexOf(patientId);
    if (index == -1) return Colors.grey; // fallback
    return patientColors[index % patientColors.length];
  }

  MmsColors._();
  static final MmsColors _instance = MmsColors._();
  factory MmsColors() {
    return _instance;
  }
}
