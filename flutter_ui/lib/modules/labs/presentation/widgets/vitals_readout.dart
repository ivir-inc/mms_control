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

import 'package:flutter_ui/data/model/vitals/vitals_model.dart';
import 'package:flutter_ui/logic/utils/string_utils.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/layouts/padded_column.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ui/data/services/vitals_rest_service.dart';
import 'dart:math';

class VitalsReadoutWidget extends StatelessWidget {
  final String? patientId;
  final double fontSize;
  final TextAlign textAlign;
  final TextOverflow textOverflow;
  final bool isHorizontal;
  final int maxLines;
  final bool includeShadowBox;
  final Color shadowBoxBgColor;
  final Color outerBoxBgColor;
  final Color? textMonoColor;
  final double outerBoxPadding;
  final double? width;
  final double? height;

  const VitalsReadoutWidget(
    this.patientId, {
    super.key,
    this.fontSize = 20,
    this.width,
    this.height,
    this.textAlign = TextAlign.center,
    this.textOverflow = TextOverflow.clip,
    this.isHorizontal = false,
    this.maxLines = 1,
    this.includeShadowBox = true,
    this.shadowBoxBgColor = MmsColors.black,
    this.outerBoxBgColor = MmsColors.white,
    this.textMonoColor,
    this.outerBoxPadding = 10,
  });

  @override
  Widget build(BuildContext context) {
    Color divColor = textMonoColor ?? MmsColors.ltGrey;

    List<Widget> children = [
      patientVitalsDashboardItem(
        EkgSimpleVitalsDisplayWidget(
          patientId ?? "",
          maxlines: maxLines,
          textAlign: textAlign,
          textOverflow: textOverflow,
          textStyle: TextStyle(
            fontSize: fontSize,
            color: textMonoColor ?? MmsColors.green,
          ),
        ),
      ),
      if (!isHorizontal) Divider(height: 3, color: divColor),
      patientVitalsDashboardItem(
        BpSimpleVitalsDisplayWidget(
          patientId ?? "",
          maxlines: maxLines,
          textStyle: TextStyle(
            fontSize: fontSize,
            color: textMonoColor ?? MmsColors.red,
          ),
        ),
      ),
      if (!isHorizontal) Divider(height: 3, color: divColor),
      patientVitalsDashboardItem(
        Spo2SimpleVitalsDisplayWidget(
          patientId ?? "",
          maxlines: maxLines,
          textAlign: textAlign,
          textOverflow: textOverflow,
          textStyle: TextStyle(
            fontSize: fontSize,
            color: textMonoColor ?? MmsColors.yellow,
          ),
        ),
      ),
      if (!isHorizontal) Divider(height: 3, color: divColor),
      patientVitalsDashboardItem(
        RrSimpleVitalsDisplayWidget(
          patientId ?? "",
          maxlines: maxLines,
          textAlign: textAlign,
          textOverflow: textOverflow,
          textStyle: TextStyle(
            fontSize: fontSize,
            color: textMonoColor ?? MmsColors.aqua,
          ),
        ),
      ),
      if (!isHorizontal) Divider(height: 3, color: divColor),
      patientVitalsDashboardItem(
        TempSimpleVitalsDisplayWidget(
          patientId ?? "",
          maxlines: maxLines,
          textAlign: textAlign,
          textOverflow: textOverflow,
          textStyle: TextStyle(
            fontSize: fontSize,
            color: textMonoColor ?? MmsColors.ltPurple,
          ),
        ),
      ),
      if (!isHorizontal) Divider(height: 3, color: divColor),
      patientVitalsDashboardItem(
        Etco2SimpleVitalsDisplayWidget(
          patientId ?? "",
          maxlines: maxLines,
          textAlign: textAlign,
          textOverflow: textOverflow,
          textStyle: TextStyle(
            fontSize: fontSize,
            color: textMonoColor ?? MmsColors.white,
          ),
        ),
      ),
    ];

    Widget displayWidget = isHorizontal
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          )
        : Column(
            children: children,
          );

    Widget innerWidget = !includeShadowBox
        ? displayWidget
        : Container(
            decoration: BoxDecoration(
              color: shadowBoxBgColor,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: const [
                BoxShadow(
                  color: MmsColors.translucentWhite,
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: displayWidget,
          );

    return SingleChildScrollView(
      child: SizedBox(
        height: height ?? 260, // Enforce a finite height for the vitals readout
        child: Container(
          color: outerBoxBgColor,
          padding: EdgeInsets.all(outerBoxPadding),
          width: width,
          child: innerWidget,
        ),
      ),
    );
  }

  Widget patientVitalsDashboardItem(Widget vitalsWidget) {
    return Container(
      padding: const EdgeInsets.all(6.8),
      child: vitalsWidget,
    );
  }
}

abstract class SimpleVitalsDisplayWidget extends StatefulWidget {
  final String patientId;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final int maxLines;

  /// Tooltip to show for this vitals value. Return null for no tooltip.
  String? tooltip(VitalsValues vitals) => null;

  const SimpleVitalsDisplayWidget(
    this.patientId, {
    super.key,
    this.textStyle,
    this.textAlign,
    this.textOverflow,
    this.maxLines = 0,
  });

  /// Might receive a null argument, in which case null can be returned.
  double? value(VitalsValues vitals);

  bool isCompoundLabel();

  /// Might receive a null argument, in which case null can be returned.
  /// If isCompoundLabel returns false, value2 will not be called.
  double? value2(VitalsValues vitals);

  /// Return null or empty string if no units.
  /// Non-empty units are only shown at the end of label, even if compound.
  String units();

  /// How many digits of value and value2 are to be displayed?
  int fractionDigits();

  /// Default minimum value, can be overridden by subclasses.
  double min() => double.negativeInfinity;

  /// Default maximum value, can be overridden by subclasses.
  double max() => double.infinity;

  String label(VitalsValues vitals) {
    return isCompoundLabel()
        ? vitalsCompoundLabel(vitals)
        : vitalsLabel(
            value(vitals),
            units(),
            fractionDigits(),
            maxLines,
          );
  }

  String vitalsCompoundLabel(VitalsValues vitals) {
    String vitalsLabel1 = vitalsLabel(
      value(vitals),
      null,
      fractionDigits(),
      1,
    );
    String vitalsLabel2 = vitalsLabel(
      value2(vitals),
      units(),
      fractionDigits(),
      maxLines,
    );
    String sep = maxLines > 2 ? "\n" : "";
    return "$vitalsLabel1$sep/$vitalsLabel2";
  }

  static String vitalsLabel(
    double? value,
    String? units,
    int fractionDigits,
    int maxLines,
  ) {
    String vitalsLabel = value?.toStringAsFixed(fractionDigits) ?? "--";
    String sep = (maxLines > 1) ? "\n" : " ";
    String unitsPortion = (units == null || units.isEmpty) ? "" : "$sep$units";

    // Always append units if provided
    return "$vitalsLabel$unitsPortion";
  }

  @override
  _SimpleVitalsDisplayWidgetState createState() =>
      _SimpleVitalsDisplayWidgetState();
}

class _SimpleVitalsDisplayWidgetState extends State<SimpleVitalsDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return Selector<VitalsValuesStoreAccess, VitalsValues>(
      selector: (context, access) =>
          access.store.getVitalsValues(widget.patientId),
      shouldRebuild: (prev, next) {
        final valueChanged = widget.value(prev) != widget.value(next);
        final value2Changed = widget.isCompoundLabel() &&
            (widget.value2(prev) != widget.value2(next));

        final tooltipChanged = widget.tooltip(prev) != widget.tooltip(next);
        final labelChanged = widget.label(prev) != widget.label(next);

        return valueChanged || value2Changed || tooltipChanged || labelChanged;
      },
      builder: (context, vitals, _) {
        final double? v1 = widget.value(vitals);
        final double? v2 =
            widget.isCompoundLabel() ? widget.value2(vitals) : null;

        bool isOutOfRange(double? v) =>
            v != null && (v < widget.min() || v > widget.max());

        // Only show the red error if we have real numbers that are out of range.
        if (isOutOfRange(v1) ||
            (widget.isCompoundLabel() && isOutOfRange(v2))) {
          return MmsText(
            "Missing or Out Of Range Data",
            textAlign: widget.textAlign,
            style: widget.textStyle?.copyWith(color: Colors.red),
            overflow: widget.textOverflow,
            maxLines: widget.maxLines,
          );
        }

        // Otherwise let label() render; it will show "--" for nulls.
        final tip = widget.tooltip(vitals);
        final labelText = widget.label(vitals);

        // The centered label
        final label = MmsText(
          labelText,
          textAlign: widget.textAlign,
          style: widget.textStyle,
          overflow: widget.textOverflow,
          maxLines: widget.maxLines,
        );

        // Force the stack to take full row width so the icon can hug the right edge.
        final stacked = SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Centered value text
              Align(alignment: Alignment.center, child: label),

              // Right-aligned info icon (only if we have a tooltip)
              if (tip != null && tip.isNotEmpty)
                Positioned(
                  right: 0,
                  child: Tooltip(
                    message: tip,
                    waitDuration: const Duration(milliseconds: 250),
                    showDuration: const Duration(seconds: 3),
                    child: Icon(
                      Icons.info_outline, // or Icons.info for stronger contrast
                      size: (widget.textStyle?.fontSize ?? 20) * 0.8,
                      color: widget.textStyle?.color ?? Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );

        // Accessibility: expose the tip (if any) to screen readers.
        return Semantics(
          label: tip ?? '',
          child: stacked,
        );
      },
    );
  }
}

class EkgSimpleVitalsDisplayWidget extends SimpleVitalsDisplayWidget {
  const EkgSimpleVitalsDisplayWidget(
    super.patientId, {
    super.key,
    super.textStyle,
    super.textAlign,
    super.textOverflow,
    int maxlines = 0,
  }) : super(
          maxLines: maxlines,
        );

  @override
  double? value(VitalsValues vitals) => vitals.ekg;

  @override
  String units() => "bpm";

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundLabel() => false;

  @override
  double? value2(VitalsValues vitals) => null;
}

class BpSimpleVitalsDisplayWidget extends SimpleVitalsDisplayWidget {
  const BpSimpleVitalsDisplayWidget(
    super.patientId, {
    super.key,
    super.textStyle,
    super.textAlign,
    TextOverflow super.textOverflow = TextOverflow.clip,
    int maxlines = 0,
  }) : super(
          maxLines: maxlines,
        );

  @override
  double? value(VitalsValues vitals) => vitals.bpHi; // Display high before low.

  @override
  String units() => "mmHg";

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundLabel() => true;

  @override
  double? value2(VitalsValues vitals) => vitals.bpLo;
}

class Spo2SimpleVitalsDisplayWidget extends SimpleVitalsDisplayWidget {
  const Spo2SimpleVitalsDisplayWidget(
    super.patientId, {
    super.key,
    super.textStyle,
    super.textAlign,
    TextOverflow super.textOverflow = TextOverflow.clip,
    int maxlines = 0,
  }) : super(maxLines: maxlines);

  @override
  double? value(VitalsValues vitals) => vitals.spo2ForDisplay;

  @override
  String units() => "%";

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundLabel() => false;

  @override
  double? value2(VitalsValues vitals) => null;

  @override
  String? tooltip(VitalsValues vitals) {
    if (vitals.spo2LikelyFraction) {
      final raw = vitals.spo2; // e.g., 0.97
      if (raw != null) {
        return "Converted from ${raw.toStringAsFixed(2)}"; // concise, like temp
      }
      return "Converted from fraction";
    }
    return null;
  }
}

class Etco2SimpleVitalsDisplayWidget extends SimpleVitalsDisplayWidget {
  const Etco2SimpleVitalsDisplayWidget(
    super.patientId, {
    super.key,
    super.textStyle,
    super.textAlign,
    TextOverflow super.textOverflow = TextOverflow.clip,
    int maxlines = 0,
  }) : super(
          maxLines: maxlines,
        );

  @override
  double? value(VitalsValues vitals) => vitals.etco2;

  @override
  String units() => "mmHg";

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundLabel() => false;

  @override
  double? value2(VitalsValues vitals) => null;
}

class RrSimpleVitalsDisplayWidget extends SimpleVitalsDisplayWidget {
  const RrSimpleVitalsDisplayWidget(
    super.patientId, {
    super.key,
    super.textStyle,
    super.textAlign,
    TextOverflow super.textOverflow = TextOverflow.clip,
    int maxlines = 0,
  }) : super(
          maxLines: maxlines,
        );

  @override
  double? value(VitalsValues vitals) => vitals.rr;

  @override
  String units() => "rpm";

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundLabel() => false;

  @override
  double? value2(VitalsValues vitals) => null;
}

class TempSimpleVitalsDisplayWidget extends SimpleVitalsDisplayWidget {
  const TempSimpleVitalsDisplayWidget(
    super.patientId, {
    super.key,
    super.textStyle,
    super.textAlign,
    TextOverflow super.textOverflow = TextOverflow.clip,
    int maxlines = 0,
  }) : super(maxLines: maxlines);

  @override
  double? value(VitalsValues vitals) => vitals.tempFahrenheitForDisplay;

  @override
  String units() => "F";

  @override
  int fractionDigits() => 1;

  @override
  bool isCompoundLabel() => false;

  @override
  double? value2(VitalsValues vitals) => null;

  @override
  String? tooltip(VitalsValues vitals) {
    if (vitals.tempLikelyCelsius) {
      final rawC = vitals.temp;
      final f = vitals.tempFahrenheitForDisplay;
      if (rawC != null && f != null) {
        return "Converted from ${rawC.toStringAsFixed(1)} °C";
      }
      return "Converted from Celsius";
    }
    return null; // no tooltip if not converted
  }
}

abstract class SimpleVitalsEditorWidget extends StatefulWidget {
  final String labelPrefix;
  final String patientId;
  final Widget? tapWidget;
  final String vital1Label;
  final String vital2Label;
  final bool includeSubmitButton;
  final bool includeCancelButton;
  final Function(double)? onChange;
  final Function(RangeValues)? onRangeChange;
  final double fontSize;
  const SimpleVitalsEditorWidget(
    this.patientId,
    this.labelPrefix,
    this.vital1Label,
    this.tapWidget, {
    super.key,
    this.vital2Label = "",
    this.includeSubmitButton = true,
    this.includeCancelButton = true,
    this.onChange,
    this.onRangeChange,
    this.fontSize = 20,
  });

  bool isCompoundValue();
  double? value();
  double? value2();
  String units();
  int fractionDigits();
  double min();
  double? min2();
  double max();
  double? max2();

  @override
  _SimpleVitalsEditorWidgetState createState() =>
      _SimpleVitalsEditorWidgetState();
}

class _SimpleVitalsEditorWidgetState extends State<SimpleVitalsEditorWidget> {
  double? _submissionValue;
  RangeValues? _submissionRange;

  Future<bool> submitEditedVital() async {
    return VitalsServices().submitEditedVital(
      widget.patientId,
      widget.vital1Label,
      _submissionValue,
      isCompoundValue: widget.isCompoundValue(),
      range: _submissionRange,
      currentRangeMax: widget.value2(),
      vitalsType2: widget.vital2Label,
    );
  }

  @override
  Widget build(BuildContext context) {
    String humanizedPatientId = StringUtils.humanizedId(widget.patientId);
    Widget sliderWidget = !widget.isCompoundValue()
        ? SimpleVitalsSliderWidget(
            widget.min(),
            widget.max(),
            widget.value(),
            (value) {
              setState(() {
                _submissionValue = value;
              });
              widget.onChange?.call(value);
            },
            fractionDigits: widget.fractionDigits(),
            units: widget.units(),
            includeSubmitButton: widget.includeSubmitButton,
            includeCancelButton: widget.includeCancelButton,
            onSubmit: submitEditedVital,
            fontSize: widget.fontSize,
          )
        : SimpleVitalsRangeSliderWidget(
            widget.min(),
            widget.max(),
            widget.value(),
            widget.min2(),
            widget.max2(),
            widget.value2(),
            (range) {
              setState(() {
                _submissionRange = range;
                widget.onRangeChange?.call(range);
              });
            },
            fractionDigits: widget.fractionDigits(),
            units: widget.units(),
            includeSubmitButton: widget.includeSubmitButton,
            includeCancelButton: widget.includeCancelButton,
            onSubmit: submitEditedVital,
            fontSize: widget.fontSize,
          );
    return widget.tapWidget == null
        ? MmsStylablePanel(
            caption: widget.labelPrefix,
            widget: sliderWidget,
            width: widget.fontSize * 18,
            // height: widget.fontSize * 4.5 + 80,
            height: 200,
          )
        : InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MmsDismissibleScreen(
                    ValueKey(toString()),
                    MmsStylablePanel(
                      caption:
                          "EDIT ${widget.labelPrefix} - $humanizedPatientId",
                      width: 500,
                      height: 250,
                      panelBgColor: MmsColors.white,
                      widget: sliderWidget,
                    ),
                  ),
                ),
              );
            },
            child: widget.tapWidget,
          );
  }
}

class SimpleVitalsSliderWidget extends StatefulWidget {
  final double min;
  final double max;
  final double? init;
  final String units;
  final int fractionDigits;
  final Function(double) onChanged;
  final bool includeSubmitButton;
  final bool includeCancelButton;
  final Function()? onSubmit;
  final double fontSize;
  const SimpleVitalsSliderWidget(
    this.min,
    this.max,
    this.init,
    this.onChanged, {
    super.key,
    this.fractionDigits = 0,
    this.units = "",
    this.includeSubmitButton = false,
    this.includeCancelButton = false,
    this.onSubmit,
    this.fontSize = 20,
  });

  @override
  _SimpleVitalsSliderWidgetState createState() =>
      _SimpleVitalsSliderWidgetState();
}

class _SimpleVitalsSliderWidgetState extends State<SimpleVitalsSliderWidget> {
  late double _currentValue;
  int? _divisions;
  late double _initValue;
  late double _increment;

  @override
  void initState() {
    super.initState();

    // Initialize _currentValue with the provided init value or default to min
    _currentValue = (widget.init ?? widget.min).clamp(widget.min, widget.max);
    _initValue = _currentValue;

    double range = widget.max - widget.min;
    int fractionDigits = widget.fractionDigits;

    for (int i = 0; i < fractionDigits; ++i) {
      range *= 10;
    }

    if (range <= 200) {
      _divisions = range.ceil();
    }

    _increment = 1.0;
    for (int i = 0; i < widget.fractionDigits; ++i) {
      _increment /= 10.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150, // Adjust the height as necessary to prevent overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MmsPaddedColumn(
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Icon(Icons.remove, size: widget.fontSize),
                    onTap: () {
                      setState(() {
                        _currentValue = (_currentValue - _increment)
                            .clamp(widget.min, widget.max);
                        widget.onChanged.call(_currentValue);
                      });
                    },
                  ),
                  SizedBox(
                    width: widget.fontSize * 6,
                    child: Column(
                      children: [
                        Center(
                          child: MmsText(
                            _currentValue
                                .toStringAsFixed(widget.fractionDigits),
                            style: TextStyle(
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: MmsText(widget.units,
                              style: TextStyle(fontSize: widget.fontSize)),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    child: Icon(Icons.add, size: widget.fontSize),
                    onTap: () {
                      setState(() {
                        _currentValue = (_currentValue + _increment)
                            .clamp(widget.min, widget.max);
                        widget.onChanged.call(_currentValue);
                      });
                    },
                  ),
                ],
              ),
              Slider(
                min: widget.min,
                max: widget.max,
                value: _currentValue,
                divisions: _divisions,
                onChanged: (newValue) {
                  setState(() {
                    _currentValue = newValue;
                    widget.onChanged.call(newValue);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SimpleVitalsRangeSliderWidget extends StatefulWidget {
  final double minLo;
  final double maxLo;
  final double? initLo;
  final double? minHi;
  final double? maxHi;
  final double? initHi;
  final String? units;
  final int fractionDigits;
  final Function(RangeValues) onChanged;
  final bool includeSubmitButton;
  final bool includeCancelButton;
  final Function()? onSubmit;
  final double fontSize;
  const SimpleVitalsRangeSliderWidget(
    this.minLo,
    this.maxLo,
    this.initLo,
    this.minHi,
    this.maxHi,
    this.initHi,
    this.onChanged, {
    super.key,
    this.fractionDigits = 0,
    this.units,
    this.includeSubmitButton = false,
    this.includeCancelButton = false,
    this.onSubmit,
    this.fontSize = 20,
  });

  @override
  _SimpleVitalsRangeSliderWidgetState createState() =>
      _SimpleVitalsRangeSliderWidgetState();
}

class _SimpleVitalsRangeSliderWidgetState
    extends State<SimpleVitalsRangeSliderWidget> {
  late RangeValues _currentRangeValues;
  int? _divisions;
//  double increment;
  late RangeValues _initRange;

  @override
  void initState() {
    super.initState();

    // Clamp initial values within bounds
    double bottom =
        (widget.initLo ?? widget.minLo).clamp(widget.minLo, widget.maxLo);
    double top = (widget.initHi ?? widget.maxHi ?? 100)
        .clamp(widget.minHi ?? widget.minLo, widget.maxHi ?? widget.maxLo);

    _currentRangeValues = RangeValues(bottom, top);
    _initRange = _currentRangeValues;

    double range = (widget.maxHi ?? 1) - widget.minLo;
    range *= pow(10, widget.fractionDigits);

    _divisions = range <= 200 ? range.ceil() : null;
  }

  void updateRange({RangeValues? newValues, double? incLo, double? incHi}) {
    setState(() {
      double currentLo = newValues?.start ?? _currentRangeValues.start;
      double currentHi = newValues?.end ?? _currentRangeValues.end;
      currentLo += incLo ?? 0;
      currentHi += incHi ?? 0;
      if (currentLo > widget.maxLo) {
        currentLo = widget.maxLo;
      }
      if (currentLo < widget.minLo) {
        currentLo = widget.minLo;
      }
      if ((widget.maxHi != null) && (currentHi > widget.maxHi!)) {
        currentHi = widget.maxHi!;
      }
      if ((widget.minHi != null) && (currentHi < widget.minHi!)) {
        currentHi = widget.minHi!;
      }
      _currentRangeValues = RangeValues(currentLo, currentHi);
    });
    widget.onChanged.call(_currentRangeValues);
  }

  @override
  Widget build(BuildContext context) {
    String currentLo =
        _currentRangeValues.start.toStringAsFixed(widget.fractionDigits);
    String currentHi =
        _currentRangeValues.end.toStringAsFixed(widget.fractionDigits);
    String currentLoToHi = "$currentLo - $currentHi";
    return Column(
      children: [
        MmsPaddedColumn(
          [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    InkWell(
                      child: Icon(
                        Icons.add,
                        size: widget.fontSize,
                      ),
                      onTap: () {
                        updateRange(incLo: 1);
                      },
                    ),
                    InkWell(
                      child: Icon(
                        Icons.remove,
                        size: widget.fontSize,
                      ),
                      onTap: () {
                        updateRange(incLo: -1);
                      },
                    ),
                  ],
                ),
                SizedBox(
                    width: widget.fontSize * 6,
                    height: widget.fontSize * 2.5,
                    child: Column(
                      children: [
                        Center(
                          child: MmsText(currentLoToHi,
                              style: TextStyle(
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Center(
                          child: MmsText(widget.units ?? "",
                              style: TextStyle(
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ],
                    )),
                Column(
                  children: [
                    InkWell(
                      child: Icon(
                        Icons.add,
                        size: widget.fontSize,
                      ),
                      onTap: () {
                        updateRange(incHi: 1);
                      },
                    ),
                    InkWell(
                      child: Icon(
                        Icons.remove,
                        size: widget.fontSize,
                      ),
                      onTap: () {
                        updateRange(incHi: -1);
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: widget.fontSize * 0.5,
            ),
            RangeSlider(
              min: widget.minLo,
              max: widget.maxHi ?? 1,
              values: _currentRangeValues,
              divisions: _divisions != null
                  ? (_divisions! > 0 ? _divisions : null)
                  : null,
              onChanged: (newValues) {
                updateRange(newValues: newValues);
              },
            ),
          ],
          //            top: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        if (widget.includeSubmitButton || widget.includeCancelButton)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.includeSubmitButton)
                MmsPaddedRaisedButton(
                  "Submit",
                  onPressed: _currentRangeValues == _initRange
                      ? null
                      : () {
                          widget.onSubmit?.call();
                          Navigator.of(context).pop();
                        },
                ),
              if (widget.includeCancelButton)
                MmsPaddedRaisedButton(
                  "Cancel",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class EkgEditorWidget extends SimpleVitalsEditorWidget {
  const EkgEditorWidget(
    String patientId,
    Widget? tapWidget, {
    super.key,
    Function(double)? onChange,
    bool includeSubmitButton = true,
    bool includeCancelButton = true,
    double fontSize = 20,
  }) : super(
          patientId,
          "EKG",
          "hr",
          tapWidget,
          onChange: onChange,
          includeSubmitButton: includeSubmitButton,
          includeCancelButton: includeCancelButton,
          fontSize: fontSize,
        );

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundValue() => false;

  @override
  double max() => 180;

  @override
  double? max2() => null;

  @override
  double min() => 30;

  @override
  double? min2() => null;

  @override
  String units() => "bpm";

  @override
  double? value() => VitalsValuesStore().getVitalsValues(patientId).ekg;

  @override
  double? value2() => null;
}

class BpEditorWidget extends SimpleVitalsEditorWidget {
  const BpEditorWidget(
    String patientId,
    Widget? tapWidget, {
    super.key,
    Function(RangeValues)? onRangeChange,
    bool includeSubmitButton = true,
    bool includeCancelButton = true,
    double fontSize = 20,
  }) : super(
          patientId,
          "BP",
          "bp_diastolic",
          tapWidget,
          vital2Label: "bp_systolic",
          onRangeChange: onRangeChange,
          includeSubmitButton: includeSubmitButton,
          includeCancelButton: includeCancelButton,
          fontSize: fontSize,
        );

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundValue() => true;

  @override
  double max() => 120;

  @override
  double max2() => 150;

  @override
  double min() => 20;

  @override
  double min2() => 60;

  @override
  String units() => "mmHg";

  @override
  double? value() => VitalsValuesStore().getVitalsValues(patientId).bpLo;

  @override
  double? value2() => VitalsValuesStore().getVitalsValues(patientId).bpHi;
}

class Spo2EditorWidget extends SimpleVitalsEditorWidget {
  const Spo2EditorWidget(
    String patientId,
    Widget? tapWidget, {
    super.key,
    Function(double)? onChange,
    bool includeSubmitButton = true,
    bool includeCancelButton = true,
    double fontSize = 20,
  }) : super(
          patientId,
          "SPO2",
          "spo2",
          tapWidget,
          onChange: onChange,
          includeSubmitButton: includeSubmitButton,
          includeCancelButton: includeCancelButton,
          fontSize: fontSize,
        );

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundValue() => false;

  @override
  double max() => 100;

  @override
  double? max2() => null;

  @override
  double min() => 60;

  @override
  double? min2() => null;

  @override
  String units() => "%";

  @override
  double? value() => VitalsValuesStore().getVitalsValues(patientId).spo2;

  @override
  double? value2() => null;
}

class Etco2EditorWidget extends SimpleVitalsEditorWidget {
  const Etco2EditorWidget(
    String patientId,
    Widget? tapWidget, {
    super.key,
    Function(double)? onChange,
    bool includeSubmitButton = true,
    bool includeCancelButton = true,
    double fontSize = 20,
  }) : super(
          patientId,
          "ETCO2",
          "etco2",
          tapWidget,
          onChange: onChange,
          includeSubmitButton: includeSubmitButton,
          includeCancelButton: includeCancelButton,
          fontSize: fontSize,
        );

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundValue() => false;

  @override
  double max() => 60;

  @override
  double? max2() => null;

  @override
  double min() => 25;

  @override
  double? min2() => null;

  @override
  String units() => "";

  @override
  double? value() => VitalsValuesStore().getVitalsValues(patientId).etco2;

  @override
  double? value2() => null;
}

class RrEditorWidget extends SimpleVitalsEditorWidget {
  const RrEditorWidget(
    String patientId,
    Widget? tapWidget, {
    super.key,
    Function(double)? onChange,
    bool includeSubmitButton = true,
    bool includeCancelButton = true,
    double fontSize = 20,
  }) : super(
          patientId,
          "RR",
          "rr",
          tapWidget,
          onChange: onChange,
          includeSubmitButton: includeSubmitButton,
          includeCancelButton: includeCancelButton,
          fontSize: fontSize,
        );

  @override
  int fractionDigits() => 0;

  @override
  bool isCompoundValue() => false;

  @override
  double max() => 30;

  @override
  double? max2() => null;

  @override
  double min() => 4;

  @override
  double? min2() => null;

  @override
  String units() => "rpm";

  @override
  double? value() => VitalsValuesStore().getVitalsValues(patientId).rr;

  @override
  double? value2() => null;
}

class TempEditorWidget extends SimpleVitalsEditorWidget {
  const TempEditorWidget(
    String patientId,
    Widget? tapWidget, {
    super.key,
    Function(double)? onChange,
    bool includeSubmitButton = true,
    bool includeCancelButton = true,
    double fontSize = 20,
  }) : super(
          patientId,
          "TEMP",
          "temp",
          tapWidget,
          onChange: onChange,
          includeSubmitButton: includeSubmitButton,
          includeCancelButton: includeCancelButton,
          fontSize: fontSize,
        );

  @override
  int fractionDigits() => 1;

  @override
  bool isCompoundValue() => false;

  @override
  double max() => 106.0;

  @override
  double? max2() => null;

  @override
  double min() => 90.0;

  @override
  double? min2() => null;

  @override
  String units() => "F";

  @override
  double? value() => VitalsValuesStore().getVitalsValues(patientId).temp;

  @override
  double? value2() => null;
}

/// Create a set of slider widgets for editing EKG and other vitals.
/// Returned Panel will contain either a Wrap (isHorizontal is null),
/// a Row (isHorizontal is true), or a Column (isHorizontal is false),
/// which contains the six editor widgets. Specify the overall width
/// and height of the returned Panel, if desired. Functions may be passed
/// to capture the changes to any of the sliders. Specifying [includeButtons]
/// as true will include a Submit button and possibly a Cancel button.
/// The Submit button, if clicked, will call
/// VitalsServices().submitEditedVital for each slider widget that had
/// a value change. If [popNavigator] is true, then a Cancel button
/// will be included when [includeButtons] is true. When [includeButtons] and
/// [popNavigator] are both true, clicking either the Submit or Cancel button
/// will result in popping the context Navigator.
class VitalsCompositeEditorPanel extends StatefulWidget {
  final String patientId;
  final bool? isHorizontal;
  final double? width;
  final double height;
  final Function(double)? onEkgChange;
  final Function(RangeValues)? onBpRangeChange;
  final Function(double)? onSpo2Change;
  final Function(double)? onEtco2Change;
  final Function(double)? onRrChange;
  final Function(double)? onTempChange;
  final bool includeButtons;
  final bool popNavigator;
  final double fontSize;
  const VitalsCompositeEditorPanel(
    this.patientId, {
    super.key,
    this.width,
    this.height = 600,
    this.isHorizontal,
    this.onEkgChange,
    this.onBpRangeChange,
    this.onSpo2Change,
    this.onEtco2Change,
    this.onRrChange,
    this.onTempChange,
    this.includeButtons = false,
    this.popNavigator = false,
    this.fontSize = 18,
  });

  @override
  _VitalsCompositeEditorPanelState createState() =>
      _VitalsCompositeEditorPanelState();
}

class _VitalsCompositeEditorPanelState
    extends State<VitalsCompositeEditorPanel> {
  double? _ekgVital;
  RangeValues? _bpVitals;
  double? _spo2Vital;
  double? _etco2Vital;
  double? _rrVital;
  double? _tempVital;
  late EkgEditorWidget _ekgEditorWidget;
  late BpEditorWidget _bpEditorWidget;
  late Spo2EditorWidget _spo2EditorWidget;
  late Etco2EditorWidget _etco2EditorWidget;
  late RrEditorWidget _rrEditorWidget;
  late TempEditorWidget _tempEditorWidget;

  void ekgChanged(double newValue) {
    _ekgVital = newValue;
    widget.onEkgChange?.call(newValue);
  }

  void bpChanged(RangeValues newRange) {
    _bpVitals = newRange;
    widget.onBpRangeChange?.call(newRange);
  }

  void spo2Changed(double newValue) {
    _spo2Vital = newValue;
    widget.onSpo2Change?.call(newValue);
  }

  void etco2Changed(double newValue) {
    _etco2Vital = newValue;
    widget.onEtco2Change?.call(newValue);
  }

  void rrChanged(double newValue) {
    _rrVital = newValue;
    widget.onRrChange?.call(newValue);
  }

  void tempChanged(double newValue) {
    _tempVital = newValue;
    widget.onTempChange?.call(newValue);
  }

  void submitAll() {
    VitalsServices().submitEditedVital(
      widget.patientId,
      _ekgEditorWidget.vital1Label,
      _ekgVital,
      vitalsType2: _ekgEditorWidget.vital2Label,
    );
    VitalsServices().submitEditedVital(
      widget.patientId,
      _bpEditorWidget.vital1Label,
      null,
      isCompoundValue: true,
      range: _bpVitals,
      currentRangeMax: _bpEditorWidget.value2(),
      vitalsType2: _bpEditorWidget.vital2Label,
    );
    VitalsServices().submitEditedVital(
      widget.patientId,
      _spo2EditorWidget.vital1Label,
      _spo2Vital,
      vitalsType2: '',
    );
    VitalsServices().submitEditedVital(
      widget.patientId,
      _etco2EditorWidget.vital1Label,
      _etco2Vital,
      vitalsType2: '',
    );
    VitalsServices().submitEditedVital(
      widget.patientId,
      _rrEditorWidget.vital1Label,
      _rrVital,
      vitalsType2: '',
    );
    VitalsServices().submitEditedVital(
      widget.patientId,
      _tempEditorWidget.vital1Label,
      _tempVital,
      vitalsType2: '',
    );
  }

  @override
  void initState() {
    super.initState();
    _ekgEditorWidget = EkgEditorWidget(
      widget.patientId,
      null,
      onChange: ekgChanged,
      includeSubmitButton: false,
      includeCancelButton: false,
      fontSize: widget.fontSize,
    );
    _bpEditorWidget = BpEditorWidget(
      widget.patientId,
      null,
      onRangeChange: bpChanged,
      includeSubmitButton: false,
      includeCancelButton: false,
      fontSize: widget.fontSize,
    );
    _spo2EditorWidget = Spo2EditorWidget(
      widget.patientId,
      null,
      onChange: spo2Changed,
      includeSubmitButton: false,
      includeCancelButton: false,
      fontSize: widget.fontSize,
    );
    _etco2EditorWidget = Etco2EditorWidget(
      widget.patientId,
      null,
      onChange: etco2Changed,
      includeSubmitButton: false,
      includeCancelButton: false,
      fontSize: widget.fontSize,
    );
    _rrEditorWidget = RrEditorWidget(
      widget.patientId,
      null,
      onChange: rrChanged,
      includeSubmitButton: false,
      includeCancelButton: false,
      fontSize: widget.fontSize,
    );
    _tempEditorWidget = TempEditorWidget(
      widget.patientId,
      null,
      onChange: tempChanged,
      includeSubmitButton: false,
      includeCancelButton: false,
      fontSize: widget.fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> vitalEditorWidgets = <Widget>[
      _ekgEditorWidget,
      _bpEditorWidget,
      _spo2EditorWidget,
      _etco2EditorWidget,
      _rrEditorWidget,
      _tempEditorWidget,
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return MmsRoundedBarlessPanel(
        rounding: 0,
        widget: Container(
            height: widget.height, // Expand to available height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MmsPaddedRaisedButton(
                      "Submit",
                      onPressed: submitAll,
                    ),
                    MmsPaddedRaisedButton(
                      "Cancel",
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: widget.height - 80, // Limit height to avoid overflow
                  child: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: vitalEditorWidgets.map((widget) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }
}
