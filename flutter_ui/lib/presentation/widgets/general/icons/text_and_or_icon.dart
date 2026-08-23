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

import 'dart:ui' as ui show TextHeightBehavior;
import 'package:flutter/material.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class TextAndOrIcon {
  final String? text;
  final Icon? icon;
  TextAndOrIcon({this.text = "", this.icon});

  factory TextAndOrIcon.text(String? text) => TextAndOrIcon(text: text);
  factory TextAndOrIcon.icon(Icon? icon) => TextAndOrIcon(icon: icon);
  factory TextAndOrIcon.textIcon(String? text, Icon? icon) => TextAndOrIcon(
        text: text,
        icon: icon,
      );

  static List<TextAndOrIcon> convertTextList(List<String> textList) {
    return textList.map((text) => TextAndOrIcon.text(text)).toList();
  }

  static List<TextAndOrIcon> convertIconList(List<Icon> iconList) {
    return iconList.map((icon) => TextAndOrIcon.icon(icon)).toList();
  }
}

class TextAndOrIconWidget extends StatelessWidget {
  final TextAndOrIcon? textAndOrIcon;
  final TextStyle? textStyle;
  final TextOverflow? textOverflow;
  final int? maxLines;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextScaler? textScaler; // Updated parameter from textScaleFactor
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;

  const TextAndOrIconWidget(
    this.textAndOrIcon, {
    super.key,
    this.maxLines = 1,
    this.textStyle,
    this.textOverflow = TextOverflow.ellipsis,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.textScaler, // Updated parameter
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return MmsText(
      textAndOrIcon?.text,
      iconEntry: textAndOrIcon?.icon,
      maxLines: maxLines,
      overflow: textOverflow,
      style: textStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      textScaler: textScaler, // Updated usage of textScaler
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  static List<Widget> convertTextAndOrIconList(
    List<TextAndOrIcon> textAndOrIconList, {
    int maxLines = 1,
    TextOverflow textOverflow = TextOverflow.ellipsis,
    TextStyle? textStyle,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextScaler? textScaler, // Updated parameter
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    ui.TextHeightBehavior? textHeightBehavior,
  }) {
    return textAndOrIconList
        .map(
          (element) => TextAndOrIconWidget(
            element,
            maxLines: maxLines,
            textOverflow: textOverflow,
            textStyle: textStyle,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textDirection: textDirection,
            locale: locale,
            softWrap: softWrap,
            textScaler: textScaler, // Updated usage of textScaler
            semanticsLabel: semanticsLabel,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior,
          ),
        )
        .toList();
  }
}
