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

class MmsBoxShadedText extends StatelessWidget {
  final String text;
  final Icon? iconEntry;
  final bool isBold;
  final double width;
  final double height;
  final Color bgColor;
  final Color shadowColor;
  final Color textColor;

  const MmsBoxShadedText(
    this.text, {
    super.key,
    this.iconEntry,
    this.isBold = false,
    this.width = 100,
    this.height = 32,
    this.bgColor = MmsColors.ltGreen,
    this.shadowColor = MmsColors.mdGrey,
    this.textColor = MmsColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      decoration: BoxDecoration(color: bgColor, boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 1,
          spreadRadius: 0,
          offset: const Offset(1, 1),
        )
      ]),
      height: height,
      width: width,
      child: MmsText(text,
          iconEntry: iconEntry,
          style: TextStyle(
              color: textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }
}
