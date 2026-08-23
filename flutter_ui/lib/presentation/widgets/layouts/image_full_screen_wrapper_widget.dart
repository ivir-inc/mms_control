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
import 'package:flutter_ui/presentation/widgets/layouts/full_screen_layout.dart';

class ImageFullScreenWrapperWidget extends StatelessWidget {
  final Image child;
  final Widget? tapWidget;
  final Object heroTag;

  const ImageFullScreenWrapperWidget(
    this.child, {
    super.key,
    this.tapWidget,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.zoomIn,
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            fullscreenDialog: true,
            pageBuilder: (BuildContext context, _, __) {
              return FullScreenLayout(
                heroTag: heroTag,
                child: child,
              );
            },
          ),
        );
      },
      child: tapWidget,
    );
  }
}
