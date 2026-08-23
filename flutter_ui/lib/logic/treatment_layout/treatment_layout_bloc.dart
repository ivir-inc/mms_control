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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/treatment_layout/treatment_layout_config.dart';
import 'package:flutter_ui/data/services/treatment_layout_service.dart';
import 'treatment_layout_event.dart';
import 'treatment_layout_state.dart';

class TreatmentLayoutBloc
    extends Bloc<TreatmentLayoutEvent, TreatmentLayoutState> {
  TreatmentLayoutBloc() : super(const TreatmentLayoutState()) {
    on<LoadLayout>(_onLoad);
    on<RenameTreatmentCategory>(_onRenameTreatment);
    on<RenameMedicationCategory>(_onRenameMedication);
    on<MoveItem>(_onMoveItem);
    on<SaveLayout>(_onSave);
    on<ResetLayout>(_onReset);
  }

  Future<void> _onLoad(
      LoadLayout event, Emitter<TreatmentLayoutState> emit) async {
    emit(state.copyWith(isLoading: true));
    final config = await TreatmentLayoutService.fetchLayout();
    if (config != null) {
      emit(state.copyWith(config: config, isLoading: false));
    } else {
      emit(state.copyWith(
          isLoading: false, error: 'Failed to load treatment layout'));
    }
  }

  void _onRenameTreatment(
      RenameTreatmentCategory event, Emitter<TreatmentLayoutState> emit) {
    final config = state.config;
    if (config == null) return;
    final updated = List<LayoutCategory>.from(config.treatments);
    // Expand if the target is a padded empty slot beyond the stored config
    // length (display pads to 6; config may have fewer) — same padding
    // MoveItem already does for cross-category drops into a blank slot.
    while (updated.length <= event.index) {
      updated.add(const LayoutCategory(name: '', columns: []));
    }
    updated[event.index] = updated[event.index].copyWith(name: event.name);
    emit(state.copyWith(config: config.copyWith(treatments: updated)));
    add(const SaveLayout());
  }

  void _onRenameMedication(
      RenameMedicationCategory event, Emitter<TreatmentLayoutState> emit) {
    final config = state.config;
    if (config == null) return;
    final updated = List<LayoutCategory>.from(config.medications);
    while (updated.length <= event.index) {
      updated.add(const LayoutCategory(name: '', columns: []));
    }
    updated[event.index] = updated[event.index].copyWith(name: event.name);
    emit(state.copyWith(config: config.copyWith(medications: updated)));
    add(const SaveLayout());
  }

  void _onMoveItem(MoveItem event, Emitter<TreatmentLayoutState> emit) {
    final config = state.config;
    if (config == null) return;

    final categories = List<LayoutCategory>.from(
      event.isMedication ? config.medications : config.treatments,
    );

    if (event.sameCategoryReorder) {
      // Work on the flat allItems list regardless of how many LayoutColumns
      // the backend returned, and anchor the insert to a neighbor's name —
      // the flat list may contain ghost names not present in the current
      // metadata, so positional indexes from the display grid don't apply
      // here. Save the result as a single column (multi-column structure is
      // not needed by the frontend's flat-grid display).
      final cat = categories[event.fromCategoryIndex];
      final flat = List<String>.from(cat.allItems);
      flat.remove(event.itemName);
      final anchor = event.beforeItemName == null
          ? -1
          : flat.indexOf(event.beforeItemName!);
      final insertAt = anchor >= 0 ? anchor : flat.length;
      flat.insert(insertAt, event.itemName);
      categories[event.fromCategoryIndex] = cat.copyWith(
        columns: [LayoutColumn(name: null, items: flat)],
      );
    } else {
      // Expand categories list if the target is a padded empty slot beyond
      // the stored config length (display pads to 6; config may have fewer).
      while (categories.length <= event.toCategoryIndex) {
        categories.add(const LayoutCategory(name: '', columns: []));
      }

      final fromCat = categories[event.fromCategoryIndex];
      final toCat = categories[event.toCategoryIndex];

      final fromCols = List<LayoutColumn>.from(fromCat.columns);
      for (int ci = 0; ci < fromCols.length; ci++) {
        final items = List<String>.from(fromCols[ci].items);
        if (items.contains(event.itemName)) {
          items.remove(event.itemName);
          fromCols[ci] = fromCols[ci].copyWith(items: items);
          break;
        }
      }

      final toCols = List<LayoutColumn>.from(toCat.columns);
      if (toCols.isEmpty) {
        toCols.add(LayoutColumn(name: null, items: [event.itemName]));
      } else {
        final last = toCols.last;
        toCols[toCols.length - 1] =
            last.copyWith(items: [...last.items, event.itemName]);
      }

      categories[event.fromCategoryIndex] = fromCat.copyWith(columns: fromCols);
      categories[event.toCategoryIndex] = toCat.copyWith(columns: toCols);
    }

    final newConfig = event.isMedication
        ? config.copyWith(medications: categories)
        : config.copyWith(treatments: categories);

    emit(state.copyWith(config: newConfig));
    add(const SaveLayout());
  }

  Future<void> _onSave(
      SaveLayout event, Emitter<TreatmentLayoutState> emit) async {
    final config = state.config;
    if (config == null) return;
    await TreatmentLayoutService.saveLayout(config);
  }

  Future<void> _onReset(
      ResetLayout event, Emitter<TreatmentLayoutState> emit) async {
    emit(state.copyWith(isLoading: true));
    final config = await TreatmentLayoutService.resetLayout();
    if (config != null) {
      emit(state.copyWith(config: config, isLoading: false));
    } else {
      emit(state.copyWith(
          isLoading: false, error: 'Failed to reset layout'));
    }
  }
}
