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
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/layouts/padded_column.dart';
import 'package:flutter_ui/presentation/widgets/general/numbers/simple_numeric_range_display_widget.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class NumericRangeSliderEditableTappableWidget extends StatefulWidget {
  final SimpleNumericRangeDisplayWidget tapWidget;
  final double min;
  final double max;
  final Function(RangeValues) onChanged;
  final Function() onSubmit;
  final String submitLabel;
  final String cancelLabel;
  final String caption;
  final Color panelBgColor;
  const NumericRangeSliderEditableTappableWidget(
    this.tapWidget, {
    super.key,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onSubmit,
    required this.submitLabel,
    required this.cancelLabel,
    required this.caption,
    required this.panelBgColor,
  });

  @override
  _NumericRangeSliderEditableTappableWidgetState createState() =>
      _NumericRangeSliderEditableTappableWidgetState();
}

class _NumericRangeSliderEditableTappableWidgetState
    extends State<NumericRangeSliderEditableTappableWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NumericRangeSliderDismissibleScreen(
            minLo: widget.min,
            maxLo: widget.max,
            initLo: widget.tapWidget.valueLo(),
            minHi: widget.min,
            maxHi: widget.max,
            initHi: widget.tapWidget.valueHi(),
            units: widget.tapWidget.units,
            fractionDigits: widget.tapWidget.fractionDigits,
            onChanged: widget.onChanged,
            onSubmit: widget.onSubmit,
            submitLabel: widget.submitLabel,
            cancelLabel: widget.cancelLabel,
            caption: widget.caption,
            panelBgColor: widget.panelBgColor,
          ),
        ));
      },
      child: widget.tapWidget,
    );
  }
}

class NumericRangeSliderDismissibleScreen extends StatefulWidget {
  final double minLo;
  final double maxLo;
  final double? initLo;
  final double minHi;
  final double maxHi;
  final double? initHi;
  final String? units;
  final int fractionDigits;
  final Function(RangeValues)? onChanged;
  final Function()? onSubmit;
  final String? submitLabel;
  final String? cancelLabel;
  final String? caption;
  final Color? panelBgColor;

  const NumericRangeSliderDismissibleScreen({
    super.key,
    required this.minLo,
    required this.maxLo,
    this.initLo,
    required this.minHi,
    required this.maxHi,
    this.initHi,
    this.units,
    this.fractionDigits = 0,
    this.onChanged,
    this.onSubmit,
    this.submitLabel = "Submit",
    this.cancelLabel = "Cancel",
    this.caption,
    this.panelBgColor = Colors.white,
  });

  @override
  _NumericRangeSliderDismissibleScreenState createState() =>
      _NumericRangeSliderDismissibleScreenState();
}

class _NumericRangeSliderDismissibleScreenState
    extends State<NumericRangeSliderDismissibleScreen> {
  @override
  Widget build(BuildContext context) {
    return MmsDismissibleScreen(
      ValueKey(toString()),
      MmsStylablePanel(
        caption: widget.caption,
        width: 500,
        height: 250,
        panelBgColor: widget.panelBgColor,
        widget: NumericRangeSliderEditor(
          widget.minLo,
          widget.maxLo,
          widget.initLo,
          widget.minHi,
          widget.maxHi,
          widget.initHi,
          widget.onChanged,
          fractionDigits: widget.fractionDigits,
          units: widget.units,
          submitLabel: widget.submitLabel,
          cancelLabel: widget.cancelLabel,
          onSubmit: widget.onSubmit,
        ),
      ),
    );
  }
}

class NumericRangeSliderEditor extends StatefulWidget {
  final double minLo;
  final double maxLo;
  final double? initLo;
  final double minHi;
  final double maxHi;
  final double? initHi;
  final String? units;
  final int fractionDigits;
  final Function(RangeValues)? onChanged;
  final Function()? onSubmit;
  final String? submitLabel;
  final String? cancelLabel;
  const NumericRangeSliderEditor(
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
    this.onSubmit,
    this.submitLabel,
    this.cancelLabel,
  });

  @override
  _NumericRangeSliderEditorState createState() =>
      _NumericRangeSliderEditorState();
}

class _NumericRangeSliderEditorState extends State<NumericRangeSliderEditor> {
  late RangeValues _currentRangeValues;
  late int _divisions;
  late RangeValues _initRange;

  @override
  void initState() {
    super.initState();

    // Assign default values for bottom and top
    double bottom = widget.initLo ?? widget.minLo;
    double top = widget.initHi ?? widget.maxHi;

    // Initialize range values
    _currentRangeValues = RangeValues(bottom, top);
    _initRange = _currentRangeValues;

    // Calculate the range and adjust based on fractionDigits
    double range = widget.maxHi - widget.minLo;
    range *= (widget.fractionDigits > 0) ? (10 * widget.fractionDigits) : 1;

    // Determine divisions if range <= 200
    _divisions = (range <= 200 ? range.ceil() : null)!;
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
      if (currentHi > widget.maxHi) {
        currentHi = widget.maxHi;
      }
      if (currentHi < widget.minHi) {
        currentHi = widget.minHi;
      }
      _currentRangeValues = RangeValues(currentLo, currentHi);
    });
    widget.onChanged?.call(_currentRangeValues);
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
                      child: const Icon(Icons.add),
                      onTap: () {
                        updateRange(incLo: 1);
                      },
                    ),
                    InkWell(
                      child: const Icon(Icons.remove),
                      onTap: () {
                        updateRange(incLo: -1);
                      },
                    ),
                  ],
                ),
                SizedBox(
                    width: 120,
                    height: 30,
                    child: Center(
                      child: MmsText(currentLoToHi,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    )),
                Column(
                  children: [
                    InkWell(
                      child: const Icon(Icons.add),
                      onTap: () {
                        updateRange(incHi: 1);
                      },
                    ),
                    InkWell(
                      child: const Icon(Icons.remove),
                      onTap: () {
                        updateRange(incHi: -1);
                      },
                    ),
                  ],
                ),
              ],
            ),
            if ((widget.units ?? "").isNotEmpty)
              Center(
                child: MmsText(widget.units,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            RangeSlider(
              min: widget.minLo,
              max: widget.maxHi,
              values: _currentRangeValues,
              divisions: _divisions > 0 ? _divisions : null,
              onChanged: (newValues) {
                updateRange(newValues: newValues);
              },
            ),
          ],
          top: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.submitLabel != null)
              MmsPaddedRaisedButton(
                widget.submitLabel!,
                onPressed: _currentRangeValues == _initRange
                    ? null
                    : () {
                        widget.onSubmit?.call();
                        Navigator.of(context).pop();
                      },
              ),
            if (widget.cancelLabel != null)
              MmsPaddedRaisedButton(
                widget.cancelLabel!,
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
