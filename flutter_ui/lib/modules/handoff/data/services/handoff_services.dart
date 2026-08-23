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

import 'dart:convert';
import 'package:flutter_ui/data/services/base_url_manager.dart';

import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:http/http.dart' as http;
import '../models/handoff_ready_checks_model.dart';

Logger _logger = Logger(
  "HandoffServices",
  debugging: false,
);

class HandoffServices {
  static const String handoffImageDataType = "HandoffImageData";
  HandoffServices._private();

  static final HandoffServices _instance = HandoffServices._private();

  factory HandoffServices() => _instance;

  static const String submitImagesRestUrl = "mms/patient/meddoc";
  static const String sendHandoffStatusRestUrl = "mms/patient/handoff";
  static const String fetchImageDocumentRestUrl = "mms/patient/meddoc";
  static const String signalImagesRetrievalUrl = "mms/files/action";

  Future<bool> submitImage(HandoffImagesModel model) async {
    String submissionUrl =
        "${BaseUrlManager.baseUrl}/$submitImagesRestUrl?patientId=${model.patientId}";
    _logger.log(20,
        "Submitting image ${model.pageName}:${model.pageNum} for patient ${model.patientId}",
        counter: 0);
    try {
      HandoffImagesModel incIdxModel = HandoffImagesModel(
        patientId: model.patientId,
        pageNum: model.pageNum + 1, // To submit base-1 page numbers.
        pageTotal: model.pageTotal,
        pageName: model.pageName,
        dataUrl: model.dataUrl,
      );
      final response = await http.post(
        Uri.parse(submissionUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode(incIdxModel.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.log(
            21, "Received good response status code: ${response.statusCode}");
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> sendHandoffStatus(
    HandoffReadyChecks status, {
    String? patientId,
    String? facilityId,
  }) async {
    if (patientId == null) {
      return false;
    }
    String submissionUrl =
        "${BaseUrlManager.baseUrl}/$sendHandoffStatusRestUrl";
    String statusStr = status.name.toUpperCase();
    _logger.log(
      10,
      "Sending handoff status: $statusStr",
      counter: 0,
    );
    try {
      final response = await http.post(
        Uri.parse(submissionUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "status": statusStr,
          "patientId": patientId,
          if (facilityId != null) "facilityId": facilityId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.log(
            11, "Received good response status code: ${response.statusCode}");
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> signalImagesRetrieval() async {
    bool success = true;
    _logger.log(
      30,
      "Signal that DD1380 images are to be retrieved.",
      counter: 0,
    );
    String signalUrl = "${BaseUrlManager.baseUrl}/$signalImagesRetrievalUrl";

    try {
      final response = await http.post(
        Uri.parse(signalUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "action": "GET_ALL",
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.log(31,
            "Server successfully received signal to retrieve DD1380 images.");
      } else {
        success = false;
        _logger.log(32,
            "Server returned status code [${response.statusCode}] when UI attempted to signal it to retrieve DD1380 images.");
      }
    } catch (e) {
      success = false;
      _logger.log(33,
          "Exception thrown while attempting to signal server to retrieve DD1380 images:\n$e");
    }
    return success;
  }

  Future<String?> fetchImageDocument(int docId, String? patientId) async {
    String? dataUrl;
    _logger.log(
      1,
      "Called fetchImageDocument, docId: $docId, pid: $patientId",
      counter: 0,
      logLevel: 0,
    );
    if (patientId == null) {
      return null;
    }
    _logger.log(
      1,
      "Fetching Image $docId for patient $patientId",
      logLevel: 0,
    );
    String submissionUrl =
        "${BaseUrlManager.baseUrl}/$fetchImageDocumentRestUrl?docId=$docId";
    final response = await http.get(Uri.parse(submissionUrl));
    if (response.statusCode == 200) {
      var jsonMap = json.decode(response.body);
      if (jsonMap is Map) {
        String mapPatientId = jsonMap["patientId"]?.toString() ?? patientId;
        if (mapPatientId != patientId) {
          return null;
        }
        dataUrl = jsonMap["dataUrl"].toString();
      }
      _logger.log(1, "Got dataUrl. Length: ${dataUrl?.length}", logLevel: 0);
      String dataUrlSub =
          dataUrl?.padRight(120).substring(100, 120) ?? "<No dataUrl>";
      _logger.log(1, "DataUrl substring: $dataUrlSub", logLevel: 0);
      return dataUrl;
    }
    return null;
  }
}
