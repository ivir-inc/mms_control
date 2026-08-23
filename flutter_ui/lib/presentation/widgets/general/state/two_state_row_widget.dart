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
import 'package:flutter_ui/presentation/widgets/layouts/padded_row.dart';
import 'package:flutter_ui/presentation/widgets/general/state/two_state_widget.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';

class MmsTwoStateRowWidget extends MmsPaddedRow {
  MmsTwoStateRowWidget(
    String label,
    MmsTwoStateWidget widget, {super.key, 
    Icon? labelIcon,
  }) : super(
          [
            MmsFieldLabelText(
              text: label,
              iconEntry: labelIcon,
            ),
            widget
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          top: 0.0,
          bottom: 0.0,
        );
}
