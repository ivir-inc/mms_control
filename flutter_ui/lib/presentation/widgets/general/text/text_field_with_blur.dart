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
import 'package:flutter/services.dart';

// Regular stock TextField with option for a callback when the field loses focus.
class TextFieldWithBlur extends StatefulWidget {
  final TextEditingController? controller;
  final bool? expands;
  final int? maxLines;
  final int? minLines;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final Function(String)? callback;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Function(bool)? onFocusChanged;

  const TextFieldWithBlur({
    super.key,
    this.controller,
    this.expands,
    this.maxLines,
    this.minLines,
    this.decoration,
    this.style,
    this.keyboardType,
    this.callback,
    this.inputFormatters,
    this.focusNode,
    this.onFocusChanged,
  });

  @override
  _TextFieldWithBlurState createState() => _TextFieldWithBlurState();
}

class _TextFieldWithBlurState extends State<TextFieldWithBlur> {
  late final FocusNode _internalFocusNode =
      widget.focusNode ?? FocusNode(); // support external node

  @override
  void initState() {
    super.initState();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_internalFocusNode.hasFocus) {
      final text = widget.controller?.text ?? '';
      widget.callback?.call(text);
    }
    widget.onFocusChanged?.call(_internalFocusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _internalFocusNode,
      controller: widget.controller,
      expands: widget.expands ?? false,
      // textAlignVertical: TextAlignVertical.top, // unset this comment for non-vertically centered text
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      decoration: widget.decoration,
      style: widget.style,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
    );
  }
}
