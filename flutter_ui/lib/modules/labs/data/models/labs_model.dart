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

import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

const Color hcgCardColor = Color.fromRGBO(218, 232, 252, 1);
const Color behindCardColor = Color.fromRGBO(245, 245, 245, 1);
const Color eldonCardColor = Color.fromRGBO(213, 232, 212, 1);
const Color bloodCardColor = Color.fromRGBO(248, 206, 204, 1);
const Color urinalysisCardColor = Color.fromRGBO(255, 242, 204, 1);

enum LabCardType { hcg, eldon, blood, urinalysis, empty } // LabCardType

class LabCardData extends Equatable {
  /// Semantically and explicitly empty card.
  static const LabCardData empty = LabCardData(type: LabCardType.empty);

  final LabCardType type;
  final String id;
  final String displayText;
  final Color cardColor;
  final bool onTablet;
  final bool selected;

  const LabCardData({
    this.type = LabCardType.empty,
    this.id = "",
    this.displayText = "",
    cardColor,
    this.onTablet = false,
    this.selected = false,
  }) : cardColor = cardColor ?? MmsColors.transparent;

  factory LabCardData.copy(LabCardData obj,
      {LabCardType? overrideType,
      String? overrideId,
      String? overrideDisplayText,
      Color? overrideCardColor,
      bool? overrideOnTablet,
      bool? overrideSelected}) {
    return LabCardData(
      type: overrideType ?? obj.type,
      id: overrideId ?? obj.id,
      displayText: overrideDisplayText ?? obj.displayText,
      cardColor: overrideCardColor ?? obj.cardColor,
      onTablet: overrideOnTablet ?? obj.onTablet,
      selected: overrideSelected ?? obj.selected,
    );
  }

  ExecutionLab toExecutionLab(bool newOnTablet) {
    return ExecutionLab(id: id, onLearnerTab: newOnTablet);
  }

  ExecutionLab toExecutionLabFull() {
    return ExecutionLab(
      id: id,
      type: type.name, // Use the 'name' getter
      displayText: displayText,
      onLearnerTab: onTablet,
    );
  }

  @override
  List<Object> get props =>
      [type, id, displayText, cardColor, onTablet, selected];
} // LabCardData

class LabCardDataSet extends Equatable {
  final LabCardData hcgLabCardData;
  final LabCardData eldonLabCardData;
  final List<LabCardData> bloodLabCardArray;
  final List<LabCardData> urinalysisLabCardArray;

  LabCardDataSet(
      hcgLabCardData,
      eldonLabCardData,
      List<LabCardData> bloodLabCardArray,
      List<LabCardData> urinalysisLabCardArray)
      : hcgLabCardData = hcgLabCardData ?? LabCardData.empty,
        eldonLabCardData = eldonLabCardData ?? LabCardData.empty,
        bloodLabCardArray = List.from(bloodLabCardArray),
        urinalysisLabCardArray = List.from(urinalysisLabCardArray);

  factory LabCardDataSet.copy(
    LabCardDataSet obj, {
    LabCardData? overrideHcgLabCardData,
    LabCardData? overrideEldonLabCardData,
    List<LabCardData>? overrideBloodLabCardArray,
    List<LabCardData>? overrideUrinalysisLabCardArray,
  }) {
    return LabCardDataSet(
      overrideHcgLabCardData ?? obj.hcgLabCardData,
      overrideEldonLabCardData ?? obj.eldonLabCardData,
      overrideBloodLabCardArray ?? obj.bloodLabCardArray,
      overrideUrinalysisLabCardArray ?? obj.urinalysisLabCardArray,
    );
  }

  ExecutionList toExecutionList() {
    ExecutionLab hcgLab = hcgLabCardData.toExecutionLabFull();
    ExecutionLab eldonLab = eldonLabCardData.toExecutionLabFull();
    List<ExecutionLab> bloodLabs = [];
    List<ExecutionLab> urinalysisLabs = [];
    for (var element in bloodLabCardArray) {
      bloodLabs.add(element.toExecutionLabFull());
    }
    for (var element in urinalysisLabCardArray) {
      urinalysisLabs.add(element.toExecutionLabFull());
    }
    return ExecutionList(
      hcgLab: hcgLab,
      eldonLab: eldonLab,
      bloodLabs: bloodLabs,
      urineLabs: urinalysisLabs,
    );
  }

  @override
  List<Object> get props => [
        hcgLabCardData,
        eldonLabCardData,
        bloodLabCardArray,
        urinalysisLabCardArray
      ];
}

class LabCardDataSetStore extends ChangeNotifier {
  final Map<String, LabCardDataSet> _labCardDataMap = {};

  LabCardDataSetStore._private();

  static final LabCardDataSetStore _instance = LabCardDataSetStore._private();

  factory LabCardDataSetStore() => _instance;

  void selectHcgLabCard(String patientId, bool selected) {
    LabCardDataSet patientLabCardDataSet = getLabCardDataSet(patientId);
    bool isSelected = patientLabCardDataSet.hcgLabCardData.selected;
    if (selected != isSelected) {
      LabCardDataSet subLabCardDataSet = LabCardDataSet.copy(
        patientLabCardDataSet,
        overrideHcgLabCardData: LabCardData.copy(
          patientLabCardDataSet.hcgLabCardData,
          overrideSelected: selected,
        ),
      );
      putLabCardDataSet(patientId, subLabCardDataSet);
    }
  }

  void selectEldonLabCard(String patientId, bool selected) {
    LabCardDataSet patientLabCardDataSet = getLabCardDataSet(patientId);
    bool isSelected =
        patientLabCardDataSet.eldonLabCardData.selected;
    if (selected != isSelected) {
      LabCardDataSet subLabCardDataSet = LabCardDataSet.copy(
        patientLabCardDataSet,
        overrideEldonLabCardData: LabCardData.copy(
          patientLabCardDataSet.eldonLabCardData,
          overrideSelected: selected,
        ),
      );
      putLabCardDataSet(patientId, subLabCardDataSet);
    }
  }

  void selectHcgAndEldonLabCard(String? patientId, bool selected) {
    LabCardDataSet patientLabCardDataSet = getLabCardDataSet(patientId);
    bool isHcgSelected =
        patientLabCardDataSet.hcgLabCardData.selected;
    bool isEldonSelected =
        patientLabCardDataSet.eldonLabCardData.selected;
    if (selected != isHcgSelected || selected != isEldonSelected) {
      LabCardDataSet subLabCardDataSet = LabCardDataSet.copy(
        patientLabCardDataSet,
        overrideHcgLabCardData: LabCardData.copy(
          patientLabCardDataSet.hcgLabCardData,
          overrideSelected: selected,
        ),
        overrideEldonLabCardData: LabCardData.copy(
          patientLabCardDataSet.eldonLabCardData,
          overrideSelected: selected,
        ),
      );
      putLabCardDataSet(patientId, subLabCardDataSet);
    }
  }

  void selectAllBloodLabCards(String? patientId, bool selected) {
    LabCardDataSet patientLabCardDataSet = getLabCardDataSet(patientId);
    List<LabCardData>? bloodCardDataArray =
        patientLabCardDataSet.bloodLabCardArray;
    bool hasChanged = false;
    for (var cardData in bloodCardDataArray) {
      if (cardData.selected != selected) {
        hasChanged = true;
      }
    }
    if (hasChanged) {
      List<LabCardData> subBloodCardDataArray = [];
      for (var cardData in bloodCardDataArray) {
        subBloodCardDataArray
            .add(LabCardData.copy(cardData, overrideSelected: selected));
      }
      LabCardDataSet subDataSet = LabCardDataSet.copy(patientLabCardDataSet,
          overrideBloodLabCardArray: subBloodCardDataArray);
      putLabCardDataSet(patientId, subDataSet);
    }
  }

  void selectAllUrinalysisLabCards(String? patientId, bool selected) {
    LabCardDataSet patientLabCardDataSet = getLabCardDataSet(patientId);
    List<LabCardData>? urinalysisCardDataArray =
        patientLabCardDataSet.urinalysisLabCardArray;
    bool hasChanged = false;
    for (var cardData in urinalysisCardDataArray) {
      if (cardData.selected != selected) {
        hasChanged = true;
      }
    }
    if (hasChanged) {
      List<LabCardData> subUrinalysisCardDataArray = [];
      for (var cardData in urinalysisCardDataArray) {
        subUrinalysisCardDataArray
            .add(LabCardData.copy(cardData, overrideSelected: selected));
      }
      LabCardDataSet subDataSet = LabCardDataSet.copy(patientLabCardDataSet,
          overrideUrinalysisLabCardArray: subUrinalysisCardDataArray);
      putLabCardDataSet(patientId, subDataSet);
    }
  }

  void toggleLabCard(String? patientId, LabCardData cardData) {
    LabCardDataSet patientLabCardDataSet = getLabCardDataSet(patientId);
    LabCardData? patientHcg = patientLabCardDataSet.hcgLabCardData;
    LabCardData? patientEldon = patientLabCardDataSet.eldonLabCardData;
    List<LabCardData>? patientBloodData =
        patientLabCardDataSet.bloodLabCardArray;
    List<LabCardData>? patientUrinalysisData =
        patientLabCardDataSet.urinalysisLabCardArray;
    LabCardData hcgCardData;
    LabCardData eldonCardData;
    List<LabCardData> bloodCardDataArray = [];
    List<LabCardData> urinalysisCardDataArray = [];
    if (patientHcg == cardData) {
      hcgCardData =
          LabCardData.copy(cardData, overrideSelected: !cardData.selected);
    } else {
      hcgCardData = patientHcg;
    }
    if (patientEldon == cardData) {
      eldonCardData =
          LabCardData.copy(cardData, overrideSelected: !cardData.selected);
    } else {
      eldonCardData = patientEldon;
    }
    for (var bloodData in patientBloodData) {
      if (bloodData == cardData) {
        bloodCardDataArray.add(
            LabCardData.copy(cardData, overrideSelected: !cardData.selected));
      } else {
        bloodCardDataArray.add(bloodData);
      }
    }
    for (var urinalysisData in patientUrinalysisData) {
      if (urinalysisData == cardData) {
        urinalysisCardDataArray.add(
            LabCardData.copy(cardData, overrideSelected: !cardData.selected));
      } else {
        urinalysisCardDataArray.add(urinalysisData);
      }
    }
    putLabCardDataSet(
        patientId,
        LabCardDataSet(hcgCardData, eldonCardData, bloodCardDataArray,
            urinalysisCardDataArray));
  }

  void putLabCardDataSet(String? patientId, LabCardDataSet labCardDataSet) {
    LabCardDataSet? patientLabCardDataSet = _labCardDataMap[patientId];
    if (labCardDataSet != patientLabCardDataSet) {
      _labCardDataMap[patientId ?? ""] = labCardDataSet;
      notifyListeners();
    }
  }

  LabCardDataSet getLabCardDataSet(String? patientId) =>
      _labCardDataMap[patientId] ??
      LabCardDataSet(const LabCardData(type: LabCardType.empty),
          const LabCardData(type: LabCardType.empty), const [], const []);
}

class LabCardDataSetStoreAccess extends ChangeNotifier {
  final LabCardDataSetStore store = LabCardDataSetStore();

  LabCardDataSetStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}

class ExecutionLab {
  final String? type;
  final String? id;
  final String? displayText;
  final bool? onLearnerTab;

  ExecutionLab({this.type, this.id, this.displayText, this.onLearnerTab});

  factory ExecutionLab.fromJson(Map<String, dynamic> json) {
    return ExecutionLab(
      type: json['type'],
      id: json['id'],
      displayText: json['displayText'],
      onLearnerTab: json['onLearnerTab'],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'displayText': displayText,
        'onLearnerTab': onLearnerTab
      };
} // ExecutionLab

class ExecutionList {
  ExecutionLab? hcgLab;
  ExecutionLab? eldonLab;
  List<ExecutionLab>? bloodLabs;
  List<ExecutionLab>? urineLabs;

  ExecutionList({this.hcgLab, this.eldonLab, this.bloodLabs, this.urineLabs});

  factory ExecutionList.fromJson(Map<String, dynamic> json) {
    ExecutionList returnList = ExecutionList();
    returnList.hcgLab = ExecutionLab.fromJson(json['hcgLab']);
    returnList.eldonLab = ExecutionLab.fromJson(json['eldonLab']);
    if (json['bloodLabs'] == null) {
      returnList.bloodLabs = null;
    } else {
      returnList.bloodLabs = (json['bloodLabs'] as List)
          .map((i) => ExecutionLab.fromJson(i))
          .toList();
    }
    if (json['urineLabs'] == null) {
      returnList.urineLabs = null;
    } else {
      returnList.urineLabs = (json['urineLabs'] as List)
          .map((i) => ExecutionLab.fromJson(i))
          .toList();
    }

    return returnList;
  }

  Map<String, dynamic> toJson() => {
        'hcgLab': hcgLab?.toJson(),
        'eldonLab': eldonLab?.toJson(),
        'bloodLabs': bloodLabs?.map((i) => i.toJson()).toList(),
        'urineLabs': urineLabs?.map((i) => i.toJson()).toList(),
      };
} // ExecutionList

class Scenario {
  final String? id;
  final String? name;
  final String? description;

  Scenario({this.id, this.name, this.description});

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
