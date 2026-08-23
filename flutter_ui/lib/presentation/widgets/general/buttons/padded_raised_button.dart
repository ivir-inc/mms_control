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
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

/// Creates a labeled ElevatedButton widget with default
/// padding of 10 pixels all around, but different padding
/// may be specified. A text widget is automatically used
/// as the child of the ElevatedButton, for which a
/// TextStyle parameter may be passed. May also specify
/// any other parameters standard for an ElevatedButton.
/// Set the expanded named parameter to true if you want
/// the returned button wrapped in an Expanded widget, which
/// is useful for getting evenly sized buttons in a row.
class MmsPaddedRaisedButton extends StatelessWidget {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final ButtonStyle? buttonStyle;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final String label;
  final Icon? labelIcon;
  final TextStyle? textStyle;
  final bool expanded;
  const MmsPaddedRaisedButton(
    this.label, {
    super.key,
    this.labelIcon,
    this.textStyle,
    this.buttonStyle,
    this.focusNode,
    this.onPressed,
    this.onLongPress,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.left = 10.0,
    this.top = 10.0,
    this.right = 10.0,
    this.bottom = 10.0,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget paddedButton = Padding(
        padding: EdgeInsets.fromLTRB(left, top, right, bottom),
        child: ElevatedButton(
            style: buttonStyle,
            onPressed: onPressed,
            onLongPress: onLongPress,
            focusNode: focusNode,
            autofocus: autofocus,
            clipBehavior: clipBehavior,
            child: MmsText(
              label,
              iconEntry: labelIcon,
              style: textStyle,
            )));
    return expanded ? Expanded(child: paddedButton) : paddedButton;
  }
}
