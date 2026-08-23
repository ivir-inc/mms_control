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

/// Provides a static method for MMS-standardized behavior of dismissible dialogs
class MmsDialogHelper {
  /// Creates a dialog dismissible with a swipe.
  ///
  /// Example code follows:
  ///
  /// ```
  /// MmsDialogHelper.popupDismissibleDialog(
  ///   context,
  ///   ValueKey("LabsScreen"),
  ///   direction: DismissDirection.startToEnd,
  ///   contentWidget: LabsScreen()),
  /// );
  /// ```
  ///
  /// To close the dialog programmatically, make the following call,
  /// but be sure the dialog is open when making this call:
  ///
  /// ```
  /// Navigator.of(context).pop();
  /// ```
  ///
  /// If vertical scrolling behavior is desired for [contentWidget],
  /// call [popupScrollableDismissibleDialog()], which allows
  /// for dismissing with horizontal swiping only, since vertical
  /// motion is intended for scrolling the content widget.
  ///
  /// The underlying [Dismissible] requires a [Key], and [dismissibleKey]
  /// is used for that purpose. A [ValueKey] identifying the content involved
  /// works nicely. Don't use a [Key] already in use by [contentWidget] or
  /// any other existing widget.
  ///
  /// The user may dismiss the dialog by swiping in [direction]. Note that
  /// tapping/clicking outside the bounds of the dialog may not dismiss
  /// the dialog as it can for other dialogs.
  ///
  /// [contentWidget] will be placed inside a [Column] residing within
  /// a decorated [Container]. The [Column] contains a _close_ icon, aligned
  /// to the top right of the screen, as another means of dismissing the
  /// dialog. [contentWidget] is placed in the [Column] after the _close_
  /// icon. The [Container] for the [Column] is automatically sized to
  /// fill most of the screen, so [contentWidget] has a large share of
  /// screen real estate for its use.
  ///
  /// A [then] [Function] may be passed in to be called when the popup
  /// has been dismissed. An argument is passed to [then], but as of this
  /// writing may be ignored.

  static void popupDismissibleDialog(BuildContext context, Key dismissibleKey,
      {DismissDirection direction = DismissDirection.horizontal,
      required Widget contentWidget,
      Function? then}) {
    double ht = MediaQuery.of(context).size.height;
    double wt = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        builder: (context) {
          return Dismissible(
            key: dismissibleKey,
            direction: direction,
            onDismissed: (direction) {
              Navigator.of(context).pop();
            },
            child: Dialog(
              insetPadding: const EdgeInsets.all(20),
              backgroundColor: MmsColors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                width: wt,
                height: ht,
                decoration: BoxDecoration(
                    color: MmsColors.black,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    boxShadow: const [
                      BoxShadow(
                        color: MmsColors.white,
                        offset: Offset(1, 1),
                        blurRadius: 1,
                        spreadRadius: 2,
                      )
                    ],
                    border: Border.all(color: MmsColors.ltGreen)),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      heightFactor: 0.8,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        color: MmsColors.white,
                        icon: const Icon(Icons.close),
                        tooltip: "Dismiss",
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    contentWidget,
                  ],
                ),
              ),
            ),
          );
        }).then((arg) {
      if (then != null) {
        then(arg);
      }
    });
  }

  /// Create a dialog with vertical scrolling, dismissible with a horizontal swipe.
  static void popupScrollableDismissibleDialog(
      BuildContext context, Key dismissibleKey,
      {Widget? contentWidget, Function? then}) {
    popupDismissibleDialog(
      context,
      dismissibleKey,
      then: then,
      contentWidget: Expanded(
        child: SingleChildScrollView(
          child: contentWidget,
        ),
      ),
    );
  }
}
