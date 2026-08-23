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

enum PatientManagementAction {
  initialize,
  addPatient,
  updatePhysiologySource,
  toggleVisibility,
  deletePatients,
  updatePatients,
  assignPatientCase,
  refreshFromServer,
  remoteDelete,
}

class PatientManagementEvent extends Equatable {
  final PatientManagementAction action;
  final List<Patient> patients;
  final String? patientId;
  final PatientSource? patientSource;
  final int? patientCaseNum;
  final BuildContext? context;
  final bool locallyCreated;
  final List<String>? patientIds; // for remoteDelete

  const PatientManagementEvent(
    this.action,
    this.patients, {
    this.patientId,
    this.patientSource,
    this.patientCaseNum,
    this.locallyCreated = true,
    this.context,
    this.patientIds,
  });

  @override
  List<Object?> get props => [
        action,
        patients,
        patientId,
        patientSource,
        patientCaseNum,
        locallyCreated,
        context,
        patientIds,
      ];
}
