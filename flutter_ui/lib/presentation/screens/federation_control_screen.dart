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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/config/app_config.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/logic/utils/connector_status.dart';
import 'package:flutter_ui/modules/treatments/presentation/widgets/scenario_holder.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:provider/provider.dart';
import '../theme/common_colors.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/modules/federation/data/models/federation_connection_models.dart';
import 'package:flutter_ui/modules/federation/data/services/federation_connection_services.dart';
import 'package:flutter_ui/modules/federation/presentation/widgets/recent_events_widgets.dart';
import 'package:flutter_ui/modules/treatments/presentation/widgets/scenario_dropdown.dart';

Logger _logger = Logger("Federation Control Screen");

class FederationControlScreenWidget extends StatefulWidget {
  final List<Patient> patientList;
  final Function(String) onPatientTap; // Updated to String for patientId

  const FederationControlScreenWidget(this.patientList, this.onPatientTap,
      {super.key});

  @override
  FederationControlScreenWidgetState createState() =>
      FederationControlScreenWidgetState();
}

class FederationControlScreenWidgetState
    extends State<FederationControlScreenWidget> {
  @override
  void initState() {
    super.initState();
    FederationService().requireRecurringFederationFetch();

    // Pre-fetch scenario data for all patients
    for (Patient patient in widget.patientList) {
      ScenarioHolder.instanceFor(patientId: patient.id).initialize();
    }
  }

  @override
  void dispose() {
    FederationService().releaseRecurringFederationFetch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeAccess = FederationInfoStoreAccess(); // ONE instance

    return _buildInner(context, storeAccess);
  }

  Widget _buildInner(
      BuildContext context, FederationInfoStoreAccess storeAccess) {
    bool includeRecentEvents = AppConfig().includeRecentEvents;
    final double viewportHeight = MediaQuery.of(context).size.height;
    const double offsetFromTop = 63; // Account for app bar, top padding, etc.
    const double outerPadding = 13;
    const double interPanelSpacing = outerPadding - 2;

    final double availablePanelHeight =
        viewportHeight - offsetFromTop - outerPadding;

    const double connectorHeight = 257; // Subtract extra to prevent overflow
    const double chromeAllowance =
        14; // caption + vertical padding + fudge factor
    final double controlPanelHeight =
        availablePanelHeight - connectorHeight - chromeAllowance;

    return Container(
      color: MmsColors.mainBodyBackgroundColor,
      padding: const EdgeInsets.all(outerPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT COLUMN: Connector + Control
          SizedBox(
            width: 200,
            height: availablePanelHeight,
            child: Column(
              children: [
                FederationConnectorPanel(FederationService(), width: 200),
                const SizedBox(height: interPanelSpacing),
                Expanded(
                  child: Selector<FederationInfoStoreAccess, ConnectorStatus?>(
                    selector: (_, store) => ConnectorStatus.ofType(
                      store.federationInfo.comboModel?.federationConnectionModel
                          .status,
                    ),
                    builder: (context, status, _) {
                      return FederationControlPanel(
                        width: 200,
                        verticalLayout: true,
                        includeInitMessage: false,
                        fixedHeight: controlPanelHeight,
                        connectorStatus: status,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: interPanelSpacing),

          // MIDDLE COLUMN: Federates List
          SizedBox(
            width: 200,
            height: availablePanelHeight,
            child: const FederatesListPanel(width: double.infinity),
          ),

          const SizedBox(width: interPanelSpacing),

          // RIGHT COLUMN: Recent Events (takes up remaining space)
          if (includeRecentEvents)
            Expanded(
              child: SizedBox(
                height: availablePanelHeight,
                child: const RecentEventsPanel(),
              ),
            ),
          const FederationStatusWatcher(),
        ],
      ),
    );
  }

  Widget multiPatientsSection({
    required BuildContext context,
    required BoxConstraints constraints,
  }) {
    _logger.log(100, "Building multiPatients Section");

    return BlocBuilder<PatientManagementBloc, PatientManagementState>(
      builder: (context, state) {
        if (state.patients.isEmpty) {
          return const Center(child: MmsText("No patients available."));
        }

        // Filter only visible patients
        List<Patient> visiblePatients = state.patients
            .where((patient) => state.patientVisibility[patient.id] ?? false)
            .toList();

        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent:
                220, // Ensures a reasonable maximum width for each card
            crossAxisSpacing: 12, // Spacing between cards horizontally
            mainAxisSpacing: 12, // Spacing between cards vertically
            childAspectRatio:
                1.5, // Adjusts the width-to-height ratio for a better fit
          ),
          itemCount: visiblePatients.length,
          itemBuilder: (context, index) {
            final patient = visiblePatients[index];
            return getPatientContainer(
              context,
              patient.id,
              patient,
            );
          },
        );
      },
    );
  }

  Widget getPatientContainer(
    BuildContext context,
    String patientId,
    Patient patientInfo,
  ) {
    return PatientSummaryWidget(
      patientId, // Pass patient ID here
      patientInfo,
      widget.onPatientTap, // Use the updated function
    );
  }
}

class PatientSummaryWidget extends StatefulWidget {
  final String patientId;
  final Patient patientInfo;
  final Function(String) onPatientTap;

  const PatientSummaryWidget(
      this.patientId, this.patientInfo, this.onPatientTap,
      {super.key});

  @override
  PatientSummaryWidgetState createState() => PatientSummaryWidgetState();
}

class PatientSummaryWidgetState extends State<PatientSummaryWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 180, // Set a consistent minimum width
        maxWidth: 200, // Set a consistent maximum width
        minHeight: 100, // Minimum height for the card
        maxHeight: 120, // Maximum height for the card
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MmsColors.mdkGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          patientItem(
            context,
            widget.patientInfo.id,
            widget.patientId,
            hasBorder: false,
            isBold: true,
            onPatientTap: widget.onPatientTap,
          ),
          // const SizedBox(height: 4),
          // patientItem(
          //   context,
          //   widget.patientInfo.name,
          //   widget.patientId,
          //   onPatientTap: widget.onPatientTap,
          // ),
          const SizedBox(height: 4),
          patientItem(
            context,
            "",
            widget.patientId,
            widgetOverridingText: MmsScenarioSelectionLabel(
              patientId: widget.patientInfo.id,
              textStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.normal,
              ),
            ),
            onPatientTap: widget.onPatientTap,
          ),
        ],
      ),
    );
  }
}

Widget patientItem(
  BuildContext context,
  String? itemText,
  String patientId, {
  bool hasBorder = true,
  bool isBold = false,
  Color bg = Colors.white,
  Widget? widgetOverridingText,
  required Function(String) onPatientTap,
}) {
  return InkWell(
    onTap: () {
      onPatientTap(patientId); // Use patientId instead of index
    },
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        border: hasBorder ? Border.all(color: MmsColors.mdkGrey) : null,
      ),
      child: widgetOverridingText ??
          MmsText(
            itemText ?? "",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
    ),
  );
}

class FederationConnectorPanel extends StatefulWidget {
  final FederationService service;
  final double width;

  const FederationConnectorPanel(this.service, {super.key, this.width = 400});

  @override
  _FederationConnectorPanelState createState() =>
      _FederationConnectorPanelState();
}

class _FederationConnectorPanelState extends State<FederationConnectorPanel> {
  bool _isConnecting = false;

  void _handleConnect() {
    setState(() => _isConnecting = true);

    widget.service.postFederationConnectionRequest("join", callback: () {
      setState(() => _isConnecting = false);
    });
  }

  void _handleDisconnect() {
    widget.service.postFederationConnectionRequest("resign");
  }

  @override
  Widget build(BuildContext context) {
    return Selector<FederationInfoStoreAccess, FederationConnectionModel?>(
      selector: (_, store) =>
          store.federationInfo.comboModel?.federationConnectionModel,
      shouldRebuild: (prev, next) => prev != next,
      builder: (context, connectionData, _) {
        final status = ConnectorStatus.ofType(connectionData?.status);
        final stateColor =
            status?.stateColor ?? ConnectorStatus.disconnected.stateColor;

        final isConnected = status == ConnectorStatus.connected;
        final isDisconnected = status == ConnectorStatus.disconnected;
        final isError = status == ConnectorStatus.error;

        // Reset _isConnecting when status becomes connected
        if (_isConnecting && isConnected) {
          _isConnecting = false;
        }

        final buttonText = _isConnecting
            ? "Connecting..."
            : (isDisconnected || isError)
                ? "Connect"
                : "Disconnect";

        final isDisabled = _isConnecting || isError;

        return MmsRoundedBarlessPanel(
          width: widget.width,
          caption: "Federation Connector",
          widget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const MmsFieldLabelText(text: "Federate Name:"),
                MmsText(connectionData?.federateName ?? "<Unavailable>"),
                const SizedBox(height: 12),
                const MmsFieldLabelText(text: "Federation Name:"),
                MmsText(connectionData?.federationName ?? "<Unavailable>"),
                const SizedBox(height: 8),
                const MmsFieldLabelText(text: 'Status:'),
                MmsText(
                  status?.statusLabel ?? "Unknown",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: stateColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: MmsPaddedRaisedButton(
                    buttonText,
                    onPressed: isDisabled
                        ? null
                        : isDisconnected
                            ? _handleConnect
                            : _handleDisconnect,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FederationControlPanel extends StatefulWidget {
  final double width;
  final double? fixedHeight;
  final bool includeInitMessage;
  final bool verticalLayout;
  final ConnectorStatus? connectorStatus;

  const FederationControlPanel({
    super.key,
    this.width = 400,
    this.fixedHeight,
    this.includeInitMessage = true,
    this.verticalLayout = false,
    this.connectorStatus,
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

  bool get isConnected => widget.connectorStatus == ConnectorStatus.connected;

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
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ctrlBtn("Start", "start"),
        _ctrlBtn("Pause", "pause"),
        _ctrlBtn("Resume", "resume"),
        _ctrlBtn("Stop", "stop"),
        _ctrlBtn("Save", "save"),
        if (widget.includeInitMessage) _ctrlBtn("Init", "initialize"),
      ],
    );

    return MmsRoundedBarlessPanel(
      width: widget.width,
      height: widget.fixedHeight,
      caption: "Federation Control",
      widget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: content,
      ),
    );
  }

  // one helper so every button looks identical
  Widget _ctrlBtn(String label, String action) {
    final isDisabled = !isConnected || _processingAction || _sentAction;

    return MmsPaddedRaisedButton(
      label,
      expanded: false,
      left: 2,
      right: 2,
      top: 2,
      bottom: 2,
      onPressed: isDisabled ? null : () => postAction(action),
    );
  }
}

class FederatesListPanel extends StatefulWidget {
  final double width;
  const FederatesListPanel({super.key, this.width = 250});

  @override
  State<FederatesListPanel> createState() => _FederatesListPanelState();
}

class _FederatesListPanelState extends State<FederatesListPanel> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<FederationInfoStoreAccess, List<String>>(
      selector: (context, access) {
        final model = access.federatesModel;
        if (model.isError || model.federates.isEmpty) {
          return [];
        }
        // Filter out "<Unavailable>"
        return model.federates.where((f) => f != "<Unavailable>").toList();
      },
      shouldRebuild: (prev, next) => !const ListEquality().equals(prev, next),
      builder: (context, federates, _) {
        final isEmpty = federates.isEmpty;

        return MmsRoundedBarlessPanel(
          width: widget.width,
          caption: "Federates List (${federates.length})",
          widget: isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: MmsText(
                      "No valid federates available.",
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    itemCount: federates.length,
                    itemBuilder: (context, index) {
                      final name = federates[index];
                      final isEven = index.isEven;
                      return Container(
                        color: isEven ? Colors.grey[200] : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Center(
                          child: MmsText(
                            name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}

class FederationStatusWatcher extends StatefulWidget {
  const FederationStatusWatcher({super.key});

  @override
  State<FederationStatusWatcher> createState() =>
      _FederationStatusWatcherState();
}

// Make it global to persist across builds
ConnectorStatus? _lastKnownFederationStatus;

class _FederationStatusWatcherState extends State<FederationStatusWatcher> {
  @override
  Widget build(BuildContext context) {
    return Selector<FederationInfoStoreAccess, ConnectorStatus?>(
      selector: (_, store) => store.federationConnectionStatus,
      builder: (context, currentStatus, _) {
        if (currentStatus != _lastKnownFederationStatus) {
          if (currentStatus == ConnectorStatus.connected) {
            FederationService().requireRecurringFederatesFetch();
          } else if (currentStatus == ConnectorStatus.disconnected) {
            FederationService().releaseRecurringFederatesFetch();
          }

          _lastKnownFederationStatus = currentStatus;
        }

        return const SizedBox.shrink(); // No visible UI
      },
    );
  }
}
