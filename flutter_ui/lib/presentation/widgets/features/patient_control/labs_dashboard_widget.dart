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
import 'package:flutter_ui/presentation/widgets/layouts/sized_labeled_text_row.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/modules/labs/data/models/labs_model.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/modules/labs/data/services/labs_rest_services.dart';
import 'package:flutter_ui/modules/labs/presentation/screens/labs_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/icons/text_and_or_icon.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("LabsDashboardWidget");

class LabsDashboardWidget extends StatefulWidget {
  final String patientId;

  const LabsDashboardWidget({required this.patientId, super.key});

  @override
  _LabsDashboardWidgetState createState() => _LabsDashboardWidgetState();
}

class _LabsDashboardWidgetState extends State<LabsDashboardWidget> {
  late MmsLabsExecutionService _labsService;

  @override
  void initState() {
    super.initState();
    _initializeLabsService();
  }

  void _initializeLabsService() {
    _labsService = MmsLabsExecutionService();
    try {
      _labsService.requireRecurringLabsExecutionFetch(
        widget.patientId,
        callback: () {
          // Handle the callback for recurring labs fetch
        },
      );
    } catch (e) {
      _logger.log(1, 'Error initializing labs service: $e');
    }
  }

  @override
  void dispose() {
    // Clean up the service when the widget is disposed
    try {
      _labsService.releaseRecurringLabsExecutionFetch(widget.patientId);
    } catch (e) {
      _logger.log(1, 'Error disposing labs service: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MmsDismissibleScreen(
            const ValueKey("LabsScreenDismissible"),
            LabsScreen(patientId: widget.patientId),
            scrollable: true,
          ),
        ));
      },
      child: MmsRoundedBarlessPanel(
        width: 300,
        height: 192,
        caption: "Labs",
        widget: _buildLabsContent(),
      ),
    );
  }

  Widget _buildLabsContent() {
    const List<double> textWidths = [60, 100];
    const double labelWidth = 100;
    const EdgeInsetsGeometry labelPadding = EdgeInsets.fromLTRB(10, 2, 5, 0);
    const EdgeInsetsGeometry textPadding = EdgeInsets.fromLTRB(5, 2, 10, 0);
    const double divHeight = 4;
    const double divThickness = 2;
    const double rowHeight = 20;

    return ChangeNotifierProvider<LabCardDataSetStoreAccess>(
      create: (_) => LabCardDataSetStoreAccess(),
      builder: (context, _) {
        return Selector<LabCardDataSetStoreAccess, LabCardDataSet>(
          builder: (context, labCardDataSet, _) {
            bool hasHcg = labCardDataSet.hcgLabCardData.type == LabCardType.hcg;
            bool hcgOnTablet =
                hasHcg && (labCardDataSet.hcgLabCardData.onTablet);
            List<String> hcgStats = [
              hasHcg ? "Yes" : "No",
              hcgOnTablet ? "Yes" : "No",
            ];

            bool hasEldon =
                labCardDataSet.eldonLabCardData.type == LabCardType.eldon;
            bool eldonOnTablet =
                hasEldon && (labCardDataSet.eldonLabCardData.onTablet);
            List<String> eldonStats = [
              hasEldon ? "Yes" : "No",
              eldonOnTablet ? "Yes" : "No",
            ];

            int numBloodAvail = 0,
                numBloodOnTablet = 0,
                numUriAvail = 0,
                numUriOnTablet = 0;
            for (var card in labCardDataSet.bloodLabCardArray) {
              if (card.type == LabCardType.blood) {
                ++numBloodAvail;
              }
              if (card.onTablet) {
                ++numBloodOnTablet;
              }
            }
            List<String> bloodStats = [
              "$numBloodAvail",
              "$numBloodOnTablet",
            ];

            for (var card in labCardDataSet.urinalysisLabCardArray) {
              if (card.type == LabCardType.urinalysis) {
                ++numUriAvail;
              }
              if (card.onTablet) {
                ++numUriOnTablet;
              }
            }
            List<String> uriStats = [
              "$numUriAvail",
              "$numUriOnTablet",
            ];

            return Column(
              children: [
                MmsSizedLabeledTextRow(
                  "",
                  TextAndOrIcon.convertTextList(["Avail", "On Tablet"]),
                  allHeaders: true,
                  textWidths: textWidths,
                  labelWidth: labelWidth,
                  labelPadding: labelPadding,
                  textPadding: textPadding,
                  height: 25,
                ),
                MmsSizedLabeledTextRow(
                  "HCG:",
                  TextAndOrIcon.convertTextList(hcgStats),
                  textWidths: textWidths,
                  labelWidth: labelWidth,
                  labelPadding: labelPadding,
                  textPadding: textPadding,
                  height: rowHeight,
                ),
                const Divider(
                  height: divHeight,
                  thickness: divThickness,
                  color: MmsColors.mdGrey,
                ),
                MmsSizedLabeledTextRow(
                  "Eldon Card:",
                  TextAndOrIcon.convertTextList(eldonStats),
                  textWidths: textWidths,
                  labelWidth: labelWidth,
                  labelPadding: labelPadding,
                  textPadding: textPadding,
                  height: rowHeight,
                ),
                const Divider(
                  height: divHeight,
                  thickness: divThickness,
                  color: MmsColors.mdGrey,
                ),
                MmsSizedLabeledTextRow(
                  "Blood:",
                  TextAndOrIcon.convertTextList(bloodStats),
                  textWidths: textWidths,
                  labelWidth: labelWidth,
                  labelPadding: labelPadding,
                  textPadding: textPadding,
                  height: rowHeight,
                ),
                const Divider(
                  height: divHeight,
                  thickness: divThickness,
                  color: MmsColors.mdGrey,
                ),
                MmsSizedLabeledTextRow(
                  "Urinalysis:",
                  TextAndOrIcon.convertTextList(uriStats),
                  textWidths: textWidths,
                  labelWidth: labelWidth,
                  labelPadding: labelPadding,
                  textPadding: textPadding,
                  height: rowHeight,
                ),
              ],
            );
          },
          selector: (_, access) =>
              access.store.getLabCardDataSet(widget.patientId),
          shouldRebuild: (LabCardDataSet prev, LabCardDataSet next) =>
              prev != next,
        );
      },
    );
  }
}
