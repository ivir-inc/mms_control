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

import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/layouts/padded_row.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/logic/utils/connector_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/federation_connection_models.dart';
import '../../data/services/federation_connection_services.dart';

class DeviceConnectorWidget extends StatefulWidget {
  final DeviceConnectionServices service;
  final String label;
  final String connectionName;
  final double width;
  const DeviceConnectorWidget(
    this.service,
    this.label,
    this.connectionName, {
    super.key,
    this.width = 250,
  });

  @override
  _DeviceConnectorWidgetState createState() => _DeviceConnectorWidgetState();
}

class _DeviceConnectorWidgetState extends State<DeviceConnectorWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FederationInfoStoreAccess>(
      create: (_) => FederationInfoStoreAccess(),
      builder: (context, _) {
        return Selector<FederationInfoStoreAccess, ConnectorConnectionModel>(
          builder: (context, conModel, _) {
            return deviceConnectorPanel(conModel);
          },
          selector: (buildContext, store) {
            return store.connectorConnectionModel(widget.connectionName);
          },
          shouldRebuild:
              (ConnectorConnectionModel prev, ConnectorConnectionModel next) =>
                  prev != next,
        );
      },
    );
  }

  Widget deviceConnectorPanel(ConnectorConnectionModel conModel) {
    return MmsStylablePanel(
        caption: widget.label,
        width: widget.width,
        widget: Column(children: [
          MmsPaddedRow(
            [
              const MmsFieldLabelText(text: 'Host: '),
              MmsText(conModel.host ?? '<Unavailable>'),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            bottom: 0.0,
          ),
          MmsPaddedRow(
            [const MmsFieldLabelText(text: 'Port: '), MmsText(conModel.port)],
            mainAxisAlignment: MainAxisAlignment.start,
            bottom: 0.0,
          ),
          connectText(conModel),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 130,
              height: 50,
              child: connectButton(
                  conModel.connectorStatus ?? ConnectorStatus.error),
            ),
          )
        ]));
  }

  Widget connectText(ConnectorConnectionModel conModel) {
    ConnectorStatus? connStatus =
        ConnectorStatus.ofType(conModel.status, def: ConnectorStatus.error);
    return createConnectTextWidget(
        connStatus!.statusLabel, connStatus.stateColor);
  }

  Widget createConnectTextWidget(String connText, Color? iconColor) {
    return MmsPaddedRow(
      [
        const MmsFieldLabelText(
          text: 'Status: ',
        ),
        MmsText(
          '$connText  ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: iconColor,
            fontSize: 14,
          ),
        ),
        Icon(
          Icons.light_mode,
          color: iconColor,
          size: 20,
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.start,
      bottom: 0.0,
    );
  } // createConnectTextWidget

  Widget connectButton(ConnectorStatus conStatus) {
    if (conStatus.isConnected || conStatus.isIdle || conStatus.isPending) {
      return MmsPaddedRaisedButton(
        "Disconnect",
        onPressed: () {
          widget.service.postDeviceDisconnectRequest();
        },
      );
    } else if (conStatus.isDisconnected || conStatus.isError) {
      return MmsPaddedRaisedButton("Connect", onPressed: () {
        widget.service.postDeviceConnectRequest();
      });
    } else {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      );
    }
  }
}

class TruMonitorConnectionWidget extends DeviceConnectorWidget {
  static const String title = "- TruMonitor Connector -";
  TruMonitorConnectionWidget({super.key})
      : super(TruMonitorConnectionService(), title,
            FederationComboModel.truMonitorName);
}

class EnduvoConnectionWidget extends DeviceConnectorWidget {
  static const String title = "- Enduvo Connector -";
  EnduvoConnectionWidget({super.key})
      : super(
            EnduvoConnectionService(), title, FederationComboModel.enduvoName);
}

class SimScopeConnectionWidget extends DeviceConnectorWidget {
  static const String title = "- SimScope Connector -";
  SimScopeConnectionWidget({super.key})
      : super(SimScopeConnectionService(), title,
            FederationComboModel.simScopeName);
}

class PumpControlConnectionWidget extends DeviceConnectorWidget {
  static const String title = "- Pump Control Connector -";
  PumpControlConnectionWidget({super.key})
      : super(PumpControlConnectionService(), title,
            FederationComboModel.pumpControlName);
}
