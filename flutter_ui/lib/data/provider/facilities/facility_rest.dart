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

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/model/facility/facility.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';

Logger _logger = Logger("FacilityRest");

class FacilityRest {
  static const String savedUrl = "mms/facility/saved";
  static const String hlaUrl = "mms/facility/hla";

  String _combineUrl(String baseUrl, String endpoint) {
    baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    endpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return "$baseUrl/$endpoint";
  }

  Future<List<Facility>> fetchFacilitiesSaved() async {
    final url = _combineUrl(BaseUrlManager.baseUrl, '$savedUrl/all');
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) return responseToFacilityList(resp);
    _logger.logError(1, 'Saved fetch failed: ${resp.statusCode}');
    return [];
  }

  Future<List<Facility>> fetchFacilitiesHla() async {
    final url = _combineUrl(BaseUrlManager.baseUrl, '$hlaUrl/all');
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) return responseToFacilityList(resp);
    _logger.logError(1, 'HLA fetch failed: ${resp.statusCode}');
    return [];
  }

  List<Facility> responseToFacilityList(Response response) {
    try {
      Iterable jsonDecodedList = json.decode(response.body);
      return jsonDecodedList
          .map((jsonDecoded) => Facility.fromJson(jsonDecoded))
          .toList();
    } catch (e) {
      _logger.logError(1, "Error parsing Facility data: $e");
      return [];
    }
  }

  Future<Facility> postNewFacility(Facility facility) async {
    String postFullUrl = _combineUrl(BaseUrlManager.baseUrl, savedUrl);
    Map<String, dynamic> facilityJson = facility.toJson();
    _logger.logTrace(1, "POST Request Body: ${jsonEncode(facilityJson)}");

    try {
      final response = await http.post(
        Uri.parse(postFullUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(facilityJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.logTrace(1, "Successfully posted new Facility");
        return Facility.fromJson(json.decode(response.body));
      } else {
        _logger.logError(2,
            'Failed to post new Facility. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to post new Facility');
      }
    } catch (e) {
      _logger.logError(2, 'Error posting new Facility: $e');
      throw Exception("Error attempting to post new Facility");
    }
  }

  Future<List<Facility>> putUpdateFacilities(List<Facility> facilities) async {
    String putFullUrl = _combineUrl(BaseUrlManager.baseUrl, savedUrl);
    List<Facility> updatedFacilities = [];

    for (Facility facility in facilities) {
      _logger.logDebug(1, 'Updating facility: ${facility.facilityId}');
      Map<String, dynamic> facilityJson = facility.toJson();
      try {
        final response = await http.put(
          Uri.parse(putFullUrl),
          headers: {
            "Accept": "application/json",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(facilityJson),
        );

        if (response.statusCode == 200) {
          _logger.logTrace(1,
              "Successfully updated Facility with id: ${facility.facilityId}");

          // Ask for updated facility definition:
          try {
            final updatedFacilityResponse = await http.get(
              Uri.parse('$putFullUrl/${facility.facilityId}'),
              headers: {
                "Accept": "application/json",
                'Content-Type': 'application/json; charset=UTF-8',
              },
            );
            updatedFacilities.add(
                Facility.fromJson(json.decode(updatedFacilityResponse.body)));
          } catch (e) {
            _logger.logError(2,
                'Error retrieving updated Facility with id: ${facility.facilityId}: $e');
          }
        } else {
          _logger.logError(2,
              'Failed to update Facility with id: ${facility.facilityId}. Status code: ${response.statusCode}, Body: ${response.body}');
          throw Exception(
              'Failed to update Facility with id: ${facility.facilityId}');
        }
      } catch (e) {
        _logger.logError(
            2, 'Error updating Facility with id: ${facility.facilityId}: $e');
        throw Exception(
            "Error attempting to update Facility with id: ${facility.facilityId}");
      }
    }
    return updatedFacilities;
  }

  Future<void> deleteFacility(String facilityId) async {
    _logger.logTrace(2, 'Deleting Facility with id: $facilityId');
    String deleteUrl =
        _combineUrl(BaseUrlManager.baseUrl, '$savedUrl/$facilityId');

    try {
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _logger.logTrace(
            2, "Successfully deleted Facility with id: $facilityId");
      } else {
        _logger.logError(2,
            'Failed to delete Facility. Status code: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to delete Facility');
      }
    } catch (e) {
      _logger.logError(2, 'Error deleting Facility: $e');
      throw Exception("Error attempting to delete Facility");
    }
  }

  Future<Facility> createFacilityWithId(String facilityId) async {
    final Facility facility = Facility.createWithFacilityId(facilityId);
    return await postNewFacility(facility);
  }
}
