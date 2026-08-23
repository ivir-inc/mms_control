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
import 'package:flutter_ui/presentation/widgets/layouts/labeled_value.dart';
import 'package:flutter_ui/presentation/widgets/layouts/padded_column.dart';

/// Creates a Column widget containing multiple padded
/// rows of bolded, black labels and text values styled as specified.
/// Padding and alignment can be specified for both the
/// column (outer padding/alignment) and the rows
/// (inner padding/alignment), with the outer padding
/// defaulting to zero and the inner padding defaulting
/// to 10 pixels all around.
///
/// The labels and values are passed as a list of MmsStyledLabelValue.
/// Each MmsStyledLabelValue is expected to contain a "label"
/// and a "value", though if either are omitted, the
/// empty string will be used. The object may also contain a
/// TextStyle object to be used to style the value in that row.
class MmsLabeledValuesColumn extends StatelessWidget {
  final double outerLeft;
  final double outerTop;
  final double outerRight;
  final double outerBottom;
  final double innerLeft;
  final double innerTop;
  final double innerRight;
  final double innerBottom;
  final MainAxisAlignment outerMainAxisAlignment;
  final CrossAxisAlignment outerCrossAxisAlignment;
  final MainAxisAlignment innerMainAxisAlignment;
  final CrossAxisAlignment innerCrossAxisAlignment;
  final List<MmsStyledLabelValue> labelsAndValues;
  const MmsLabeledValuesColumn(
    this.labelsAndValues, {
    super.key,
    this.outerLeft = 0.0,
    this.outerTop = 0.0,
    this.outerRight = 0.0,
    this.outerBottom = 10.0, // To give a default padding below last row.
    this.innerLeft = 10.0,
    this.innerTop = 10.0,
    this.innerRight = 10.0,
    this.innerBottom = 0.0, // Top and bottom both 10.0 would give 20.0 between.
    this.outerMainAxisAlignment = MainAxisAlignment.spaceAround,
    this.outerCrossAxisAlignment = CrossAxisAlignment.start,
    this.innerMainAxisAlignment = MainAxisAlignment.start,
    this.innerCrossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rowWidgets = <Widget>[];
    for (var element in labelsAndValues) {
      Widget labVal = MmsLabeledValue(
        element.label,
        element.value,
        labelIcon: element.labelIcon,
        valueIcon: element.valueIcon,
        style: element.style,
        left: innerLeft,
        top: innerTop,
        right: innerRight,
        bottom: innerBottom,
        mainAxisAlignment: innerMainAxisAlignment,
        crossAxisAlignment: innerCrossAxisAlignment,
      );
      rowWidgets.add(labVal);
    }
    return MmsPaddedColumn(
      rowWidgets,
      left: outerLeft,
      top: outerTop,
      right: outerRight,
      bottom: outerBottom,
      mainAxisAlignment: outerMainAxisAlignment,
      crossAxisAlignment: outerCrossAxisAlignment,
    );
  }
}

class MmsDoublePaddedValuesColumn extends StatelessWidget {
  final double outerLeft;
  final double outerTop;
  final double outerRight;
  final double outerBottom;
  final double innerLeft;
  final double innerTop;
  final double innerRight;
  final double innerBottom;
  final MainAxisAlignment outerMainAxisAlignment;
  final CrossAxisAlignment outerCrossAxisAlignment;
  final MainAxisAlignment innerMainAxisAlignment;
  final CrossAxisAlignment innerCrossAxisAlignment;
  final List<String> values;
  const MmsDoublePaddedValuesColumn(
    this.values, {
    super.key,
    this.outerLeft = 0.0,
    this.outerTop = 0.0,
    this.outerRight = 0.0,
    this.outerBottom = 10.0, // To give a default padding below last row.
    this.innerLeft = 10.0,
    this.innerTop = 10.0,
    this.innerRight = 10.0,
    this.innerBottom = 0.0, // Top and bottom both 10.0 would give 20.0 between.
    this.outerMainAxisAlignment = MainAxisAlignment.spaceAround,
    this.outerCrossAxisAlignment = CrossAxisAlignment.start,
    this.innerMainAxisAlignment = MainAxisAlignment.start,
    this.innerCrossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rowWidgets = <Widget>[];
    for (var element in values) {
      Widget labVal = MmsLabeledValue(
        "",
        element,
        left: innerLeft,
        top: innerTop,
        right: innerRight,
        bottom: innerBottom,
        mainAxisAlignment: innerMainAxisAlignment,
        crossAxisAlignment: innerCrossAxisAlignment,
      );
      rowWidgets.add(labVal);
    }
    return MmsPaddedColumn(
      rowWidgets,
      left: outerLeft,
      top: outerTop,
      right: outerRight,
      bottom: outerBottom,
      mainAxisAlignment: outerMainAxisAlignment,
      crossAxisAlignment: outerCrossAxisAlignment,
    );
  }
}
