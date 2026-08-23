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
import 'package:flutter_ui/data/model/facility/facility.dart';

class FacilityState extends Equatable {
  final List<Facility> savedFacilities;
  final List<Facility> hlaFacilities;
  final Facility? facilityBeingEdited;
  final bool isLoadingSaved;
  final bool isLoadingHla;
  final String? errorSaved;
  final String? errorHla;

  const FacilityState({
    this.savedFacilities = const [],
    this.hlaFacilities = const [],
    this.facilityBeingEdited,
    this.isLoadingSaved = false,
    this.isLoadingHla = false,
    this.errorSaved,
    this.errorHla,
  });

  FacilityState copyWith({
    List<Facility>? savedFacilities,
    List<Facility>? hlaFacilities,
    Facility? facilityBeingEdited,
    bool? isLoadingSaved,
    bool? isLoadingHla,
    String? errorSaved,
    String? errorHla,
  }) =>
      FacilityState(
        savedFacilities: savedFacilities ?? this.savedFacilities,
        hlaFacilities: hlaFacilities ?? this.hlaFacilities,
        facilityBeingEdited: facilityBeingEdited ?? this.facilityBeingEdited,
        isLoadingSaved: isLoadingSaved ?? this.isLoadingSaved,
        isLoadingHla: isLoadingHla ?? this.isLoadingHla,
        errorSaved: errorSaved,
        errorHla: errorHla,
      );

  @override
  List<Object?> get props => [
        savedFacilities,
        hlaFacilities,
        facilityBeingEdited,
        isLoadingSaved,
        isLoadingHla,
        errorSaved,
        errorHla
      ];
}
