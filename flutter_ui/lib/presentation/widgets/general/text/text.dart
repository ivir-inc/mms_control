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

/// Behaves like a standard Text widget, accepting all the same
/// parameters, but applying a workaround for the loss of
/// characters at the end of the string in Firefox.
class MmsText extends StatelessWidget {
  final String? data;
  final Icon? iconEntry;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler; // New replacement for textScaleFactor
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;
  final bool removeExtraSpace;
  final String? newlineSequence;

  const MmsText(
    this.data, {
    super.key,
    this.iconEntry,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler, // Replaced textScaleFactor with textScaler
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.removeExtraSpace = false,
    this.newlineSequence,
  });

  @override
  Widget build(BuildContext context) {
    bool hasData = data?.isNotEmpty ?? false;
    Widget? text;
    if (hasData) {
      String? useData = removeExtraSpace
          ? data?.trim().replaceAll(RegExp(r'\s+'), " ")
          : data;
      useData = (newlineSequence?.isNotEmpty ?? false)
          ? useData?.replaceAll(newlineSequence!, "\n")
          : useData;
      text = Text(
        "${useData!} ", // Workaround for Firefox loss of end of strings
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler, // Applied textScaler instead of textScaleFactor
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
      );
    }
    bool hasIcon = iconEntry != null;
    if (hasData && hasIcon) {
      return Row(
        children: [iconEntry!, text!],
      );
    } else if (hasData) {
      return text!;
    } else if (hasIcon) {
      return iconEntry!;
    } else {
      return const Text("");
    }
  }
}
