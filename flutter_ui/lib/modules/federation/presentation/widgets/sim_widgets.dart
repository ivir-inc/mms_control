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

import 'package:flutter_ui/logic/utils/string_utils.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/numbers/number_slider_widgets.dart';
import 'package:flutter_ui/presentation/widgets/general/numbers/simple_number_display_widget.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/federation_connection_models.dart';
import '../../data/services/federation_connection_services.dart';
import '../../data/models/sim_model.dart';
import '../../data/services/sim_services.dart';

class SpeedFactorControlWidget extends SimpleNumberDisplayWidget {
  final String id;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;

  // Remove maxLines, units, and fractionDigits fields here, as they are already part of the parent class.
  const SpeedFactorControlWidget(
    this.id, {
    super.key,
    this.textStyle,
    this.textAlign,
    this.textOverflow,
    required super.maxLines, // Now using the parameter directly for the parent class.
    required String super.units,
    required super.fractionDigits,
  });

  @override
  _SpeedFactorControlWidgetState createState() =>
      _SpeedFactorControlWidgetState();

  @override
  double value() {
    SimDateTimeModel? model = SimDateTimeModelStore().simDateTimeModel(
      "", // Currently, we aren't using an id with DateTime data
    );
    return model?.rate.toDouble() ?? 1;
  }
}

class _SpeedFactorControlWidgetState extends State<SpeedFactorControlWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SimDateTimeModelStoreAccess>(
        create: (_) => SimDateTimeModelStoreAccess(),
        builder: (context, _) {
          return Selector<SimDateTimeModelStoreAccess, SimDateTimeModel>(
            builder: (context, model, _) {
              return MmsText(
                widget.displayString(),
                textAlign: widget.textAlign,
                style: widget.textStyle,
                overflow: widget.textOverflow,
                maxLines: widget.maxLines,
              );
            },
            selector: (buildContext, access) {
              return access.store.simDateTimeModel(
                    widget.id,
                  ) ??
                  SimDateTimeModel.errModel;
            },
            shouldRebuild: (prev, next) => prev.rate != next.rate,
          );
        });
  }
}

class SpeedFactorEditableTappableWidget extends StatefulWidget {
  final SpeedFactorControlWidget tapWidget;
  const SpeedFactorEditableTappableWidget(this.tapWidget, {super.key});

  @override
  _SpeedFactorEditableTappableWidgetState createState() =>
      _SpeedFactorEditableTappableWidgetState();
}

class _SpeedFactorEditableTappableWidgetState
    extends State<SpeedFactorEditableTappableWidget> {
  late int _submitValue;

  @override
  void initState() {
    super.initState();
    _submitValue = widget.tapWidget.value().round();
  }

  void onChanged(double newValue) {
//    setState(() {
    _submitValue = newValue.round();
//    });
  }

  void onSubmit() {
    MmsSimService().postClockRate(_submitValue);
  }

  @override
  Widget build(BuildContext context) {
    return NumberSliderEditableTappableWidget(
      widget.tapWidget,
      min: 1,
      max: 50,
      onChanged: onChanged,
      onSubmit: onSubmit,
      submitLabel: "Submit",
      cancelLabel: "Cancel",
      caption: "Edit Sim Speed Factor",
      panelBgColor: MmsColors.white,
    );
  }
}

class SpeedFactorComboWidget extends StatefulWidget {
  final String id;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final int maxLines;
  final String units;
  final int fractionDigits;
  const SpeedFactorComboWidget(
    this.id, {
    super.key,
    this.textStyle,
    this.textAlign,
    this.textOverflow,
    required this.maxLines,
    required this.units,
    required this.fractionDigits,
  });

  @override
  _SpeedFactorComboWidgetState createState() => _SpeedFactorComboWidgetState();
}

class _SpeedFactorComboWidgetState extends State<SpeedFactorComboWidget> {
  @override
  Widget build(BuildContext context) {
    return SpeedFactorEditableTappableWidget(SpeedFactorControlWidget(
      widget.id,
      textStyle: widget.textStyle,
      textAlign: widget.textAlign,
      textOverflow: widget.textOverflow,
      maxLines: widget.maxLines,
      units: widget.units,
      fractionDigits: widget.fractionDigits,
    ));
  }
}

class ScenarioEngineActionWidget extends StatefulWidget {
  final String patientId;
  final String? label;
  final String action;
  final String? federationPatientAction;
  final Icon? labelIcon;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;
  final FocusNode? focusNode;
  final bool? autofocus;
  final Clip? clipBehavior;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final bool? expanded;
  const ScenarioEngineActionWidget({
    super.key,
    required this.action,
    required this.patientId,
    this.federationPatientAction,
    this.label,
    this.labelIcon,
    this.textStyle,
    this.buttonStyle,
    this.focusNode,
    this.autofocus,
    this.clipBehavior = Clip.none,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.expanded,
  });

  @override
  _ScenarioEngineActionWidgetState createState() =>
      _ScenarioEngineActionWidgetState();
}

class _ScenarioEngineActionWidgetState
    extends State<ScenarioEngineActionWidget> {
  Future<bool> submitScenarioAndFederationActions(
    String patientId, {
    String? action,
    String? federationPatientAction,
  }) async {
    bool success = true;
    if (action != null) {
      success = await MmsSimService().postSimScenEngControl(
        widget.action,
        patientId: widget.patientId,
      );
    }
    if (success && federationPatientAction != null) {
      FederationActionModel model =
          await FederationService().postFederationControlAction(
        federationPatientAction,
        patientId: patientId,
      );
      bool isError = model.isError ?? false;
      success = !isError;
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    String useLabel = widget.label ?? StringUtils.humanizedId(widget.action);
    return MmsPaddedRaisedButton(
      useLabel,
      onPressed: () {
        submitScenarioAndFederationActions(
          widget.patientId,
          action: widget.action,
          federationPatientAction: widget.federationPatientAction,
        );
      },
      labelIcon: widget.labelIcon,
      textStyle: widget.textStyle,
      buttonStyle: widget.buttonStyle,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus ?? false,
      clipBehavior: widget.clipBehavior ?? Clip.none,
      left: widget.left ?? 10.0,
      top: widget.top ?? 10.0,
      right: widget.right ?? 10.0,
      bottom: widget.bottom ?? 10.0,
      expanded: widget.expanded ?? false,
    );
  }
}
