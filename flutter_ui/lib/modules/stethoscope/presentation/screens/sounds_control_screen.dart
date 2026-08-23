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
import 'package:provider/provider.dart';
import 'package:flutter_ui/logic/utils/string_utils.dart';
import 'package:flutter_ui/presentation/widgets/layouts/padded_row.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/padded_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import '../../data/services/sounds_services.dart';
import '../../data/models/sounds_model.dart';

Logger _logger = Logger("SoundsControlScreen");

class SoundsControlScreen extends StatefulWidget {
  final String patientId;

  const SoundsControlScreen({super.key, required this.patientId});

  @override
  _SoundsControlScreenState createState() => _SoundsControlScreenState();
}

class _SoundsControlScreenState extends State<SoundsControlScreen> {
  late SoundsInfo _soundsInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshSounds(); // Auto-fetch sounds on load
  }

  @override
  void didUpdateWidget(covariant SoundsControlScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      _refreshSounds(); // Fetch new data when patientId changes
    }
  }

  /// **Fetch and update Sounds data**
  void _refreshSounds() async {
    setState(() => _isLoading = true); // Show loading state

    try {
      final newSoundsInfo = await MmsSoundsService().fetchSignsInfo(patientId: widget.patientId);
      setState(() {
        _soundsInfo = newSoundsInfo;
        _isLoading = false;
      });
      _logger.log(0, "Refreshed SoundsInfo: $_soundsInfo");
    } catch (e) {
      _logger.log(1, "Error refreshing SoundsInfo: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundsInfoStoreAccess>(
      builder: (context, soundStore, _) {
        return Column(
          children: [
            const SizedBox(height: 16), // Space before dropdowns
            if (_isLoading)
              const Center(child: CircularProgressIndicator()) // Show loading indicator
            else
              soundAssignmentsPanel(context),
          ],
        );
      },
    );
  }

  /// **Sound Assignments Panel**
  Widget soundAssignmentsPanel(BuildContext context) {
    String patientLabel = " - ${StringUtils.humanizedId(widget.patientId)}";

    return Panel(
      width: 400.0,
      height: 350, // Increased height to fit refresh button
      text: "Sound Assignments$patientLabel",
      widget: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          soundAssignmentRow("Heart", "heartSound", _soundsInfo.heartSound, HeartSoundEnum.values),
          soundAssignmentRow("Lung", "lungSound", _soundsInfo.lungSound, LungSoundEnum.values),
          soundAssignmentRow("Bowel", "bowelSound", _soundsInfo.bowelSound, BowelSoundEnum.values),
          soundAssignmentRow("Cough", "coughSound", _soundsInfo.coughSound, CoughSoundEnum.values),
        ],
      ),
    );
  }

  /// **Row for each sound type**
  MmsPaddedRow soundAssignmentRow<T extends Enum>(
      String label, String category, T? selectedEnum, List<T> enumValues) {
    return MmsPaddedRow(
      <Widget>[
        MmsPaddedLabelText("$label Sound:", top: 16.0),
        soundDropdown(category, selectedEnum, enumValues),
      ],
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  /// **Dropdown with mapped enum values**
  Widget soundDropdown<T extends Enum>(String category, T? selectedEnum, List<T> enumValues) {
    return DropdownButton<T>(
      value: selectedEnum ?? enumValues.firstWhere((e) => e.name == "notApplicable"),
      items: enumValues.map((entry) {
        return DropdownMenuItem<T>(
          value: entry,
          child: MmsText(_getEnumDisplayLabel(entry)),
        );
      }).toList(),
      onChanged: (newValue) async {
        if (newValue == null || newValue == selectedEnum) return;

        _logger.log(0, "Changing $category to ${_getEnumDisplayLabel(newValue)}");

        setState(() {
          _soundsInfo = soundsInfoWithUpdate(_soundsInfo, category, newValue);
        });

        await MmsSoundsService().updateSound(widget.patientId, category, _enumToJson(newValue));
      },
    );
  }

  /// **Helper function to safely convert Enum to JSON**
  String? _enumToJson(Enum enumValue) {
    if (enumValue is HeartSoundEnum) return enumValue.toJson();
    if (enumValue is LungSoundEnum) return enumValue.toJson();
    if (enumValue is BowelSoundEnum) return enumValue.toJson();
    if (enumValue is CoughSoundEnum) return enumValue.toJson();
    return enumValue.name;
  }

  /// **Helper function to update SoundsInfo while preserving previous values**
  SoundsInfo soundsInfoWithUpdate(SoundsInfo current, String category, Enum newValue) {
    return SoundsInfo(
      heartSound: category == "heartSound" ? newValue as HeartSoundEnum : current.heartSound,
      lungSound: category == "lungSound" ? newValue as LungSoundEnum : current.lungSound,
      bowelSound: category == "bowelSound" ? newValue as BowelSoundEnum : current.bowelSound,
      coughSound: category == "coughSound" ? newValue as CoughSoundEnum : current.coughSound,
    );
  }

  /// **Helper function to format Enum display names**
  String _getEnumDisplayLabel(Enum? enumValue) {
    if (enumValue == null) return "No Sound Detected";

    final String name = enumValue.name;

    // Special cases
    if (name.toLowerCase() == "notapplicable") return "Not Yet Set";
    if (name.toLowerCase() == "nullsound") return "No Sound Detected";

    return name
        .replaceAll("_", " ") // Convert underscores to spaces
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'), // Insert space before uppercase letters
          (match) => "${match.group(1)} ${match.group(2)}",
        )
        .split(' ') // Split words
        .map((word) => word[0].toUpperCase() + word.substring(1)) // Title case each word
        .join(' '); // Rejoin into a properly formatted string
  }

}
