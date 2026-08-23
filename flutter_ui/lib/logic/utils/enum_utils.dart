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

import 'package:flutter_ui/logic/utils/string_utils.dart';

class EnumUtils {
  static final Type stringType = "".runtimeType;
  static bool isEnum(dynamic data) {
    // Check if data is not a string type
    if (data?.runtimeType == stringType) {
      return false;
    }

    // Check if the enum has a `name` property, which all enums should have
    try {
      return data is Enum;
    } catch (e) {
      return false;
    }
  }
  /// Intended to find an enum corresponding to [underscoredValue].
  /// Pass the list of values for an enum, and the one that matches
  /// [underscoredValue] will be returned, where an enum is determined
  /// to match [underscoredValue] if
  /// [StringUtils.dynaUnderscoredBreaks(value_i, def: def, upperCase: upperCase,)]
  /// is equal to [underscoredValue.toString()], where [value_i] is the ith
  /// element of [values]. If nothing matches, then [defObj] is returned.
  ///
  /// Example usage: [getValue(WrapAlignment.values, "space_between")] returns
  /// [WrapAlignment.spaceBetween], as does
  /// [getValue(WrapAlignment.values, "SPACE_BETWEEN", uppercase: true,)].
  ///
  /// There may be use for this method aside from getting a matched enum.
  static T? getMatchedObject<T>(
    List<T> values,
    dynamic underscoredValue, {
    String def = "",
    bool upperCase = false,
    T? defObj,
  }) {
    int numVals = values.length;
    for (int i = 0; i < numVals; ++i) {
      String poss = StringUtils.dynaUnderscoredBreaks(
        values[i],
        def: def,
        upperCase: upperCase,
      );
      if (poss == underscoredValue.toString()) {
        return values[i];
      }
    }
    return defObj;
  }
}
