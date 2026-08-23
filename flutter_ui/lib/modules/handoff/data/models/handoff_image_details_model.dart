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
import 'package:flutter_ui/data/storage/base_data_store.dart';

import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/provider/networking/data_router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/handoff_services.dart';

Logger _logger = Logger("HandoffImageDetailsModel", debugging: true);

class HandoffImageDetailsModel extends Equatable {
  static const String _noPatientId = "";
  static const String _noDocName = "";
  static const int _noDocId = -1;
  static const int _noDocSession = -1;
  static const bool _allowDd1380First = false;
  final String patientId;
  final int docId;
  final String docName;
  final int docSession;
  const HandoffImageDetailsModel({
    required this.patientId,
    required this.docId,
    required this.docName,
    required this.docSession,
  });

  static const HandoffImageDetailsModel none = HandoffImageDetailsModel(
    patientId: _noPatientId,
    docId: _noDocId,
    docName: _noDocName,
    docSession: _noDocSession,
  );

  factory HandoffImageDetailsModel.calc({
    required String patientId,
    required String docIdStr,
    required String docName,
  }) {
    String useDocName = "";
    String usePatientId = patientId;
    _logger.log(
        30, "calculating docSession for $docIdStr :: $patientId :: $docName",
        counter: 0);
    int docId = int.tryParse(docIdStr.toString(), radix: 10) ?? -1;
    String? docSessionStr;
    List<String> docNameParts = docName.split('_');
    _logger.log(30, "Split docName:");
    _logger.log(30, docNameParts.toString());
    if (docNameParts.length > 3) {
      String docName0 = docNameParts[0];
      String docName1 = docNameParts[1];
      String docName2 = docNameParts[2];
      if (docName0 == "dd1380") {
        _logger.log(30, "Got dd1380 first in doc name");
        if (_allowDd1380First) {
          docSessionStr = docNameParts[1];
          if (docNameParts.length > 4) {
            String docName4 = docNameParts[4];
            String suffix = "cp${docName2}tp${docName4}x";
            useDocName = "${patientId}_dd1380_${docSessionStr}_$suffix";
            _logger.log(30, "Converted doc name:");
            _logger.log(30, useDocName);
          }
        } else {
          usePatientId == "";
          useDocName = "";
        }
      } else if (docName1 == "dd1380" && docNameParts.length > 3) {
        docSessionStr = docNameParts[2];
        useDocName = docName;
        if (usePatientId.isEmpty) {
          usePatientId = docName0;
        }
      } else {
        _logger.log(30, "Can't find dd1380 where expected in doc name");
        _logger.log(30, "docName0: $docName0, docName1: $docName1");
      }
    }
    if (usePatientId.isEmpty || useDocName == "") {
      return HandoffImageDetailsModel.none;
    }
    _logger.log(31, "Doc session string to parse: $docSessionStr");
    int docSession = int.tryParse(docSessionStr ?? "", radix: 10) ?? -1;
    _logger.log(32, "Parsed doc session: $docSession");
    return HandoffImageDetailsModel(
        docId: docId,
        patientId: usePatientId,
        docName: useDocName,
        docSession: docSession);
  }

  factory HandoffImageDetailsModel.copy(
    HandoffImageDetailsModel model,
    int? docId,
    String? patientId,
    String? docName,
    int? docSession,
  ) =>
      model.replica(
        docId: docId,
        patientId: patientId,
        docName: docName,
        docSession: docSession,
      );

  HandoffImageDetailsModel replica({
    int? docId,
    String? patientId,
    String? docName,
    int? docSession,
  }) {
    return HandoffImageDetailsModel(
      docId: docId ?? this.docId,
      patientId: patientId ?? this.patientId,
      docName: docName ?? this.docName,
      docSession: docSession ?? this.docSession,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        //docId,
        patientId,
        docName,
        docSession,
      ];
}

class HandoffImageDetailsStore extends BaseDataStore {
  static const String _handoffAvailableImagesDataType = "DocumentList";

  final Map<String, List<HandoffImageDetailsModel>> _patientCurrentImagesMap =
      {};
  final Map<String, Map<String, String>> _patientDocumentIdsMap = {};

  HandoffImageDetailsStore._private() {
    MmsDataRouter().registerStoreForDataType(
      _handoffAvailableImagesDataType,
      this,
    );
  }

  static final HandoffImageDetailsStore _instance =
      HandoffImageDetailsStore._private();

  factory HandoffImageDetailsStore() => _instance;

  Set<String> allPatientIds() {
    Set<String> patientIds = Set.of(_patientCurrentImagesMap.keys);
    patientIds.addAll(_patientDocumentIdsMap.keys);
    return patientIds;
  }

  void clearPatientMaps() {
    _patientCurrentImagesMap.clear();
    _patientDocumentIdsMap.clear();
  }

  bool addImageDetails(
    HandoffImageDetailsModel detailsModel, {
    bool notifyOnChange = false,
  }) {
    List<HandoffImageDetailsModel> patientModels =
        _patientCurrentImagesMap[detailsModel.patientId] ?? [];
    if (patientModels.contains(detailsModel)) {
      return false;
    }
    List<HandoffImageDetailsModel> listToRetain = List.of(patientModels);
    listToRetain.add(detailsModel.replica());
    _patientCurrentImagesMap[detailsModel.patientId] = listToRetain;
    if (notifyOnChange) {
      notifyListeners();
    }
    return true;
  }

  bool hasDocId(
    String patientId,
    int docId, {
    String? dataUrl,
  }) {
    Map<String, String>? patientDocIds = _patientDocumentIdsMap[patientId];
    bool containsDocId = patientDocIds?.containsKey("$docId") ?? false;
    String? currDataUrl = patientDocIds?["$docId"];
    return containsDocId && ((dataUrl == null) || (currDataUrl == dataUrl));
  }

  bool addDocIdAndDataUrlForPatient(
    String patientId,
    int docId,
    String dataUrl, {
    bool notifyOnChange = false,
  }) {
    _logger.log(14, "DataUrl length? ${dataUrl.length}", counter: 0);
    if (hasDocId(
      patientId,
      docId,
      dataUrl: dataUrl,
    )) {
      _logger.log(14,
          "Already has doc id $docId for patient id $patientId. Not adding.");
      return false;
    }
    _logger.log(14,
        "Doesn't already have docId: $docId for patient id: $patientId. Adding.");
    Map<String, String> patientDocIds = _patientDocumentIdsMap[patientId] ?? {};
    Map<String, String> newPatientDocIds = Map.of(patientDocIds);
    newPatientDocIds["$docId"] = dataUrl;
    _logger.log(
        14, "******** Number of patient doc ids: ${newPatientDocIds.length}");
    _patientDocumentIdsMap[patientId] = newPatientDocIds;
    Map<String, String>? pDocIds = _patientDocumentIdsMap[patientId];
    _logger.log(14,
        "+++++++++++++++++ Number of patient doc ids: ${pDocIds?.length ?? 0}");
    if (notifyOnChange) {
      notifyListeners();
    }
    for (String key in newPatientDocIds.keys) {
      String? findUrl = newPatientDocIds[key];
      _logger.log(14,
          "***************** length of url for docId $key: ${findUrl?.length ?? 0}");
    }
    return true;
  }

  List<String> patientImagesList(String patientId) {
    int maxSession = -1;
    List<HandoffImageDetailsModel> patientModels =
        _patientCurrentImagesMap[patientId] ?? [];
    _logger.log(11, "PatientModels.length: ${patientModels.length}",
        counter: 0);
    _logger.log(11, patientModels.toString());
    _logger.log(
        11, "PatientDocumentIdsMap.length: ${_patientDocumentIdsMap.length}");
    for (HandoffImageDetailsModel model in patientModels) {
      if (model.docSession > maxSession) {
        maxSession = model.docSession;
      }
    }
    _logger.log(11, "Max session: $maxSession");
    List<int> patientDocIds = [];
    for (HandoffImageDetailsModel model in patientModels) {
      _logger.log(11, "Doc session: ${model.docSession}");
      if (model.docSession == maxSession) {
        patientDocIds.add(model.docId);
        _logger.log(11, "Added doc Id: ${model.docId}");
      }
    }
    patientDocIds.sort();
    List<String> patientImages = [];
    Map<String, String> patientDocIdsMap =
        _patientDocumentIdsMap[patientId] ?? {};
    _logger.log(11,
        "Number of elements in patientDocIdsMap: ${patientDocIdsMap.length}");
    for (int docId in patientDocIds) {
      _logger.log(11, "Getting image for docId: $docId");
      String? patientImage = patientDocIdsMap["$docId"];
      if (patientImage != null) {
        _logger.log(11, "Adding patient image for docId: $docId");
        patientImages.add(patientImage);
      }
    }
    _logger.log(11, "Number of images for patient: ${patientImages.length}");
    return patientImages;
  }

  @override
  bool acceptsBool() => false;

  @override
  bool acceptsDouble() => false;

  @override
  bool acceptsInt() => false;

  @override
  bool acceptsJson() => true;

  @override
  bool acceptsRawString() => false;

  @override
  void parseAndStoreJsonByDataType(String dataType, payload) {
    doParseAndStoreJsonByDataType(dataType, payload);
  }

  Future<bool> doParseAndStoreJsonByDataType(String dataType, payload) async {
    bool hasChange = false;
    Set<String> hasImagesSet = {};
    if (dataType == _handoffAvailableImagesDataType &&
        payload is Map<String, dynamic>) {
      _logger.log(
        12,
        "Parse and Store Document List Data",
        counter: 0,
        logLevel: 0,
      );
      Map<String, dynamic> jsonMap = payload;
      List<dynamic>? availableDocs = jsonMap["availableDocs"];
      // if (availableDocs?.isNotEmpty ?? false) {
      //   clearPatientMaps();
      // }
      for (var element in availableDocs ?? {}) {
        if (element is Map) {
          var docId = element["docId"];
          var docName = element["docName"];
          var patientId = element["patientId"];
          var docExtension = element["docExtension"];
          if (docExtension == "jpg" || docExtension == "jpeg") {
//            if (docName.toString().startsWith("dd1380_")) {
            _logger.log(12, "$docId :: $patientId :: $docName", logLevel: 0);
            HandoffImageDetailsModel detailsModel =
                HandoffImageDetailsModel.calc(
              patientId: patientId?.toString() ?? "",
              docIdStr: docId?.toString() ?? "",
              docName: docName?.toString() ?? "",
            );
            if (detailsModel == HandoffImageDetailsModel.none) {
              _logger.log(
                12,
                "Returned HandoffImageDetailsModell.none",
                logLevel: 0,
              );
              _logger.log(12, detailsModel.toString(), logLevel: 0);
              continue;
            }
            _logger.log(12, "Returned HandoffImageDetailsModel:", logLevel: 0);
            _logger.log(12, detailsModel.toString(), logLevel: 0);
            _logger.log(12, "Add image details. Has change?", logLevel: 0);
            bool changed = addImageDetails(detailsModel);
            _logger.log(12, "$changed", logLevel: 0);
            hasChange = hasChange || changed;
            _logger.log(12, "Fetch image document.");
            String? dataUrl = await HandoffServices().fetchImageDocument(
              detailsModel.docId,
              detailsModel.patientId,
            );
            if (dataUrl != null) {
              _logger.log(12, "Returned data Url is not null. Adding it.");
              if (addDocIdAndDataUrlForPatient(
                detailsModel.patientId,
                detailsModel.docId,
                dataUrl,
              )) {
                hasImagesSet.add(detailsModel.patientId);
              }
            } else {
              _logger.log(12, "Returned data Url is null.");
            }
//            }
          }
        }
      }
    }
    if (hasChange) {
      _logger.log(12, "Notifying listeners.");
      notifyListeners();
    }
    return true;
  }

  @override
  void storeBoolByDataType(String dataType, String identifier, bool data) {
    // Intentionally empty.
  }

  @override
  void storeDoubleByDataType(String dataType, String identifier, double data) {
    // Intentionally empty.
  }

  @override
  void storeIntByDataType(String dataType, String identifier, int data) {
    // Intentionally empty.
  }

  @override
  void storeRawStringByDataType(
      String dataType, String identifier, String rawString) {}
}

class HandoffImageDetailsStoreAccess extends ChangeNotifier {
  HandoffImageDetailsStore store = HandoffImageDetailsStore();

  HandoffImageDetailsStoreAccess() {
    store.addListener(notifyListeners);
  }

  @override
  void dispose() {
    store.removeListener(notifyListeners);
    super.dispose();
  }
}
