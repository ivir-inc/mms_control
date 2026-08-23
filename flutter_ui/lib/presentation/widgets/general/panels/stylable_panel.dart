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

/// [PanelActionWidgets] are each expected to be represented as an icon
/// of size 20, that will do some action when clicked.
class MmsStylablePanel extends StatelessWidget {
  final double? width;
  final double? height;
  final String? caption;
  final Widget? captionContent; // New parameter for custom caption widget
  final Icon? captionIcon;
  final Widget? widget;
  final EdgeInsetsGeometry? childPadding;
  final double? rounding;
  final double? elevation;
  final Color? captionBarColor;
  final Color? captionTextColor;
  final FontWeight? captionFontWeight;
  final Color? panelBgColor;
  final Color? shadowColor;
  final bool expandable;
  final List<Widget> panelActionWidgets;

  const MmsStylablePanel({
    super.key,
    this.width,
    this.height,
    this.caption,
    this.captionContent, // New parameter
    this.captionIcon,
    this.widget,
    this.childPadding,
    this.rounding,
    this.elevation,
    this.captionBarColor,
    this.captionTextColor = MmsColors.white,
    this.captionFontWeight = FontWeight.bold,
    this.panelBgColor = MmsColors.white,
    this.shadowColor = MmsColors.black,
    this.expandable = false,
    this.panelActionWidgets = const [],
  });

  @override
  Widget build(BuildContext context) {
    final Color useCaptionBarColor = captionBarColor ?? MmsColors.dkBlue;
    final EdgeInsetsGeometry useChildPadding =
        childPadding ?? const EdgeInsets.fromLTRB(10, 5, 10, 5);
    final double? childHeight =
        (height != null && height! > 33) ? height! - 33 : null;
    final double? childWidth = (width != null && width! > 0) ? width : null;
    final double useRounding = rounding ?? 5;
    final double useElevation = elevation ?? 5;

    // Show either captionContent or fallback to caption if content isn't provided
    final bool hasCaption =
        captionContent != null || caption != null || captionIcon != null;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width ?? double.infinity,
        maxHeight: height ?? double.infinity,
      ),
      child: Card(
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(useRounding)),
        ),
        clipBehavior: Clip.antiAlias,
        color: panelBgColor,
        borderOnForeground: true,
        elevation: useElevation,
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensure the column does not expand infinitely
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasCaption)
              Container(
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: useCaptionBarColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(useRounding),
                    topRight: Radius.circular(useRounding),
                  ),
                ),
                height: 40, // Adjust the height to fit content
                child: captionContent ??
                    Center(
                      // Prioritize captionContent
                      child: MmsText(
                        caption,
                        iconEntry: captionIcon,
                        style: TextStyle(
                          color: captionTextColor,
                          fontWeight: captionFontWeight,
                        ),
                      ),
                    ),
              ),
            if (hasCaption)
              const Divider(
                height: 3,
                thickness: 1,
                indent: 3,
                endIndent: 3,
                color: MmsColors.black,
              ),
            if (widget != null)
              Flexible(
                fit: FlexFit
                    .loose, // Use Flexible with FlexFit.loose to prevent infinite expansion
                child: Container(
                  height: childHeight,
                  width: childWidth,
                  padding: useChildPadding,
                  child: widget,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ExpandedPanel is used in the expandable feature to prevent deep recursion.
class ExpandedPanel extends StatelessWidget {
  final String? caption;
  final Icon? captionIcon;
  final Widget? widget;
  final EdgeInsetsGeometry? childPadding;
  final double? rounding;
  final double? elevation;
  final Color? captionBarColor;
  final Color? captionTextColor;
  final FontWeight? captionFontWeight;
  final Color? panelBgColor;
  final Color? shadowColor;
  final List<Widget> panelActionWidgets;

  const ExpandedPanel({
    super.key,
    this.caption,
    this.captionIcon,
    this.widget,
    this.childPadding,
    this.rounding,
    this.elevation,
    this.captionBarColor,
    this.captionTextColor,
    this.captionFontWeight,
    this.panelBgColor,
    this.shadowColor,
    this.panelActionWidgets = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MmsStylablePanel(
      height: MediaQuery.of(context).size.height - 70,
      width: MediaQuery.of(context).size.width - 20,
      widget: widget,
      caption: caption,
      captionIcon: captionIcon,
      childPadding: childPadding,
      rounding: rounding,
      elevation: elevation,
      captionBarColor: captionBarColor,
      captionTextColor: captionTextColor,
      captionFontWeight: captionFontWeight,
      panelBgColor: panelBgColor,
      shadowColor: shadowColor,
      expandable: false, // Prevent further expansion
      panelActionWidgets: panelActionWidgets,
    );
  }
}
