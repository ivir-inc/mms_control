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
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';

/// [PanelActionWidgets] are each expected to be represented as an icon
/// of size 20, that will do some action when clicked.
class MmsRoundedBarlessPanel extends MmsStylablePanel {
  const MmsRoundedBarlessPanel({
    super.key,
    super.width,
    super.height,
    double super.rounding = 20,
    super.elevation,
    super.caption,
    super.captionIcon,
    super.widget,
    super.expandable,
    super.panelActionWidgets,
    EdgeInsetsGeometry? padding,
  }) : super(
          childPadding: padding,
          captionBarColor: MmsColors.white,
          captionTextColor: MmsColors.black,
          panelBgColor: MmsColors.white,
        );
}
