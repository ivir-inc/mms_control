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
import 'package:flutter_ui/presentation/widgets/general/numbers/simple_number_display_widget.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class NumberSliderEditableTappableWidget extends StatefulWidget {
  final SimpleNumberDisplayWidget tapWidget;
  final double min;
  final double max;
  final Function(double) onChanged;
  final Function() onSubmit;
  final String submitLabel;
  final String cancelLabel;
  final String caption;
  final Color panelBgColor;
  const NumberSliderEditableTappableWidget(
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
  _NumberSliderEditableTappableWidgetState createState() =>
      _NumberSliderEditableTappableWidgetState();
}

class _NumberSliderEditableTappableWidgetState
    extends State<NumberSliderEditableTappableWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NumberSliderDismissibleScreen(
            min: widget.min,
            max: widget.max,
            init: widget.tapWidget.value(),
            units: widget.tapWidget.units ?? "",
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

class NumberSliderDismissibleScreen extends StatefulWidget {
  final double min;
  final double max;
  final double init;
  final String units;
  final int fractionDigits;
  final Function(double) onChanged;
  final Function() onSubmit;
  final String submitLabel;
  final String cancelLabel;
  final String caption;
  final Color panelBgColor;

  const NumberSliderDismissibleScreen({
    super.key,
    required this.min,
    required this.max,
    required this.init,
    required this.units,
    required this.fractionDigits,
    required this.onChanged,
    required this.onSubmit,
    this.submitLabel = "Submit",
    this.cancelLabel = "Cancel",
    required this.caption,
    this.panelBgColor = Colors.white,
  });

  @override
  _NumberSliderDismissibleScreenState createState() =>
      _NumberSliderDismissibleScreenState();
}

class _NumberSliderDismissibleScreenState
    extends State<NumberSliderDismissibleScreen> {
  @override
  Widget build(BuildContext context) {
    return MmsDismissibleScreen(
      ValueKey(toString()),
      MmsStylablePanel(
        caption: widget.caption,
        width: 500,
        height: 250,
        panelBgColor: widget.panelBgColor,
        widget: NumberSliderEditor(
          widget.min,
          widget.max,
          widget.init,
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

class NumberSliderEditor extends StatefulWidget {
  final double? min;
  final double? max;
  final double? init;
  final String units;
  final int fractionDigits;
  final Function(double) onChanged;
  final Function()? onSubmit;
  final String? submitLabel;
  final String? cancelLabel;
  const NumberSliderEditor(
    this.min,
    this.max,
    this.init,
    this.onChanged, {
    super.key,
    this.fractionDigits = 0,
    this.units = "",
    this.onSubmit,
    this.submitLabel,
    this.cancelLabel,
  });

  @override
  _NumberSliderEditorState createState() => _NumberSliderEditorState();
}

class _NumberSliderEditorState extends State<NumberSliderEditor> {
  late double _currentValue;
  late int _divisions;
  late double _increment;
  late double _max;
  late double _min;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.init ?? widget.min ?? 0;
    _min = widget.min ?? 0;
    _max = widget.max ?? 100;
    if (_min > _max) {
      double temp = _min;
      _min = _max;
      _max = temp;
    }
    if (_currentValue > _max) {
      _currentValue = _max;
    }
    if (_currentValue < _min) {
      _currentValue = _min;
    }
    double range = _max - _min;
    int fractionDigits = widget.fractionDigits;
    for (int i = 0; i < fractionDigits; ++i) {
      range = range * 10;
    }
    if (range <= 200) {
      _divisions = range.ceil();
    }
    _increment = 1.0;
    for (int i = 0; i < fractionDigits; ++i) {
      _increment /= 10.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MmsPaddedColumn(
          [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  child: const Icon(Icons.remove),
                  onTap: () {
                    setState(() {
                      _currentValue -= _increment;
                      if (_currentValue < _min) {
                        _currentValue = _min;
                      }
                      if (_currentValue > _max) {
                        _currentValue = _max;
                      }
                      widget.onChanged.call(_currentValue);
                    });
                  },
                ),
                SizedBox(
                    width: 100,
                    height: 30,
                    child: Center(
                      child: MmsText(
                          _currentValue
                              .toStringAsFixed(widget.fractionDigits),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    )),
                InkWell(
                  child: const Icon(Icons.add),
                  onTap: () {
                    setState(() {
                      _currentValue += _increment;
                      if (_currentValue > _max) {
                        _currentValue = _max;
                      }
                      if (_currentValue < _min) {
                        _currentValue = _min;
                      }
                      widget.onChanged.call(_currentValue);
                    });
                  },
                ),
              ],
            ),
            if ((widget.units).isNotEmpty)
              Center(
                child: MmsText(widget.units,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            Slider(
              min: _min,
              max: _max,
              value: _currentValue,
              divisions: _divisions > 0 ? _divisions : null,
              onChanged: (newValue) {
                setState(() {
                  _currentValue = newValue;
                  widget.onChanged.call(newValue);
                });
              },
            ),
          ],
          top: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.submitLabel != null)
              MmsPaddedRaisedButton(
                widget.submitLabel!,
                onPressed: () {
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
