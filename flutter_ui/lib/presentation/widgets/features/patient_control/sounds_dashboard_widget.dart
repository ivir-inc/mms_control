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

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/modules/stethoscope/presentation/screens/sounds_control_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/layouts/sized_labeled_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ui/modules/stethoscope/data/services/sounds_services.dart';
import 'package:flutter_ui/modules/stethoscope/data/models/sounds_model.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/presentation/widgets/layouts/sized_labeled_text_row.dart';
import 'package:flutter_ui/presentation/widgets/general/icons/text_and_or_icon.dart';

Logger _logger = Logger("SoundsDashboardWidget");

class SoundsDashboardWidget extends StatefulWidget {
  final String patientId;
  final bool includeScopeSoundLastCheckedWidget;

  const SoundsDashboardWidget({
    required this.patientId,
    this.includeScopeSoundLastCheckedWidget = false,
    super.key,
  });

  @override
  _SoundsDashboardWidgetState createState() => _SoundsDashboardWidgetState();
}

class _SoundsDashboardWidgetState extends State<SoundsDashboardWidget> {
  static const Icon volumeUp = Icon(Icons.volume_up);
  bool _isFetching = false; // Track fetch state to prevent redundant calls

  @override
  void initState() {
    super.initState();
    _fetchSignsData(forceCall: true); // Ensure fresh data is fetched initially
  }

  /// **Detect patient switch and fetch new data**
  @override
  void didUpdateWidget(covariant SoundsDashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      _fetchSignsData(forceCall: true); // Fetch new data when patient changes
    }
  }

  /// **Fetch updated sounds info (Forces API fetch if necessary)**
  void _fetchSignsData({bool forceCall = false}) async {
    if (_isFetching) return; // Prevent duplicate requests
    setState(() => _isFetching = true);

    final soundStore = Provider.of<SoundsInfoStoreAccess>(context, listen: false);
    final existingData = soundStore.store.getSoundsInfo(widget.patientId);

    if (existingData.patientId != null && !forceCall) {
      _logger.log(0, "Using locally stored data for patientId: ${widget.patientId}");
      setState(() => _isFetching = false);
      return;
    }

    _logger.log(0, "Fetching latest signs for patientId: ${widget.patientId}...");

    try {
      final newSignsInfo = await MmsSoundsService().fetchSignsInfo(
        patientId: widget.patientId,
        forceCall: true, // ✅ Explicitly force API fetch
      );
      soundStore.store.updateSoundsInfo(widget.patientId, newSignsInfo);
      _logger.log(0, "Updated UI with fresh API data for patient: ${widget.patientId}");
      if (mounted) setState(() {});
    } catch (error) {
      _logger.log(1, "Error fetching signs for ${widget.patientId}: $error");
    } finally {
      setState(() => _isFetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MmsDismissibleScreen(
            const ValueKey("SoundsControlScreenDismissible"),
            MmsStylablePanel(
              widget: SoundsControlScreen(patientId: widget.patientId),
            ),
            scrollable: true,
          ),
        ));
      },
      child: MmsRoundedBarlessPanel(
        width: 300,
        caption: "Sounds",
        widget: _buildSoundsContent(),
      ),
    );
  }

  /// **Consumer to listen for real-time changes**
  Widget _buildSoundsContent() {
    return Consumer<SoundsInfoStoreAccess>(
      builder: (context, access, _) {
        final soundsInfo = access.store.getSoundsInfo(widget.patientId);

        _logger.log(0, "Rendering Dashboard for patientId: ${widget.patientId}");
        _logger.log(0, "Current Sounds Info: $soundsInfo");

        return Container(
          height: 250,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSoundRow("Heart", soundsInfo.heartSound),
              _buildSoundRow("Lung", soundsInfo.lungSound),
              _buildSoundRow("Bowel", soundsInfo.bowelSound),
              _buildSoundRow("Cough", soundsInfo.coughSound),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundRow(String label, Enum? soundEnum) {
    // Ensure we properly display real backend values
    soundEnum ??= HeartSoundEnum.notApplicable;

    _logger.log(0, "Sound [$label]: ${soundEnum.name}");

    return MmsSizedLabeledTextRow(
      "$label:",
      [
        TextAndOrIcon.icon(volumeUp),
        TextAndOrIcon.text(_getEnumDisplayLabel(soundEnum)),
      ],
      textWidths: const [30, 180],
      labelWidth: 60,
    );
  }

  /// **Helper function to format sound labels in Title Case**
  String _getEnumDisplayLabel(Enum? soundEnum) {
    if (soundEnum == null) return "Not Set";

    final String name = soundEnum.name; // Preserve original casing

    // Special cases
    if (name.toUpperCase() == "NOT_APPLICABLE") return "Not Applicable";
    if (name.toUpperCase() == "NULLSOUND") return "No Sound Detected";
    if (name.toUpperCase() == "N_A") return "Not Available"; // Handle "N_A" case for Cough

    // Convert camel case and underscores to title case words
    return name
        .replaceAll("_", " ") // Convert underscores to spaces
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'), // Insert space before uppercase letters
          (match) => "${match.group(1)} ${match.group(2)}",
        )
        .replaceAllMapped(
          RegExp(r'\b[a-z]'), // Capitalize first letter of each word
          (match) => match.group(0)!.toUpperCase(),
        );
  }

}
