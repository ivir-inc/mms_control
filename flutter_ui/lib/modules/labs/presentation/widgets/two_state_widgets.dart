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

import 'package:flutter_ui/presentation/widgets/general/state/two_state_row_widget.dart';
import 'package:flutter_ui/presentation/widgets/general/state/two_state_value_holder.dart';
import 'package:flutter_ui/presentation/widgets/general/state/two_state_widget.dart';

import '../../data/services/two_state_services.dart';

class LabsOnlyModeRowWidget extends MmsTwoStateRowWidget {
  LabsOnlyModeRowWidget(
      {super.key, bool valueState = false, bool errorState = false})
      : super(
            "Labs Only Mode:",
            MmsTwoStateWidget(
              LabsOnlyModeService(),
              activeLabel: 'On',
              inactiveLabel: 'Off',
              initValueByService: false,
              hasError: errorState,
              valueHolder: MmsTwoStateValueHolder(state: valueState),
            ));
}

class InstructorControlRowWidget extends MmsTwoStateRowWidget {
  InstructorControlRowWidget(
      {super.key, bool valueState = false, bool errorState = false})
      : super(
            "Instructor Control:",
            MmsTwoStateWidget(
              InstructorControlService(),
              activeLabel: 'On',
              inactiveLabel: 'Off',
              initValueByService: false,
              hasError: errorState,
              valueHolder: MmsTwoStateValueHolder(state: valueState),
            ));
}

class AllowVitalsChangeRowWidget extends MmsTwoStateRowWidget {
  AllowVitalsChangeRowWidget(
      {super.key, bool valueState = false, bool errorState = false})
      : super(
            "Allow Federation to change vitals:",
            MmsTwoStateWidget(
              AllowVitalsChangeService(),
              activeLabel: 'On',
              inactiveLabel: 'Off',
              hasError: errorState,
              valueHolder: MmsTwoStateValueHolder(state: valueState),
            ));
}

class AllowSoundsChangeRowWidget extends MmsTwoStateRowWidget {
  AllowSoundsChangeRowWidget(
      {super.key, bool valueState = false, bool errorState = false})
      : super(
            "Allow Federation to change sounds:",
            MmsTwoStateWidget(
              AllowSoundsChangeService(),
              activeLabel: 'On',
              inactiveLabel: 'Off',
              hasError: errorState,
              valueHolder: MmsTwoStateValueHolder(state: valueState),
            ));
}
