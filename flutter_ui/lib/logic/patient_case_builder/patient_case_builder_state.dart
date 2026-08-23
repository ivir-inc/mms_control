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

part of 'patient_case_builder_bloc.dart';

class PatientCaseBuilderState extends Equatable {
  final List<PatientCase> patientCases;
  final String? patientCaseUnderEditOrDisplay;
  final String? injuryIdUnderEdit;
  final Map<String, PatientCase>? patientPatientCase;
  final RequestStatus requestStatus;
  final String? errorMessage;
  final SaveStatus saving;

  const PatientCaseBuilderState(
      {required this.patientCases,
      this.patientCaseUnderEditOrDisplay,
      this.injuryIdUnderEdit,
      this.patientPatientCase,
      this.requestStatus = RequestStatus.initial,
      this.errorMessage,
      this.saving = SaveStatus.saved});

  PatientCaseBuilderState copyWith({
    List<PatientCase>? patientCases,
    String? patientCaseUnderEditOrDisplay,
    String? injuryIdUnderEdit,
    Map<String, PatientCase>? patientPatientCase,
    RequestStatus? requestStatus,
    String? errorMessage,
    SaveStatus? saving,
  }) {
    return PatientCaseBuilderState(
      patientCases: patientCases ?? this.patientCases,
      patientCaseUnderEditOrDisplay:
          patientCaseUnderEditOrDisplay ?? this.patientCaseUnderEditOrDisplay,
      injuryIdUnderEdit: injuryIdUnderEdit ?? this.injuryIdUnderEdit,
      patientPatientCase: patientPatientCase ?? this.patientPatientCase,
      requestStatus: requestStatus ?? this.requestStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [
        patientCases,
        patientCaseUnderEditOrDisplay,
        injuryIdUnderEdit,
        patientPatientCase,
        requestStatus,
        errorMessage,
        saving,
      ];
}

enum RequestStatus { initial, loading, success, failure }

enum SaveStatus { saving, saved }
