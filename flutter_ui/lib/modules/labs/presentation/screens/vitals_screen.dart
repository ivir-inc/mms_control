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
import 'package:flutter_ui/logic/utils/string_utils.dart';
import 'package:flutter_ui/modules/labs/presentation/widgets/vitals_readout.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import '../widgets/note_widget.dart';
import 'package:flutter_ui/data/services/vitals_rest_service.dart';

const Color ekgColor = Color.fromRGBO(0, 254, 2, 1);
const Color bpColor = Color.fromRGBO(229, 0, 23, 1);
const Color spo2Color = Color.fromRGBO(229, 227, 67, 1);
const Color etco2Color = Color.fromRGBO(255, 255, 255, 1);
const Color rrColor = Color.fromRGBO(213, 62, 255, 1);
const Color tempColor = Color.fromRGBO(0, 254, 2, 1);

enum VitalsChangeType { visibility, pattern }

Map<VitalsType, Color> vitalsColorMap = {
  VitalsType.ekg: ekgColor,
  VitalsType.bp: bpColor,
  VitalsType.spo2: spo2Color,
  VitalsType.etco2: etco2Color,
  VitalsType.rr: rrColor,
  VitalsType.temp: tempColor,
};

class VitalsChangedNotification extends Notification {
  final int patternId;
  final bool visibilityOn;
  final VitalsChangeType changeType;
  final VitalsType vitalsType;

  const VitalsChangedNotification({
    required this.changeType,
    required this.vitalsType,
    required this.patternId,
    required this.visibilityOn,
  });
}

class VitalsScreen extends StatefulWidget {
  final String? patientId;
  const VitalsScreen({super.key, this.patientId});

  @override
  VitalsScreenState createState() => VitalsScreenState();
}

class VitalsScreenState extends State<VitalsScreen> {
  @override
  Widget build(BuildContext context) {
    String patientLabel = "";
    if (widget.patientId != null) {
      String humanizedId = StringUtils.humanizedId(widget.patientId ?? "");
      patientLabel = " - $humanizedId";
    }

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height, // Ensure finite height
        child: Wrap(
          children: [
            Container(
              height: 550,
              width: 600, // Fixed height for the panel
              child: Panel(
                width: double.infinity,
                text: "Vitals Control$patientLabel",
                widget: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: VitalsTableWidget(widget.patientId ?? ""),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 250,
              width: 400, // Fixed height for the panel
              child: Panel(
                width: double.infinity,
                text: "Send Note",
                widget: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NotesWidget(patientId: widget.patientId ?? ""),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VitalsTableWidget extends StatefulWidget {
  final String patientId;
  final bool individualEditors;
  final bool isHorizontalEditor;

  const VitalsTableWidget(
    this.patientId, {
    super.key,
    this.individualEditors = false,
    this.isHorizontalEditor = false,
  });

  @override
  _VitalsTableWidget createState() => _VitalsTableWidget();
}

class _VitalsTableWidget extends State<VitalsTableWidget> {
  late Future<VitalsPatternOptions?> futureVitalsPatternOptions;
  late Future<VitalsPattern?> futureVitalsPattern;
  late Future<VitalsElementVisibility?> futureVitalsVisibility;
  VitalsPatternOptions? lastVitalsPatternOptions;
  VitalsPattern? lastVitalsPattern;
  VitalsElementVisibility? lastVitalsVisibility;
  late String pId;

  @override
  void initState() {
    super.initState();
    pId = widget.patientId;

    futureVitalsPatternOptions = VitalsServices()
        .fetchVitalsPatternOptions(patientId: pId)
        .catchError((error) {
      debugPrint("Error fetching VitalsPatternOptions: $error");
      return null; // Return null to prevent future failures
    });

    futureVitalsPattern =
        VitalsServices().fetchVitalsPattern(patientId: pId).catchError((error) {
      debugPrint("Error fetching VitalsPattern: $error");
      return null;
    });

    futureVitalsVisibility = VitalsServices()
        .fetchVitalsVisibility(patientId: pId)
        .catchError((error) {
      debugPrint("Error fetching VitalsVisibility: $error");
      return null;
    });
  }

  Widget vitalsGroupEditor(
    Widget child, {
    bool isHorizontal = false,
  }) {
    return InkWell(
      onTap: () {
        debugPrint("Vitals group tapped");
        String valKeyStr = "$child.$isHorizontal";
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MmsDismissibleScreen(
              ValueKey(valKeyStr),
              VitalsCompositeEditorPanel(
                pId,
                isHorizontal: isHorizontal,
                width: 600,
                includeButtons: true,
                popNavigator: true,
              ),
              scrollable: false,
            ),
          ),
        );
      },
      splashColor: Colors.blueAccent.withOpacity(0.2), // Added splash color
      highlightColor:
          Colors.blueAccent.withOpacity(0.1), // Added highlight color
      child: Container(
        color: Colors.transparent, // Ensure there's a clickable surface
        padding: const EdgeInsets.all(4.0), // Add padding for better tap area
        child: child,
      ),
    );
  }

  Widget ekgTouchPoint(
    String pId,
    bool isRowHeader,
  ) {
    Widget? rowHeaderWidget;
    Widget? displayWidget;
    if (isRowHeader) {
      rowHeaderWidget = buildRowHeader("EKG", ekgColor);
    } else {
      displayWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 80,
          maxHeight: 35,
        ),
        child: Center(
          child: EkgSimpleVitalsDisplayWidget(
            pId,
          ),
        ),
      );
    }
    if (widget.individualEditors) {
      if (isRowHeader) {
        return EkgEditorWidget(
          pId,
          rowHeaderWidget!,
        );
      }
      return EkgEditorWidget(
        pId,
        displayWidget!,
      );
    }
    if (isRowHeader) {
      return vitalsGroupEditor(
        rowHeaderWidget!,
        isHorizontal: widget.isHorizontalEditor,
      );
    }
    return vitalsGroupEditor(
      displayWidget!,
      isHorizontal: widget.isHorizontalEditor,
    );
  }

  Widget bpTouchPoint(
    String pId,
    bool isRowHeader,
  ) {
    Widget? rowHeaderWidget;
    Widget? displayWidget;
    if (isRowHeader) {
      rowHeaderWidget = buildRowHeader("BP", bpColor);
    } else {
      displayWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 80,
          maxHeight: 35,
        ),
        child: Center(
          child: BpSimpleVitalsDisplayWidget(
            pId,
            textAlign: TextAlign.center,
            maxlines: 2,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    if (widget.individualEditors) {
      if (isRowHeader) {
        return BpEditorWidget(
          pId,
          rowHeaderWidget!,
        );
      }
      return BpEditorWidget(
        pId,
        displayWidget!,
      );
    }
    if (isRowHeader) {
      return vitalsGroupEditor(
        rowHeaderWidget!,
        isHorizontal: widget.isHorizontalEditor,
      );
    }
    return vitalsGroupEditor(
      displayWidget!,
      isHorizontal: widget.isHorizontalEditor,
    );
  }

  Widget spo2TouchPoint(
    String pId,
    bool isRowHeader,
  ) {
    Widget? rowHeaderWidget;
    Widget? displayWidget;
    if (isRowHeader) {
      rowHeaderWidget = buildRowHeader("SpO2", spo2Color);
    } else {
      displayWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 80,
          maxHeight: 35,
        ),
        child: Center(
          child: Spo2SimpleVitalsDisplayWidget(
            pId,
          ),
        ),
      );
    }
    if (widget.individualEditors) {
      if (isRowHeader) {
        return Spo2EditorWidget(
          pId,
          rowHeaderWidget!,
        );
      }
      return Spo2EditorWidget(
        pId,
        displayWidget!,
      );
    }
    if (isRowHeader) {
      return vitalsGroupEditor(
        rowHeaderWidget!,
        isHorizontal: widget.isHorizontalEditor,
      );
    }
    return vitalsGroupEditor(
      displayWidget!,
      isHorizontal: widget.isHorizontalEditor,
    );
  }

  Widget etco2TouchPoint(
    String pId,
    bool isRowHeader,
  ) {
    Widget? rowHeaderWidget;
    Widget? displayWidget;
    if (isRowHeader) {
      rowHeaderWidget = buildRowHeader("EtCO2", etco2Color);
    } else {
      displayWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 80,
          maxHeight: 35,
        ),
        child: Center(
          child: Etco2SimpleVitalsDisplayWidget(
            pId,
          ),
        ),
      );
    }
    if (widget.individualEditors) {
      if (isRowHeader) {
        return Etco2EditorWidget(
          pId,
          rowHeaderWidget!,
        );
      }
      return Etco2EditorWidget(
        pId,
        displayWidget!,
      );
    }
    if (isRowHeader) {
      return vitalsGroupEditor(
        rowHeaderWidget!,
        isHorizontal: widget.isHorizontalEditor,
      );
    }
    return vitalsGroupEditor(
      displayWidget!,
      isHorizontal: widget.isHorizontalEditor,
    );
  }

  Widget rrTouchPoint(
    String pId,
    bool isRowHeader,
  ) {
    Widget? rowHeaderWidget;
    Widget? displayWidget;
    if (isRowHeader) {
      rowHeaderWidget = buildRowHeader("RR", rrColor);
    } else {
      displayWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 80,
          maxHeight: 35,
        ),
        child: Center(
          child: RrSimpleVitalsDisplayWidget(
            pId,
          ),
        ),
      );
    }
    if (widget.individualEditors) {
      if (isRowHeader) {
        return RrEditorWidget(
          pId,
          rowHeaderWidget!,
        );
      }
      return RrEditorWidget(
        pId,
        displayWidget!,
      );
    }
    if (isRowHeader) {
      return vitalsGroupEditor(
        rowHeaderWidget!,
        isHorizontal: widget.isHorizontalEditor,
      );
    }
    return vitalsGroupEditor(
      displayWidget!,
      isHorizontal: widget.isHorizontalEditor,
    );
  }

  Widget tempTouchPoint(
    String pId,
    bool isRowHeader,
  ) {
    Widget? rowHeaderWidget;
    Widget? displayWidget;
    if (isRowHeader) {
      rowHeaderWidget = buildRowHeader("Temp", tempColor);
    } else {
      displayWidget = ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 80,
          maxHeight: 35,
        ),
        child: Center(
          child: TempSimpleVitalsDisplayWidget(
            pId,
          ),
        ),
      );
    }
    if (widget.individualEditors) {
      if (isRowHeader) {
        return TempEditorWidget(
          pId,
          rowHeaderWidget!,
        );
      }
      return TempEditorWidget(
        pId,
        displayWidget!,
      );
    }
    if (isRowHeader) {
      return vitalsGroupEditor(
        rowHeaderWidget!,
        isHorizontal: widget.isHorizontalEditor,
      );
    }
    return vitalsGroupEditor(
      displayWidget!,
      isHorizontal: widget.isHorizontalEditor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        futureVitalsPatternOptions,
        futureVitalsPattern,
        futureVitalsVisibility
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          debugPrint("Error or null data in snapshot: ${snapshot.error}");
          return const Center(
            child: Text('Failed to load vitals data. Please try again.'),
          );
        }

        lastVitalsPatternOptions = snapshot.data![0] as VitalsPatternOptions?;
        lastVitalsPattern = snapshot.data![1] as VitalsPattern?;
        lastVitalsVisibility = snapshot.data![2] as VitalsElementVisibility?;

        return buildVitalsTable();
      },
    );
  }

  Widget buildVitalsTable() {
    return SizedBox(
      height: 400, // Enforce a finite height for the table
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(100),
              1: FixedColumnWidth(100),
              2: FixedColumnWidth(300),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              buildHeaderRow(),
              buildVitalsRow(
                "EKG",
                VitalsType.ekg,
                ekgColor,
                lastVitalsVisibility?.ekg ?? false,
                lastVitalsPatternOptions?.ekg ?? [],
                lastVitalsPattern?.ekg ?? 0,
              ),
              buildVitalsRow(
                "BP",
                VitalsType.bp,
                bpColor,
                lastVitalsVisibility?.bp ?? false,
                lastVitalsPatternOptions?.bp ?? [],
                lastVitalsPattern?.bp ?? 0,
              ),
              buildVitalsRow(
                "SpO2",
                VitalsType.spo2,
                spo2Color,
                lastVitalsVisibility?.spo2 ?? false,
                lastVitalsPatternOptions?.spo2 ?? [],
                lastVitalsPattern?.spo2 ?? 0,
              ),
              buildVitalsRow(
                "EtCO2",
                VitalsType.etco2,
                etco2Color,
                lastVitalsVisibility?.etco2 ?? false,
                lastVitalsPatternOptions?.etco2 ?? [],
                lastVitalsPattern?.etco2 ?? 0,
              ),
              buildVitalsRow(
                "RR",
                VitalsType.rr,
                rrColor,
                lastVitalsVisibility?.rr ?? false,
                [], // No pattern options for RR
                0,
              ),
              buildVitalsRow(
                "Temp",
                VitalsType.temp,
                tempColor,
                lastVitalsVisibility?.temp ?? false,
                [], // No pattern options for Temp
                0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow buildHeaderRow() {
    return TableRow(
      children: [
        buildHeaderText("Vitals"),
        buildHeaderText("Visibility"),
        buildHeaderText("Pattern"),
      ],
    );
  }

  String getUnitForType(VitalsType type) {
    switch (type) {
      case VitalsType.ekg:
        return "per min";
      case VitalsType.bp:
        return "mmHg";
      case VitalsType.spo2:
        return "%";
      case VitalsType.etco2:
        return "mmHg";
      case VitalsType.rr:
        return "per min";
      case VitalsType.temp:
        return "F";
    }
  }

  TableRow buildVitalsRow(
    String label,
    VitalsType type,
    Color color,
    bool visibility,
    List<VitalsPatternOptionItem> options,
    int selectedPattern,
  ) {
    return TableRow(
      children: [
        vitalsGroupEditor(buildRowHeader(label, color)), // Clickable column
        VisibilitySwitchWidget(vitalsType: type, switchOn: visibility),
        PatternDropDownWidget(
          optionItemList: options,
          selectedItem: selectedPattern,
          vitalsType: type,
        ),
      ],
    );
  }

  Widget buildHeaderText(String text) {
    return MmsText(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Container buildRowHeader(String text, Color color) {
    return Container(
      color: Colors.black, // Lighter background color
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MmsText(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class PatternDropDownWidget extends StatelessWidget {
  final int maxTextSize = 35;
  final List<VitalsPatternOptionItem>? optionItemList;
  final int? selectedItem;
  final VitalsType vitalsType;

  const PatternDropDownWidget(
      {super.key,
      this.optionItemList,
      this.selectedItem,
      required this.vitalsType});

  static const _itemStyle = TextStyle(
    fontFamily: 'MmsSans',
    fontWeight: FontWeight.w500, // uses Roboto-Medium.ttf
    fontSize: 14,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    final items = buildMenuItems();

    return DropdownButton<int>(
      value: selectedItem,
      // Force a concrete, local font match for the button's visible label
      style: _itemStyle,
      dropdownColor: Colors.white, // make sure menu text is readable
      iconEnabledColor: Colors.black,
      selectedItemBuilder: (_) =>
          _selectedBuilders(), // ensure closed button text is styled
      items: items,
      onChanged: (newValue) {
        if (newValue == null) return;
        VitalsChangedNotification(
          changeType: VitalsChangeType.pattern,
          vitalsType: vitalsType,
          patternId: newValue,
          visibilityOn: true,
        ).dispatch(context);
      },
    );
  }

  List<DropdownMenuItem<int>> buildMenuItems() {
    final list = <DropdownMenuItem<int>>[];
    for (final patternItem
        in optionItemList ?? const <VitalsPatternOptionItem>[]) {
      list.add(
        DropdownMenuItem<int>(
          value: patternItem.value,
          child: Text(
            patternItem.patternName != null
                ? _padOrChop(patternItem.patternName!)
                : '',
            style: _itemStyle, // explicit style for menu rows
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    return list;
  }

  /// Ensures the label shown when the menu is CLOSED uses the same style.
  List<Widget> _selectedBuilders() {
    return [
      for (final patternItem
          in optionItemList ?? const <VitalsPatternOptionItem>[])
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            patternItem.patternName != null
                ? _padOrChop(patternItem.patternName!)
                : '',
            style: _itemStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];
  }

  String _padOrChop(String name) {
    if (name.length > maxTextSize) {
      return '${name.substring(0, maxTextSize - 3)}...';
    }
    return name;
  }
} // PatternDropDownWidget

class VisibilitySwitchWidget extends StatelessWidget {
  final bool switchOn;
  final VitalsType vitalsType;

  const VisibilitySwitchWidget({
    super.key,
    required this.vitalsType,
    this.switchOn = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Align items horizontally
      children: [
        Switch(
          value: switchOn,
          onChanged: (newValue) {
            VitalsChangedNotification(
              changeType: VitalsChangeType.visibility,
              vitalsType: vitalsType,
              visibilityOn: newValue,
              patternId: 0,
            ).dispatch(context);
          },
        ),
        switchOn
            ? const MmsText(
                'On',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              )
            : const MmsText(
                'Off',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
      ],
    );
  }
}
