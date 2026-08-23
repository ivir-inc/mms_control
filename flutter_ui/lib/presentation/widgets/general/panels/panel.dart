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

/// Creates a Card widget containing other widgets to help
/// give a standard look and feel to MMS pages.
class Panel extends StatelessWidget {
  final double width;
  final double? height;
  final String text;
  final Widget widget;
  final Icon? iconEntry;

  const Panel({
    super.key,
    required this.width,
    this.height,
    required this.text,
    required this.widget,
    this.iconEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: width,
        height: height ?? 300.0, // Set a reasonable default height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.center,
              color: MmsColors.dkBlue,
              height: 30,
              child: MmsText(
                text,
                iconEntry: iconEntry,
                style: const TextStyle(color: MmsColors.white),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: widget,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
