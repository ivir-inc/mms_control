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

class MmsSizedLabeledText extends StatelessWidget {
  final String label;
  final String text;
  final Icon? labelIcon;
  final Icon? textIcon;
  final double? labelWidth;
  final double? textWidth;
  final double? height;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Color labelFgColor;
  final Color labelBgColor;
  final Color textFgColor;
  final Color textBgColor;
  final EdgeInsetsGeometry labelPadding;
  final EdgeInsetsGeometry textPadding;

  const MmsSizedLabeledText(
    this.label,
    this.text, {
    super.key,
    this.labelIcon,
    this.textIcon,
    this.labelWidth = 80,
    this.textWidth = 200,
    this.height = 20,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.labelFgColor = MmsColors.black,
    this.labelBgColor = MmsColors.transparent,
    this.textFgColor = MmsColors.black,
    this.textBgColor = MmsColors.transparent,
    this.labelPadding = const EdgeInsets.fromLTRB(10, 0, 5, 0),
    this.textPadding = const EdgeInsets.fromLTRB(5, 0, 10, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          color: labelBgColor,
          padding: labelPadding,
          width: labelWidth,
          height: height,
          child: MmsText(label,
              iconEntry: labelIcon,
              style:
                  TextStyle(color: labelFgColor, fontWeight: FontWeight.bold)),
        ),
        // Use Flexible to handle overflow
        Flexible(
          child: Container(
            color: textBgColor,
            padding: textPadding,
            height: height,
            child: Text(
              text,
              style:
                  TextStyle(color: textFgColor, fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis, // Prevent overflow with ellipsis
            ),
          ),
        ),
      ],
    );
  }
}
