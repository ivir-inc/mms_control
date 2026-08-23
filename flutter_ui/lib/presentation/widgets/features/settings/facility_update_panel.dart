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
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';

class FacilityUpdatePanel extends StatelessWidget {
  const FacilityUpdatePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return MmsStylablePanel(
      caption: "Facility Update",
      widget: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Current Facility ID',
            ),
            textAlign: TextAlign.center,
            initialValue: 'POI',
          ),
          const MmsPaddedRaisedButton("Update"),
        ],
      ),
      width: 400,
      captionBarColor: Colors.white, // Customize as needed
      captionTextColor: Colors.black,
      captionFontWeight: FontWeight.w700, // Set text to bold
      rounding: 8.0,
      elevation: 4.0,
    );
  }
}
