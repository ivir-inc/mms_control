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
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';

class MmsScrollableConstrainedStylablePanel extends StatelessWidget {
  final double fixedWidth;
  final double minusWidth;
  final double minWidth;
  final double maxWidth;
  final double widthFactor;
  final double fixedHeight;
  final double minusHeight;
  final double minHeight;
  final double maxHeight;
  final double heightFactor;
  final String? caption;
  final Icon? captionIcon;
  final Widget? fixedTopWidget;
  final double fixedTopWidgetHeight;
  final Widget? widget;
  final EdgeInsetsGeometry? childPadding;
  final double? rounding;
  final double? elevation;
  final Color? captionBarColor;
  final Color? captionTextColor;
  final FontWeight? captionFontWeight;
  final Color? panelBgColor;
  final Color? shadowColor;

  /// Creates an [MmsStylablePanel] packed inside a number of other widgets
  /// to allow the panel to take up the entire screen, less [minusWidth]
  /// on the width and [minusHeight] on the height. If [widthFactor]
  /// and/or [heightFactor] are non-zero, they will be multiplied by the
  /// width and height values calculated above to determine width and height
  /// values for the panel, unless [fixedWidth] and/or [fixedHeight] are
  /// non-zero, in which case the provided non-zero [fixedWidth] and/or
  /// [fixedHeight] are used. If the dimensions resulting from the above are
  /// less than the non-zero values of [minWidth] and/or
  /// [minHeight], the supplied minimum values are used instead. After
  /// that, if the dimensions exceed the non-zero values of [maxWidth] and/or
  /// [maxHeight], the supplied maximum values are used instead. Finally,
  /// if the calculated width or height values are larger or smaller than
  /// specified by the constraints passed behind the scenes to the
  /// LayoutBuilder, the panel will be constrained accordingly.
  ///
  /// The panel is designed to be scrollable vertically if its contents
  /// exceed the height of the panel.
  ///
  /// The arguments for [MmsScrollableConstrainedStylablePanel] not
  /// described above are similar to those for [MmsStylablePanel].
  const MmsScrollableConstrainedStylablePanel({
    super.key,
    this.caption,
    this.captionIcon,
    this.captionBarColor,
    this.captionFontWeight,
    this.captionTextColor,
    this.childPadding,
    this.elevation,
    this.panelBgColor,
    this.rounding,
    this.shadowColor,
    this.widget,
    this.fixedTopWidget,
    this.fixedTopWidgetHeight = 24,
    this.fixedWidth = 0.0,
    this.minusWidth = 0.0,
    this.widthFactor = 1.0,
    this.minWidth = 0.0,
    this.maxWidth = 0.0,
    this.fixedHeight = 0.0,
    this.minusHeight = 0.0,
    this.minHeight = 0.0,
    this.maxHeight = 0.0,
    this.heightFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double ht = fixedHeight;
      if (fixedHeight <= 0.0) {
        ht = MediaQuery.of(context).size.height - minusHeight;
        if (heightFactor > 0.0) {
          ht = ht * heightFactor;
        }
      }
      if (minHeight > 0.0 && ht < minHeight) {
        ht = minHeight;
      }
      if (maxHeight > 0.0 && ht > maxHeight) {
        ht = maxHeight;
      }
      if (ht < constraints.minHeight + 4) {
        ht = constraints.minHeight + 4;
      }
      if (ht > constraints.maxHeight - 4) {
        ht = constraints.maxHeight - 4;
      }
      double wt = fixedWidth;
      if (wt <= 0.0) {
        wt = MediaQuery.of(context).size.width - minusWidth;
        if (widthFactor > 0.0) {
          wt = wt * widthFactor;
        }
      }
      if (minWidth > 0.0 && wt < minWidth) {
        wt = minWidth;
      }
      if (maxWidth > 0.0 && wt > maxWidth) {
        wt = maxWidth;
      }
      if (wt < constraints.minWidth + 4) {
        wt = constraints.minWidth + 4;
      }
      if (wt > constraints.maxWidth - 4) {
        wt = constraints.maxWidth - 4;
      }
      double useFixedTopWidgetHeight = fixedTopWidgetHeight;
      if (fixedTopWidget == null) {
        useFixedTopWidgetHeight = 0;
      }
      return Container(
        width: wt,
        height: ht,
        color: MmsColors.transparent,
        child: MmsStylablePanel(
          caption: caption,
          captionIcon: captionIcon,
          captionBarColor: captionBarColor,
          captionFontWeight: captionFontWeight,
          captionTextColor: captionTextColor,
          childPadding: childPadding,
          elevation: elevation,
          panelBgColor: panelBgColor,
          rounding: rounding,
          shadowColor: shadowColor,
          width: wt,
          height: ht - 8,
          widget: Stack(
            children: [
              if (fixedTopWidget != null) fixedTopWidget!,
              Positioned(
                top: useFixedTopWidgetHeight,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(child: widget),
              ),
            ],
          ),
        ),
      );
    });
  }
}
