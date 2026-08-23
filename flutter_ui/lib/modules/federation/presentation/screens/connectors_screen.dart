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
import 'package:flutter_ui/presentation/widgets/layouts/labeled_value.dart';
import 'package:flutter_ui/presentation/widgets/layouts/labeled_values_columns.dart';
import 'package:flutter_ui/presentation/widgets/layouts/padded_row.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/logic/utils/connector_status.dart';
import 'package:provider/provider.dart';

import '../widgets/connector_widgets.dart';
import '../widgets/control_panel.dart';
import '../../data/models/federation_connection_models.dart';
import '../../data/services/federation_connection_services.dart';

class FederationComboScreen extends StatefulWidget {
  final bool includeFederationConnector;
  final bool includeConnectors;
  final bool includeControls;
  final bool includeFederates;
  final bool includeInitMessage;

  const FederationComboScreen({
    super.key,
    this.includeFederationConnector = true,
    this.includeConnectors = true,
    this.includeControls = false,
    this.includeFederates = false,
    this.includeInitMessage = true,
  });

  @override
  _FederationComboScreenState createState() => _FederationComboScreenState();
}

class _FederationComboScreenState extends State<FederationComboScreen> {
  FederationService service = FederationService();
  Future<FederationComboModel>? futureComboData;

  @override
  void initState() {
    super.initState();
    if (widget.includeConnectors || widget.includeFederationConnector) {
      service.requireRecurringFederationFetch();
    }
    if (widget.includeFederates) {
      service.requireRecurringFederatesFetch();
    }
  }

  @override
  void dispose() {
    if (widget.includeConnectors || widget.includeFederationConnector) {
      service.releaseRecurringFederationFetch();
    }
    if (widget.includeFederates) {
      service.releaseRecurringFederatesFetch();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FederationInfoStoreAccess>(
        create: (_) => FederationInfoStoreAccess(),
        builder: (context, _) {
          return Selector<FederationInfoStoreAccess, FederationInfo>(
            builder: (context, model, _) {
              return Table(
                columnWidths: const {
                  0: FixedColumnWidth(420.0),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(children: [
                    Wrap(children: [
                      if (widget.includeFederationConnector)
                        FederationConnectorPanel(
                          service,
                          width: 400,
                        ),
                      if (widget.includeControls)
                        FederationControlPanel(
                          width: 400,
                          includeInitMessage: widget.includeInitMessage,
                        ),
                      if (widget.includeFederates)
                        const FederationFederatesPanel(
                          width: 400,
                        ),
                    ]),
                    if (widget.includeConnectors) const ConnectorsContainer(),
                  ])
                ],
              );
            },
            selector: (buildContext, store) {
              return store.federationInfo;
            },
            shouldRebuild: (FederationInfo prev, FederationInfo next) =>
                prev != next,
          );
        });
  }
}

class FederationConnectorPanel extends StatefulWidget {
  final FederationService service;
  final double width;
  const FederationConnectorPanel(
    this.service, {
    super.key,
    this.width = 400,
  });

  @override
  _FederationConnectorPanelState createState() =>
      _FederationConnectorPanelState();
}

class _FederationConnectorPanelState extends State<FederationConnectorPanel> {
  FederationConnectionModel? _connectionData;
  ConnectorStatus? connectorStatus;

  @override
  void initState() {
    super.initState();
    // Moved initialization logic here
    _connectionData = FederationInfoStore().federationConnectionModel;
    connectorStatus = ConnectorStatus.ofType(_connectionData?.status);
  }

  @override
  Widget build(BuildContext context) {
    try {
      Color stateColor = connectorStatus?.stateColor ??
          ConnectorStatus.disconnected.stateColor;
      return MmsStylablePanel(
          width: widget.width,
          caption: "Federation Connector",
          widget: Column(children: [
            MmsLabeledValuesColumn(
              [
                MmsStyledLabelValue("Federate Name:",
                    _connectionData?.federateName ?? "<Unavailable>"),
                MmsStyledLabelValue("Federation Name:",
                    _connectionData?.federationName ?? "<Unavailable>"),
              ],
            ),
            MmsPaddedRow(
              [
                const MmsFieldLabelText(
                  text: 'Status: ',
                ),
                MmsText(
                  connectorStatus?.statusLabel ??
                      ConnectorStatus.disconnected.statusLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: stateColor,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.light_mode,
                  color: stateColor,
                  size: 20,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
              bottom: 0.0,
            ),
            MmsPaddedRaisedButton(
              (connectorStatus ?? ConnectorStatus.disconnected) ==
                      ConnectorStatus.disconnected
                  ? "Connect"
                  : "Disconnect",
              onPressed: (connectorStatus ?? ConnectorStatus.disconnected) ==
                      ConnectorStatus.disconnected
                  ? () {
                      widget.service.postFederationConnectionRequest("join");
                    }
                  : () {
                      widget.service.postFederationConnectionRequest("resign");
                    },
            )
          ]));
    } catch (e) {
      return const SizedBox(width: 400, height: 250);
    }
  }
}

class FederationFederatesPanel extends StatefulWidget {
  final double width;
  const FederationFederatesPanel({
    super.key,
    this.width = 250,
  });

  @override
  _FederationFederatesPanelState createState() =>
      _FederationFederatesPanelState();
}

class _FederationFederatesPanelState extends State<FederationFederatesPanel> {
  @override
  Widget build(BuildContext context) {
    FederatesModel federatesModel = FederationInfoStore().federatesModel;
    try {
      List<String> federates;
      if ((federatesModel.isError) || (federatesModel.federates.isEmpty)) {
        federates = ["<Unavailable>"];
      } else {
        federates = federatesModel.federates;
      }
      return MmsStylablePanel(
        width: widget.width,
        caption: "Federates List",
        widget: MmsDoublePaddedValuesColumn(
          federates,
        ),
      );
    } catch (e) {
      return const SizedBox(width: 200, height: 250);
    }
  }
}

class ConnectorsContainer extends StatelessWidget {
  const ConnectorsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      TruMonitorConnectionWidget(),
      EnduvoConnectionWidget(),
      SimScopeConnectionWidget(),
      PumpControlConnectionWidget()
    ]);
  }
}
