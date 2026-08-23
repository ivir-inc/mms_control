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
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/provider/facilities/federation_control_wire_store.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:flutter_ui/data/repositories/facilities/facility_repository.dart';
import 'package:flutter_ui/logic/facility/facility_event.dart';
import 'package:flutter_ui/logic/facility/facility_state.dart';

/// Unified bloc that manages both Saved and HLA facility lists.
/// - Saved facilities: write-enabled (add/update/remove)
/// - HLA facilities: read-only (loaded from backend)
class FacilityBloc extends Bloc<FacilityEvent, FacilityState> {
  final FacilityRepository repository;
  late final FederationControlWireStore _fedStore;

  FacilityBloc(this.repository) : super(const FacilityState()) {
    // New explicit loaders
    on<LoadSavedFacilities>(_onLoadSaved);
    on<LoadHlaFacilities>(_onLoadHla);

    // Saved-only mutations
    on<AddFacility>(_onAdd);
    on<RemoveFacility>(_onRemove);
    on<EditFacility>(_onEdit);
    on<UpdateFacility>(_onUpdate);

    // Listen for FederationControl START and refresh HLA list
    _fedStore = FederationControlWireStore(
      onStart: () => add(const LoadHlaFacilities()),
    );
    MmsDataRouter().registerStoreForDataType('FederationControl', _fedStore);
  }

  // ---- Loaders ----

  Future<void> _onLoadSaved(
    FacilityEvent event,
    Emitter<FacilityState> emit,
  ) async {
    emit(state.copyWith(isLoadingSaved: true, errorSaved: null));
    try {
      // repository.getSavedFacilities() should call /mms/facility/saved/all
      final saved = await repository.getSavedFacilities();
      emit(state.copyWith(savedFacilities: saved, isLoadingSaved: false));
    } catch (e) {
      emit(state.copyWith(
        isLoadingSaved: false,
        errorSaved: e.toString(),
      ));
    }
  }

  Future<void> _onLoadHla(
    LoadHlaFacilities event,
    Emitter<FacilityState> emit,
  ) async {
    emit(state.copyWith(isLoadingHla: true, errorHla: null));
    try {
      // repository.getHlaFacilities() should call /mms/facility/hla/all
      final hla = await repository.getHlaFacilities();
      emit(state.copyWith(hlaFacilities: hla, isLoadingHla: false));
    } catch (e) {
      emit(state.copyWith(
        isLoadingHla: false,
        errorHla: e.toString(),
      ));
    }
  }

  // ---- Saved-only mutations ----

  Future<void> _onAdd(
    AddFacility event,
    Emitter<FacilityState> emit,
  ) async {
    emit(state.copyWith(isLoadingSaved: true));
    try {
      await repository.addFacility(event.facilityId);
      // refresh saved slice only
      final saved = await repository.getSavedFacilities();
      emit(state.copyWith(savedFacilities: saved, isLoadingSaved: false));
    } catch (e) {
      emit(state.copyWith(errorSaved: e.toString(), isLoadingSaved: false));
    }
  }

  Future<void> _onRemove(
    RemoveFacility event,
    Emitter<FacilityState> emit,
  ) async {
    emit(state.copyWith(isLoadingSaved: true));
    try {
      await repository.removeFacility(event.facilityId);
      // refresh saved slice only
      final saved = await repository.getSavedFacilities();
      emit(state.copyWith(savedFacilities: saved, isLoadingSaved: false));
    } catch (e) {
      emit(state.copyWith(errorSaved: e.toString(), isLoadingSaved: false));
    }
  }

  void _onEdit(
    EditFacility event,
    Emitter<FacilityState> emit,
  ) {
    // Editing applies to saved facilities only
    final facility = state.savedFacilities
        .firstWhereOrNull((f) => f.facilityId == event.facilityId);
    emit(state.copyWith(facilityBeingEdited: facility));
  }

  Future<void> _onUpdate(
    UpdateFacility event,
    Emitter<FacilityState> emit,
  ) async {
    emit(state.copyWith(isLoadingSaved: true));
    try {
      await repository.updateFacility(event.facility);

      // Refresh saved slice
      final updatedSaved = await repository.getSavedFacilities();

      // Keep editor in sync with the item that was just updated
      final updatedEdited = updatedSaved.firstWhereOrNull(
        (f) => f.facilityId == event.facility.facilityId,
      );

      emit(state.copyWith(
        savedFacilities: updatedSaved,
        facilityBeingEdited: updatedEdited,
        isLoadingSaved: false,
      ));
    } catch (e) {
      emit(state.copyWith(errorSaved: e.toString(), isLoadingSaved: false));
    }
  }

  @override
  Future<void> close() {
    // Cleanly unregister to avoid leaks / duplicate callbacks
    MmsDataRouter().removeStoreForDataType('FederationControl', _fedStore);
    return super.close();
  }
}
