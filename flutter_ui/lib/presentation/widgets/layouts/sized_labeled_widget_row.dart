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
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class MmsSizedLabeledWidgetRow extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final double labelWidth;
  final List<double> childrenWidths;
  final double childDefWidth;
  final double? height;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Alignment verticalChildAlignment;
  final Color labelFgColor;
  final Color labelBgColor;
  final Color childBgColor;
  final EdgeInsetsGeometry labelPadding;
  final EdgeInsetsGeometry childPadding;
  final TextOverflow labelOverflow;

  const MmsSizedLabeledWidgetRow(
    this.label,
    this.children, {
    super.key,
    this.labelWidth = 80,
    this.childrenWidths = const [],
    this.childDefWidth = 200,
    this.height = 20,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalChildAlignment = Alignment.centerLeft,
    this.labelFgColor = MmsColors.black,
    this.labelBgColor = MmsColors.transparent,
    this.childBgColor = MmsColors.transparent,
    this.labelPadding = const EdgeInsets.fromLTRB(10, 0, 5, 0),
    this.childPadding = const EdgeInsets.fromLTRB(5, 0, 10, 0),
    this.labelOverflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = <Widget>[];

    widgetList.add(Container(
      color: labelBgColor,
      padding: labelPadding,
      width: labelWidth,
      height: height, // null means auto-wrap
      constraints: height == null ? const BoxConstraints() : null,
      child: Align(
        alignment: verticalChildAlignment,
        child: MmsText(
          label,
          maxLines: height == null ? null : 1,
          overflow: height == null ? TextOverflow.visible : labelOverflow,
          style: TextStyle(
            color: labelFgColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));

    for (int i = 0; i < children.length; ++i) {
      Widget child = children[i];
      widgetList.add(Container(
        color: childBgColor,
        padding: childPadding,
        width: childrenWidths.length > i ? childrenWidths[i] : childDefWidth,
        height: height,
        constraints: height == null ? const BoxConstraints() : null,
        child: Align(
          alignment: verticalChildAlignment,
          child: child,
        ),
      ));
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: widgetList,
      ),
    );
  }
}
