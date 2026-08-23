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

abstract class FacilityEvent extends Equatable {
  const FacilityEvent();
  @override
  List<Object?> get props => [];
}

class LoadSavedFacilities extends FacilityEvent {
  const LoadSavedFacilities();
}

class LoadHlaFacilities extends FacilityEvent {
  const LoadHlaFacilities();
}

class AddFacility extends FacilityEvent {
  final String facilityId;
  const AddFacility(this.facilityId);

  @override
  List<Object?> get props => [facilityId];
}

class RemoveFacility extends FacilityEvent {
  final String facilityId;
  const RemoveFacility(this.facilityId);

  @override
  List<Object?> get props => [facilityId];
}

class EditFacility extends FacilityEvent {
  final String facilityId;
  const EditFacility(this.facilityId);

  @override
  List<Object?> get props => [facilityId];
}

class UpdateFacility extends FacilityEvent {
  final Facility facility;
  const UpdateFacility(this.facility);

  @override
  List<Object?> get props => [facility];
}
