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
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';

/// Text widget assumed to be used as a bolded black label,
/// with font size 14, and a default padding of 10 pixels
/// all around.
class MmsPaddedLabelText extends StatelessWidget {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final String label;
  final Icon? labelIcon;
  const MmsPaddedLabelText(
    this.label, {
    super.key,
    this.labelIcon,
    this.left = 10.0,
    this.top = 10.0,
    this.right = 10.0,
    this.bottom = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(left, top, right, bottom),
        child: MmsFieldLabelText(
          text: label,
          iconEntry: labelIcon,
        ));
  }
}
