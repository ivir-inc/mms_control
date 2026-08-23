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

part of 'patient_management_bloc.dart';

class PatientManagementState extends Equatable {
  final List<Patient> patients;
  final Map<String, bool> patientVisibility;

  const PatientManagementState({
    required this.patients,
    required this.patientVisibility,
  });

  PatientManagementState copyWith({
    List<Patient>? patients,
    Map<String, bool>? patientVisibility,
  }) {
    return PatientManagementState(
      patients: patients ?? this.patients,
      patientVisibility: patientVisibility ?? this.patientVisibility,
    );
  }

  @override
  List<Object?> get props => [patients, patientVisibility];
}
