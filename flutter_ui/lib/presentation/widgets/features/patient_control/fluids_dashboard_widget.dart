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
import 'package:provider/provider.dart';
import 'package:flutter_ui/modules/pump_control/data/models/pump_control_model.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/text/box_shaded_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class FluidsDashboardWidget extends StatefulWidget {
  final String patientId;

  const FluidsDashboardWidget({required this.patientId, super.key});

  @override
  _FluidsDashboardWidgetState createState() => _FluidsDashboardWidgetState();
}

class _FluidsDashboardWidgetState extends State<FluidsDashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RuntimeStatusStoreAccess>(
      create: (_) => RuntimeStatusStoreAccess(),
      child: Consumer<RuntimeStatusStoreAccess>(
        builder: (context, runtimeStatusStore, child) {
          final runtimeStatus =
              runtimeStatusStore.getRuntimeStatus(widget.patientId);

          return MmsRoundedBarlessPanel(
            width: 300,
            height: 210,
            caption: "Fluids",
            widget: _buildFluidsContent(runtimeStatus),
          );
        },
      ),
    );
  }

  Widget _buildFluidsContent(RuntimeStatus? runtimeStatus) {
    const String unknownLabel = "Unknown";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: MmsText(
                "Urine",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            MmsBoxShadedText(
              runtimeStatus?.urinePumpLabel ?? unknownLabel,
              bgColor: _pumpStatusColor(runtimeStatus?.urinePumpLabel),
            ),
            const SizedBox(height: 20),
            const MmsText(
              "Catheter",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: MmsBoxShadedText(
                runtimeStatus?.catheterLabel ?? unknownLabel,
                bgColor: _pumpStatusColor(runtimeStatus?.catheterLabel),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 2,
            height: 120,
            color: MmsColors.mdGrey,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: MmsText(
                "Blood",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            MmsBoxShadedText(
              runtimeStatus?.bloodPumpLabel ?? unknownLabel,
              bgColor: _pumpStatusColor(runtimeStatus?.bloodPumpLabel),
            ),
          ],
        ),
      ],
    );
  }

  Color _pumpStatusColor(String? statusLabel) {
    if (statusLabel?.toLowerCase() == "off") {
      return MmsColors.pink;
    } else if (statusLabel?.toLowerCase() == "on") {
      return MmsColors.ltGreen;
    }
    return MmsColors.ltGrey;
  }
}
