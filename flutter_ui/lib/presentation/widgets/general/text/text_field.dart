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
import 'package:flutter_ui/presentation/theme/common_colors.dart';

/// Creates a TextField widget with height of 30,
/// center alignment, black text with normal font weight
/// and font size of 12, and a grey border of width 1.
class MmsTextField extends StatelessWidget {
  final double? width;
  final TextEditingController? textController;
  final double? height;
  final int? maxLines;
  final bool enabled;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const MmsTextField({
    super.key,
    this.width,
    this.textController,
    this.maxLines,
    this.height = 40,
    this.enabled = true,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: Align(
          alignment: Alignment.center,
          child: TextField(
              enabled: enabled,
              maxLines: maxLines,
              keyboardType: keyboardType,
              onSubmitted: onSubmitted,
              controller: textController,
//              expands: true,
              style: const TextStyle(fontWeight: FontWeight.normal, color: MmsColors.black, fontSize: 16),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 1, color: MmsColors.mdGrey)))),
        ));
  }
}
