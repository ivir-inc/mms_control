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
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class CollapsibleSettingsPanel extends StatelessWidget {
  final String title;
  final Widget collapsedSummary;
  final Widget expandedContent;
  final bool isExpanded;
  final VoidCallback onToggle;

  const CollapsibleSettingsPanel({
    super.key,
    required this.title,
    required this.collapsedSummary,
    required this.expandedContent,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return MmsStylablePanel(
      captionContent: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: MmsText(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(isExpanded ? Icons.create_sharp : Icons.create_outlined),
            color: Colors.black,
            onPressed: onToggle,
          ),
        ],
      ),
      captionBarColor: Colors.white,
      captionTextColor: Colors.white,
      elevation: 4.0,
      rounding: 8.0,
      width: 700,
      widget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: isExpanded ? expandedContent : collapsedSummary,
      ),
    );
  }
}
