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
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import '../widgets/two_state_widgets.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  _ConnectionScreenState();

  @override
  Widget build(BuildContext context) {
    return const Wrap(children: [
      Panel(
        width: 300,
        height: 40,
        text: "HLA Configuration",
        widget: Padding(
          padding: EdgeInsets.all(2),
          child: StethoscopeConfigWidget(),
        ),
      )
    ]);
  }
}

class StethoscopeConfigWidget extends StatefulWidget {
  const StethoscopeConfigWidget({super.key});

  @override
  _StethoscopeConfigWidgetState createState() =>
      _StethoscopeConfigWidgetState();
}

class _StethoscopeConfigWidgetState extends State<StethoscopeConfigWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const MmsText('HLA Listeners:  ',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
      Table(
          columnWidths: const {
            0: FixedColumnWidth(110),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            StethoscopeTableRow(),
          ]),
    ]);
  } // build
}
