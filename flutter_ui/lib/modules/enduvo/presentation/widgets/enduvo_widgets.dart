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
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/text/padded_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/sized_labeled_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:provider/provider.dart';

import '../../data/services/enduvo_services.dart';
import '../../data/models/enduvo_model.dart';

class EnduvoSettingsWidget extends StatefulWidget {
  final String? patientId;

  const EnduvoSettingsWidget({super.key, this.patientId});

  @override
  EnduvoSettingsWidgetState createState() => EnduvoSettingsWidgetState();
}

class EnduvoSettingsWidgetState extends State<EnduvoSettingsWidget> {
  late Timer _checkTimer;
  late Future<bool> _futureDoer;
  late MmsEnduvoService _service;
  late Settings _settings;
  late SelectedSetting _selectedSetting;
  bool processing = false;

  Future<bool> initSettings() async {
    try {
      _service = MmsEnduvoService();
      _settings = await _service.fetchSettings(patientId: widget.patientId);
      _selectedSetting =
          await _service.fetchSelectedSetting(patientId: widget.patientId);
      return true;
    } catch (e) {
      throw Exception("Error attempting to initialize Enduvo settings");
    }
  }

  void fetchSelectedSetting() async {
    if (processing) return;
    processing = true;
    try {
      SelectedSetting newSelectedSetting =
          await _service.fetchSelectedSetting(patientId: widget.patientId);
      setSelectedSetting(newSelectedSetting, true);
    } catch (e) {
      processing = false;
    }
  }

  void setSelectedSetting(
      SelectedSetting newSelectedSetting, bool isProcessing) {
    if (mounted) {
      setState(() {
        _selectedSetting = newSelectedSetting;
        processing = isProcessing;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _futureDoer = initSettings();
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (time) {
      fetchSelectedSetting();
    });
  }

  @override
  void dispose() {
    _checkTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _futureDoer,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        try {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Align(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: MmsText("Unable to Connect...")));
          }
          return buildSettingsWidget();
        } catch (e) {
          return Align(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: MmsText("Unable to Connect... $e")));
        }
      },
    );
  }

  Widget buildSettingsWidget() {
    if (_settings.settings.isEmpty) {
      return const Align(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: MmsText("Unable to Connect...")));
    }
    List<Widget> widgets = [];
    for (var element in _settings.settings) {
      widgets.add(MmsPaddedLabelText(element.setName));
      List<Widget> buttons = [];
      for (var elem in element.settingOptions) {
        bool isSelected = selected(element.setName, elem.id);
        ButtonStyle buttonStyle = isSelected
            ? ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.lightGreen))
            : ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue));
        buttons.add(MmsPaddedRaisedButton(
          elem.label,
          buttonStyle: buttonStyle,
          onPressed: () {
            postSelectedService(element.setName, elem.id, elem.label);
          },
        ));
      }
      widgets.add(Wrap(
        children: buttons,
      ));
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets);
  }

  void postSelectedService(String setName, int id, String label) async {
    SelectedSetting newSelectedSetting = await _service
        .postSelectedSetting(setName, id, label, patientId: widget.patientId);
    setSelectedSetting(newSelectedSetting, processing);
  }

  bool selected(String setName, int id) {
    return _selectedSetting.setName == setName &&
        _selectedSetting.selection?.id == id;
  }
}

class EnduvoSelectedSettingDisplayWidget extends StatefulWidget {
  final String patientId;
  const EnduvoSelectedSettingDisplayWidget(this.patientId, {super.key});

  @override
  EnduvoSelectedSettingDisplayWidgetState createState() =>
      EnduvoSelectedSettingDisplayWidgetState();
}

class EnduvoSelectedSettingDisplayWidgetState
    extends State<EnduvoSelectedSettingDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return patientAugmentedRealityWidget(widget.patientId);
  }

  Widget patientAugmentedRealityWidget(String patientId) {
    return ChangeNotifierProvider<SelectedSettingStoreAccess>(
      create: (_) => SelectedSettingStoreAccess(),
      builder: (context, _) {
        return Selector<SelectedSettingStoreAccess, SelectedSetting>(
          builder: (context, selectedSetting, _) {
            return SizedBox(
              width: 300, // Ensure total width stays within 300px
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MmsSizedLabeledText(
                    "Disease:",
                    selectedSetting.setName ?? "Unavailable",
                    labelWidth: 80,
                    textFgColor: MmsColors.black,
                  ),
                  MmsSizedLabeledText(
                    "State:",
                    selectedSetting.selection?.label ?? "Unavailable",
                    labelWidth: 80,
                    textFgColor: MmsColors.black,
                  ),
                ],
              ),
            );
          },
          selector: (buildContext, store) =>
              store.getSelectedSetting(patientId) ??
              const SelectedSetting(null, null, null),
          shouldRebuild: (SelectedSetting prev, SelectedSetting next) =>
              prev != next,
        );
      },
    );
  }
}
