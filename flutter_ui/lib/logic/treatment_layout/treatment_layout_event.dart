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

import 'package:equatable/equatable.dart';

abstract class TreatmentLayoutEvent extends Equatable {
  const TreatmentLayoutEvent();
  @override
  List<Object?> get props => [];
}

class LoadLayout extends TreatmentLayoutEvent {
  const LoadLayout();
}

class RenameTreatmentCategory extends TreatmentLayoutEvent {
  final int index;
  final String name;
  const RenameTreatmentCategory(this.index, this.name);
  @override
  List<Object?> get props => [index, name];
}

class RenameMedicationCategory extends TreatmentLayoutEvent {
  final int index;
  final String name;
  const RenameMedicationCategory(this.index, this.name);
  @override
  List<Object?> get props => [index, name];
}

class MoveItem extends TreatmentLayoutEvent {
  final String itemName;
  final int fromCategoryIndex;
  final int toCategoryIndex;
  final bool isMedication;
  final bool sameCategoryReorder;
  // Same-category reorders anchor the drop to a neighbor's name rather than
  // a positional index: the stored layout can contain ghost names absent
  // from the current metadata, so display indexes don't map onto the flat
  // stored list. Null means "insert at the end".
  final String? beforeItemName;

  const MoveItem({
    required this.itemName,
    required this.fromCategoryIndex,
    required this.toCategoryIndex,
    this.isMedication = false,
    this.sameCategoryReorder = false,
    this.beforeItemName,
  });

  @override
  List<Object?> get props => [
        itemName,
        fromCategoryIndex,
        toCategoryIndex,
        isMedication,
        sameCategoryReorder,
        beforeItemName,
      ];
}

class SaveLayout extends TreatmentLayoutEvent {
  const SaveLayout();
}

class ResetLayout extends TreatmentLayoutEvent {
  const ResetLayout();
}
