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

// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ui/logic/utils/string_utils.dart';
import 'package:flutter_ui/presentation/widgets/general/buttons/padded_raised_button.dart';
import 'package:flutter_ui/presentation/widgets/layouts/sized_labeled_text_row.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/scrollable_constrained_stylable_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/box_shaded_text.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';
import 'package:flutter_ui/presentation/widgets/general/icons/text_and_or_icon.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';

import '../../data/models/medevac_model.dart';
import '../../data/models/injury_model.dart';
import '../../data/services/one_saf_services.dart';

class OneSAFScreen extends StatefulWidget {
  final String patientId;
  const OneSAFScreen(this.patientId, {super.key});

  static const bool _useSimStateWidget = false;

  @override
  State<OneSAFScreen> createState() => _OneSAFScreenState();
}

class _OneSAFScreenState extends State<OneSAFScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (OneSAFScreen._useSimStateWidget) const SimulationStateWidget(),
          Wrap(
            clipBehavior: Clip.hardEdge,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                color: MmsColors.transparent,
              ),
              CasualtyCreationWidget(
                widget.patientId,
              ),
              Container(
                width: 10,
                height: 10,
                color: MmsColors.transparent,
              ),
              MedevacRequestWidget(widget.patientId),
            ],
          )
        ],
      ),
    );
  }
}

class MedevacRequestWidget extends StatefulWidget {
  final String patientId;
  const MedevacRequestWidget(
    this.patientId, {
    super.key,
  });

  @override
  State<MedevacRequestWidget> createState() => _MedevacRequestWidgetState();
}

class _MedevacRequestWidgetState extends State<MedevacRequestWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MmsRoundedBarlessPanel(
          width: 300,
          caption: "MEDEVAC Status",
          widget: SizedBox(
            height: 100,
            child: Align(
              alignment: Alignment.center,
              child: MedevacStatusDisplayWidget(widget.patientId),
            ),
          ),
        ),
        MmsRoundedBarlessPanel(
            caption: "Actions",
            width: 300,
            rounding: 20,
            widget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RequestMedevacButton(widget.patientId),
                LoadPatientButton(widget.patientId),
              ],
            )),
      ],
    );
  }
}

class RequestMedevacButton extends StatefulWidget {
  final String patientId;
  const RequestMedevacButton(
    this.patientId, {
    super.key,
  });

  @override
  _RequestMedevacButtonState createState() => _RequestMedevacButtonState();
}

class _RequestMedevacButtonState extends State<RequestMedevacButton> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InjuryDetailsStoreAccess>(
          create: (_) => InjuryDetailsStoreAccess(),
        ),
        ChangeNotifierProvider<OnesafMedevacResponseStoreAccess>(
          create: (_) => OnesafMedevacResponseStoreAccess(),
        ),
      ],
      child: Selector2<InjuryDetailsStoreAccess,
          OnesafMedevacResponseStoreAccess, bool>(
        builder: (context, canActivate, _) {
          return MmsPaddedRaisedButton(
            "Request\nMEDEVAC",
            buttonStyle: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              minimumSize: const Size(106, 60),
            ),
            onPressed: canActivate
                ? () {
                    OneSafServices().sendMedevacRequest(OnesafMedevacRequest(
                        patientId: widget.patientId,
                        evacState: OnesafMedevacStatus.requestEvac));
                  }
                : null,
          );
        },
        selector: (buildContext, injuryAccess, medevacResponseAccess) =>
            injuryAccess.store.hasInjuryDetailsList(widget.patientId) &&
            medevacResponseAccess.store.canMakeRequest(widget.patientId),
        shouldRebuild: (prev, next) => prev != next,
      ),
    );
  }
}

class LoadPatientButton extends StatefulWidget {
  final String patientId;
  const LoadPatientButton(
    this.patientId, {
    super.key,
  });

  @override
  _LoadPatientButtonState createState() => _LoadPatientButtonState();
}

class _LoadPatientButtonState extends State<LoadPatientButton> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnesafMedevacResponseStoreAccess>(
        create: (_) => OnesafMedevacResponseStoreAccess(),
        builder: (context, snapshot) {
          return Selector<OnesafMedevacResponseStoreAccess, bool>(
            builder: (context, readyToLoad, _) {
              return MmsPaddedRaisedButton(
                "Load Patient",
                buttonStyle: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  minimumSize: const Size(106, 60),
                ),
                onPressed: readyToLoad
                    ? () {
                        OneSafServices().sendMedevacRequest(
                            OnesafMedevacRequest(
                                patientId: widget.patientId,
                                evacState:
                                    OnesafMedevacStatus.informLoadPatient));
                      }
                    : null,
              );
            },
            selector: (buildContext, access) =>
                access.store.readyToLoad(widget.patientId),
            shouldRebuild: (prev, next) => prev != next,
          );
        });
  }
}

class MedevacStatusDisplayWidget extends StatefulWidget {
  final String patientId;
  const MedevacStatusDisplayWidget(
    this.patientId, {
    super.key,
  });

  @override
  _MedevacStatusDisplayWidgetState createState() =>
      _MedevacStatusDisplayWidgetState();
}

class _MedevacStatusDisplayWidgetState
    extends State<MedevacStatusDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnesafMedevacResponseStoreAccess>(
      create: (_) => OnesafMedevacResponseStoreAccess(),
      builder: (context, _) {
        return Selector<OnesafMedevacResponseStoreAccess, String>(
          builder: (context, status, _) {
            return MmsText(status);
          },
          selector: (
            buildContext,
            access,
          ) =>
              access.store.getHumanizedLastMedevacStatus(widget.patientId),
          shouldRebuild: (prev, next) => prev != next,
        );
      },
    );
  }
}

class CasualtyCreationWidget extends StatefulWidget {
  final String patientId;
  const CasualtyCreationWidget(
    this.patientId, {
    super.key,
  });

  @override
  State<CasualtyCreationWidget> createState() => _CasualtyCreationWidgetState();
}

class _CasualtyCreationWidgetState extends State<CasualtyCreationWidget> {
  static const List<double> _textWidths = [170, 280, 236, 66];

  @override
  Widget build(BuildContext context) {
    String humanizedPatientId = StringUtils.humanizedId(
      widget.patientId,
    );
    return MmsScrollableConstrainedStylablePanel(
      caption: "Patient Injuries - $humanizedPatientId",
      captionBarColor: MmsColors.white,
      captionFontWeight: FontWeight.bold,
      captionTextColor: MmsColors.black,
      childPadding: const EdgeInsets.all(10),
      shadowColor: MmsColors.white,
      elevation: 5,
      panelBgColor: MmsColors.white,
      heightFactor: 1,
      minusHeight: 170,
      minHeight: 274,
      maxHeight: 400,
      //minusWidth: 40,
      //widthFactor: 0.6,
      fixedWidth: 780,
      rounding: 20,
      fixedTopWidget: injuriesListHeaderWidget(),
      fixedTopWidgetHeight: 24,
      widget: ChangeNotifierProvider<InjuryDetailsStoreAccess>(
          create: (_) => InjuryDetailsStoreAccess(),
          builder: (context, _) {
            return Selector<InjuryDetailsStoreAccess, List<InjuryDetails>>(
              builder: (context, injuriesList, _) {
                return Column(
                  children: allInjuriesDisplayList(injuriesList),
                );
              },
              selector: (buildContext, access) =>
                  access.store.getInjuryDetailsList(widget.patientId),
              shouldRebuild: (prev, next) => prev != next,
            );
          }),
    );
  }

  Widget injuriesListHeaderWidget({
    List<double> textWidths = _textWidths,
    double height = 20,
  }) {
    return MmsSizedLabeledTextRow(
      "",
      TextAndOrIcon.convertTextList(
          <String>["Injury", "Injury Description", "Location(s)", "Severity"]),
      allHeaders: true,
      labelWidth: 0,
      textWidths: textWidths,
      height: height,
      verticalTextAlignment: Alignment.topLeft,
    );
  }

  List<Widget> allInjuriesDisplayList(
    List<InjuryDetails> patientInjuriesList, {
    List<double> textWidths = _textWidths,
    double height = 20,
    bool showDuplicateData = false,
  }) {
    List<Widget> results = [];
    for (var injury in patientInjuriesList) {
      bool first = true;
      for (var location in injury.locations) {
        bool disp = first || showDuplicateData;
        List<String> locationEntry = [];
        String injuryType = disp ? injury.injuryType : "";
        locationEntry[0] = StringUtils.humanizedId(injuryType);
        String injuryDescrip = disp ? injury.description : "";
        locationEntry[1] = injuryDescrip;
        locationEntry[2] = StringUtils.humanizedId(location);
        String injurySeverity = disp ? "${injury.severity}" : "";
        locationEntry[3] = StringUtils.humanizedId(injurySeverity);
        Widget widgt = MmsSizedLabeledTextRow(
          "",
          TextAndOrIcon.convertTextList(locationEntry),
          allHeaders: false,
          labelWidth: 0,
          textWidths: textWidths,
          height: height,
          verticalTextAlignment: Alignment.topLeft,
        );
        results.add(widgt);
        first = false;
      }
    }
    return results;
  }
}

class SimulationStateWidget extends StatelessWidget {
  const SimulationStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MmsRoundedBarlessPanel(
      width: 300,
      caption: "Simulation State",
      widget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.play_arrow,
              size: 30,
              color: MmsColors.dkBlue,
              semanticLabel: "Play/Start",
            ),
          ),
          const InkWell(
            onTap: null,
            child: Icon(
              Icons.pause,
              size: 30,
              color: MmsColors.mdGrey,
              semanticLabel: "Pause",
            ),
          ),
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.stop,
              size: 30,
              color: MmsColors.dkBlue,
              semanticLabel: "Stop",
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: MmsBoxShadedText(
              "Paused",
              isBold: true,
              shadowColor: MmsColors.white,
              bgColor: MmsColors.ltYellow,
            ),
          ),
        ],
      ),
    );
  }
}
