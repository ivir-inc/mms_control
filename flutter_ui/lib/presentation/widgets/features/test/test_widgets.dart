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

import 'package:flutter_ui/data/model/raw_data/raw_data_model.dart';
import 'package:flutter_ui/data/services/all_raw_data_store_access.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text_field.dart';

import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InsertDataInRouterWidget extends StatefulWidget {
  final double editorHeight;
  final bool enabled;
  final int maxLines;
  const InsertDataInRouterWidget({
    super.key,
    this.editorHeight = 250, // Increased height for better visibility
    this.enabled = true,
    this.maxLines = 10, // Allowing multi-line input
  });

  @override
  _InsertDataInRouterWidgetState createState() =>
      _InsertDataInRouterWidgetState();
}

class _InsertDataInRouterWidgetState extends State<InsertDataInRouterWidget> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: MmsStylablePanel(
                caption: "Insert Data Into Web Socket Input Stream",
                captionTextColor: MmsColors.white,
                captionBarColor: MmsColors.dkBlue,
                captionFontWeight: FontWeight.bold,
                childPadding: const EdgeInsets.all(10),
                height: widget.editorHeight + 120, // Adjusted height
                width: MediaQuery.of(context).size.width / 2 - 20,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MmsTextField(
                      textController: _textEditingController,
                      enabled: widget.enabled,
                      maxLines: widget.maxLines,
                      height: widget.editorHeight,
                    ),
                    const SizedBox(height: 10), // Added spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15)),
                          child: const MmsText("Inject JSON"),
                          onPressed: () {
                            if (_textEditingController.text.isNotEmpty) {
                              MmsDataRouter().routeDataByContainedType(
                                  _textEditingController.text);
                            }
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15)),
                          child: const MmsText("Inject String"),
                          onPressed: () {
                            if (_textEditingController.text.contains(":")) {
                              List<String> parts =
                                  _textEditingController.text.split(":");
                              if (parts.length >= 3) {
                                MmsDataRouter().routeRawStringByNamedType(
                                  parts[0],
                                  parts[1],
                                  parts[2],
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: MmsStylablePanel(
                caption: "Display Raw WS Data",
                captionTextColor: MmsColors.white,
                captionBarColor: MmsColors.dkBlue,
                captionFontWeight: FontWeight.bold,
                childPadding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width / 2 - 20,
                height: widget.editorHeight + 120, // Adjusted height
                widget: const AllRawDataDisplayWidget(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AllRawDataDisplayWidget extends StatefulWidget {
  const AllRawDataDisplayWidget({super.key});

  @override
  _AllRawDataDisplayWidgetState createState() =>
      _AllRawDataDisplayWidgetState();
}

class _AllRawDataDisplayWidgetState extends State<AllRawDataDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AllRawDataStoreAccess>(
        create: (_) => AllRawDataStoreAccess(),
        builder: (context, _) {
          return Selector<AllRawDataStoreAccess, RawDataModel>(
            builder: (context, data, _) {
              String dt =
                  data.dataType.isNotEmpty ? data.dataType : "<unknown>";
              String id =
                  data.identifier.isNotEmpty ? data.identifier : "<unknown>";
              String raw = data.rawData.isNotEmpty
                  ? data.rawData
                  : "No data received yet.";
              return SingleChildScrollView(
                child: MmsText(
                  "$dt:$id:$raw",
                  maxLines: 10,
                  softWrap: true,
                ),
              );
            },
            selector: (buildContext, access) => access.store.lastData,
            shouldRebuild: (prev, next) => prev != next,
          );
        });
  }
}
