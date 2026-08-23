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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:provider/provider.dart';

import '../../data/models/labs_model.dart';
import '../../data/services/labs_rest_services.dart';

enum ChangeType { scenario, selectedToTab, selectedFromTab }

enum CardChangeType { hcgOrEldon, blood, urinalysis }

class ScenarioChangedNotification extends Notification {
  final String? patientId;
  final ChangeType changeType;
  final CardChangeType? cardChangeType;
  const ScenarioChangedNotification(
      this.patientId, this.changeType, this.cardChangeType);
}

class LabsScreen extends StatefulWidget {
  final String? patientId;
  const LabsScreen({super.key, this.patientId});

  @override
  _LabsScreen createState() => _LabsScreen();
}

class _LabsScreen extends State<LabsScreen> {
  Future<ExecutionList>? futureExecutionList;

  @override
  void initState() {
    super.initState();
    futureExecutionList = MmsLabsExecutionService()
        .fetchLabsExecution(patientId: widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExecutionList>(
        future: futureExecutionList,
        builder: (context, AsyncSnapshot<ExecutionList> snapshot) {
          String patientLabel = "";
          if (widget.patientId != null) {
            patientLabel = " - ${widget.patientId}";
          }
          return NotificationListener<ScenarioChangedNotification>(
            onNotification: (notification) {
              setState(() {
                if (notification.changeType == ChangeType.scenario) {
                  futureExecutionList = MmsLabsExecutionService()
                      .fetchLabsExecution(patientId: widget.patientId);
                } else {
                  bool addToTablet =
                      false; // default for ChangeType.selectedFromTab
                  if (notification.changeType == ChangeType.selectedToTab) {
                    addToTablet = true;
                  }
                  bool affectsHcgOrEldon =
                      notification.cardChangeType == CardChangeType.hcgOrEldon;
                  bool affectsBlood =
                      notification.cardChangeType == CardChangeType.blood;
                  bool affectsUrinalysis =
                      notification.cardChangeType == CardChangeType.urinalysis;
                  LabCardDataSet labCardDataSet =
                      LabCardDataSetStore().getLabCardDataSet(widget.patientId);

                  ExecutionList exList = ExecutionList();

                  if (affectsHcgOrEldon &&
                      labCardDataSet.hcgLabCardData.selected) {
                    exList.hcgLab = labCardDataSet.hcgLabCardData
                        .toExecutionLab(addToTablet);
                  }

                  if (affectsHcgOrEldon &&
                      labCardDataSet.eldonLabCardData.selected) {
                    exList.eldonLab = labCardDataSet.eldonLabCardData
                        .toExecutionLab(addToTablet);
                  }

                  exList.bloodLabs = <ExecutionLab>[];
                  if (affectsBlood) {
                    for (LabCardData bLab in labCardDataSet.bloodLabCardArray) {
                      if (bLab.selected) {
                        exList.bloodLabs?.add(bLab.toExecutionLab(addToTablet));
                      }
                    }
                  }

                  exList.urineLabs = <ExecutionLab>[];
                  if (affectsUrinalysis) {
                    for (LabCardData uLab
                        in labCardDataSet.urinalysisLabCardArray) {
                      if (uLab.selected) {
                        exList.urineLabs?.add(uLab.toExecutionLab(addToTablet));
                      }
                    }
                  }
                  futureExecutionList = MmsLabsExecutionService()
                      .postLabsExecution(exList, patientId: widget.patientId);
                }
              });
              return true;
            },
            child: Wrap(children: <Widget>[
              Panel(
                  width: 300,
                  height: 40,
                  text: "Scenario$patientLabel",
                  widget: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ScenarioPanelWidget(patientId: widget.patientId))),
              Panel(
                  width: 400,
                  height: 40,
                  text: "Blood Labs",
                  widget: Padding(
                      padding: const EdgeInsets.all(4),
                      child: BloodLabsPanelWidget(widget.patientId))),
              Panel(
                  width: 400,
                  height: 40,
                  text: "Urinalysis Labs",
                  widget: Padding(
                      padding: const EdgeInsets.all(4),
                      child: UrineLabsPanelWidget(widget.patientId))),
            ]),
          );
        });
  }
}

class ScenarioPanelWidget extends StatefulWidget {
  final String? patientId;

  const ScenarioPanelWidget({super.key, this.patientId});

  @override
  _ScenarioPanelWidgetState createState() => _ScenarioPanelWidgetState();
}

class _ScenarioPanelWidgetState extends State<ScenarioPanelWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        const MmsFieldLabelText(
          text: "Scenario:",
        ),
        ScenarioDropDownWidget(patientId: widget.patientId),
      ]),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: 2.0,
          width: 250.0,
          color: Colors.black,
        ),
      ),
      const SizedBox(
        height: 20,
        child: MmsText("Single Labs "),
      ),
      SingleLabs(widget.patientId),
    ]);
  }
}

class SingleLabs extends StatefulWidget {
  final String? patientId;

  const SingleLabs(this.patientId, {super.key});

  @override
  _SingleLabs createState() => _SingleLabs();
}

class _SingleLabs extends State<SingleLabs> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LabCardDataSetStoreAccess>(
        create: (_) => LabCardDataSetStoreAccess(),
        builder: (context, _) {
          return Selector<LabCardDataSetStoreAccess, LabCardDataSet>(
            builder: (context, labCardDataSet, _) {
              return Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              LabCardDataSetStore().selectHcgAndEldonLabCard(
                                  widget.patientId, true);
                            },
                            child: const MmsText("Select All")),
                        ElevatedButton(
                            onPressed: () {
                              ScenarioChangedNotification(
                                      widget.patientId,
                                      ChangeType.selectedToTab,
                                      CardChangeType.hcgOrEldon)
                                  .dispatch(context);
                            },
                            child: const MmsText("Show Learner")),
                        ElevatedButton(
                            onPressed: () {
                              ScenarioChangedNotification(
                                      widget.patientId,
                                      ChangeType.selectedFromTab,
                                      CardChangeType.hcgOrEldon)
                                  .dispatch(context);
                            },
                            child: const MmsText("Hide")),
                      ]),
                  const Padding(
                    padding: EdgeInsets.all(1.0),
                    child: SizedBox(
                      height: 1.0,
                      width: 1.0,
                    ),
                  ),
                  Row(children: <Widget>[
                    Column(children: <Widget>[
                      const MmsText("HCG"),
                      SelectableCard(
                        widget.patientId,
                        labCardDataSet.hcgLabCardData,
                      ),
                    ]),
                    Column(children: <Widget>[
                      const MmsText("Eldon Card"),
                      SelectableCard(
                        widget.patientId,
                        labCardDataSet.eldonLabCardData,
                      ),
                    ])
                  ]),
                ],
              );
            },
            selector: (buildContext, access) =>
                access.store.getLabCardDataSet(widget.patientId),
            shouldRebuild: (LabCardDataSet prev, LabCardDataSet next) =>
                prev.hcgLabCardData != next.hcgLabCardData ||
                prev.eldonLabCardData != next.eldonLabCardData,
          );
        });
  }
}

class SelectableCard extends StatefulWidget {
  final LabCardData cardData;
  final String? patientId;
  const SelectableCard(this.patientId, this.cardData, {super.key});

  @override
  _SelectableCard createState() => _SelectableCard();
}

class _SelectableCard extends State<SelectableCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    LabCardData widgetCardData = widget.cardData;
    return widgetCardData.type == LabCardType.empty
        ? const SizedBox(width: 100, height: 40, child: MmsText(" "))
        : MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () {
                  LabCardDataSetStore()
                      .toggleLabCard(widget.patientId, widgetCardData);
                },
                child: Card(
                    shape: widgetCardData.selected
                        ? RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Colors.blue, width: 2.0),
                            borderRadius:
                                BorderRadius.circular(4.0) // Corrected
                            )
                        : RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Colors.white, width: 2.0),
                            borderRadius:
                                BorderRadius.circular(4.0) // Corrected
                            ),
                    color: widgetCardData.onTablet
                        ? behindCardColor
                        : widgetCardData.cardColor,
                    child: widgetCardData.onTablet
                        ? Container(
                            width: 100,
                            height: 40,
                            padding: const EdgeInsets.all(2),
                            child: Stack(children: <Widget>[
                              Align(
                                  alignment: Alignment.center,
                                  child: MmsText(widgetCardData.displayText)),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Image.asset("images/open_eye.png",
                                      package: "common", height: 16.0)),
                            ]))
                        : Container(
                            width: 100,
                            height: 40,
                            padding: const EdgeInsets.all(2),
                            child: Stack(children: <Widget>[
                              Align(
                                  alignment: Alignment.center,
                                  child: MmsText(widgetCardData.displayText)),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Image.asset("images/closed_eye_25.png",
                                      package: "common",
                                      colorBlendMode: BlendMode.modulate,
                                      height: 16.0)),
                            ])))),
          );
  }
}

class BloodLabsPanelWidget extends StatefulWidget {
  final String? patientId;

  const BloodLabsPanelWidget(this.patientId, {super.key});

  @override
  _BloodLabs createState() => _BloodLabs();
}

class _BloodLabs extends State<BloodLabsPanelWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LabCardDataSetStoreAccess>(
        create: (_) => LabCardDataSetStoreAccess(),
        builder: (context, _) {
          return Selector<LabCardDataSetStoreAccess, LabCardDataSet>(
            builder: (context, labCardDataSet, _) {
              return Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              LabCardDataSetStore().selectAllBloodLabCards(
                                  widget.patientId, true);
                            },
                            child: const MmsText("Select All")),
                        ElevatedButton(
                            onPressed: () {
                              ScenarioChangedNotification(
                                widget.patientId,
                                ChangeType.selectedToTab,
                                CardChangeType.blood,
                              ).dispatch(context);
                            },
                            child: const MmsText("Show Learner")),
                        ElevatedButton(
                            onPressed: () {
                              ScenarioChangedNotification(
                                widget.patientId,
                                ChangeType.selectedFromTab,
                                CardChangeType.blood,
                              ).dispatch(context);
                            },
                            child: const MmsText("Hide")),
                      ]),
                  SizedBox(
                      width: 400,
                      height: 300,
                      child: Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollController,
                          child: GridView.count(
                              controller: _scrollController,
                              crossAxisCount: 3,
                              childAspectRatio: 100 / 40,
                              children: <Widget>[
                                for (LabCardData data
                                    in labCardDataSet.bloodLabCardArray)
                                  SelectableCard(
                                    widget.patientId,
                                    data,
                                  )
                              ]))),
                ],
              );
            },
            selector: (buildContext, access) =>
                access.store.getLabCardDataSet(widget.patientId),
            shouldRebuild: (LabCardDataSet prev, LabCardDataSet next) =>
                !listEquals(prev.bloodLabCardArray, next.bloodLabCardArray),
          );
        });
  }
}

class UrineLabsPanelWidget extends StatefulWidget {
  final String? patientId;
  const UrineLabsPanelWidget(this.patientId, {super.key});
  @override
  _UrineLabs createState() => _UrineLabs();
}

class _UrineLabs extends State<UrineLabsPanelWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LabCardDataSetStoreAccess>(
        create: (_) => LabCardDataSetStoreAccess(),
        builder: (context, _) {
          return Selector<LabCardDataSetStoreAccess, LabCardDataSet>(
            builder: (context, labCardDataSet, _) {
              return Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              LabCardDataSetStore().selectAllUrinalysisLabCards(
                                  widget.patientId, true);
                            },
                            child: const MmsText("Select All")),
                        ElevatedButton(
                            onPressed: () {
                              ScenarioChangedNotification(
                                widget.patientId,
                                ChangeType.selectedToTab,
                                CardChangeType.urinalysis,
                              ).dispatch(context);
                            },
                            child: const MmsText("Show Learner")),
                        ElevatedButton(
                            onPressed: () {
                              ScenarioChangedNotification(
                                widget.patientId,
                                ChangeType.selectedFromTab,
                                CardChangeType.urinalysis,
                              ).dispatch(context);
                            },
                            child: const MmsText("Hide")),
                      ]),
                  SizedBox(
                      width: 400,
                      height: 300,
                      child: Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollController,
                          child: GridView.count(
                              controller: _scrollController,
                              crossAxisCount: 3,
                              childAspectRatio: 100 / 40,
                              children: <Widget>[
                                for (LabCardData data
                                    in labCardDataSet.urinalysisLabCardArray)
                                  SelectableCard(
                                    widget.patientId,
                                    data,
                                  )
                              ]))),
                ],
              );
            },
            selector: (buildContext, access) =>
                access.store.getLabCardDataSet(widget.patientId),
            shouldRebuild: (LabCardDataSet prev, LabCardDataSet next) =>
                !listEquals(
                    prev.urinalysisLabCardArray, next.urinalysisLabCardArray),
          );
        });
  }
}

class ScenarioDropDownWidget extends StatefulWidget {
  final String? patientId;

  const ScenarioDropDownWidget({super.key, this.patientId});

  @override
  _ScenarioDropDownWidgetState createState() => _ScenarioDropDownWidgetState();
}

class _ScenarioDropDownWidgetState extends State<ScenarioDropDownWidget> {
  late Future<Scenario?> futureSelectedScenario;
  late Future<List<Scenario>> futureScenarioList;
  String? alertChoice;

  @override
  void initState() {
    super.initState();
    futureSelectedScenario = MmsTruMonitorScenarioService()
        .fetchExecutionScenario(patientId: widget.patientId);
    futureScenarioList = MmsTruMonitorScenarioService()
        .fetchScenarios(patientId: widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([futureScenarioList, futureSelectedScenario]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        String selectedValue = "<none>";
        bool hasScenarios = false;
        List<DropdownMenuItem<String>> menuItemList =
            <DropdownMenuItem<String>>[];

        if (snapshot.connectionState == ConnectionState.waiting) {
          menuItemList.add(createDropDownMenuItem("<none>", "<No Scenarios>"));
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          List<Scenario> scenarioList = snapshot.data?[0] as List<Scenario>;
          if (snapshot.data?[1] != null) {
            selectedValue = (snapshot.data?[1] as Scenario).id ?? "<none>";
          } else if (selectedValue == "<none>" && scenarioList.isNotEmpty) {
            menuItemList
                .add(createDropDownMenuItem("<none>", "<Select a Scenario>"));
          }
          for (Scenario item in scenarioList) {
            menuItemList.add(createDropDownMenuItem(item.id, item.name));
          }
          if (menuItemList.isEmpty) {
            menuItemList
                .add(createDropDownMenuItem("<none>", "<No Scenarios>"));
          } else {
            hasScenarios = true;
          }
        }

        return DropdownButton<String>(
          value: selectedValue,
          items: menuItemList,
          onChanged: (newValue) {
            if (hasScenarios &&
                newValue != selectedValue &&
                newValue != "<none>") {
              _showMyDialog(newValue).then((continuePressed) {
                if (continuePressed ?? false) {
                  futureSelectedScenario = MmsTruMonitorScenarioService()
                      .postExecutionScenario(newValue,
                          patientId: widget.patientId)
                      .whenComplete(() {
                    if (mounted) {
                      // Ensure the widget is still mounted before using context
                      ScenarioChangedNotification(
                        widget.patientId,
                        ChangeType.scenario,
                        null,
                      ).dispatch(context);
                    }
                  });
                }
              });
            }
          },
        );
      },
    );
  }

  DropdownMenuItem<String> createDropDownMenuItem(
      String? id, String? displayText) {
    return DropdownMenuItem<String>(
      value: id,
      child: MmsText(_padOrChop(displayText ?? "")),
    );
  }

  String _padOrChop(String scenarioName) {
    if (scenarioName.length > 20) {
      return "${scenarioName.substring(0, 17)}...";
    } else if (scenarioName.length < 20) {
      return scenarioName.padRight(20 - scenarioName.length, " ");
    } else {
      return scenarioName;
    }
  }

  Future<bool?> _showMyDialog(String? scenId) {
    alertChoice = null;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const MmsText('Change Scenario '),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                MmsText(
                    'Changing a scenario will clear any existing labs off the learner tablet.'),
                MmsText('Do you want to continue?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const MmsText('Cancel'),
              onPressed: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop(false);
                }
              },
            ),
            TextButton(
              child: const MmsText('Continue'),
              onPressed: () {
                if (mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
            ),
          ],
        );
      },
    );
  }
} // of _ScenarioDropDownWidget

class LabCardWidget extends StatelessWidget {
  final String? displayText;
  final Color? cardColor;

  const LabCardWidget({super.key, this.displayText, this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: SizedBox(
          width: 100,
          height: 40,
          child:
              Align(alignment: Alignment.center, child: MmsText(displayText))),
    );
  }
}
