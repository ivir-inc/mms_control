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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';

import '../../data/services/federation_connection_services.dart';
import '../../data/models/federation_connection_models.dart';

class FederationControlPanel extends StatefulWidget {
  final double width;
  final bool includeInitMessage;
  const FederationControlPanel({super.key, 
    this.width = 400,
    this.includeInitMessage = true,
  });

  @override
  _FederationControlPanelState createState() => _FederationControlPanelState();
}

class _FederationControlPanelState extends State<FederationControlPanel> {
  static const _secondsDelay = 3;
  bool _processingAction = false;
  bool _sentAction = false;
  bool _hasActionError = false;
//  MmsFederationActionService actionService = MmsFederationActionService();

  Future<void> postAction(String action) async {
    try {
      setState(() {
        _processingAction = true;
        _sentAction = false;
      });
      // FederationActionData data =
      //     await actionService.postFederationAction(action);
      FederationActionModel data =
          await FederationService().postFederationControlAction(action);
      _hasActionError = data.isError ?? false;
      setState(() {
        _processingAction = false;
        _sentAction = !_hasActionError;
      });
      if (_sentAction) {
        Future.delayed(const Duration(seconds: _secondsDelay), () {
          setState(() {
            _sentAction = false;
          });
        });
      }
    } catch (e) {
      setState(() {
        _processingAction = false;
        _hasActionError = true;
        _sentAction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MmsStylablePanel(
      width: widget.width,
      caption: "Federation Control",
      widget: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              MmsPaddedRaisedButton(
                "Start",
                expanded: true,
                onPressed: (!_processingAction && !_sentAction)
                    ? () {
                        postAction("start");
                      }
                    : null,
              ),
              MmsPaddedRaisedButton(
                "Pause",
                expanded: true,
                onPressed: (!_processingAction && !_sentAction)
                    ? () {
                        postAction("pause");
                      }
                    : null,
              ),
              MmsPaddedRaisedButton(
                "Resume",
                expanded: false,
                onPressed: (!_processingAction && !_sentAction)
                    ? () {
                        postAction("resume ");
                      }
                    : null,
              ),
              MmsPaddedRaisedButton(
                "Stop",
                expanded: true,
                onPressed: (!_processingAction && !_sentAction)
                    ? () {
                        postAction("stop");
                      }
                    : null,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MmsPaddedRaisedButton(
                "Save",
                expanded: false,
                onPressed: (!_processingAction && !_sentAction)
                    ? () {
                        postAction("save");
                      }
                    : null,
              ),
              if (widget.includeInitMessage)
                // Align(
                //   alignment: Alignment.topLeft,
                //   child:
                MmsPaddedRaisedButton(
                  "Send initialize message",
                  onPressed: (!_processingAction && !_sentAction)
                      ? () {
                          postAction("initialize");
                        }
                      : null,
                ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
