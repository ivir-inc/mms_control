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
import 'package:flutter_ui/modules/treatments/presentation/widgets/scenario_holder.dart';
import 'package:flutter_ui/presentation/screens/patient_control_screen.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/icons/text_and_or_icon.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("MmsTabbedWidget");

class MmsTabbedWidget extends StatefulWidget {
  final bool isVerticalTabLayout;
  final bool asScrollableContents;
  final Color tabBackgroundColor;
  final Color selectedTabBackgroundColor;
  final TextStyle tabTextStyle;
  final TextStyle selectedTabTextStyle;
  final List<TextAndOrIcon> tabLabels;
  final List<Widget> tabContents;
  final int initialIndex;

  const MmsTabbedWidget({
    super.key,
    this.isVerticalTabLayout = false,
    this.asScrollableContents = false,
    this.tabBackgroundColor = MmsColors.black,
    this.selectedTabBackgroundColor = MmsColors.dkBlue,
    this.tabTextStyle = const TextStyle(color: MmsColors.white),
    this.selectedTabTextStyle =
        const TextStyle(color: MmsColors.white, fontWeight: FontWeight.bold),
    required this.tabLabels,
    required this.tabContents,
    this.initialIndex = 0,
  });

  @override
  MmsTabbedWidgetState createState() => MmsTabbedWidgetState();
}

class MmsTabbedWidgetState extends State<MmsTabbedWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(
        vsync: this,
        length: widget.tabLabels.length,
        initialIndex: widget.initialIndex);
    _tabController.addListener(() {
      setTabState(_tabController.index);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabLabels.length != widget.tabContents.length) {
      throw Exception(
          "Number of tab labels (${widget.tabLabels.length}) must match number of tab contents (${widget.tabContents.length})");
    }
    return LayoutBuilder(builder: (context, constraints) {
      double screenHeight = MediaQuery.of(context).size.height;
      double screenWidth = MediaQuery.of(context).size.width;
      return SizedBox(
        width: constraints.maxWidth == double.infinity
            ? screenWidth * 0.9
            : constraints.maxWidth,
        height: constraints.maxHeight == double.infinity
            ? screenHeight - 110
            : constraints.maxHeight,
        child: widget.isVerticalTabLayout
            ? _verticalTabControlWidget()
            : _horizontalTabControlWidget(),
      );
    });
  }

  Widget _verticalTabControlWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: widget.tabBackgroundColor,
          child: Column(
            children: tabItems(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: tabScreens(),
          ),
        )
      ],
    );
  }

  Widget _horizontalTabControlWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: widget.tabBackgroundColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: tabItems(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: tabScreens(),
          ),
        )
      ],
    );
  }

  List<Widget> tabItems() {
    List<Widget> items = <Widget>[];
    for (int i = 0; i < widget.tabLabels.length; ++i) {
      items.add(tabItem(
        widget.tabLabels[i].text,
        i,
        iconEntry: widget.tabLabels[i].icon,
      ));
    }
    return items;
  }

  List<Widget> tabScreens() {
    if (!widget.asScrollableContents) {
      return List<Widget>.generate(widget.tabContents.length, (index) {
        return KeyedSubtree(
          key: ValueKey('tab_${widget.tabLabels[index].text}_${index}'),
          child: widget.tabContents[index],
        );
      });
    }

    List<Widget> tabScreens = <Widget>[];
    for (int i = 0; i < widget.tabContents.length; i++) {
      tabScreens.add(SingleChildScrollView(
        key: ValueKey('scrollable_tab_${widget.tabLabels[i].text}_${i}'),
        child: widget.tabContents[i],
      ));
    }
    return tabScreens;
  }

  Widget tabItem(
    String? label,
    int? tabIndex, {
    Icon? iconEntry,
  }) {
    Widget labelWidget = Container(
      decoration: BoxDecoration(
          color: _selectedIndex == tabIndex
              ? widget.selectedTabBackgroundColor
              : widget.tabBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
      width: 120,
      padding: const EdgeInsets.all(5),
      child: Center(
        child: MmsText(label,
            iconEntry: iconEntry,
            style: _selectedIndex == tabIndex
                ? widget.selectedTabTextStyle
                : widget.tabTextStyle),
      ),
    );
    return InkWell(
        child: labelWidget,
        onTap: () {
          selectTab(tabIndex!);
        });
  }

  void setTabState(int tabIndex) {
    setState(() {
      _selectedIndex = tabIndex;
      _logger.log(1, "Tab selected: ${widget.tabLabels[tabIndex].text}");

      // Refresh the current tab's content
      if (widget.tabContents[tabIndex] is PatientControlScreen) {
        final patientId = widget.tabLabels[tabIndex].text;
        _logger.log(
            1, "Refreshing PatientControlScreen for patientId: $patientId");
        ScenarioHolder.instanceFor(patientId: patientId!, refresh: true);
      }
    });
  }

  void selectTab(int tabIndex) {
    setTabState(tabIndex);
    _tabController.animateTo(tabIndex);
  }
}
