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
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_ui/data/model/qr_code/network_interface_info.dart';
import 'package:flutter_ui/data/services/base_url_manager.dart';
import 'package:flutter_ui/data/services/http_helper.dart';
import 'package:flutter_ui/shared/logging/logger.dart';

final _logger = Logger('QrCodeService');
const _networkPath = '/mms/system/network';
const _qrPath = '/mms/system/qr';
const _maskPath = '/mms/system/network/endpointMask';

class QrCodeService {
  static Future<List<NetworkInterfaceInfo>> fetchNetworkInterfaces() async {
    final url = '${BaseUrlManager.baseUrl}$_networkPath';
    try {
      final response = await http.get(
        Uri.parse(MmsHttpHelper.breakCacheGetUrl(url)),
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as List;
        return decoded
            .map((e) =>
                NetworkInterfaceInfo.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _logger.log(1, 'fetchNetworkInterfaces failed: ${response.statusCode}');
    } catch (e) {
      _logger.log(1, 'fetchNetworkInterfaces error: $e');
    }
    return [];
  }

  /// Returns the QR PNG bytes, or null if the backend has no matching IP
  /// (404) or the request otherwise fails.
  static Future<Uint8List?> fetchQrCodeImageBytes() async {
    final url = '${BaseUrlManager.baseUrl}$_qrPath';
    try {
      final response =
          await http.get(Uri.parse(MmsHttpHelper.breakCacheGetUrl(url)));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      if (response.statusCode != 404) {
        _logger.log(1, 'fetchQrCodeImageBytes failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger.log(1, 'fetchQrCodeImageBytes error: $e');
    }
    return null;
  }

  /// Returns the current mask/IP preference, or null if unset or the
  /// request fails. The backend returns the literal string "<no mask>"
  /// when unset — normalized to null here.
  static Future<String?> fetchEndpointMask() async {
    final url = '${BaseUrlManager.baseUrl}$_maskPath';
    try {
      final response = await http.get(
        Uri.parse(MmsHttpHelper.breakCacheGetUrl(url)),
        headers: {'accept': 'text/plain'},
      );
      if (response.statusCode == 200) {
        final body = response.body.trim();
        return body.isEmpty || body == '<no mask>' ? null : body;
      }
      _logger.log(1, 'fetchEndpointMask failed: ${response.statusCode}');
    } catch (e) {
      _logger.log(1, 'fetchEndpointMask error: $e');
    }
    return null;
  }

  static Future<bool> updateEndpointMask(String ip) async {
    final url = '${BaseUrlManager.baseUrl}$_maskPath';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'text/plain; charset=UTF-8'},
        body: ip,
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.log(1, 'updateEndpointMask error: $e');
    }
    return false;
  }
}
