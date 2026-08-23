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

class Patient {
  final String id;
  final String name;
  PatientSource physiologySource; // Mutable for updating the source
  bool monitorPatient; // Mutable to support local state for visibility
  final bool physiologySourceCanChange;
  final int? patientCaseNum;

  // Constructor to initialize a Patient object
  Patient(
    this.id,
    this.name,
    this.physiologySource,
    this.monitorPatient, {
    this.physiologySourceCanChange = true,
    this.patientCaseNum,
  });

  // Factory constructor to create a Patient object from a JSON map
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      json['id'] as String,
      json['name'] ?? json['id'] as String, // Fallback to id if name is missing
      _getPatientSourceFromJson(json['physiologySource']),
      json['monitorPatient'] ?? false, // Default to false if not provided.
      physiologySourceCanChange: json['physiologySourceCanChange'] ?? true,
      patientCaseNum: json['patientCaseNum'],
    );
  }

  // Factory constructor to create a Patient object from a JSON map provided by websocket (note use of 'visible' rather than 'monitorPatient' in fromJson() above)
  factory Patient.fromWireJson(Map<String, dynamic> json) {
    return Patient(
      json['id'] as String,
      json['name'] ?? json['id'] as String, // Fallback to id if name is missing
      _getPatientSourceFromJson(json['physiologySource']),
      json['visible'] ??
          false, // Default to false if not provided. 'visible' from backend is equivalent to frontend's 'monitorPatient'
      physiologySourceCanChange: json['physiologySourceCanChange'] ?? true,
      patientCaseNum: json['patientCaseNum'],
    );
  }

  // Convert Patient object to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'physiologySource': physiologySource.name
          .toUpperCase(), // Convert enum to uppercase as required
      'monitorPatient': monitorPatient,
      'patientCaseNum': patientCaseNum,
      // 'physiologySourceCanChange': physiologySourceCanChange,
    };
  }

  // Helper method to convert JSON string to PatientSource enum safely
  static PatientSource _getPatientSourceFromJson(String? source) {
    if (source == null) return PatientSource.unknown;
    return PatientSource.values.firstWhere(
      (e) => e.name.toLowerCase() == source.toLowerCase(),
      orElse: () => PatientSource.unknown,
    );
  }

  // Method to clone the Patient object with the option to modify specific fields (Immutable update pattern)
  Patient copyWith({
    String? id,
    String? name,
    PatientSource? physiologySource,
    bool? monitorPatient,
    bool? physiologySourceCanChange,
    int? patientCaseNum,
  }) {
    return Patient(
      id ?? this.id,
      name ?? this.name,
      physiologySource ?? this.physiologySource,
      monitorPatient ?? this.monitorPatient,
      physiologySourceCanChange:
          physiologySourceCanChange ?? this.physiologySourceCanChange,
      patientCaseNum: patientCaseNum ?? this.patientCaseNum,
    );
  }

  // Display the patient's information in a readable format
  @override
  String toString() {
    return 'Patient(id: $id, name: $name, physiologySource: $physiologySource, monitorPatient: $monitorPatient, physiologySourceCanChange: $physiologySourceCanChange, patientCaseNum: $patientCaseNum)';
  }
}

// Enum to represent different sources of patient physiology
enum PatientSource {
  external,
  internal,
  unknown;

  // Override toString to provide a clean string representation
  @override
  String toString() => name;
}
