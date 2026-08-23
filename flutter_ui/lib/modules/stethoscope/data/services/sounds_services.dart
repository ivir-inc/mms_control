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
import 'dart:convert';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/data/services/recurring_services.dart';
import 'package:http/http.dart' as http;
import '../models/sounds_model.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

final _logger = Logger("MmsSoundsService");

class MmsSoundsService {
  static const String signsRestUrl = "mms/signs"; // ✅ Ensuring correct API path

  MmsSoundsService._private();
  static final _instance = MmsSoundsService._private();
  factory MmsSoundsService() => _instance;

  final Map<String, Timer> timers = {};
  final Map<String, int> timerRequests = {};
  final Map<String, Stopwatch> stopwatches = {};

  /// **Schedule recurring fetch of signs data**
  void requireRecurringSoundsFetch(
  String patientId, {
    required Function() callback,
  }) {
    MmsRecurringServices().requireRecurringFetch(
      patientId,
      timerRequests,
      timers,
      ({String patientId = "", Function()? callback, bool forceCall = false}) {
        fetchSignsInfoWrapper(
          patientId: patientId,
          callback: callback,
          forceCall: forceCall,
        );
      },
      callback: callback,
    );
  }

  /// **Release scheduled fetch of signs data**
  void releaseRecurringSoundsFetch(String patientId) {
    MmsRecurringServices().releaseRecurringFetch(patientId, timerRequests, timers);
  }

  /// **Wrapper function to fetch signs data asynchronously**
  void fetchSignsInfoWrapper({
    required String patientId,
    Function()? callback, // ✅ Fix: Explicitly define as Function()?
    bool forceCall = false,
  }) {
    fetchSignsInfo(patientId: patientId, callback: callback, forceCall: forceCall)
        .catchError((error) {
      _logger.log(1, "Error fetching signs info for $patientId: $error");
    });
  }

  /// **Fetch Signs for a Patient (Forces API call if needed)**
  Future<SoundsInfo> fetchSignsInfo({
    required String patientId,
    Function()? callback,
    bool forceCall = false,
  }) async {
    // 🔍 Check if patient data exists locally first
    final existingData = SoundsInfoStore().getSoundsInfo(patientId);

    if (existingData.patientId != null && !forceCall) {
      _logger.log(0, "Using locally stored data for patientId: $patientId");
      callback?.call();
      return existingData;
    }

    try {
      final url = "${BaseUrlManager.baseUrl}/$signsRestUrl/$patientId";
      _logger.log(0, "Fetching signs from API: $url");
      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final newSoundsInfo = SoundsInfo.fromJson(jsonData);

        SoundsInfoStore().updateSoundsInfo(patientId, newSoundsInfo);
        _logger.log(0, "Successfully updated SoundsInfo from API for $patientId: $newSoundsInfo");

        callback?.call();
        return newSoundsInfo;
      } else if (response.statusCode == 404) {
        _logger.log(1, "PatientId $patientId not found. Creating new entry...");
        return createNewPatientSigns(patientId);
      } else {
        _logger.log(2, "API returned error ${response.statusCode} for $patientId");
      }
    } catch (e) {
      _logger.log(1, "Exception fetching signs for patientId $patientId: $e");
    }

    callback?.call();
    return existingData; // Return local fallback if API fails
  }

  /// **Explicitly Create a New Entry for a Missing Patient**
  Future<SoundsInfo> createNewPatientSigns(String patientId) async {
    _logger.log(0, "Creating new SoundsInfo entry for patient: $patientId");

    final newSoundsInfo = SoundsInfo(patientId: patientId);
    SoundsInfoStore().updateSoundsInfo(patientId, newSoundsInfo);

    try {
      final url = "${BaseUrlManager.baseUrl}/$signsRestUrl/$patientId";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newSoundsInfo.toJson()),
      );

      if (response.statusCode == 201) {
        _logger.log(0, "Successfully initialized new patient entry for $patientId");
      } else {
        _logger.log(2, "API returned ${response.statusCode} when creating new entry for $patientId");
      }
    } catch (e) {
      _logger.log(1, "Error creating new entry for $patientId: $e");
    }

    return newSoundsInfo;
  }

  /// **Update Sound for a Specific Patient**
  Future<void> updateSound(String patientId, String category, String? selectedSound) async {
    final url = "${BaseUrlManager.baseUrl}/$signsRestUrl/$patientId";

    // Ensure default values are correctly set based on the sound category
    String resolvedValue = (category == "coughSound")
        ? selectedSound ?? "N_A" // Default for CoughEnum
        : selectedSound ?? "NOT_APPLICABLE"; // Default for other enums

    try {
      _logger.log(0, "Updating $category for patientId: $patientId -> $resolvedValue");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "patientId": patientId,
          category: resolvedValue,
        }),
      );

      if (response.statusCode == 200) {
        await fetchSignsInfo(patientId: patientId, forceCall: true);
        _logger.log(0, "Successfully updated $category to $resolvedValue for patientId: $patientId");
      } else {
        _logger.log(2, "Failed to update sign for $category (Code: ${response.statusCode})");
      }
    } catch (e) {
      _logger.log(1, "Exception updating sign for $category: $e");
    }
  }
}
