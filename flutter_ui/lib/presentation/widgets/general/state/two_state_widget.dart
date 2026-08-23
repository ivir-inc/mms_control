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
import 'package:flutter_ui/data/services/two_state_service.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/state/two_state_value_holder.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class MmsTwoStateWidget extends StatefulWidget {
  final String stateKey;
  final MmsTwoStateService service;
  final String activeLabel;
  final String inactiveLabel;
  final Icon? activeIcon;
  final Icon? inactiveIcon;
  final Icon? errorIcon;
  final bool initValueByService;
  final MmsTwoStateValueHolder? valueHolder;
  final bool hasError;
  const MmsTwoStateWidget(this.service,
      {super.key,
      this.stateKey = 'state',
      this.activeLabel = 'Active',
      this.inactiveLabel = 'Inactive',
      this.activeIcon,
      this.inactiveIcon,
      this.errorIcon,
      this.initValueByService = true,
      this.hasError = false,
      this.valueHolder});

  @override
  _MmsTwoStateWidgetState createState() => _MmsTwoStateWidgetState();
}

class _MmsTwoStateWidgetState extends State<MmsTwoStateWidget> {
  Future<MmsTwoStateServiceData>? futureStatus;
  bool hasError = false;
  late MmsTwoStateValueHolder valueHolder;

  _MmsTwoStateWidgetState();

  @override
  void initState() {
    super.initState();
    valueHolder = widget.valueHolder ?? MmsTwoStateValueHolder();
    hasError = widget.hasError;
    if (widget.initValueByService) {
      futureStatus =
          widget.service.fetchState(currentState: valueHolder.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MmsTwoStateServiceData>(
        future: futureStatus,
        builder: (context, AsyncSnapshot<MmsTwoStateServiceData> snapshot) {
          if (snapshot.hasData) {
            valueHolder.state =
                snapshot.data?.state ?? valueHolder.state;
            hasError = snapshot.data?.error ?? false;
          }
          String onOffString = widget.inactiveLabel;
          Icon? onOffIcon = widget.inactiveIcon;
          Color onOffColor = MmsColors.black;
          if (valueHolder.state) {
            onOffString = widget.activeLabel;
            onOffIcon = widget.activeIcon;
            onOffColor = MmsColors.green;
          }
          if (hasError) {
            onOffString = 'Error';
            onOffIcon = widget.errorIcon;
            onOffColor = MmsColors.red;
          }
          return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                    value: valueHolder.state,
                    onChanged: (value) {
                      setState(() {
                        futureStatus = widget.service.postState(value);
                      });
                    }),
                MmsText(onOffString,
                    iconEntry: onOffIcon,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onOffColor,
                        fontSize: 14))
              ]);
        });
  }
}
