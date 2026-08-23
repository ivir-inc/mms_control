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
import 'package:flutter_ui/presentation/widgets/general/panels/panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';
import '../widgets/pump_control_widgets.dart';

class PumpControlScreen extends StatefulWidget {
  final String? patientId;
  const PumpControlScreen({super.key, this.patientId});

  @override
  _PumpControlScreenState createState() => _PumpControlScreenState();
}

class _PumpControlScreenState extends State<PumpControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: [pumpControlSchedulingPanel(), pumpControlRuntimePanel()]);
  }

  Panel pumpControlSchedulingPanel() {
    const String title = "Scheduling";
    String patientLabel = "";
    if (widget.patientId != null) {
      patientLabel = " - ${widget.patientId}";
    }
    return Panel(
        width: 500.0,
        height: 40,
        text: "$title$patientLabel",
        widget: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MmsFieldLabelText(text: "Programmed"),
                  PumpControlSchedulingWidget(
                    patientId: widget.patientId,
                  ),
                ])));
  }

  Panel pumpControlRuntimePanel() {
    const String title = "Runtime";
    return Panel(
        width: 300.0,
        height: 40,
        text: title,
        widget: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PumpControlRuntimeWidget(
                patientId: widget.patientId,
              ),
            ]));
  }
}
