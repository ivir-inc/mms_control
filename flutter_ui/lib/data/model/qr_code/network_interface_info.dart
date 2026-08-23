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

class NetworkInterfaceInfo {
  final String name;
  final String displayName;
  final List<String> ipv4;
  final List<String> ipv6;

  const NetworkInterfaceInfo({
    required this.name,
    required this.displayName,
    required this.ipv4,
    required this.ipv6,
  });

  factory NetworkInterfaceInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInterfaceInfo(
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      ipv4: (json['ipv4'] as List?)?.map((e) => e.toString()).toList() ?? [],
      ipv6: (json['ipv6'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  /// True if every address on this interface is link-local (169.254.0.0/16).
  /// Used to sort self-assigned/failed-DHCP interfaces toward the bottom of
  /// selection lists rather than filtering them out entirely.
  bool get isLinkLocalOnly =>
      ipv4.isNotEmpty && ipv4.every((ip) => ip.startsWith('169.254.'));
}
