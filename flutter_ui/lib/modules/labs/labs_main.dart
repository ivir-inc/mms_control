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
import 'package:flutter_ui/presentation/widgets/general/drawers/ivir_drawer_widget.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
// import 'package:stethoscope/sounds_control_screen.dart';
// import 'package:webui_labs/configuration_screen.dart';
// import 'package:webui_labs/vitals_screen.dart';
// import 'package:webui_labs/labs_screen.dart';

class LabsMainControlScreen extends StatelessWidget {
  const LabsMainControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4, //5,
        child: Scaffold(
            appBar: AppBar(
              title: const Row(children: [
                Image(
                    image: AssetImage('images/mms_logo_title.png',
                        package: 'common')),
                Text('  Vitals, Sounds, Labs  ')
              ]),
              backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
              bottom: const TabBar(
                tabs: [
//                  MmsText("Admin"),
                  MmsText("Configuration"),
                  MmsText("Vitals"),
                  MmsText("Sounds"),
                  MmsText("Labs")
                ],
              ),
            ),
            drawer: const IvirDrawerWidget(),
            body: const TabBarView(children: <Widget>[
//              SingleChildScrollView(child: AdminScreen()),
              // SingleChildScrollView(child: ConfigurationScreen()),
              // SingleChildScrollView(child: VitalsScreen()),
              // SingleChildScrollView(child: SoundsControlScreen()),
              // SingleChildScrollView(child: LabsScreen()),
            ])));
  }
} //of MyHomePage
