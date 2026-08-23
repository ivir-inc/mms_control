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
import 'package:flutter_ui/data/model/patients/patient.dart';
import 'package:flutter_ui/modules/treatments/presentation/widgets/scenario_holder.dart';
import 'package:flutter_ui/presentation/screens/federation_control_screen.dart';
import 'package:flutter_ui/presentation/screens/patient_control_screen.dart';
import 'package:flutter_ui/presentation/screens/about_screen.dart';
import 'package:flutter_ui/presentation/screens/qr_code_screen.dart';
import 'package:flutter_ui/presentation/screens/settings_control_screen.dart';
import 'package:flutter_ui/modules/aar/presentation/widgets/aar_widget.dart';
import 'package:flutter_ui/modules/onesaf/presentation/screens/one_saf_screen.dart';
import 'package:flutter_ui/presentation/widgets/features/test/test_widgets.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/screens/patient_dashboard_screen.dart';

Logger _logger = Logger("MmsVerticalControlTabsWidget");

class MmsVerticalControlTabsWidget extends StatefulWidget {
  final List<Patient> patientList;
  final TabController tabController;
  final List<Color> bgColors;
  final List<TextStyle> textStyles;
  final List<String> tabIds;
  final bool includeAar;
  final bool includeWsTest;
  final bool includeOnesafTab;
  final bool includePatientDashboard;

  const MmsVerticalControlTabsWidget({
    super.key,
    required this.patientList,
    required this.tabController,
    required this.bgColors,
    required this.textStyles,
    required this.tabIds,
    required this.includeAar,
    required this.includeWsTest,
    required this.includeOnesafTab,
    required this.includePatientDashboard,
  });

  @override
  _MmsVerticalControlTabsWidgetState createState() =>
      _MmsVerticalControlTabsWidgetState();
}

class _MmsVerticalControlTabsWidgetState
    extends State<MmsVerticalControlTabsWidget> {
  late String currentTabId; // Tab to display; derived from the parent's
  // TabController initialIndex so it matches whatever tab (e.g. 'qrCode' vs
  // 'federation' per showOnStartup) the parent decided to start on.
  late Map<String, Widget> screenCache; // Cache for screens
  final ScrollController _sideScroll = ScrollController();

  /// Keep a stable GlobalKey for each patient row so we can scroll into view.
  final Map<String, GlobalKey> _patientItemKeys = {};

  // A very subtle divider used above/below the scroll area
  Divider get _subtleDivider => Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.10),
      );

  @override
  void initState() {
    super.initState();
    currentTabId = widget.tabIds.isNotEmpty
        ? widget.tabIds[widget.tabController.index]
        : 'federation';
    widget.tabController.addListener(_onTabChange);
    _initializeScreenCache();
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChange);
    _sideScroll.dispose();
    super.dispose();
  }

  void _initializeScreenCache() {
    screenCache = {
      if (widget.includeWsTest) 'wsTest': const InsertDataInRouterWidget(),
      if (widget.includeAar) 'aar': const AarTimelineWidget(),
      if (widget.includeOnesafTab)
        'onesaf': OneSAFScreen(
          widget.patientList.isNotEmpty ? widget.patientList[0].id : "",
        ),
      'settings': const SettingsControlScreen(),
      'qrCode': const QrCodeScreen(),
      'about': const AboutScreen(),
    };

    // Add screens for each patient
    for (Patient patient in widget.patientList) {
      screenCache[patient.id] = PatientControlScreen(patientId: patient.id);
    }
  }

  void _ensurePatientScreenCached(String tabId) {
    if (!screenCache.containsKey(tabId)) {
      final patient = widget.patientList.firstWhere(
        (patient) => patient.id == tabId,
        orElse: () => Patient(
          tabId,
          'Unknown',
          PatientSource.unknown,
          false,
        ),
      );
      screenCache[tabId] = PatientControlScreen(patientId: patient.id);
    }
  }

  void _onTabChange() {
    setState(() {
      final int currentTab = widget.tabController.index;
      if (currentTab >= 0 && currentTab < widget.tabIds.length) {
        currentTabId = widget.tabIds[currentTab];
        _logger.log(1, "Switched to tab: $currentTabId");

        // Force refresh the ScenarioHolder for the selected patient
        if (widget.patientList.any((patient) => patient.id == currentTabId)) {
          // _logger.log(
          //     1, "Refreshing ScenarioHolder for patientId: $currentTabId");
          ScenarioHolder.instanceFor(patientId: currentTabId, refresh: true);
        }
      } else {
        widget.tabController.animateTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTabSidebar(),
        Expanded(
          child: Container(
            color: MmsColors.mainBodyBackgroundColor,
            child: _buildTabContent(currentTabId),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(String tabId) {
    if (tabId == 'federation') {
      return FederationControlScreenWidget(
        widget.patientList,
        (patientId) => _selectTabById(patientId),
      );
    }

    if (tabId == 'patientDash') {
      return PatientDashboardScreen(
        widget.patientList,
        (patientId) => _selectTabById(patientId),
        onAddPatientsTap: () => _selectTabById('settings'),
      );
    }

    _ensurePatientScreenCached(tabId);
    return screenCache[tabId] ?? const Center(child: Text("Unknown tab"));
  }

  Widget _buildTabSidebar() {
    return Container(
      color: MmsColors.appBackgroundColor,
      width: 160,
      // No SafeArea so the first item touches the top edge
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed top items (not scrollable)
          _tabItem(context, 'Federation Dashboard', 'federation'),
          if (widget.includePatientDashboard)
            _tabItem(context, 'Patient Dashboard', 'patientDash'),

          _subtleDivider,

          // Scrollable middle section (features + patients)
          Expanded(
            child: ListView(
              controller: _sideScroll,
              padding: EdgeInsets.zero,
              children: _buildScrollableItems(),
            ),
          ),

          _subtleDivider,

          // Fixed bottom items
          _tabItem(context, 'Settings', 'settings'),
          _tabItem(context, 'QR Code', 'qrCode'),
          _tabItem(context, 'About', 'about'),
        ],
      ),
    );
  }

  /// Items that live in the scrollable middle section.
  List<Widget> _buildScrollableItems() {
    final items = <Widget>[
      if (widget.includeWsTest) _tabItem(context, 'WS Test', 'wsTest'),
      if (widget.includeAar) _tabItem(context, 'AAR', 'aar'),
      if (widget.includeOnesafTab) _tabItem(context, 'OneSAF', 'onesaf'),
    ];

    final sortedPatientList = List<Patient>.from(widget.patientList)
      ..sort((a, b) => (a.name.toLowerCase()).compareTo(b.name.toLowerCase()));

    for (final patient in sortedPatientList) {
      final patientName = (patient.physiologySource == PatientSource.external)
          ? '${patient.name}*'
          : patient.name;

      // Ensure a stable key for this patient item
      final key = _patientItemKeys.putIfAbsent(
        patient.id,
        () => GlobalKey(debugLabel: 'patient-${patient.id}'),
      );

      items.add(
        // The key MUST be on a widget that is a direct child of the ListView.
        KeyedSubtree(
          key: key,
          child: _patientTabItem(context, patientName, patient.id),
        ),
      );
    }

    return items;
  }

  Widget _tabItem(BuildContext context, String label, String tabId) {
    final tabIndex = widget.tabIds.indexOf(tabId);

    if (tabIndex == -1) return const SizedBox();

    final bool isActive = currentTabId == tabId;
    final Color backgroundColor = isActive
        ? MmsColors.mainBodyBackgroundColor
        : MmsColors.appBackgroundColor;

    final TextStyle textStyle = isActive
        ? widget.textStyles[tabIndex]
            .copyWith(fontWeight: FontWeight.bold, color: Colors.white)
        : widget.textStyles[tabIndex];

    return InkWell(
      onTap: () => _selectTabById(tabId),
      child: Container(
        width: 160,
        color: backgroundColor,
        padding: const EdgeInsets.all(5),
        child: Text(label, style: textStyle),
      ),
    );
  }

  Widget _patientTabItem(BuildContext context, String label, String tabId) {
    final tabIndex = widget.tabIds.indexOf(tabId);
    if (tabIndex == -1) return const SizedBox();

    final bool isActive = currentTabId == tabId;
    final Color backgroundColor = isActive
        ? MmsColors.mainBodyBackgroundColor
        : MmsColors.appBackgroundColor;
    final TextStyle textStyle = isActive
        ? widget.textStyles[tabIndex]
            .copyWith(fontWeight: FontWeight.bold, color: Colors.white)
        : widget.textStyles[tabIndex];
    final Color iconColor = isActive ? Colors.white : Colors.white38;

    return Stack(
      children: [
        // Text and chevron rendered at full row width
        Container(
          width: 160,
          height: 32,
          color: backgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(label,
                      style: textStyle,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child:
                    Icon(Icons.arrow_forward_ios, size: 13, color: iconColor),
              ),
            ],
          ),
        ),
        // Transparent tap layer covering the right half
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 120,
          child: GestureDetector(
            onTap: () => _selectTabById(tabId),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }

  void _selectTabById(String tabId) {
    final tabIndex = widget.tabIds.indexOf(tabId);
    if (tabIndex != -1) {
      setState(() {
        currentTabId = tabId;
        //_logger.log(1, "Selecting tab by ID: $tabId");

        // Force refresh the ScenarioHolder for the selected patient
        if (widget.patientList.any((patient) => patient.id == tabId)) {
          //_logger.log(1, "Refreshing ScenarioHolder for patientId: $tabId");
          ScenarioHolder.instanceFor(patientId: tabId, refresh: true);
        }

        widget.tabController.animateTo(tabIndex);
      });

      // If the selected tab is a patient, scroll it into view in the sidebar.
      if (_patientItemKeys.containsKey(tabId)) {
        // Wait until this frame lays out, then ensure it's visible.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _patientItemKeys[tabId]!.currentContext;
          if (ctx != null) {
            // alignment ~0.15 keeps the item a bit below the top edge
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: 0.15,
            );
          }
        });
      }
    }
  }
}
