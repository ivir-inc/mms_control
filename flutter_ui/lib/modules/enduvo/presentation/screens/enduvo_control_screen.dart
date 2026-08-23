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
import '../widgets/enduvo_widgets.dart';

class EnduvoControlScreen extends StatefulWidget {
  final String? patientId;
  const EnduvoControlScreen({super.key, this.patientId});

  @override
  _EnduvoControlScreenState createState() => _EnduvoControlScreenState();
}

class _EnduvoControlScreenState extends State<EnduvoControlScreen> {
  @override
  Widget build(BuildContext context) {
    return controlPanel();
  }

  Widget controlPanel() {
    String patientLabel = "";
    if (widget.patientId != null) {
      patientLabel = " - ${widget.patientId}";
    }
    final String title = "Control$patientLabel";
    return Wrap(
      children: [
        Panel(
            width: 600.0,
            height: 40,
            text: title,
            widget: EnduvoSettingsWidget(
              patientId: widget.patientId,
            ))
      ],
    );
  }
}
