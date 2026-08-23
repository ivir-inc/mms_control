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

enum PatientCaseBuilderAction {
  initialize,
  addPatientCase,
  renamePatientCase,
  editOrDisplayPatientCase,
  removePatientCase,
  addInjury,
  removeInjuries,
  editInjury,
  renameInjury,
  updateInjuryLocation,
  updateInjuryType,
  updateInjuryDescription,
  updateInjurySeverity,
  updateInjuryDetail,
  updateInjuryMechanism,
  enableTreatment,
  disableTreatment,
  enableMedication,
  disableMedication,
  updateInitialVitalSigns,
  clearInitialVitalSigns,
  assignPatientCaseToPatient,
  sendPhysicalTreatment,
  sendMedication,
  updateBiologicalSex,
}

class PatientCaseBuilderEvent extends Equatable {
  final PatientCaseBuilderAction action;
  final List<PatientCase>? patientCases;
  final String?
      patientCaseName; // serves as the unique identifier for the Patient Case
  final String? newNameForPatientCase;
  final List<Injury>? injuryIds;
  final String?
      injuryId; // addInjury: the (current) unique identifier for the injury. For use while creating a new injury (addInjury) or renaming an injury (renameInjury)
  final String? newIdForInjury; // renameInjury: use for new injury name
  final BodyLocationRecord?
      bodyLocation; // used to specify body locations for (a) injury definitions (patient case builder) and (b) physical device treatments (patient case runtime)
  final RegionTissueTypeEnum? updatedTissueType;
  final InjuryTypeEnum? updatedInjuryType;
  final InjuryDescriptionEnum? updatedInjuryDescription;
  final double? updatedInjurySeverityDouble;
  final int? updatedInjurySeverityInteger;
  final String? updatedInjuryDetail;
  final MechanismOfInjuryRecord? updatedMechanismOfInjury;
  final String? dynamicTreatmentName;
  final bool? enableDynamicTreatment;
  final String? dynamicMedicationName;
  final bool? enableDynamicMedication;
  final InitialVitalSigns? updatedVitals;
  final String? patientId;
  final int?
      patientCaseNum; // used by Patient Screen only; patientCaseName is the unique identifier otherwise
  final String? dynamicDeviceName;
  final String? administrationRoute;
  final double? dosageValue;
  final int? dosageTimePeriod;
  final BiologicalSexEnum? updatedBiologicalSex;

  final BuildContext? context;

  const PatientCaseBuilderEvent(
    this.action, {
    this.patientCases,
    this.patientCaseName,
    this.newNameForPatientCase,
    this.injuryIds,
    this.injuryId,
    this.newIdForInjury,
    this.bodyLocation,
    this.updatedTissueType,
    this.updatedInjuryType,
    this.updatedInjuryDescription,
    this.updatedInjurySeverityDouble,
    this.updatedInjurySeverityInteger,
    this.updatedInjuryDetail,
    this.updatedMechanismOfInjury,
    this.dynamicTreatmentName,
    this.enableDynamicTreatment,
    this.dynamicMedicationName,
    this.enableDynamicMedication,
    this.updatedVitals,
    this.patientId,
    this.patientCaseNum,
    this.dynamicDeviceName,
    this.administrationRoute,
    this.dosageValue,
    this.dosageTimePeriod,
    this.updatedBiologicalSex,
    this.context,
  });

  @override
  List<Object?> get props => [
        action,
        patientCases,
        patientCaseName,
        newNameForPatientCase,
        injuryIds,
        injuryId,
        newIdForInjury,
        bodyLocation,
        updatedTissueType,
        updatedInjuryType,
        updatedInjuryDescription,
        updatedInjurySeverityDouble,
        updatedInjurySeverityInteger,
        updatedInjuryDetail,
        updatedMechanismOfInjury,
        dynamicTreatmentName,
        enableDynamicTreatment,
        dynamicMedicationName,
        enableDynamicMedication,
        updatedVitals,
        patientId,
        patientCaseNum,
        dynamicDeviceName,
        administrationRoute,
        dosageValue,
        dosageTimePeriod,
        updatedBiologicalSex,
        context
      ];
}
