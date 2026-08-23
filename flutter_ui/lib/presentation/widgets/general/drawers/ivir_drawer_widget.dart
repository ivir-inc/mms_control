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
import 'package:flutter_ui/presentation/widgets/general/buttons/text_link_button.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

/// A drawer widget for use on each MMS page to provide
/// access to all the other MMS pages. When a new MMS page
/// is created, this drawer widget may be updated to
/// include it.
class IvirDrawerWidget extends StatelessWidget {
  const IvirDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: const <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: MmsColors.black,
          ),
          child: MmsText(
            'MMS Tools',
            style: TextStyle(
              color: MmsColors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.control_point),
          title: MmsTextLinkButton('Vitals, Sounds, Labs', "#/labs",
              targetWindow: "mms_labs"),
        ),
        ListTile(
          leading: Icon(Icons.control_point),
          title: MmsTextLinkButton('Treatments', "../treatments/index.html",
              targetWindow: "mms_treatments"),
        ),
        ListTile(
          leading: Icon(Icons.control_point),
          title: MmsTextLinkButton('Pump Control', "../pump_control/index.html",
              targetWindow: "mms_pumpcontrol"),
        ),
        ListTile(
          leading: Icon(Icons.control_point),
          title: MmsTextLinkButton('Enduvo Control', "../enduvo/index.html",
              targetWindow: "mms_enduvo"),
        ),
        ListTile(
          leading: Icon(Icons.control_point),
          title: MmsTextLinkButton('Federation', "../federation/index.html",
              targetWindow: "mms_federation"),
        ),
        ListTile(
          leading: Icon(Icons.control_point),
          title: MmsTextLinkButton('Terminal', "../terminal/index.html",
              targetWindow: "mms_terminal"),
        ),
        ListTile(
          title: Image(image: AssetImage('images/IVIRlogo_w200.png')),
        ),
      ],
    ));
  }
}
