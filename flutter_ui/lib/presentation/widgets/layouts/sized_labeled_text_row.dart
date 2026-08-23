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
import 'package:flutter_ui/presentation/widgets/layouts/sized_labeled_widget_row.dart';
import 'package:flutter_ui/presentation/widgets/general/icons/text_and_or_icon.dart';

class MmsSizedLabeledTextRow extends StatelessWidget {
  final String label;
  final List<TextAndOrIcon> textAndOrIconList;
  final double labelWidth;
  final List<double> textWidths;
  final double textWidth;
  final double? height;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Alignment verticalTextAlignment;
  final Color labelFgColor;
  final Color labelBgColor;
  final Color textFgColor;
  final Color textBgColor;
  final EdgeInsetsGeometry labelPadding;
  final EdgeInsetsGeometry textPadding;
  final bool allHeaders;
  final TextOverflow labelOverflow;
  final TextOverflow textOverflow;
  final Color? overrideTextColor;

  const MmsSizedLabeledTextRow(
    this.label,
    this.textAndOrIconList, {
    super.key,
    this.labelWidth = 80,
    this.textWidths = const [],
    this.textWidth = 200,
    this.height = 20,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalTextAlignment = Alignment.centerLeft,
    this.labelFgColor = MmsColors.black,
    this.labelBgColor = MmsColors.transparent,
    this.textFgColor = MmsColors.black,
    this.textBgColor = MmsColors.transparent,
    this.labelPadding = const EdgeInsets.fromLTRB(10, 0, 5, 0),
    this.textPadding = const EdgeInsets.fromLTRB(5, 0, 10, 0),
    this.allHeaders = false,
    this.labelOverflow = TextOverflow.ellipsis,
    this.textOverflow = TextOverflow.ellipsis,
    this.overrideTextColor,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = TextAndOrIconWidget.convertTextAndOrIconList(
      textAndOrIconList,
      maxLines:
          height == null ? 10 : 1, // or any high number you want for wrapping.
      // Truncate to 1 line when height is specified; wrap when height is null
      // (and give room to show multiple lines)
      textOverflow: height == null ? TextOverflow.visible : textOverflow,
      textStyle: TextStyle(
        color: overrideTextColor ?? textFgColor,
        fontWeight: allHeaders ? FontWeight.bold : FontWeight.normal,
      ),
    );

    return MmsSizedLabeledWidgetRow(
      label,
      children,
      labelWidth: labelWidth,
      childrenWidths: textWidths,
      childDefWidth: textWidth,
      height: height,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      verticalChildAlignment: verticalTextAlignment,
      labelFgColor: overrideTextColor ?? labelFgColor,
      labelBgColor: labelBgColor,
      childBgColor: textBgColor,
      labelPadding: labelPadding,
      childPadding: textPadding,
      labelOverflow: labelOverflow,
    );
  }
}
