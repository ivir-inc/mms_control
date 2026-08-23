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
import 'package:flutter_ui/data/services/two_state_service.dart';
import 'package:flutter_ui/presentation/widgets/general/state/two_state_widget.dart';
import 'package:flutter_ui/presentation/widgets/general/text/padded_label_text.dart';

class MmsTwoStateTableRow extends TableRow {
  MmsTwoStateTableRow(
    String label,
    MmsTwoStateService service, {
    Key? twoStateWidgetKey,
    Icon? labelIcon,
    String activeLabel = 'Active',
    String inactiveLabel = 'Inactive',
    Icon? activeIcon,
    Icon? inactiveIcon,
  }) : super(children: [
          MmsPaddedLabelText(
            label,
            labelIcon: labelIcon,
          ),
          MmsTwoStateWidget(
            service,
            key: twoStateWidgetKey,
            activeLabel: activeLabel,
            inactiveLabel: inactiveLabel,
            activeIcon: activeIcon,
            inactiveIcon: inactiveIcon,
          ),
        ]);
}
