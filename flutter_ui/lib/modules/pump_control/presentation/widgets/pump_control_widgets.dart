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

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_ui/modules/pump_control/data/models/pump_control_model.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/general/text/field_label_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

import '../../data/services/pump_control_services.dart';

// ==========================Scenarios=======================

class PumpControlSchedulingWidget extends StatefulWidget {
  final String? patientId;

  const PumpControlSchedulingWidget({super.key, this.patientId});

  @override
  _PumpControlSchedulingWidgetState createState() =>
      _PumpControlSchedulingWidgetState();
}

class _PumpControlSchedulingWidgetState
    extends State<PumpControlSchedulingWidget> {
  late Future<bool> _futureDoer;
  late MmsPumpControlScenarioService _service;
  late PumpControlScenarios _scenarios;
  late SelectedScenario _selectedScenario;

  Future<bool> initScenarios() async {
    try {
      _service = MmsPumpControlScenarioService();
      _scenarios = await _service.fetchScenarios(patientId: widget.patientId);
      _selectedScenario =
          await _service.fetchSelectedScenario(patientId: widget.patientId);
      return true;
    } catch (e) {
      throw Exception("Error attempting to initialize pump control scenarios");
    }
  }

  @override
  void initState() {
    super.initState();
    _futureDoer = initScenarios();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _futureDoer,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        try {
          if (!snapshot.hasData || !snapshot.data!) {
            return const Align(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: MmsText("Unable to Connect...")));
          }
          Widget scenariosDropdown = buildScenariosDropDownButton();
          Widget ratesWidget = buildRatesWidget();
          return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [scenariosDropdown, ratesWidget]);
        } catch (e) {
          return const Align(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: MmsText("Unable to Connect...")));
        }
      },
    );
  }

  static DropdownMenuItem<int> createDropDownMenuItem(int val, String name) {
    return DropdownMenuItem<int>(
      value: val,
      child: MmsText(name),
    );
  }

  static List<DropdownMenuItem<int>> buildScenariosDropDownList(
      PumpControlScenarios pumpControlScenarios) {
    List<DropdownMenuItem<int>> list = <DropdownMenuItem<int>>[];
    List<PumpControlScenario> scenariosList = pumpControlScenarios.scenarios;
    if (scenariosList.isEmpty) {
      list.add(createDropDownMenuItem(-1, "<No Scenarios Available>"));
    }
    for (var s in scenariosList) {
      list.add(createDropDownMenuItem(s.id, s.name));
    }
    return list;
  }

  DropdownButton<int> buildScenariosDropDownButton() {
    List<DropdownMenuItem<int>> dropdownMenuItems =
        buildScenariosDropDownList(_scenarios);
    int? currentId = _scenarios.isValidScenarioId(_selectedScenario.id)
        ? _selectedScenario.id
        : null;
    return DropdownButton<int>(
      items: dropdownMenuItems,
      value: currentId,
      onChanged: (int? newId) {
        postSelectedService(newId);
      },
    );
  }

  void postSelectedService(int? newId) async {
    SelectedScenario newSelectedScenario = await _service.postSelectedScenario(
        newId, _scenarios.scenarioNameForId(newId),
        patientId: widget.patientId);
    newSelectedScenario =
        await _service.fetchSelectedScenario(patientId: widget.patientId);
    setState(() {
      _selectedScenario = newSelectedScenario;
    });
  }

  Widget buildRatesWidget() {
    List<Widget> rateWidgetsList = buildRateWidgetsList();
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Column(children: rateWidgetsList));
  }

  List<Widget> buildRateWidgetsList() {
    List<Widget> rateWidgetsList = [];
    Widget? negWidget = buildRateWidget("neg");
    if (negWidget != null) {
      rateWidgetsList.add(negWidget);
    }
    Widget? lowWidget = buildRateWidget("low");
    if (lowWidget != null) {
      rateWidgetsList.add(lowWidget);
    }
    Widget? desiredWidget = buildRateWidget("desired");
    if (desiredWidget != null) {
      rateWidgetsList.add(desiredWidget);
    }
    Widget? highWidget = buildRateWidget("high");
    if (highWidget != null) {
      rateWidgetsList.add(highWidget);
    }
    if (rateWidgetsList.isEmpty) {
      rateWidgetsList.add(const MmsText("Can't connect..."));
    }
    return rateWidgetsList;
  }

  int defaultRateValue(String rateLabel) {
    if (rateLabel == "neg") {
      return 1;
    }
    if (rateLabel == "low") {
      return 2;
    }
    if (rateLabel == "desired") {
      return 4;
    }
    if (rateLabel == "high") {
      return 5;
    }
    return 4;
  }

  String getRateLongLabelForRateLabel(String rateLabel, int rateValue) {
    String capRateLabel = (rateLabel).isEmpty
        ? ""
        : "${rateLabel[0].toUpperCase()}${rateLabel.substring(1)}";
    return "$capRateLabel (${rateValue}ml/hr)";
  }

  Widget? buildRateWidget(String itemRateName) {
    int? id = _selectedScenario.id;
    PumpControlScenario? fullScenario = _scenarios.scenarioById(id);
    int itemRateValue = fullScenario?.getRateValueForRateLabel(itemRateName) ??
        defaultRateValue(itemRateName);
    String label = getRateLongLabelForRateLabel(itemRateName, itemRateValue);
    int selectedRateValue =
        _selectedScenario.rateValue ?? defaultRateValue("desired");
    Widget r = MmsText(label);
    try {
      r = SizedBox(
          width: 250.0,
          height: 30.0,
          child: RadioListTile<int>(
            activeColor: Colors.green,
            value: itemRateValue,
            groupValue: selectedRateValue,
            title: MmsText(label),
            selected: itemRateValue == selectedRateValue,
            onChanged: fullScenario != null
                ? (value) {
                    if (value != null) {
                      postNewRate(value);
                    }
                  }
                : null,
          ));
    } catch (e) {
      return null;
    }
    return r;
  }

  void postNewRate(int newRate) async {
    if ((_selectedScenario.id == null) || (_selectedScenario.name == null)) {
      return;
    }

    int id = _selectedScenario.id!;
    String name = _selectedScenario.name!;
    PumpControlScenario? fullScenario = _scenarios.scenarioById(id);
    if (fullScenario == null) {
      return;
    }
    String? rateLabel = fullScenario.getRateLabelForRateValue(newRate);
    if (rateLabel == null) {
      return;
    }
    SelectedScenario newSelectedScenario = await _service.postSelectedRate(
        id, name, rateLabel, newRate,
        patientId: widget.patientId);
    newSelectedScenario =
        await _service.fetchSelectedScenario(patientId: widget.patientId);
    setState(() {
      _selectedScenario = newSelectedScenario;
    });
  }
}

// =========================RuntimeStatus======================

class PumpControlRuntimeWidget extends StatefulWidget {
  final String? patientId;
  const PumpControlRuntimeWidget({super.key, this.patientId});

  @override
  _PumpControlRuntimeWidgetState createState() =>
      _PumpControlRuntimeWidgetState();
}

class _PumpControlRuntimeWidgetState extends State<PumpControlRuntimeWidget> {
  Timer? _checkTimer;
  RuntimeStatus? _runtimeStatus;
  late Future<RuntimeStatus> _futureRuntimeStatus;
  late MmsRuntimeStatusService _service;
  @override
  void initState() {
    super.initState();
    _service = MmsRuntimeStatusService();
    _futureRuntimeStatus =
        _service.fetchRuntimeStatuses(patientId: widget.patientId);
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (time) {
      setState(() {
        _futureRuntimeStatus =
            _service.fetchRuntimeStatuses(patientId: widget.patientId);
      });
    });
  }

  @override
  void dispose() {
    if (_checkTimer != null) {
      _checkTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RuntimeStatus>(
      future: _futureRuntimeStatus,
      builder: (context, AsyncSnapshot<RuntimeStatus> snapshot) {
        if (snapshot.hasData) {
          _runtimeStatus = snapshot.data;
        }
        return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MmsFieldLabelText(text: "Urine Pump"),
                    MmsText(_runtimeStatus?.urinePumpLabel ?? "<Unavailable>"),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MmsFieldLabelText(text: "Catheter"),
                        MmsText(
                            _runtimeStatus?.catheterLabel ?? "<Unavailable>"),
                      ],
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const MmsFieldLabelText(
                        text: "Dispense only if catheter is in"),
                    Switch(
                      value: _runtimeStatus?.dispenseRestricted ?? false,
                      onChanged: (newValue) {
                        postNewDispenseRestriction(newValue);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const MmsFieldLabelText(text: "Blood Pump"),
                    // TODO Should the blood pump default to "on" when we don't know for sure?
                    Switch(
                      value:
                          _runtimeStatus?.bloodPumpLabel?.toLowerCase() == "off"
                              ? false
                              : true,
                      onChanged: (newValue) {
                        postControlState(
                            newValue ? "BLOOD_PUMP_ON" : "BLOOD_PUMP_OFF");
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _runtimeStatus?.emergencyStopped != null
                        ? MmsPaddedRaisedButton(
                            _runtimeStatus?.emergencyStopped ?? false ? "Resume" : "Emergency Stop",
                            onPressed: () {
                            postControlState(
                                _runtimeStatus?.emergencyStopped ?? false
                                    ? "ESTOP_RESUME"
                                    : "ESTOP_STOP");
                          },
                            buttonStyle: ButtonStyle(
                                backgroundColor: _runtimeStatus?.emergencyStopped ?? false
                                    ? WidgetStateProperty.all<Color>(
                                        Colors.lightGreen)
                                    : WidgetStateProperty.all<Color>(
                                        Colors.pink),
                                foregroundColor:
                                    _runtimeStatus?.emergencyStopped ?? false
                                        ? WidgetStateProperty.all<Color>(
                                            Colors.white)
                                        : WidgetStateProperty.all<Color>(
                                            Colors.black)))
                        : MmsPaddedRaisedButton("Emergency Stop",
                            onPressed: null,
                            buttonStyle: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(Colors.grey),
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.black38)))
                  ],
                ),
              ],
            ));
      },
    );
  }

  void postNewDispenseRestriction(bool newValue) {
    setState(() {
      _futureRuntimeStatus = _service.postDispenseRestriction(newValue,
          patientId: widget.patientId);
    });
  }

  void postControlState(String action) {
    setState(() {
      _futureRuntimeStatus =
          _service.postControlStop(action, patientId: widget.patientId);
    });
  }
}
