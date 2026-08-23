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
import 'package:flutter_ui/shared/logging/logger.dart';
import 'mms_control_consumer_tab_widget.dart';

Logger _logger = Logger("MmsControlWidget");

class MmsControlWidget extends StatefulWidget {
  const MmsControlWidget({super.key});

  @override
  State<MmsControlWidget> createState() => _MmsControlWidgetState();
}

class _MmsControlWidgetState extends State<MmsControlWidget> {
  String currentTabId = "federation";

  void setTabById(String tabId) {
    setState(() {
      currentTabId = tabId;
    });
    _logger.log(0, "Set tab ID: $tabId - MmsControlWidget");
  }

  @override
  Widget build(BuildContext context) {
    _logger.log(1, "Build - MmsControlWidget");

    // Simply return the widget without wrapping in a new BlocProvider
    return const MmsControlConsumerTabWidget();
  }
}
