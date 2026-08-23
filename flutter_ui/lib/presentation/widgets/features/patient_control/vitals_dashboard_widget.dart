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
import 'package:flutter_ui/modules/labs/presentation/screens/vitals_screen.dart';
import 'package:flutter_ui/modules/labs/presentation/widgets/vitals_readout.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';

class VitalsDashboardWidget extends StatelessWidget {
  final String patientId;

  const VitalsDashboardWidget({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MmsDismissibleScreen(
                  const ValueKey("VitalsScreenDismissible"),
                  VitalsScreen(
                    patientId: patientId,
                  ),
                  scrollable: true,
                )));
      },
      child: MmsRoundedBarlessPanel(
        width: 200,
        caption: "Vitals",
        widget: SizedBox(
          height: 260, // Enforce finite height for VitalsReadoutWidget
          child: VitalsReadoutWidget(
            patientId,
            height: 260,
            outerBoxPadding: 6,
          ),
        ),
      ),
    );
  }
}
