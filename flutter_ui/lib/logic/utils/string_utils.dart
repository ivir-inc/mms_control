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

import 'package:flutter_ui/logic/utils/enum_utils.dart';

class StringUtils {
  /// Converts a camelCase or snake_case identifier into a human-readable string
  /// with spaces and capitalized words.
  ///
  /// Example: "patientId_number" → "Patient Id Number"
  static String humanizedId(String id) {
    String humanized = "";
    if (id.isNotEmpty) {
      String? separatedOnLowerToUpper = id.replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}');
      List<String> parts = separatedOnLowerToUpper.split(RegExp(r"[_ ]+"));
      parts.asMap().forEach((index, part) {
        if (index > 0) {
          humanized = "$humanized ";
        }
        String capPart = "${part[0].toUpperCase()}${part.substring(1)}";
        humanized = "$humanized$capPart";
      });
    }
    return humanized;
  }

  /// Converts a string into underscore-separated format,
  /// inserting underscores between camelCase boundaries and replacing spaces.
  ///
  /// By default, the result is lowercase, but can be uppercased with [uppercase].
  /// Returns [def] if the input is empty.
  ///
  /// Example: "PatientId Number" → "patient_id_number"
  static String underscoredBreaks(
    String val, {
    bool uppercase = false,
    String def = "",
  }) {
    String? underscored;
    if (val.isNotEmpty) {
      String separatedOnLowerToUpper = val.replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}');
      String replaceSpaces =
          separatedOnLowerToUpper.replaceAll(RegExp(r'[ ]+'), "_");
      underscored =
          uppercase ? replaceSpaces.toUpperCase() : replaceSpaces.toLowerCase();
    }
    return underscored ?? def;
  }

  /// Safely converts any dynamic value into a string.
  /// - If it's an enum, returns the enum's name.
  /// - Otherwise, uses `toString()` or returns [def] if null.
  ///
  /// Example: MyEnum.valueOne → "valueOne"
  static String dynaString(
    dynamic val, {
    String def = "",
  }) {
    String valString;
    if (EnumUtils.isEnum(val)) {
      valString = (val as Enum).name;
    } else {
      valString = val?.toString() ?? def;
    }
    return valString;
  }

  /// Convenience method: runs [dynaString] on a dynamic value,
  /// then applies [underscoredBreaks] to the result.
  ///
  /// Useful for normalizing dynamic values (enums, strings, etc.)
  /// into a consistent underscore-separated identifier.
  ///
  /// Example: MyEnum.valueOne → "value_one"
  static dynaUnderscoredBreaks(
    dynamic val, {
    String def = "",
    bool upperCase = false,
  }) {
    return underscoredBreaks(
      dynaString(
        val,
      ),
      uppercase: upperCase,
      def: def,
    );
  }

  /// Converts an identifier-like string (with underscores or mixed case)
  /// into a clean, sentence-cased phrase.
  ///
  /// - Underscores and multiple spaces are replaced with a single space.
  /// - All letters are lowercased except the first one.
  ///
  /// Example:
  ///   "START_HANDOFF" → "Start handoff"
  ///   "patient_moved" → "Patient moved"
  ///   "facilityUpdated" → "Facility updated"
  static String sentenceCaseUnderscored(String val) {
    if (val.isEmpty) return val;
    // Normalize camelCase boundaries to spaces
    final separated = val.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}');
    // Replace underscores/spaces with single space, lowercase everything
    final cleaned = separated.replaceAll(RegExp(r'[_ ]+'), ' ').toLowerCase();
    // Sentence case: capitalize first letter
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}
