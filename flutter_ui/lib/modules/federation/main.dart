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
import 'presentation/screens/connectors_screen.dart';
import '../labs/labs_main.dart';
//import 'package:mms_fed_control/top_control_widget.dart';

void main() {
  runApp(MaterialApp(
    title: MainControlScreen.title,
    initialRoute: '/federation',
    routes: {'/federation': (context) => const MainControlScreen(),
    '/labs' : (context) => const LabsMainControlScreen()},
    theme: ThemeData(
      useMaterial3: false,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class MainControlScreen extends StatelessWidget {
  static const String title = 'MMS Control';

  const MainControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(children: [
            Image(image: AssetImage('images/mms_logo_title.png')),
            MmsText('  $title')
          ]),
          backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
          bottom: const TabBar(
            tabs: [MmsText("Connectors"), MmsText("Federation Control")],
          ),
        ),
        drawer: const IvirDrawerWidget(),
        body: const TabBarView(
          children: [
            SingleChildScrollView(
              child: FederationComboScreen(),
            ),
            SingleChildScrollView(
              child: FederationComboScreen(
                includeFederationConnector: false,
                includeConnectors: false,
                includeControls: true,
                includeInitMessage: false,
                includeFederates: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
