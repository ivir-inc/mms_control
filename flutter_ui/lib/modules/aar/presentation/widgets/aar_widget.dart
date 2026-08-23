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
import 'package:flutter_ui/data/provider/patients/patients_service.dart';
import 'package:provider/provider.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_ui/data/model/patients/patients_model.dart';
import 'package:flutter_ui/data/model/recent_events/recent_events_model.dart';
import 'package:flutter_ui/logic/utils/string_utils.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/services/unstructured_data_stores.dart';

import '../../data/models/aar_model.dart';

Logger _logger = Logger(
  "AarWidget",
  debugging: true,
);

class PatientEventsAndVitalsCombo extends Equatable {
  final List<RecentEventsModel> recentEventsModels;
  final List<String> patientIds;
  final SinglePatientInfo? patientInfo;
  final List<Map<String, dynamic>> vitalsList;
  final int timelineSeconds;
  final int startSeconds;
  final int endSeconds;
  const PatientEventsAndVitalsCombo({
    required this.recentEventsModels,
    required this.patientIds,
    this.patientInfo,
    required this.vitalsList,
    required this.timelineSeconds,
    required this.startSeconds,
    required this.endSeconds,
  });

  static const emptyCombo = PatientEventsAndVitalsCombo(
    recentEventsModels: [],
    patientIds: [],
    vitalsList: [],
    timelineSeconds: 0,
    startSeconds: 0,
    endSeconds: 0,
  );

  int get numMinutes => ((endSeconds + 1 - startSeconds) / 60).ceil();

  @override
  List<Object?> get props => [
        recentEventsModels,
        patientIds,
        patientInfo,
        vitalsList,
        timelineSeconds,
      ];
}

const String _selectedAarPatientIdDataType = "SelectedAarPatientId";
const String _selectedAarPatientIdTimelineId = "Timeline";
const String _noPatientIdStoredYet = "__NO__";
const String _selectedAarSecondsDataType = "SelectedAarSeconds";

class AarTimelineWidget extends StatefulWidget {
  const AarTimelineWidget({super.key});

  @override
  _AarTimelineWidgetState createState() => _AarTimelineWidgetState();

  static void initStores() {
    VitalsAarStore.instance();
    PatientInfoStore();
    RecentEventsStore();
  }
}

class _AarTimelineWidgetState extends State<AarTimelineWidget> {
  VitalsAarStore? vitalsAarStore;
  Future<VitalsAarStore> futureVitalsAarStore = VitalsAarStore.instance();
  bool hasAddedListenerForVitals = false;

  @override
  void initState() {
    RawStringStore().limitOne(
      _selectedAarPatientIdDataType,
      _selectedAarPatientIdTimelineId,
    );
    _logger.log(1, "Fetching patient info");
    MmsPatientsService().fetchPatientsInfo(callback: refresh);
    _logger.log(2, "Fetched patient info");
    super.initState();
  }

  @override
  void dispose() {
    if (hasAddedListenerForVitals) {
      vitalsAarStore?.removeListener(refresh);
    }
    super.dispose();
  }

  void refresh() {
    setState(() {
      _logger.log(10, "Refresh - AarTimelineWidget");
      List<String> patientIds = PatientInfoStore().patientIds;
      _logger.log(10, "Patient Ids:");
      _logger.log(10, patientIds.toString());

      String? patientId = RawStringStore().first(
        _selectedAarPatientIdDataType,
        _selectedAarPatientIdTimelineId,
        def: _noPatientIdStoredYet,
      );
      String newPatientId = _noPatientIdStoredYet;
      if (patientId != null && patientIds.contains(patientId)) {
        newPatientId = patientId;
      } else {
        newPatientId =
            patientIds.isNotEmpty ? patientIds.first : _noPatientIdStoredYet;
      }
      _logger.log(
          10, "New patient id stored for dropdown button: $newPatientId");
      RawStringStore().storeRawStringByDataType(_selectedAarPatientIdDataType,
          _selectedAarPatientIdTimelineId, newPatientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        return FutureBuilder<VitalsAarStore>(
            future: futureVitalsAarStore,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.expand(
                  child: MmsText("Loading data..."),
                );
              }
              vitalsAarStore = snapshot.data;
              if (!hasAddedListenerForVitals) {
                vitalsAarStore?.addListener(refresh);
                hasAddedListenerForVitals = true;
              }
              return MultiProvider(
                  providers: [
                    // ChangeNotifierProvider<VitalsAarStoreAccess>(
                    //     create: (_) => VitalsAarStoreAccess()),
                    ChangeNotifierProvider<PatientInfoStoreAccess>(
                        create: (_) => PatientInfoStoreAccess()),
                    ChangeNotifierProvider<RecentEventsStoreAccess>(
                        create: (_) => RecentEventsStoreAccess()),
                    ChangeNotifierProvider<RawStringStoreAccess>(
                        create: (_) => RawStringStoreAccess()),
                    ChangeNotifierProvider<PrimitivesStoreAccess>(
                        create: (_) => PrimitivesStoreAccess()),
                  ],
                  builder: (context, _) {
                    return Selector4<
//                        VitalsAarStoreAccess,
                        PatientInfoStoreAccess,
                        RecentEventsStoreAccess,
                        RawStringStoreAccess,
                        PrimitivesStoreAccess,
                        PatientEventsAndVitalsCombo>(
                      builder: (context, comboModel, _) {
                        // Get the nearest Vitals model to the
                        // selected comboModel.timelineSeconds value.
                        Map<String, dynamic>? cvMap =
                            closestVitalsMap(comboModel);
                        return Column(
                          children: [
                            Row(
                              children: [
                                const PatientSelectDropDownButton(),
                                if (cvMap != null)
                                  ClosestVitalsDisplay(
                                    vitalsMap: cvMap,
                                    startSeconds: comboModel.startSeconds,
                                  ),
                              ],
                            ),
                            Center(
                              child: AarDrawTimelineWidget(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight / 3,
                                numMinutes: comboModel.numMinutes,
                              ),
                            ),
                          ],
                        );
                      },
                      selector: (buildContext, /* vaAccess, */ patAccess,
                          recAccess, rawStrAccess, primitivesAccess) {
                        bool hasVaStore = vitalsAarStore != null;
                        _logger.log(3, "Has Va Store? $hasVaStore");
                        int timelineSeconds = primitivesAccess.store.intData(
                            _selectedAarSecondsDataType,
                            _selectedAarPatientIdTimelineId);
                        String? patientId = rawStrAccess.store.first(
                          _selectedAarPatientIdDataType,
                          _selectedAarPatientIdTimelineId,
                          def: _noPatientIdStoredYet,
                        );
                        if (patientId == _noPatientIdStoredYet) {
                          return PatientEventsAndVitalsCombo.emptyCombo;
                        }
                        List<Map<String, dynamic>> vitalsList =
                            vitalsAarStore?.patientVitalsList(patientId!) ?? [];
                        List<String> patientIds = patAccess.store.patientIds;
                        SinglePatientInfo? patientInfo =
                            patAccess.store.patientInfo(patientId!);
                        List<RecentEventsModel> recentEvents =
                            recAccess.store.eventsList;
                        int startSeconds =
                            vitalsAarStore?.firstSecondsForPatient(patientId) ??
                                0;
                        int endSeconds =
                            vitalsAarStore?.lastSecondsForPatient(patientId) ??
                                0;
                        if (endSeconds < startSeconds) {
                          endSeconds = startSeconds;
                        }
                        return PatientEventsAndVitalsCombo(
                          recentEventsModels: recentEvents,
                          patientIds: patientIds,
                          patientInfo: patientInfo,
                          vitalsList: vitalsList,
                          timelineSeconds: timelineSeconds,
                          startSeconds: startSeconds,
                          endSeconds: endSeconds,
                        );
                      },
                      shouldRebuild: (prev, next) => prev != next,
                    );
                  });
            });
      }),
    );
  }

  Map<String, dynamic>? closestVitalsMap(PatientEventsAndVitalsCombo model) {
    int wallMsForVitals = (model.timelineSeconds + model.startSeconds) * 1000;
    _logger.log(323, "Wall Ms for Vitals: $wallMsForVitals");
    List<Map<String, dynamic>> vitalsMapsList = model.vitalsList;
    int listLen = vitalsMapsList.length;
    _logger.log(323, "Vitals List Length: $listLen");
    if (vitalsMapsList.isEmpty) {
      return null;
    } else if (vitalsMapsList.length == 1) {
      return vitalsMapsList.first;
    }
    Map<String, dynamic> retMap = vitalsMapsList.first;
    int count = 0;
    for (Map<String, dynamic> vitalsMap in vitalsMapsList) {
      dynamic timestamp = vitalsMap["timestamp"];
      ++count;
      _logger.log(323, "Vitals Map Count: $count");
      _logger.log(323, "Timestamp: $timestamp");
      if (timestamp is int) {
        if (timestamp > wallMsForVitals) {
          if ((wallMsForVitals - (retMap["timestamp"] ?? 0)) <
              (timestamp - wallMsForVitals)) {
            return retMap;
          } else {
            return vitalsMap;
          }
        }
        retMap = vitalsMap;
      }
    }
    return retMap;
  }
}

class ClosestVitalsDisplay extends StatefulWidget {
  final Map<String, dynamic> vitalsMap;
  final int startSeconds;
  const ClosestVitalsDisplay({
    super.key,
    required this.vitalsMap,
    required this.startSeconds,
  });

  @override
  _ClosestVitalsDisplayState createState() => _ClosestVitalsDisplayState();
}

class _ClosestVitalsDisplayState extends State<ClosestVitalsDisplay> {
  @override
  Widget build(BuildContext context) {
    double bpHi = widget.vitalsMap["systolicBp"];
    double bpLo = widget.vitalsMap["diastolicBp"];
    double ekg = widget.vitalsMap["heartRate"];
    double temp = widget.vitalsMap["temp"];
    double rr = widget.vitalsMap["respiratoryRate"];
    double etco2 = widget.vitalsMap["etco2"];
    double spo2 = widget.vitalsMap["spO2"];
    int timestamp = widget.vitalsMap["timestamp"];
    String timeString =
        RecentEventsModel.timeString(timestamp - (widget.startSeconds * 1000));
    return Container(
      color: MmsColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MmsText("Time: $timeString"),
          MmsText("Ekg: $ekg"),
          MmsText("BP: $bpHi/$bpLo"),
          MmsText("Temp: $temp"),
          MmsText("RR: $rr"),
          MmsText("Etco2: $etco2"),
          MmsText("Spo2: $spo2"),
        ],
      ),
    );
  }
}

class AarDrawTimelineWidget extends StatefulWidget {
  final double width;
  final double height;
  final int numMinutes;
  const AarDrawTimelineWidget({
    super.key,
    required this.width,
    required this.height,
    required this.numMinutes,
  });

  @override
  _AarDrawTimelineWidgetState createState() => _AarDrawTimelineWidgetState();
}

class _AarDrawTimelineWidgetState extends State<AarDrawTimelineWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {}, // Need this to be able to do onTapDown.
      onTapDown: (details) {
        _logger.log(10, "tap down");
        double dx = details.localPosition.dx;
        AarTimelineDetails timelineDetails = AarTimelineDetails(
          numMinutes: widget.numMinutes,
          width: widget.width,
        );
        if (dx < timelineDetails.left) {
          dx = timelineDetails.left;
        } else if (dx > timelineDetails.right) {
          dx = timelineDetails.right;
        }
        double fraction = (dx - timelineDetails.left) /
            (timelineDetails.right - timelineDetails.left);
        double minorTicks = timelineDetails.drawWidth *
            fraction /
            timelineDetails.widthPerMinorTick;
        double minutesSelected =
            minorTicks * timelineDetails.numMinsPerMinorTick;
        double dSecondsSelected = minutesSelected * 60;
        int secondsSelected = dSecondsSelected.round();
        setState(() {
          _logger.log(10, "$secondsSelected");
          PrimitivesStore().storeIntByDataType(
            _selectedAarSecondsDataType,
            _selectedAarPatientIdTimelineId,
            secondsSelected,
          );
        });
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.white,
        child: CustomPaint(
          painter: AarTimelinePainter(
            numMinutes: widget.numMinutes,
          ),
        ),
      ),
    );
  }
}

class AarTimelineDetails {
  double widthPerMinorTick = 0;
  double widthPerMinute = 0;
  double numMinsPerMinorTick = 0;
  double left = 0;
  double right = 0;
  double drawWidth = 0;

  AarTimelineDetails({
    required double width,
    required int numMinutes,
    double minMinorTicksSpace = 25,
  }) {
    _calculate(width, numMinutes, minMinorTicksSpace);
  }

  void _calculate(
    double width,
    int numMinutes,
    double minMinorTicksSpace,
  ) {
    left = width * 0.1;
    right = width * 0.9;
    drawWidth = right - left;

    int useNumMinutes = numMinutes;
    if (useNumMinutes < 1) {
      useNumMinutes = 1;
    }
    widthPerMinute = (drawWidth / useNumMinutes) * 0.9999;
    widthPerMinorTick = widthPerMinute;
    numMinsPerMinorTick = 1;
    List<double> minorTickPartitions = [
      1.5,
      2.5,
      5,
      7.5,
    ];
    while (widthPerMinorTick < minMinorTicksSpace) {
      numMinsPerMinorTick++;
      widthPerMinorTick += widthPerMinute;
    }
    double minorTickPartition = 1;
    int expTen = 1;
    int loopCount = 0;
    while (numMinsPerMinorTick > minorTickPartition) {
      minorTickPartition = minorTickPartitions[loopCount] * expTen;
      ++loopCount;
      if (loopCount >= minorTickPartitions.length) {
        loopCount = 0;
        expTen *= 10;
      }
    }
    numMinsPerMinorTick = minorTickPartition;
    widthPerMinorTick = numMinsPerMinorTick * widthPerMinute;
  }
}

class AarTimelinePainter extends CustomPainter {
  final int numMinutes;
  final double minMinorTicksSpace;
  AarTimelinePainter({
    required this.numMinutes,
    this.minMinorTicksSpace = 25,
  });

  @override
  void paint(Canvas canvas, Size size) {
    AarTimelineDetails details = AarTimelineDetails(
      width: size.width,
      numMinutes: numMinutes,
      minMinorTicksSpace: minMinorTicksSpace,
    );

    const Offset topLeft = Offset(4, 4);
    Offset bottomRight = Offset(size.width - 4, size.height - 4);
    Offset leftEnd = Offset(details.left, size.height * 0.5);
    Offset rightEnd = Offset(details.right, size.height * 0.5);
    double drawWidth = details.drawWidth;
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Rect rect = Rect.fromPoints(topLeft, bottomRight);
    canvas.drawRect(rect, paint);
    canvas.drawLine(leftEnd, rightEnd, paint);
    paint.strokeWidth = 1;

    drawTick(canvas, paint, leftEnd, 0, 4, label: "0");
    double totalSpaceDrawn = details.widthPerMinorTick;
    int count = 0;
    while (totalSpaceDrawn <= drawWidth) {
      count++;
      double numMins = count * details.numMinsPerMinorTick;
      drawTick(
        canvas,
        paint,
        leftEnd,
        totalSpaceDrawn,
        4,
        label: count % 4 == 0 ? "$numMins" : null,
      );
      totalSpaceDrawn += details.widthPerMinorTick;
    }

    int selectedSecondsMark = PrimitivesStore()
        .intData(_selectedAarSecondsDataType, _selectedAarPatientIdTimelineId);
    paint.color = MmsColors.green;
    paint.strokeWidth = 4;
    double minutesMark = details.widthPerMinute * selectedSecondsMark / 60;
    drawTick(
      canvas,
      paint,
      leftEnd,
      minutesMark,
      16,
    );
  }

  void drawTick(
    Canvas canvas,
    Paint paint,
    Offset leftEnd,
    double dxDist,
    double dyDist, {
    String? label,
  }) {
    double useDyDist = dyDist;
    if (label != null) {
      useDyDist = 2 * dyDist;
    }
    Offset topOffset = Offset(leftEnd.dx + dxDist, leftEnd.dy - useDyDist);
    Offset bottomOffset = Offset(leftEnd.dx + dxDist, leftEnd.dy + useDyDist);
    canvas.drawLine(topOffset, bottomOffset, paint);
    if (label != null) {
      TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.black),
        text: label,
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
          canvas,
          Offset(leftEnd.dx + dxDist - (tp.size.width / 2),
              leftEnd.dy + 2 * useDyDist));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate != this);
  }
}

class PatientSelectDropDownButton extends StatefulWidget {
  final Function? onChanged;
  const PatientSelectDropDownButton({
    super.key,
    this.onChanged,
  });

  @override
  _PatientSelectDropDownButtonState createState() =>
      _PatientSelectDropDownButtonState();
}

class PatientComboInfo extends Equatable {
  final String patientId;
  final List<String> patientIds;

  const PatientComboInfo({
    required this.patientId,
    required this.patientIds,
  });

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        patientId,
        patientIds,
      ];
}

class _PatientSelectDropDownButtonState
    extends State<PatientSelectDropDownButton> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<PatientInfoStoreAccess>(
              create: (_) => PatientInfoStoreAccess()),
          ChangeNotifierProvider<RawStringStoreAccess>(
              create: (_) => RawStringStoreAccess()),
        ],
        builder: (context, _) {
          return Selector2<PatientInfoStoreAccess, RawStringStoreAccess,
              PatientComboInfo>(
            builder: (context, info, __) {
              List<DropdownMenuItem<String>> patientDropdownList =
                  createMenuList(info.patientId, info.patientIds);
              DropdownButton<String> patientIdMenu = DropdownButton<String>(
                value: info.patientId,
                items: patientDropdownList,
                onChanged: info.patientIds.isEmpty
                    ? null
                    : (newValue) async {
                        widget.onChanged?.call();
                        RawStringStore().storeRawStringByDataType(
                            _selectedAarPatientIdDataType,
                            _selectedAarPatientIdTimelineId,
                            newValue ?? _noPatientIdStoredYet);
                      },
              );
              return Container(
                  color: MmsColors.white,
                  padding: const EdgeInsets.all(4),
                  child: patientIdMenu);
            },
            selector: (buildContext, pInfoAccess, rawStrAccess) {
              String? patientId = RawStringStore().first(
                _selectedAarPatientIdDataType,
                _selectedAarPatientIdTimelineId,
                def: _noPatientIdStoredYet,
              );
              List<String> patientIds = PatientInfoStore().patientIds;
              _logger.log(
                  100, "Building Patient IDs dropdown button. Patient IDs:");
              _logger.log(100, patientIds.toString());
              return PatientComboInfo(
                patientId: patientId ?? _noPatientIdStoredYet,
                patientIds: patientIds,
              );
            },
            shouldRebuild: (prev, next) => prev != next,
          );
        });
  }

  static DropdownMenuItem<String> createDropDownMenuItem(
      String val, String name) {
    return DropdownMenuItem<String>(
      value: val,
      child: MmsText(name),
    );
  }

  static List<DropdownMenuItem<String>> createMenuList(
      String patientId, List<String> patientIds) {
    List<DropdownMenuItem<String>> list = <DropdownMenuItem<String>>[];
    List<String> patientIds = PatientInfoStore().patientIds;
    for (var patientId in patientIds) {
      if (patientId.isNotEmpty && patientId != _noPatientIdStoredYet) {
        String humanizedPatientId = StringUtils.humanizedId(patientId);
        list.add(createDropDownMenuItem(patientId, humanizedPatientId));
      }
    }
    if (list.isEmpty) {
      list.add(createDropDownMenuItem(
          _noPatientIdStoredYet, "<No Patients Available>"));
    }
    return list;
  }
}
