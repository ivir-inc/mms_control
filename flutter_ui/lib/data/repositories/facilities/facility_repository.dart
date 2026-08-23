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

import 'package:flutter_ui/data/model/facility/facility.dart';
import 'package:flutter_ui/data/provider/facilities/facility_rest.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

Logger _logger = Logger("FacilityRepository");

class FacilityRepository {
  final FacilityRest rest;
  FacilityRepository(this.rest);

  // Keep separate caches (optional but handy)
  final Map<String, Facility> _saved = {};
  final Map<String, Facility> _hla = {};

  Facility? getFacility(String? facilityId) {
    return _saved[facilityId];
  }

  Future<void> addFacility(String facilityId) async {
    _logger.logDebug(1, 'Adding new facility (facilityId only)');
    final posted = await rest.createFacilityWithId(facilityId);
    _saved[posted.facilityId] = posted;
  }

  Future<List<Facility>> getSavedFacilities() async {
    final list = await rest.fetchFacilitiesSaved();
    for (final f in list) {
      _saved[f.facilityId] = f;
    }
    return _saved.values.toList();
  }

  Future<List<Facility>> getHlaFacilities() async {
    final list = await rest.fetchFacilitiesHla();
    for (final f in list) _hla[f.facilityId] = f;
    return _hla.values.toList();
  }

  Future<void> removeFacility(String facilityId) async {
    _logger.logDebug(1, 'Removing facility: $facilityId');
    await rest.deleteFacility(facilityId);
    _saved.remove(facilityId);
  }

  Future<void> updateFacility(Facility facility) async {
    _logger.logDebug(1, 'Updating facility: ${facility.facilityId}');
    final updated = await rest.putUpdateFacilities([facility]);
    if (updated.isNotEmpty) {
      _saved[updated.first.facilityId] = updated.first;
    }
  }
}
