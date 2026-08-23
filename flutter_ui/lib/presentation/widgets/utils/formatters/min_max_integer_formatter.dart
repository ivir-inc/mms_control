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

import 'package:flutter/services.dart';
import 'package:flutter_ui/presentation/widgets/general/icons/icon_helper.dart';

/// Returns a Material icon, but only if the string starts with "icon:",
/// which is then followed by the name of the icon.
///
/// Returns [null] if the string doesn't start with the substring "icon:".
///
/// Returns [null] if the named icon isn't included in the icons map in
/// [IconHelper].
//   static Icon materialIconByNameConditionally(
//       String conditionalMaterialIconName) {
//     if (conditionalMaterialIconName?.startsWith("icon:") ?? false) {
//       return materialIconByName(conditionalMaterialIconName.substring(5));
//     }
//     return null;
//   }
// }

/// Allows only integers to be input.
class MinMaxIntegerFormatter extends TextInputFormatter {
  final int min;
  final int max;

  /// Only allows integer input between [min] and [max], inclusive.
  MinMaxIntegerFormatter(this.min, this.max);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow empty input and delegate formatting decision to `int.tryParse`.
    int? inVal = int.tryParse(newValue.text);
    bool isAllowed =
        newValue.text == '' || (inVal != null && inVal >= min && inVal <= max);
    return isAllowed ? newValue : oldValue;
  }
}
