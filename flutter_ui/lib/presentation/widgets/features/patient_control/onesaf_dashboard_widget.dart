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
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/modules/onesaf/presentation/screens/one_saf_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class OnesafDashboardWidget extends StatelessWidget {
  final String patientId;

  const OnesafDashboardWidget({required this.patientId, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MmsDismissibleScreen(
              const ValueKey("OnesafScreenDismissible"),
              OneSAFScreen(
                patientId,
              ),
              scrollable: true,
            ),
          ),
        );
      },
      child: MmsRoundedBarlessPanel(
        width: 200,
        caption: "OneSAF",
        widget: Center(
          child: MmsText(
            patientId,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
