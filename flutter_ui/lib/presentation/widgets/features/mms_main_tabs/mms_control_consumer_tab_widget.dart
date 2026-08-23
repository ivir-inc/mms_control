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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/provider/networking/common_ws.dart';
import 'package:flutter_ui/modules/federation/data/models/federation_connection_models.dart';
import 'package:flutter_ui/presentation/widgets/features/mms_main_tabs/mms_vertical_control_tabs_widget.dart';
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/services/unstructured_data_stores.dart';
import 'package:flutter_ui/config.dart';
import 'package:flutter_ui/logic/qr_code/qr_code_bloc.dart';
import 'package:provider/provider.dart';

Logger _logger = Logger("MmsControlConsumerTabWidget");

class MmsControlConsumerTabWidget extends StatefulWidget {
  const MmsControlConsumerTabWidget({super.key});

  @override
  _MmsControlConsumerTabWidgetState createState() =>
      _MmsControlConsumerTabWidgetState();
}

class _MmsControlConsumerTabWidgetState
    extends State<MmsControlConsumerTabWidget> with TickerProviderStateMixin {
  TabController? _tabController;
  String currentTabId = 'federation';
  List<String> tabIds = [];
  List<Patient> visiblePatients = [];
  bool includeAar = false;
  bool includeWsTest = false;
  bool includeOnesafTab = false;
  bool includePatientDashboard = false;

  StreamSubscription<Patient>? _wsPatientSubscription;
  late PatientManagementBloc _patientBloc;
  static bool _subscribedToWs = false;
  bool _initializedStartupTab = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _patientBloc is cached early here using didChangeDependencies() to
    // avoid 'Looking up a deactivated widget's ancestor is unsafe' Dart
    // error
    _patientBloc = context.read<PatientManagementBloc>();

    // Decide the initial tab once: QR Code if "Show on startup" is checked,
    // Federation Dashboard otherwise. Guarded so later dependency changes
    // don't override a tab the user has since navigated to.
    if (!_initializedStartupTab) {
      _initializedStartupTab = true;
      final showOnStartup = context.read<QrCodeBloc>().state.showOnStartup;
      currentTabId = showOnStartup ? 'qrCode' : 'federation';
    }
  }

  @override
  void initState() {
    super.initState();

    includeAar = PrimitivesStore().boolData(Config.aarParm, Config.appWideKey);
    includeWsTest =
        PrimitivesStore().boolData(Config.wsTestTabParm, Config.appWideKey);
    // Hidden until updated for federation (COM-6)
    // includeOnesafTab = PrimitivesStore().boolData(Config.onesafParm, Config.appWideKey);

    includePatientDashboard = PrimitivesStore()
        .boolData(Config.patientDashboardParm, Config.appWideKey);

    if (!_subscribedToWs) {
      _subscribedToWs = true;
      _wsPatientSubscription =
          MmsWsClient().patientStream.listen((Patient newPatient) {
        _logger.logDebug(
            1, "Received new patient over WebSocket: ${newPatient.name}");
        _patientBloc.add(
          PatientManagementEvent(
              PatientManagementAction.addPatient, [newPatient],
              locallyCreated: false),
        );
      });
    }
  }

  @override
  void dispose() {
    _wsPatientSubscription?.cancel();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientManagementBloc, PatientManagementState>(
      builder: (context, patientManagementState) {
        // Fetch visible patients based on the local visibility map
        visiblePatients = _getVisiblePatients(
          patientManagementState.patients,
          patientManagementState.patientVisibility,
        );

        // Set up tab IDs
        tabIds = [
          'federation',
          if (includePatientDashboard) 'patientDash',
          ...visiblePatients.map((patient) => patient.id),
          if (includeWsTest) 'wsTest',
          'settings',
          'qrCode',
          'about',
        ];

        // Preserve the currentTabId if it is valid in the new set of tabIds
        if (!tabIds.contains(currentTabId)) {
          currentTabId =
              'settings'; // Default to 'settings' if the current tab is removed
        }

        // Refresh the tab controller if the number of tabs changes
        if (_tabController == null || _tabController!.length != tabIds.length) {
          _refreshTabController();
        }

        return _buildTabController();
      },
    );
  }

  // Helper to get visible patients based on local visibility state
  List<Patient> _getVisiblePatients(
      List<Patient> patients, Map<String, bool> visibilityMap) {
    return patients
        .where((patient) => visibilityMap[patient.id] ?? true)
        .toList();
  }

  // Refresh the TabController when necessary
  void _refreshTabController() {
    _tabController
        ?.dispose(); // Dispose the old controller to prevent memory leaks

    _tabController = TabController(
      vsync: this,
      length: tabIds.length,
      initialIndex: tabIds.indexOf(currentTabId),
    );

    _tabController!.addListener(() {
      setState(() {
        currentTabId = tabIds[_tabController!.index]; // Track the active tab ID
      });
    });
  }

  Widget _buildTabController() {
    return ChangeNotifierProvider(
      create: (_) => FederationInfoStoreAccess(),
      child: MmsVerticalControlTabsWidget(
        patientList: visiblePatients,
        tabController: _tabController!,
        tabIds: tabIds,
        includeAar: includeAar,
        includeWsTest: includeWsTest,
        includeOnesafTab: includeOnesafTab,
        includePatientDashboard: includePatientDashboard,
        bgColors: List.generate(tabIds.length, (_) => Colors.blueGrey),
        textStyles: List.generate(
            tabIds.length, (_) => const TextStyle(color: Colors.white)),
      ),
    );
  }
}
