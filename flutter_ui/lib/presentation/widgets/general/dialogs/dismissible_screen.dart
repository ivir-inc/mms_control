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
import 'package:flutter/services.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';

class MmsDismissibleScreen extends StatefulWidget {
  final Widget child;
  final Key dismissibleKey;
  final DismissDirection direction;
  final bool scrollable;

  /// Callback to determine if dismiss should proceed
  final Future<bool> Function()? onAttemptDismiss;

  const MmsDismissibleScreen(
    this.dismissibleKey,
    this.child, {
    super.key,
    this.direction = DismissDirection.horizontal,
    this.scrollable = true,
    this.onAttemptDismiss,
  });

  @override
  _MmsDismissibleScreenState createState() => _MmsDismissibleScreenState();
}

class _MmsDismissibleScreenState extends State<MmsDismissibleScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget = widget.child;
    if (widget.scrollable) {
      contentWidget = Expanded(
        child: SingleChildScrollView(
          child: widget.child,
        ),
      );
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          () async {
            final shouldDismiss = await widget.onAttemptDismiss?.call() ?? true;
            if (shouldDismiss && context.mounted) {
              Navigator.of(context).pop();
            }
          }();
        }
      },
      child: Scaffold(
        backgroundColor: MmsColors.transparent,
        body: Dismissible(
          key: widget.dismissibleKey,
          direction: widget.direction,
          confirmDismiss: (_) async {
            if (widget.onAttemptDismiss != null) {
              return await widget.onAttemptDismiss!();
            }
            return true;
          },
          onDismissed: (_) {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: MmsColors.black,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: const [
                BoxShadow(
                  color: MmsColors.white,
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: MmsColors.ltGreen),
            ),
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
                    onPressed: () async {
                      final shouldDismiss =
                          await widget.onAttemptDismiss?.call() ?? true;
                      if (shouldDismiss) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                ),
                contentWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
