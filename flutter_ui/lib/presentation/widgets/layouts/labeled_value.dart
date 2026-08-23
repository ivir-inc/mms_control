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
import 'package:flutter_ui/presentation/widgets/layouts/padded_row.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

/// Creates a padded Row widget containing a bold label
/// and a value.
class MmsLabeledValue extends StatelessWidget {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final String? label;
  final Icon? labelIcon;
  final String? value;
  final Icon? valueIcon;
  final TextStyle? style;
  const MmsLabeledValue(
    this.label,
    this.value, {
    super.key,
    this.labelIcon,
    this.valueIcon,
    this.style,
    this.left = 10.0,
    this.top = 10.0,
    this.right = 10.0,
    this.bottom = 10.0,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return MmsPaddedRow(
      <Widget>[
        MmsFieldLabelText(
          text: label,
          iconEntry: labelIcon,
        ),
        MmsText(
          value,
          iconEntry: valueIcon,
          style: style,
        ),
      ],
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }
}

class MmsStyledLabelValue {
  final String label;
  final String value;
  final TextStyle? style;
  final Icon? labelIcon;
  final Icon? valueIcon;
  MmsStyledLabelValue(
    this.label,
    this.value, {
    this.labelIcon,
    this.valueIcon,
    this.style,
  });
}
