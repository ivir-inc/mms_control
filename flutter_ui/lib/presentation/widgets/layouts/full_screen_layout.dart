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

class FullScreenLayout extends StatefulWidget {
  const FullScreenLayout({
    super.key,
    this.child,
    this.heroTag,
  });

  final Image? child;
  final Object? heroTag;

  @override
  _FullScreenLayoutState createState() => _FullScreenLayoutState();
}

class _FullScreenLayoutState extends State<FullScreenLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          // Stack(
          //   fit: StackFit.passthrough,
          //   children: [
          InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () => Navigator.of(context).pop(),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: widget.heroTag == null
              ? widget.child
              : Hero(
                  tag: widget.heroTag!,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    child: widget.child,
                  ),
                ),
        ),
      ),
      // SafeArea(
      //   child: Align(
      //     alignment: Alignment.topLeft,
      //     child: MaterialButton(
      //       padding: const EdgeInsets.all(15),
      //       elevation: 0,
      //       child: Icon(
      //         Icons.arrow_back,
      //         color: Colors.white,
      //         size: 25,
      //       ),
      //       color: Colors.black12,
      //       highlightElevation: 2,
      //       minWidth: double.minPositive,
      //       height: double.minPositive,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(100),
      //       ),
      //       onPressed: () => Navigator.of(context).pop(),
      //     ),
      //   ),
      // ),
      //   ],
      // ),
    );
  }
}
