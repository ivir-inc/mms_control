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
import 'package:url_launcher/url_launcher.dart';

/// A widget for linking to a URL via a labeled button, with
/// the ability to specify a target window and an alignment
/// for the label within the button.
class MmsTextLinkButton extends StatelessWidget {
  final String? label;
  final Icon? labelIcon;
  final String url;
  final String targetWindow;
  final Alignment alignment;

  const MmsTextLinkButton(this.label, this.url,
      {super.key,
      this.labelIcon,
      this.targetWindow = "_blank",
      this.alignment = Alignment.centerLeft});

  void _launchUrl(String url, String windowName) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          webOnlyWindowName: targetWindow,
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {_launchUrl(url, targetWindow)},
      child: Align(
          alignment: alignment,
          child: MmsText(
            label,
            iconEntry: labelIcon,
          )),
    );
  }
}
