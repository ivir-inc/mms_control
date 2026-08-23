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
import 'package:flutter/material.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:http/http.dart' as http;

enum VitalsType { ekg, bp, spo2, etco2, rr, temp }

class VitalsPattern {
  final int? ekg;
  final int? bp;
  final int? spo2;
  final int? etco2;

  VitalsPattern({this.ekg, this.bp, this.spo2, this.etco2});

  factory VitalsPattern.fromJson(Map<String, dynamic> json) {
    return VitalsPattern(
      ekg: json['ekg'],
      bp: json['bp'],
      spo2: json['spo2'],
      etco2: json['etco2'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'ekg': ekg, 'bp': bp, 'spo2': spo2, 'etco2': etco2};
}

class VitalsElementVisibility {
  final bool? ekg;
  final bool? bp;
  final bool? spo2;
  final bool? etco2;
  final bool? rr;
  final bool? temp;

  VitalsElementVisibility(
      {this.ekg, this.bp, this.spo2, this.etco2, this.rr, this.temp});

  factory VitalsElementVisibility.fromJson(Map<String, dynamic> json) {
    return VitalsElementVisibility(
      ekg: json['ekg'],
      bp: json['bp'],
      spo2: json['spo2'],
      etco2: json['etco2'],
      rr: json['rr'],
      temp: json['temp'],
    );
  }

  Map<String, dynamic> toJson() => {
        'ekg': ekg,
        'bp': bp,
        'spo2': spo2,
        'etco2': etco2,
        'rr': rr,
        'temp': temp
      };
}

class VitalsPatternOptionItem {
  final int? value;
  final String? patternName;

  VitalsPatternOptionItem({this.value, this.patternName});

  factory VitalsPatternOptionItem.fromJson(Map<String, dynamic> json) {
    return VitalsPatternOptionItem(
      value: json['value'],
      patternName: json['patternName'],
    );
  }

  Map<String, dynamic> toJson() => {'value': value, 'patternName': patternName};
}

class VitalsPatternOptions {
  final List<VitalsPatternOptionItem>? ekg;
  final List<VitalsPatternOptionItem>? bp;
  final List<VitalsPatternOptionItem>? spo2;
  final List<VitalsPatternOptionItem>? etco2;

  VitalsPatternOptions({this.ekg, this.bp, this.spo2, this.etco2});

  factory VitalsPatternOptions.fromJson(Map<String, dynamic> json) {
    VitalsPatternOptions patternOptions = VitalsPatternOptions(
      ekg: (json['ekg'] as List)
          .map((i) => VitalsPatternOptionItem.fromJson(i))
          .toList(),
      bp: (json['bp'] as List)
          .map((i) => VitalsPatternOptionItem.fromJson(i))
          .toList(),
      spo2: (json['spo2'] as List)
          .map((i) => VitalsPatternOptionItem.fromJson(i))
          .toList(),
      etco2: (json['etco2'] as List)
          .map((i) => VitalsPatternOptionItem.fromJson(i))
          .toList(),
    );
    return patternOptions;
  }
}

class VitalsServices {
  VitalsServices._private();

  static final VitalsServices _instance = VitalsServices._private();

  factory VitalsServices() => _instance;

  Future<VitalsPatternOptions?> fetchVitalsPatternOptions(
      {String? patientId}) async {
    String url =
        '${BaseUrlManager.baseUrl}/mms/truMonitor/vitals/pattern/options';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return VitalsPatternOptions.fromJson(json.decode(response.body));
    } else if (response.statusCode == 204) {
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get VitalsPatternOptions');
    }
  }

  Future<VitalsPattern?> fetchVitalsPattern({String? patientId}) async {
    String url = '${BaseUrlManager.baseUrl}/mms/truMonitor/vitals/pattern';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return VitalsPattern.fromJson(json.decode(response.body));
    } else if (response.statusCode == 204) {
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get VitalsPatternOptions');
    }
  }

  Future<VitalsPattern?> postVitalsPattern(VitalsType type, int newValue,
      {String? patientId}) async {
    String url = '${BaseUrlManager.baseUrl}/mms/truMonitor/vitals/pattern';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(VitalsPattern(
        ekg: type == VitalsType.ekg ? newValue : null,
        bp: type == VitalsType.bp ? newValue : null,
        spo2: type == VitalsType.spo2 ? newValue : null,
        etco2: type == VitalsType.etco2 ? newValue : null,
      ).toJson()),
    );
    if ((response.statusCode == 201) || (response.statusCode == 200)) {
      return VitalsPattern.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create VitalsPattern.');
    }
  }

  Future<VitalsElementVisibility?> fetchVitalsVisibility(
      {String? patientId}) async {
    String url = '${BaseUrlManager.baseUrl}/mms/truMonitor/vitals/visibility';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return VitalsElementVisibility.fromJson(json.decode(response.body));
    } else if (response.statusCode == 204) {
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get VitalsVisibility');
    }
  }

  Future<VitalsElementVisibility> postVitalsVisibility(
      VitalsType type, bool newValue,
      {String? patientId}) async {
    String url = '${BaseUrlManager.baseUrl}/mms/truMonitor/vitals/visibility';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(VitalsElementVisibility(
        ekg: type == VitalsType.ekg ? newValue : null,
        bp: type == VitalsType.bp ? newValue : null,
        spo2: type == VitalsType.spo2 ? newValue : null,
        etco2: type == VitalsType.etco2 ? newValue : null,
        rr: type == VitalsType.rr ? newValue : null,
        temp: type == VitalsType.temp ? newValue : null,
      ).toJson()),
    );
    if ((response.statusCode == 201) || (response.statusCode == 200)) {
      return VitalsElementVisibility.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create VitalsVisibility.');
    }
  }

  Future<bool> postVitalEdited(String vitalsType, double targetVital,
      {int? rate, String? patientId}) async {
    String url = '${BaseUrlManager.baseUrl}/mms/sceneng/vitals';
    if (patientId != null) {
      url = "$url?patientId=$patientId";
    }
    try {
      final response = await http.post(Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            "vitalsType": vitalsType,
            "targetVital": targetVital,
            if (rate != null) "rate": rate,
          }));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception("Error posting edited vital.");
    }
  }

  /// [vitalsType] must not be null.
  /// If [isCompoundValue] is passed as true, then [range] will be used to
  /// submit its two extreme values, provided [range] is not null, in which
  /// case, [currentRangeMax], and [vitalsType2] must not be null.
  /// If [isCompoundValue] is false, then [value] will be used to submit a
  /// single value, provided it is not null. If [isCompoundValue] is true
  /// and [range] is null, or if [isCompoundValue] is false and [value] is
  /// null, then nothing will be submitted.
  Future<bool> submitEditedVital(
    String patientId,
    String vitalsType,
    double? value, {
    bool isCompoundValue = false,
    RangeValues? range,
    double? currentRangeMax,
    required String vitalsType2,
  }) async {
    bool allSucceeded = true;
    if (!isCompoundValue) {
      if (value != null) {
        allSucceeded = await VitalsServices().postVitalEdited(
          vitalsType,
          value,
          patientId: patientId
//        rate: rate, // TODO Rate not yet implemented.
        );
      }
    } else if (range != null) {
      bool submitStartFirst =
          range.start < (currentRangeMax ?? double.maxFinite.toInt());
      if (submitStartFirst) {
        // Don't submit start higher than current end.
        allSucceeded = allSucceeded &&
            await VitalsServices().postVitalEdited(
              vitalsType,
              range.start,
              patientId: patientId
//        rate: rate, // Rate not yet implemented.
            );
      }
      allSucceeded = allSucceeded &&
          await VitalsServices().postVitalEdited(
            vitalsType2,
            range.end,
            patientId: patientId
//        rate: rate2, // Rate not yet implemented.
          );
      if (!submitStartFirst) {
        allSucceeded = allSucceeded &&
            await VitalsServices().postVitalEdited(
              vitalsType,
              range.start,
              patientId: patientId
//        rate: rate, // Rate not yet implemented.
            );
      }
    }
    return allSucceeded;
  }
}
