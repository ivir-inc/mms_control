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

class Facility extends Equatable {
  final String id;
  final String facilityId;
  final String facilityType;
  final String roleOfCare;
  final int capacity;
  final bool active;
  final bool controlledLocal;

  const Facility({
    required this.id,
    required this.facilityId,
    required this.facilityType,
    required this.roleOfCare,
    required this.capacity,
    required this.active,
    required this.controlledLocal,
  });

  Facility copyWith({
    String? id,
    String? facilityId,
    String? facilityType,
    String? roleOfCare,
    int? capacity,
    bool? active,
    bool? controlledLocal,
  }) {
    return Facility(
        id: id ?? this.id,
        facilityId: facilityId ?? this.facilityId,
        facilityType: facilityType ?? this.facilityType,
        roleOfCare: roleOfCare ?? this.roleOfCare,
        capacity: capacity ?? this.capacity,
        active: active ?? this.active,
        controlledLocal: controlledLocal ?? this.controlledLocal);
  }

  /// Convenience: create a new facility for add dialog
  factory Facility.createWithFacilityId(String facilityId) {
    return Facility(
      id: '',
      facilityId: facilityId,
      facilityType: 'FIXED', // default or inferred
      roleOfCare: 'ROLE1', // default or inferred
      capacity: 10, // sensible default
      active: false,
      controlledLocal: false,
    );
  }

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id']?.toString() ?? '',
      facilityId: json['facilityId'] ?? json['facilityId'] ?? '',
      facilityType: json['facilityType'] ?? '',
      roleOfCare: json['roleOfCare'] ?? '',
      capacity: json['patientCapacity'] is int
          ? json['patientCapacity']
          : int.tryParse(json['patientCapacity'].toString()) ?? 0,
      active: json['active'] == true ||
              json['active'] == 1 ||
              json['active'] == 'true'
          ? true
          : false,
      controlledLocal: json['controlledLocal'] == true ||
              json['controlledLocal'] == 1 ||
              json['controlledLocal'] == 'true'
          ? true
          : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityId': facilityId,
      'facilityType': facilityType,
      'roleOfCare': roleOfCare,
      'patientCapacity': capacity,
      'active': active,
      'controlledLocal': controlledLocal
    };
  }

  @override
  List<Object?> get props => [
        id,
        facilityId,
        facilityType,
        roleOfCare,
        capacity,
        active,
        controlledLocal
      ];
}
