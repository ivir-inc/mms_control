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

import 'package:flutter/material.dart';
import 'package:flutter_ui/data/model/metadata/metadata.dart'
    show SimpleEnumItem;
import 'package:flutter_ui/data/storage/metadata_store.dart';

enum BiologicalSexEnum { female, male }

extension BiologicalSexEnumExtension on BiologicalSexEnum {
  String get label => this == BiologicalSexEnum.male ? 'Male' : 'Female';
  String get value => toString().split('.').last; // 'female' / 'male'

  static BiologicalSexEnum fromValue(String? v) =>
      v == 'male' ? BiologicalSexEnum.male : BiologicalSexEnum.female;
}

class PatientCase {
  int? caseNum;
  String? name; // mutable for renaming
  List<Injury>? injuries;
  Treatments? treatments;
  Medications? medications;
  InitialVitalSigns? initialVitalSigns;
  BiologicalSexEnum? biologicalSex; // local patient-case setting (COM-5)

  // Constructor to initialize a Patient object
  PatientCase({
    this.caseNum,
    this.name,
    this.injuries,
    this.treatments,
    this.medications,
    this.initialVitalSigns,
    this.biologicalSex,
  });

  //
  // Convert Patient Case object to JSON for serialization
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> physicalTreatmentJson = [];
    List<Map<String, dynamic>> medicationJson = [];

    // Populate physical treatments
    for (final t in treatments?.getEnabledTypes() ?? []) {
      physicalTreatmentJson.add({
        "injuryName": null,
        "location": null,
        "physicalTreatment": t,
        "physicalDevice": null, // update if needed
      });
    }

    // Populate medications
    for (final m in medications?.getEnabledTypes() ?? []) {
      medicationJson.add({
        "injuryName": null,
        "location": null,
        "medication": m,
        "medRoute": null,
        "medDosage": null,
        "medDosageTimePeriod": null,
      });
    }

    return {
      'caseNum': caseNum,
      'name': name,
      'biologicalSex': (biologicalSex ?? BiologicalSexEnum.female).value,
      'vitals': {
        'heartRate': initialVitalSigns?.hr ?? '',
        'systolicBp': initialVitalSigns?.sbp ?? '',
        'diastolicBp': initialVitalSigns?.dbp ?? '',
        'spO2': initialVitalSigns?.spo2 ?? '',
        'respiratoryRate': initialVitalSigns?.rr ?? '',
        'etco2': initialVitalSigns?.etco2 ?? '',
        'temp': initialVitalSigns?.temp ?? '',
      },
      'injuries':
          injuries?.map((injury) => _injuryToJson(injury)).toList() ?? [],
      'physicalTreatments': physicalTreatmentJson,
      'medications': medicationJson,
    };
  }

  Map<String, dynamic> _injuryToJson(Injury injury) {
    return {
      'name': injury.id,
      'location': injury.location != null
          ? _bodyLocationToJson(injury.location!)
          : null,
      'injuryType': injury.injuryType?.enumValue ?? '',
      'description': injury.description?.enumValue ?? '',
      'detail': injury.detail ?? '',
      'severity': injury.severityScore,
      'hemorrhageRate': injury.hemorrhageRateMlPerMin,
      'totalBodySurfaceArea': injury.burnBodySurfaceAreaPercentage,
      'mechanismOfInjury': {
        'gunshotCaliber': injury.mechanism?.gunshotCaliber?.enumValue ?? '',
        'gunshotAmmunitionType':
            injury.mechanism?.gunshotAmmunitionType?.enumValue ?? '',
        'blade': injury.mechanism?.blade?.enumValue ?? '',
        'blast': injury.mechanism?.blast?.enumValue ?? '',
        'vehicleCrash': injury.mechanism?.vehicleCrash?.enumValue ?? '',
        'fall': injury.mechanism?.fall?.enumValue ?? '',
        'cbrn': injury.mechanism?.cbrn?.enumValue ?? '',
        'shrapnel': injury.mechanism?.shrapnel?.enumValue ?? '',
      }
    };
  }

  Map<String, dynamic> _bodyLocationToJson(BodyLocationRecord location) {
    return {
      'generalRegion': location.generalRegion.enumValue,
      'regionTissueType': location.regionTissueType.enumValue,
      'internalAnatomy': location.internalAnatomy.enumValue,
      'sagittalPlane': location.sagittalPlane.enumValue,
      'transversePlane': location.transversePlane.enumValue,
      'coronalPlane': location.coronalPlane.enumValue,
      'skeletalSystem': location.skeletalSystem.enumValue,
      'detailedAnatomy': location.detailedAnatomy.enumValue,
      'fmaid': location.fmaid,
    };
  }

  // Factory constructor to create a Patient Case object from a JSON map
  factory PatientCase.fromJson(Map<String, dynamic> json) {
    // debugPrint('PatientCase.fromJson: $json');

    final vitalsMap = json['vitals'] as Map<String, dynamic>?;

    return PatientCase(
      caseNum: json['caseNum'] as int?,
      name: json['name'] as String?,
      biologicalSex: BiologicalSexEnumExtension.fromValue(json['biologicalSex'] as String?),
      initialVitalSigns: vitalsMap != null
          ? InitialVitalSigns(
              hr: vitalsMap['heartRate'] as int?,
              sbp: vitalsMap['systolicBp'] as int?,
              dbp: vitalsMap['diastolicBp'] as int?,
              spo2: (vitalsMap['spO2'] as num?)?.toDouble(),
              rr: (vitalsMap['respiratoryRate'] as num?)?.toDouble(),
              etco2: (vitalsMap['etco2'] as num?)?.toDouble(),
              temp: (vitalsMap['temp'] as num?)?.toDouble(),
            )
          : null,
      injuries: (json['injuries'] as List<dynamic>?)?.map((injuryJson) {
        final locationJson = injuryJson['location'] as Map<String, dynamic>?;
        final mechanismJson =
            injuryJson['mechanismOfInjury'] as Map<String, dynamic>?;

        return Injury(
          id: injuryJson['name'] ?? '',
          location: locationJson != null
              ? BodyLocationRecord(
                  generalRegion: EnumUtils.fromMetadataValue(
                    GeneralRegionEnum.values,
                    locationJson['generalRegion'],
                    (e) => e.enumValue,
                    defaultValue: GeneralRegionEnum.notApplicable,
                  ),
                  regionTissueType: EnumUtils.fromMetadataValue(
                    RegionTissueTypeEnum.values,
                    locationJson['regionTissueType'],
                    (e) => e.enumValue,
                    defaultValue: RegionTissueTypeEnum.notApplicable,
                  ),
                  internalAnatomy: EnumUtils.fromMetadataValue(
                    InternalAnatomyEnum.values,
                    locationJson['internalAnatomy'],
                    (e) => e.enumValue,
                    defaultValue: InternalAnatomyEnum.notApplicable,
                  ),
                  sagittalPlane: EnumUtils.fromMetadataValue(
                    SagittalPlaneEnum.values,
                    locationJson['sagittalPlane'],
                    (e) => e.enumValue,
                    defaultValue: SagittalPlaneEnum.notApplicable,
                  ),
                  transversePlane: EnumUtils.fromMetadataValue(
                    TransversePlaneEnum.values,
                    locationJson['transversePlane'],
                    (e) => e.enumValue,
                    defaultValue: TransversePlaneEnum.notApplicable,
                  ),
                  coronalPlane: EnumUtils.fromMetadataValue(
                    CoronalPlaneEnum.values,
                    locationJson['coronalPlane'],
                    (e) => e.enumValue,
                    defaultValue: CoronalPlaneEnum.notApplicable,
                  ),
                  skeletalSystem: EnumUtils.fromMetadataValue(
                    SkeletalSystemEnum.values,
                    locationJson['skeletalSystem'],
                    (e) => e.enumValue,
                    defaultValue: SkeletalSystemEnum.notApplicable,
                  ),
                  detailedAnatomy: EnumUtils.fromMetadataValue(
                    DetailedAnatomyEnum.values,
                    locationJson['detailedAnatomy'],
                    (e) => e.enumValue,
                    defaultValue: DetailedAnatomyEnum.notApplicable,
                  ),
                  fmaid: locationJson['fmaid'] ?? '',
                )
              : null,
          injuryType: (injuryJson['injuryType'] as String?)?.toInjuryTypeEnum(),
          description: (injuryJson['description'] as String?)
              ?.toInjuryDescriptionTypeEnum(),
          hemorrhageRateMlPerMin:
              (injuryJson['hemorrhageRate'] as num?)?.toDouble(),
          burnBodySurfaceAreaPercentage:
              (injuryJson['totalBodySurfaceArea'] as num?)?.toDouble(),
          severityScore: injuryJson['severity'] as int?,
          detail: injuryJson['detail'] as String?,
          mechanism: mechanismJson != null
              ? MechanismOfInjuryRecord(
                  gunshotCaliber: parseEnumValue(
                    GunshotCaliberEnum.values,
                    mechanismJson['gunshotCaliber'] as String?,
                    (e) => e.enumValue,
                    GunshotCaliberEnum.notApplicable,
                  ),
                  gunshotAmmunitionType: parseEnumValue(
                    GunshotAmmunitionTypeEnum.values,
                    mechanismJson['gunshotAmmunitionType'] as String?,
                    (e) => e.enumValue,
                    GunshotAmmunitionTypeEnum.notApplicable,
                  ),
                  blade: parseEnumValue(
                    BladeTypeEnum.values,
                    mechanismJson['blade'] as String?,
                    (e) => e.enumValue,
                    BladeTypeEnum.notApplicable,
                  ),
                  blast: parseEnumValue(
                    BlastTypeEnum.values,
                    mechanismJson['blast'] as String?,
                    (e) => e.enumValue,
                    BlastTypeEnum.notApplicable,
                  ),
                  vehicleCrash: parseEnumValue(
                    VehicleCrashEnum.values,
                    mechanismJson['vehicleCrash'] as String?,
                    (e) => e.enumValue,
                    VehicleCrashEnum.notApplicable,
                  ),
                  fall: parseEnumValue(
                    FallTypeEnum.values,
                    mechanismJson['fall'] as String?,
                    (e) => e.enumValue,
                    FallTypeEnum.notApplicable,
                  ),
                  cbrn: parseEnumValue(
                    CBRNTypeEnum.values,
                    mechanismJson['cbrn'] as String?,
                    (e) => e.enumValue,
                    CBRNTypeEnum.notApplicable,
                  ),
                  shrapnel: parseEnumValue(
                    ShrapnelTypeEnum.values,
                    mechanismJson['shrapnel'] as String?,
                    (e) => e.enumValue,
                    ShrapnelTypeEnum.notApplicable,
                  ),
                )
              : null,
        );
      }).toList(),
      treatments: Treatments(
        (json['physicalTreatments'] as List<dynamic>?)
                ?.map((t) => t['physicalTreatment'] as String?)
                .where((e) => e != null)
                .map((e) => e!)
                .toList() ??
            [],
      ),
      medications: Medications(
        (json['medications'] as List<dynamic>?)
                ?.map((m) => m['medication'] as String?)
                .where((m) => m != null)
                .map((m) => m!)
                .toList() ??
            [],
      ),
    );
  }

  // Method to deep copy Patient Case object with the option to modify specific fields (Immutable update pattern)
  PatientCase copyWith({
    int? caseNum,
    String? name,
    List<Injury>? injuries,
    Treatments? treatments,
    Medications? medications,
    InitialVitalSigns? initialVitalSigns,
    BiologicalSexEnum? biologicalSex,
  }) {
    return PatientCase(
      caseNum: caseNum ?? this.caseNum,
      name: name ?? this.name,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      injuries: injuries ??
          this
              .injuries
              ?.map((injury) => injury.copyWith(
                    id: injury.id,
                    location: injury.location?.copyWith(),
                    injuryType: injury.injuryType,
                    description: injury.description,
                    hemorrhageRateMlPerMin: injury.hemorrhageRateMlPerMin,
                    burnBodySurfaceAreaPercentage:
                        injury.burnBodySurfaceAreaPercentage,
                    severityScore: injury.severityScore,
                    detail: injury.detail,
                    mechanism: injury.mechanism?.copyWith(),
                  ))
              .toList(),
      treatments: treatments ?? this.treatments?.copyWith(),
      medications: medications ?? this.medications?.copyWith(),
      initialVitalSigns:
          initialVitalSigns ?? this.initialVitalSigns?.copyWith(),
    );
  }

  // Display the Patient Case's information in a readable format
  @override
  String toString() {
    return 'Patient Case (caseNum: $caseNum, name: $name, biologicalSex: $biologicalSex, injuries: $injuries, treatments: $treatments, medications: $medications, initialVitalSigns: $initialVitalSigns )';
  }

  factory PatientCase.empty() {
    return PatientCase(
      caseNum: null,
      name: '',
      injuries: [],
      treatments: Treatments([]),
      medications: Medications([]),
      initialVitalSigns: InitialVitalSigns(),
      biologicalSex: BiologicalSexEnum.female,
    );
  }
}

String resolveEnumValueSync(String enumName, String metadataKey) {
  final metadata = MetadataStore().metadata;
  if (metadata == null) return enumName;

  final List<dynamic>? list = switch (metadataKey) {
    'treatmentDevice' => metadata.treatmentDevice,
    'administrationRoute' => metadata.administrationRoute,
    'generalRegion' => metadata.generalRegion,
    'detailedAnatomy' => metadata.detailedAnatomy,
    'skeletalSystem' => metadata.skeletalSystem,
    'coronalPlane' => metadata.coronalPlane,
    'transversePlane' => metadata.transversePlane,
    'sagittalPlane' => metadata.sagittalPlane,
    'internalAnatomy' => metadata.internalAnatomy,
    'regionTissueType' => metadata.regionTissueType,
    _ => null,
  };

  if (list != null) {
    var retVal = '';

    for (var item in list) {
      if (item is SimpleEnumItem && item.name == enumName) {
        retVal = enumName;
      }
    }

    if (retVal == '') {
      debugPrint('** ERROR: could not find enumName in metadata!! **');
    }

    return retVal;
  }

  return enumName;
}

String? resolveEnumValueSyncSafe(String? enumName, String metadataKey) {
  if (enumName == null) return null;

  final metadata = MetadataStore().metadata;
  if (metadata == null) return enumName;

  final List<dynamic>? list = switch (metadataKey) {
    'treatmentDevice' => metadata.treatmentDevice,
    'administrationRoute' => metadata.administrationRoute,
    'generalRegion' => metadata.generalRegion,
    'detailedAnatomy' => metadata.detailedAnatomy,
    'skeletalSystem' => metadata.skeletalSystem,
    'coronalPlane' => metadata.coronalPlane,
    'transversePlane' => metadata.transversePlane,
    'sagittalPlane' => metadata.sagittalPlane,
    'internalAnatomy' => metadata.internalAnatomy,
    'regionTissueType' => metadata.regionTissueType,
    _ => null,
  };

  if (list != null) {
    for (var item in list) {
      if (item is SimpleEnumItem && item.name == enumName) {
        return enumName;
      }
    }
    debugPrint('** WARNING: $enumName not found in $metadataKey metadata **');
    return null;
  }

  return enumName;
}

enum GeneralRegionEnum {
  notApplicable,
  head,
  face,
  neck,
  thorax,
  abdomen,
  pelvis,
  genitaliaMale,
  genitaliaFemale,
  shoulder,
  upperArm,
  elbow,
  forearm,
  wrist,
  hand,
  fingers,
  hip,
  thigh,
  knee,
  lowerLeg,
  ankle,
  foot,
  toes,
}

extension GeneralRegionEnumExtension on GeneralRegionEnum {
  String get label {
    switch (this) {
      case GeneralRegionEnum.notApplicable:
        return 'Not Applicable';
      case GeneralRegionEnum.head:
        return 'Head';
      case GeneralRegionEnum.face:
        return 'Face';
      case GeneralRegionEnum.neck:
        return 'Neck';
      case GeneralRegionEnum.thorax:
        return 'Thorax';
      case GeneralRegionEnum.abdomen:
        return 'Abdomen';
      case GeneralRegionEnum.pelvis:
        return 'Pelvis';
      case GeneralRegionEnum.genitaliaMale:
        return 'Genitalia Male';
      case GeneralRegionEnum.genitaliaFemale:
        return 'Genitalia Female';
      case GeneralRegionEnum.shoulder:
        return 'Shoulder';
      case GeneralRegionEnum.upperArm:
        return 'Upper Arm';
      case GeneralRegionEnum.elbow:
        return 'Elbow';
      case GeneralRegionEnum.forearm:
        return 'Forearm';
      case GeneralRegionEnum.wrist:
        return 'Wrist';
      case GeneralRegionEnum.hand:
        return 'Hand';
      case GeneralRegionEnum.fingers:
        return 'Fingers';
      case GeneralRegionEnum.hip:
        return 'Hip';
      case GeneralRegionEnum.thigh:
        return 'Thigh';
      case GeneralRegionEnum.knee:
        return 'Knee';
      case GeneralRegionEnum.lowerLeg:
        return 'Lower Leg';
      case GeneralRegionEnum.ankle:
        return 'Ankle';
      case GeneralRegionEnum.foot:
        return 'Foot';
      case GeneralRegionEnum.toes:
        return 'Toes';
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'generalRegion'); // in metadata
  }
}

enum RegionTissueTypeEnum {
  notApplicable,
  skin,
  musculature,
  skeletalStructure,
  neuralNetwork,
  vasculature,
}

extension RegionTissueTypeEnumExtension on RegionTissueTypeEnum {
  String get label {
    switch (this) {
      case RegionTissueTypeEnum.notApplicable:
        return 'Not Applicable';
      case RegionTissueTypeEnum.skin:
        return 'Skin';
      case RegionTissueTypeEnum.musculature:
        return 'Musculature';
      case RegionTissueTypeEnum.skeletalStructure:
        return 'Skeletal Structure';
      case RegionTissueTypeEnum.neuralNetwork:
        return 'Neural Network';
      case RegionTissueTypeEnum.vasculature:
        return 'Vasculature';
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'regionTissueType'); // in metadata
  }

  static RegionTissueTypeEnum fromLabel(String label) {
    return RegionTissueTypeEnum.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => RegionTissueTypeEnum.notApplicable,
    );
  }
}

enum InternalAnatomyEnum {
  notApplicable,
  brain,
  eyes,
  heart,
  lung,
  pleuralCavity,
  reproductiveOrganMale,
  reproductiveOrganFemale,
  stomach,
  abdominalCavity,
  smallIntestine,
  largeIntestine,
  liver,
  spleen,
}

extension InternalAnatomyEnumExtension on InternalAnatomyEnum {
  String get label {
    switch (this) {
      case InternalAnatomyEnum.notApplicable:
        return 'Not Applicable';
      case InternalAnatomyEnum.brain:
        return 'Brain';
      case InternalAnatomyEnum.eyes:
        return 'Eyes';
      case InternalAnatomyEnum.heart:
        return 'Heart';
      case InternalAnatomyEnum.lung:
        return 'Lung';
      case InternalAnatomyEnum.pleuralCavity:
        return 'Pleural Cavity';
      case InternalAnatomyEnum.reproductiveOrganMale:
        return 'Reproductive Organ Male';
      case InternalAnatomyEnum.reproductiveOrganFemale:
        return 'Reproductive Organ Female';
      case InternalAnatomyEnum.stomach:
        return 'Stomach';
      case InternalAnatomyEnum.abdominalCavity:
        return 'Abdominal Cavity';
      case InternalAnatomyEnum.smallIntestine:
        return 'Small Intestine';
      case InternalAnatomyEnum.largeIntestine:
        return 'Large Intestine';
      case InternalAnatomyEnum.liver:
        return 'Liver';
      case InternalAnatomyEnum.spleen:
        return 'Spleen';
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'internalAnatomy'); // in metadata
  }
}

enum SagittalPlaneEnum {
  notApplicable,
  left,
  right,
}

extension SagittalPlaneEnumExtension on SagittalPlaneEnum {
  String get label {
    switch (this) {
      case SagittalPlaneEnum.notApplicable:
        return 'Not Applicable';
      case SagittalPlaneEnum.left:
        return 'Left';
      case SagittalPlaneEnum.right:
        return 'Right';
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'sagittalPlane'); // in metadata
  }
}

enum TransversePlaneEnum {
  notApplicable,
  upper,
  lower,
}

extension TransversePlaneEnumExtension on TransversePlaneEnum {
  String get label {
    switch (this) {
      case TransversePlaneEnum.notApplicable:
        return 'Not Applicable';
      case TransversePlaneEnum.upper:
        return 'Upper';
      case TransversePlaneEnum.lower:
        return 'Lower';
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'transversePlane'); // in metadata
  }
}

enum CoronalPlaneEnum {
  notApplicable,
  anterior,
  posterior,
}

extension CoronalPlaneEnumExtension on CoronalPlaneEnum {
  String get label {
    switch (this) {
      case CoronalPlaneEnum.notApplicable:
        return 'Not Applicable';
      case CoronalPlaneEnum.anterior:
        return 'Anterior';
      case CoronalPlaneEnum.posterior:
        return 'Posterior';
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'coronalPlane'); // in metadata
  }
}

enum SkeletalSystemEnum {
  notApplicable,
  skull,
  spine,
  sternum,
  ribs,
  clavicle,
  scapula,
  humerus,
  radius,
  ulna,
  carpals,
  metacarpals,
  phalangesHand,
  pelvis,
  ilium,
  femur,
  patella,
  tibia,
  fibula,
  tarsals,
  metatarsals,
  phalangesFoot,
}

extension SkeletalSystemEnumExtension on SkeletalSystemEnum {
  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'skeletalSystem'); // in metadata
  }
}

enum DetailedAnatomyEnum {
  notApplicable,
  inframammaryPartOfChest,
  spaceOfFirstIntercostalCompartment,
  spaceOfSecondIntercostalCompartment,
  spaceOfThirdIntercostalCompartment,
  spaceOfFourthIntercostalCompartment,
  spaceOfFifthIntercostalCompartment,
  spaceOfSixthIntercostalCompartment,
  spaceOfSeventhIntercostalCompartment,
  spaceOfEighthIntercostalCompartment,
  spaceOfNinthIntercostalCompartment,
  spaceOfTenthIntercostalCompartment,
  spaceOfEleventhIntercostalCompartment,
}

extension DetailedAnatomyEnumExtension on DetailedAnatomyEnum {
  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'detailedAnatomy'); // in metadata
  }
}

class BodyLocationRecord {
  GeneralRegionEnum generalRegion;
  RegionTissueTypeEnum regionTissueType;
  InternalAnatomyEnum internalAnatomy; // n/a
  SagittalPlaneEnum sagittalPlane;
  TransversePlaneEnum transversePlane; // n/a
  CoronalPlaneEnum coronalPlane;
  SkeletalSystemEnum skeletalSystem; // n/a
  DetailedAnatomyEnum detailedAnatomy; // n/a
  String fmaid;

  BodyLocationRecord({
    required this.generalRegion,
    this.regionTissueType = RegionTissueTypeEnum.notApplicable,
    this.internalAnatomy = InternalAnatomyEnum.notApplicable,
    required this.sagittalPlane,
    this.transversePlane = TransversePlaneEnum.notApplicable,
    required this.coronalPlane,
    this.skeletalSystem = SkeletalSystemEnum.notApplicable,
    this.detailedAnatomy = DetailedAnatomyEnum.notApplicable,
    this.fmaid = '',
  });

  static String generateLabel({
    required SagittalPlaneEnum sagittal,
    required CoronalPlaneEnum coronal,
    required GeneralRegionEnum region,
  }) {
    if (region == GeneralRegionEnum.face) {
      return region.label;
    }

    List<String> parts = [];

    if (sagittal != SagittalPlaneEnum.notApplicable) {
      parts.add(sagittal.label);
    }
    if (coronal != CoronalPlaneEnum.notApplicable) {
      parts.add(coronal.label);
    }
    parts.add(region.label);

    return parts.join(' ');
  }

  @override
  String toString() {
    List<String> parts = [];

    parts.add('General Region: ${generalRegion.label}');
    parts.add('Tissue Type: ${regionTissueType.label}');

    if (internalAnatomy != InternalAnatomyEnum.notApplicable) {
      parts.add('Internal Anatomy: ${internalAnatomy.label}');
    }

    if (sagittalPlane != SagittalPlaneEnum.notApplicable) {
      parts.add('Sagittal Plane: ${sagittalPlane.label}');
    }

    if (transversePlane != TransversePlaneEnum.notApplicable) {
      parts.add('Transverse Plane: ${transversePlane.label}');
    }

    if (coronalPlane != CoronalPlaneEnum.notApplicable) {
      parts.add('Coronal Plane: ${coronalPlane.label}');
    }

    if (skeletalSystem != SkeletalSystemEnum.notApplicable) {
      parts.add('Skeletal System: ${skeletalSystem.name}');
    }

    if (detailedAnatomy != DetailedAnatomyEnum.notApplicable) {
      parts.add('Detailed Anatomy: ${detailedAnatomy.name}');
    }

    if (fmaid.isNotEmpty) {
      parts.add('FMA ID: $fmaid');
    }

    return 'BodyLocationRecord(${parts.join(', ')})';
  }

  BodyLocationRecord copyWith({
    GeneralRegionEnum? generalRegion,
    RegionTissueTypeEnum? regionTissueType,
    InternalAnatomyEnum? internalAnatomy, // n/a
    SagittalPlaneEnum? sagittalPlane,
    TransversePlaneEnum? transversePlane, // n/a
    CoronalPlaneEnum? coronalPlane,
    SkeletalSystemEnum? skeletalSystem, // n/a
    DetailedAnatomyEnum? detailedAnatomy, // n/a
    String? fmaid,
  }) {
    return BodyLocationRecord(
      generalRegion: generalRegion ?? this.generalRegion,
      regionTissueType: regionTissueType ?? this.regionTissueType,
      internalAnatomy: internalAnatomy ?? this.internalAnatomy,
      sagittalPlane: sagittalPlane ?? this.sagittalPlane,
      transversePlane: transversePlane ?? this.transversePlane,
      coronalPlane: coronalPlane ?? this.coronalPlane,
      skeletalSystem: skeletalSystem ?? this.skeletalSystem,
      detailedAnatomy: detailedAnatomy ?? this.detailedAnatomy,
      fmaid: fmaid ?? this.fmaid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generalRegion': generalRegion.enumValue,
      'regionTissueType': regionTissueType.enumValue,
      'internalAnatomy': internalAnatomy.enumValue,
      'sagittalPlane': sagittalPlane.enumValue,
      'transversePlane': transversePlane.enumValue,
      'coronalPlane': coronalPlane.enumValue,
      'skeletalSystem': skeletalSystem.enumValue,
      'detailedAnatomy': detailedAnatomy.enumValue,
      'fmaid': fmaid,
    };
  }
}

enum InjuryTypeEnum {
  notApplicable,
  hemorrhage,
  airwayObstruction,
  fracture,
  traumaticBrainInjury,
  pneumothorax,
  tensionPneumothorax,
  hemothorax,
  burn,
  compartmentalPressure,
}

extension InjuryTypeEnumExtension on InjuryTypeEnum {
  String get label {
    switch (this) {
      case InjuryTypeEnum.notApplicable:
        return 'Not Applicable';
      case InjuryTypeEnum.hemorrhage:
        return 'Hemorrhage';
      case InjuryTypeEnum.airwayObstruction:
        return 'Airway Obstruction';
      case InjuryTypeEnum.fracture:
        return 'Fracture';
      case InjuryTypeEnum.traumaticBrainInjury:
        return 'Traumatic Brain Injury';
      case InjuryTypeEnum.pneumothorax:
        return 'Pneumothorax';
      case InjuryTypeEnum.tensionPneumothorax:
        return 'Tension Pneumothorax';
      case InjuryTypeEnum.hemothorax:
        return 'Hemothorax';
      case InjuryTypeEnum.burn:
        return 'Burn';
      case InjuryTypeEnum.compartmentalPressure:
        return 'Compartmental Pressure';
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    // return resolveEnumValueSync(enumName, 'injuryType'); // not in metadata
    return enumName;
  }
}

extension InjuryTypeEnumFromValue on String {
  InjuryTypeEnum toInjuryTypeEnum() {
    return InjuryTypeEnum.values.firstWhere(
      (e) => e.enumValue == this,
      orElse: () => InjuryTypeEnum.notApplicable,
    );
  }
}

enum InjuryDescriptionEnum {
  notApplicable,
  amputation,
  laceration,
  puncture,
  penetrating,
  blunt,
  sprain,
  crush,
  dislocation,
  exposure,
}

extension InjuryDescriptionEnumExtension on InjuryDescriptionEnum {
  String get label {
    switch (this) {
      case InjuryDescriptionEnum.notApplicable:
        return 'Not Applicable';
      case InjuryDescriptionEnum.amputation:
        return 'Amputation';
      case InjuryDescriptionEnum.laceration:
        return 'Laceration';
      case InjuryDescriptionEnum.puncture:
        return 'Puncture';
      case InjuryDescriptionEnum.penetrating:
        return 'Penetrating';
      case InjuryDescriptionEnum.blunt:
        return 'Blunt';
      case InjuryDescriptionEnum.sprain:
        return 'Sprain';
      case InjuryDescriptionEnum.crush:
        return 'Crush';
      case InjuryDescriptionEnum.dislocation:
        return 'Dislocation';
      case InjuryDescriptionEnum.exposure:
        return 'Exposure';
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    // return resolveEnumValueSync(enumName, 'injuryDescription'); // not in metadata
    return enumName;
  }
}

extension InjuryDescriptionEnumFromValue on String {
  InjuryDescriptionEnum toInjuryDescriptionTypeEnum() {
    return InjuryDescriptionEnum.values.firstWhere(
      (e) => e.enumValue == this,
      orElse: () => InjuryDescriptionEnum.notApplicable,
    );
  }
}

enum GunshotCaliberEnum {
  notApplicable,
  unknown,
  caliber22lr,
  caliber9mm,
  caliber10mm,
  caliber50bmg,
  caliber556x45,
  caliber762x51,
}

extension GunshotCaliberEnumExtension on GunshotCaliberEnum {
  String get label {
    switch (this) {
      case GunshotCaliberEnum.notApplicable:
        return 'Not Applicable';
      case GunshotCaliberEnum.unknown:
        return 'Unknown';
      case GunshotCaliberEnum.caliber22lr:
        return '22lr';
      case GunshotCaliberEnum.caliber9mm:
        return '9mm';
      case GunshotCaliberEnum.caliber10mm:
        return '10mm';
      case GunshotCaliberEnum.caliber50bmg:
        return '50bmg';
      case GunshotCaliberEnum.caliber556x45:
        return '556x45';
      case GunshotCaliberEnum.caliber762x51:
        return '762x51';
    }
  }
}

extension GunshotCaliberEnumFromValue on String {
  GunshotCaliberEnum toGunshotCaliberEnum() {
    return GunshotCaliberEnum.values.firstWhere(
      (e) => e.enumValue == this,
      orElse: () => GunshotCaliberEnum.notApplicable,
    );
  }
}

extension GunshotCaliberEnumValueExtension on GunshotCaliberEnum {
  String get enumValue {
    final enumName = toString().split('.').last;
    // return resolveEnumValueSync(enumName, 'gunshotCaliber'); // not in metadata
    return enumName;
  }
}

enum GunshotAmmunitionTypeEnum {
  notApplicable,
  unknown,
  fullMetalJacket,
  hollowPoint,
  armorPiercing,
  incendiary,
}

extension GunshotAmmunitionTypeEnumExtension on GunshotAmmunitionTypeEnum {
  String get label {
    switch (this) {
      case GunshotAmmunitionTypeEnum.notApplicable:
        return 'Not Applicable';
      case GunshotAmmunitionTypeEnum.unknown:
        return 'Unknown';
      case GunshotAmmunitionTypeEnum.fullMetalJacket:
        return 'Full Metal Jacket';
      case GunshotAmmunitionTypeEnum.hollowPoint:
        return 'Hollow Point';
      case GunshotAmmunitionTypeEnum.armorPiercing:
        return 'Armor Piercing';
      case GunshotAmmunitionTypeEnum.incendiary:
        return 'Incendiary';
    }
  }
}

extension GunshotAmmunitionTypeEnumFromValue on String {
  GunshotAmmunitionTypeEnum toGunshotAmmunitionTypeEnum() {
    return GunshotAmmunitionTypeEnum.values.firstWhere(
      (e) => e.enumValue == this,
      orElse: () => GunshotAmmunitionTypeEnum.notApplicable,
    );
  }
}

extension GunshotAmmunitionTypeEnumValueExtension on GunshotAmmunitionTypeEnum {
  String get enumValue {
    final enumName = toString().split('.').last;
    // return resolveEnumValueSync(enumName, 'gunshotAmmunitionType'); // not in metadata
    return enumName;
  }
}

enum BladeTypeEnum {
  notApplicable,
  unknown,
  serratedShort,
  serratedMedium,
  serratedLong,
  smoothShort,
  smoothMedium,
  smoothLong,
}

extension BladeTypeEnumExtension on BladeTypeEnum {
  String get label {
    switch (this) {
      case BladeTypeEnum.notApplicable:
        return 'Not Applicable';
      case BladeTypeEnum.unknown:
        return 'Unknown';
      case BladeTypeEnum.serratedShort:
        return 'Serrated Short';
      case BladeTypeEnum.serratedMedium:
        return 'Serrated Medium';
      case BladeTypeEnum.serratedLong:
        return 'Serrated Long';
      case BladeTypeEnum.smoothShort:
        return 'Smooth Short';
      case BladeTypeEnum.smoothMedium:
        return 'Smooth Medium';
      case BladeTypeEnum.smoothLong:
        return 'Smooth Long';
    }
  }
}

// values have to be mapped manually unlike the other 'mechanism of injury' enums
// because of the backend's use of underscores in addition to lower camel case
extension BladeTypeEnumFromValue on String {
  BladeTypeEnum toBladeTypeEnum() {
    switch (this) {
      case 'notApplicable':
        return BladeTypeEnum.notApplicable;
      case 'unknown':
        return BladeTypeEnum.unknown;
      case 'serrated_Short':
        return BladeTypeEnum.serratedShort;
      case 'serrated_Medium':
        return BladeTypeEnum.serratedMedium;
      case 'serrated_Long':
        return BladeTypeEnum.serratedLong;
      case 'smooth_Short':
        return BladeTypeEnum.smoothShort;
      case 'smooth_Medium':
        return BladeTypeEnum.smoothMedium;
      case 'smooth_Long':
        return BladeTypeEnum.smoothLong;
      default:
        return BladeTypeEnum.notApplicable;
    }
  }
}

// values have to be mapped manually unlike the other 'mechanism of injury' enums
// because of the backend's use of underscores in addition to lower camel case
extension BladeTypeEnumValueExtension on BladeTypeEnum {
  String get enumValue {
    switch (this) {
      case BladeTypeEnum.notApplicable:
        return 'notApplicable';
      case BladeTypeEnum.unknown:
        return 'unknown';
      case BladeTypeEnum.serratedShort:
        return 'serrated_Short';
      case BladeTypeEnum.serratedMedium:
        return 'serrated_Medium';
      case BladeTypeEnum.serratedLong:
        return 'serrated_Long';
      case BladeTypeEnum.smoothShort:
        return 'smooth_Short';
      case BladeTypeEnum.smoothMedium:
        return 'smooth_Medium';
      case BladeTypeEnum.smoothLong:
        return 'smooth_Long';
    }
  }
}

enum BlastTypeEnum {
  notApplicable,
  unknown,
  iedMounted,
  iedDismounted,
  grenade,
  rpg,
  indirect,
  highYieldExplosive,
}

extension BlastTypeEnumExtension on BlastTypeEnum {
  String get label {
    switch (this) {
      case BlastTypeEnum.notApplicable:
        return 'Not Applicable';
      case BlastTypeEnum.unknown:
        return 'Unknown';
      case BlastTypeEnum.iedMounted:
        return 'IED Mounted';
      case BlastTypeEnum.iedDismounted:
        return 'IED Dismounted';
      case BlastTypeEnum.grenade:
        return 'Grenade';
      case BlastTypeEnum.rpg:
        return 'RPG';
      case BlastTypeEnum.indirect:
        return 'Indirect';
      case BlastTypeEnum.highYieldExplosive:
        return 'High Yield Explosive';
    }
  }
}

// values have to be mapped manually unlike the other 'mechanism of injury' enums
// because of the backend's use of underscores/non-standard case
extension BlastTypeEnumFromValue on String {
  BlastTypeEnum toBlastTypeEnum() {
    switch (this) {
      case 'notApplicable':
        return BlastTypeEnum.notApplicable;
      case 'unknown':
        return BlastTypeEnum.unknown;
      case 'IED_Mounted':
        return BlastTypeEnum.iedMounted;
      case 'IED_Dismounted':
        return BlastTypeEnum.iedDismounted;
      case 'grenade':
        return BlastTypeEnum.grenade;
      case 'RPG':
        return BlastTypeEnum.rpg;
      case 'indirect':
        return BlastTypeEnum.indirect;
      case 'highYieldExplosive':
        return BlastTypeEnum.highYieldExplosive;
      default:
        return BlastTypeEnum.notApplicable;
    }
  }
}

// values have to be mapped manually unlike the other 'mechanism of injury' enums
// because of the backend's use of underscores/non-standard case
extension BlastTypeEnumValueExtension on BlastTypeEnum {
  String get enumValue {
    switch (this) {
      case BlastTypeEnum.notApplicable:
        return 'notApplicable';
      case BlastTypeEnum.unknown:
        return 'unknown';
      case BlastTypeEnum.iedMounted:
        return 'IED_Mounted';
      case BlastTypeEnum.iedDismounted:
        return 'IED_Dismounted';
      case BlastTypeEnum.grenade:
        return 'grenade';
      case BlastTypeEnum.rpg:
        return 'RPG';
      case BlastTypeEnum.indirect:
        return 'indirect';
      case BlastTypeEnum.highYieldExplosive:
        return 'highYieldExplosive';
    }
  }
}

enum VehicleCrashEnum {
  notApplicable,
  groundVehicleCrash,
  groundVehicleImpact,
  aircraftCrash,
}

extension VehicleCrashEnumExtension on VehicleCrashEnum {
  String get label {
    switch (this) {
      case VehicleCrashEnum.notApplicable:
        return 'Not Applicable';
      case VehicleCrashEnum.groundVehicleCrash:
        return 'Ground Vehicle Crash';
      case VehicleCrashEnum.groundVehicleImpact:
        return 'Ground Vehicle Impact';
      case VehicleCrashEnum.aircraftCrash:
        return 'Aircraft Crash';
    }
  }
}

extension VehicleCrashEnumFromLabel on String {
  VehicleCrashEnum toVehicleCrashEnum() {
    return VehicleCrashEnum.values.firstWhere(
      (e) => e.enumValue == this,
      orElse: () => VehicleCrashEnum.notApplicable,
    );
  }
}

extension VehicleCrashEnumValueExtension on VehicleCrashEnum {
  String get enumValue {
    final enumName = toString().split('.').last;
    // return resolveEnumValueSync(enumName, 'vehicleCrash'); // not in metadata
    return enumName;
  }
}

enum FallTypeEnum {
  notApplicable,
  unknown,
  under5Feet,
  between5And10Feet,
  over10Feet,
}

extension FallTypeEnumExtension on FallTypeEnum {
  String get label {
    switch (this) {
      case FallTypeEnum.notApplicable:
        return 'Not Applicable';
      case FallTypeEnum.unknown:
        return 'Unknown';
      case FallTypeEnum.under5Feet:
        return 'Under 5 Feet';
      case FallTypeEnum.between5And10Feet:
        return 'Between 5 and 10 Feet';
      case FallTypeEnum.over10Feet:
        return 'Over 10 Feet';
    }
  }
}

extension FallTypeEnumFromValue on String {
  FallTypeEnum toFallTypeEnum() {
    return FallTypeEnum.values.firstWhere(
      (e) => e.enumValue == this,
      orElse: () => FallTypeEnum.notApplicable,
    );
  }
}

extension FallTypeEnumValueExtension on FallTypeEnum {
  String get enumValue {
    final enumName = toString().split('.').last;
    // return resolveEnumValueSync(enumName, 'fall'); // not in metadata
    return enumName;
  }
}

enum CBRNTypeEnum {
  notApplicable,
  unknown,
  chemical,
  biological,
  radiological,
  nuclear,
}

extension CBRNTypeEnumExtension on CBRNTypeEnum {
  String get label {
    switch (this) {
      case CBRNTypeEnum.notApplicable:
        return 'Not Applicable';
      case CBRNTypeEnum.unknown:
        return 'Unknown';
      case CBRNTypeEnum.chemical:
        return 'Chemical';
      case CBRNTypeEnum.biological:
        return 'Biological';
      case CBRNTypeEnum.radiological:
        return 'Radiological';
      case CBRNTypeEnum.nuclear:
        return 'Nuclear';
    }
  }
}

extension CBRNTypeEnumFromValue on String {
  CBRNTypeEnum toCBRNTypeEnum() {
    return CBRNTypeEnum.values.firstWhere(
      (e) => e.enumValue == this,
      orElse: () => CBRNTypeEnum.notApplicable,
    );
  }
}

extension CBRNTypeEnumValueExtension on CBRNTypeEnum {
  String get enumValue {
    final enumName = toString().split('.').last;
    // return resolveEnumValueSync(enumName, 'cbrn'); // not in metadata
    return enumName;
  }
}

enum ShrapnelTypeEnum {
  notApplicable,
  unknown,
  roundSmall,
  roundMedium,
  roundLarge,
  jaggedSmall,
  jaggedMedium,
  jaggedLarge,
}

extension ShrapnelTypeEnumExtension on ShrapnelTypeEnum {
  String get label {
    switch (this) {
      case ShrapnelTypeEnum.notApplicable:
        return 'Not Applicable';
      case ShrapnelTypeEnum.unknown:
        return 'Unknown';
      case ShrapnelTypeEnum.roundSmall:
        return 'Round - Small';
      case ShrapnelTypeEnum.roundMedium:
        return 'Round - Medium';
      case ShrapnelTypeEnum.roundLarge:
        return 'Round - Large';
      case ShrapnelTypeEnum.jaggedSmall:
        return 'Jagged - Small';
      case ShrapnelTypeEnum.jaggedMedium:
        return 'Jagged - Medium';
      case ShrapnelTypeEnum.jaggedLarge:
        return 'Jagged - Large';
    }
  }
}

// values have to be mapped manually unlike the other 'mechanism of injury' enums
// because of the backend's use of underscores in addition to lower camel case
extension ShrapnelTypeEnumFromValue on String {
  ShrapnelTypeEnum toShrapnelTypeEnum() {
    switch (this) {
      case 'notApplicable':
        return ShrapnelTypeEnum.notApplicable;
      case 'unknown':
        return ShrapnelTypeEnum.unknown;
      case 'round_Small':
        return ShrapnelTypeEnum.roundSmall;
      case 'round_Medium':
        return ShrapnelTypeEnum.roundMedium;
      case 'round_Large':
        return ShrapnelTypeEnum.roundLarge;
      case 'jagged_Small':
        return ShrapnelTypeEnum.jaggedSmall;
      case 'jagged_Medium':
        return ShrapnelTypeEnum.jaggedMedium;
      case 'jagged_Large':
        return ShrapnelTypeEnum.jaggedLarge;
      default:
        return ShrapnelTypeEnum.notApplicable;
    }
  }
}

// values have to be mapped manually unlike the other 'mechanism of injury' enums
// because of the backend's use of underscores in addition to lower camel case
extension ShrapnelTypeEnumValueExtension on ShrapnelTypeEnum {
  String get enumValue {
    switch (this) {
      case ShrapnelTypeEnum.notApplicable:
        return 'notApplicable';
      case ShrapnelTypeEnum.unknown:
        return 'unknown';
      case ShrapnelTypeEnum.roundSmall:
        return 'round_Small';
      case ShrapnelTypeEnum.roundMedium:
        return 'round_Medium';
      case ShrapnelTypeEnum.roundLarge:
        return 'round_Large';
      case ShrapnelTypeEnum.jaggedSmall:
        return 'jagged_Small';
      case ShrapnelTypeEnum.jaggedMedium:
        return 'jagged_Medium';
      case ShrapnelTypeEnum.jaggedLarge:
        return 'jagged_Large';
    }
  }
}

class MechanismOfInjuryRecord {
  final GunshotCaliberEnum? gunshotCaliber;
  final GunshotAmmunitionTypeEnum? gunshotAmmunitionType;
  final BladeTypeEnum? blade;
  final BlastTypeEnum? blast;
  final VehicleCrashEnum? vehicleCrash;
  final FallTypeEnum? fall;
  final CBRNTypeEnum? cbrn;
  final ShrapnelTypeEnum? shrapnel;

  const MechanismOfInjuryRecord({
    this.gunshotCaliber,
    this.gunshotAmmunitionType,
    this.blade,
    this.blast,
    this.vehicleCrash,
    this.fall,
    this.cbrn,
    this.shrapnel,
  });

  MechanismOfInjuryRecord copyWith({
    GunshotCaliberEnum? gunshotCaliber,
    GunshotAmmunitionTypeEnum? gunshotAmmunitionType,
    BladeTypeEnum? blade,
    BlastTypeEnum? blast,
    VehicleCrashEnum? vehicleCrash,
    FallTypeEnum? fall,
    CBRNTypeEnum? cbrn,
    ShrapnelTypeEnum? shrapnel,
  }) {
    return MechanismOfInjuryRecord(
      gunshotCaliber: gunshotCaliber ?? this.gunshotCaliber,
      gunshotAmmunitionType:
          gunshotAmmunitionType ?? this.gunshotAmmunitionType,
      blade: blade ?? this.blade,
      blast: blast ?? this.blast,
      vehicleCrash: vehicleCrash ?? this.vehicleCrash,
      fall: fall ?? this.fall,
      cbrn: cbrn ?? this.cbrn,
      shrapnel: shrapnel ?? this.shrapnel,
    );
  }

  Map<String, String>? getSelectedMechanismAsMap() {
    final Map<String, String> selected = {};

    if (gunshotCaliber != null &&
        gunshotCaliber != GunshotCaliberEnum.notApplicable) {
      selected['gunshotCaliber'] = gunshotCaliber!.enumValue;
    }
    if (gunshotAmmunitionType != null &&
        gunshotAmmunitionType != GunshotAmmunitionTypeEnum.notApplicable) {
      selected['gunshotAmmunitionType'] = gunshotAmmunitionType!.enumValue;
    }
    if (blade != null && blade != BladeTypeEnum.notApplicable) {
      selected['blade'] = blade!.enumValue;
    }
    if (blast != null && blast != BlastTypeEnum.notApplicable) {
      selected['blast'] = blast!.enumValue;
    }
    if (vehicleCrash != null &&
        vehicleCrash != VehicleCrashEnum.notApplicable) {
      selected['vehicleCrash'] = vehicleCrash!.enumValue;
    }
    if (fall != null && fall != FallTypeEnum.notApplicable) {
      selected['fall'] = fall!.enumValue;
    }
    if (cbrn != null && cbrn != CBRNTypeEnum.notApplicable) {
      selected['cbrn'] = cbrn!.enumValue;
    }
    if (shrapnel != null && shrapnel != ShrapnelTypeEnum.notApplicable) {
      selected['shrapnel'] = shrapnel!.enumValue;
    }

    return selected.isEmpty ? null : selected;
  }
}

// Mutable because injuries are editable
class Injury {
  String id;
  BodyLocationRecord? location;
  InjuryTypeEnum? injuryType;
  InjuryDescriptionEnum? description;
  double? hemorrhageRateMlPerMin;
  double? burnBodySurfaceAreaPercentage;
  int? severityScore;
  String? detail;
  MechanismOfInjuryRecord? mechanism;

  Injury({
    required this.id,
    this.location, // It's legal to create an injury without an injury location
    this.injuryType,
    this.description,
    this.hemorrhageRateMlPerMin, // optional
    this.burnBodySurfaceAreaPercentage, // optional
    this.severityScore, // optional; valid values 1-10
    this.detail,
    this.mechanism,
  });

  Injury copyWith({
    String? id,
    BodyLocationRecord? location,
    InjuryTypeEnum? injuryType,
    InjuryDescriptionEnum? description,
    double? hemorrhageRateMlPerMin,
    double? burnBodySurfaceAreaPercentage,
    int? severityScore,
    String? detail,
    MechanismOfInjuryRecord? mechanism,
  }) {
    return Injury(
      id: id ?? this.id,
      location: location ?? this.location,
      injuryType: injuryType ?? this.injuryType,
      description: description ?? this.description,
      hemorrhageRateMlPerMin:
          hemorrhageRateMlPerMin ?? this.hemorrhageRateMlPerMin,
      burnBodySurfaceAreaPercentage:
          burnBodySurfaceAreaPercentage ?? this.burnBodySurfaceAreaPercentage,
      severityScore: severityScore ?? this.severityScore,
      detail: detail ?? this.detail,
      mechanism: mechanism ?? this.mechanism,
    );
  }

  @override
  String toString() {
    return id;
    //return 'Injury (id: $id, location: $location, injuryType: $injuryType, description: $description, hemorrhageRateMlPerMin: $hemorrhageRateMlPerMin, burnBodySurfaceAreaPercentage: $burnBodySurfaceAreaPercentage, severityScore: $severityScore, detail: $detail, mechanism: $mechanism )';
  }
}

enum PhysicalTreatmentCategoryEnum {
  airway,
  massivehemorrhage,
  respiration,
  general,
  hypothermia,
  circulation,
}

extension PhysicalTreatmentCategoryEnumExtension
    on PhysicalTreatmentCategoryEnum {
  String get label {
    switch (this) {
      case PhysicalTreatmentCategoryEnum.airway:
        return 'Airway';
      case PhysicalTreatmentCategoryEnum.massivehemorrhage:
        return 'Massive Hemorrhage';
      case PhysicalTreatmentCategoryEnum.respiration:
        return 'Respiration';
      case PhysicalTreatmentCategoryEnum.general:
        return 'General';
      case PhysicalTreatmentCategoryEnum.hypothermia:
        return 'Hypothermia';
      case PhysicalTreatmentCategoryEnum.circulation:
        return 'Circulation';
    }
  }
}

enum PhysicalTreatmentTypeEnum {
  openNasalAirway,
  openTrachealAirway,
  stopHemorrhage,
  releaseIntrapleuralPressure,
  stabilizeOrthopedicFracture,
  immobilizeSpine,
  cleanWound,
  elevateHead,
  sealChestWound,
  warmPatient,
  catheterize,
  ventilationManual,
  chestCompression,
  defibrillate,
  ventilationHyper,
  ventilationPEEP5,
  ventilationPEEP15,
  bandageBurn,
  releaseCompartmentalPressure,
  releaseSkinPressure,
  coverEye,
}

extension PhysicalTreatmentTypeEnumExtension on PhysicalTreatmentTypeEnum {
  String get label {
    switch (this) {
      case PhysicalTreatmentTypeEnum.openNasalAirway:
        return 'Open Nasal Airway';
      case PhysicalTreatmentTypeEnum.openTrachealAirway:
        return 'Open Airway';
      case PhysicalTreatmentTypeEnum.stopHemorrhage:
        return 'Stop Hemorrhage';
      case PhysicalTreatmentTypeEnum.releaseIntrapleuralPressure:
        return 'Treat Pneumothorax';
      case PhysicalTreatmentTypeEnum.stabilizeOrthopedicFracture:
        return 'Stabilize Fracture';
      case PhysicalTreatmentTypeEnum.immobilizeSpine:
        return 'Immobilize Spine';
      case PhysicalTreatmentTypeEnum.cleanWound:
        return 'Clean Wound';
      case PhysicalTreatmentTypeEnum.elevateHead:
        return 'Elevate Head';
      case PhysicalTreatmentTypeEnum.sealChestWound:
        return 'Seal Chest Wound';
      case PhysicalTreatmentTypeEnum.warmPatient:
        return 'Warm Patient';
      case PhysicalTreatmentTypeEnum.catheterize:
        return 'Catheterization';
      case PhysicalTreatmentTypeEnum.ventilationManual:
        return 'Manual Ventilation';
      case PhysicalTreatmentTypeEnum.chestCompression:
        return 'Chest Compressions';
      case PhysicalTreatmentTypeEnum.defibrillate:
        return 'Defibrillate';
      case PhysicalTreatmentTypeEnum.ventilationHyper:
        return 'Hyperventilate';
      case PhysicalTreatmentTypeEnum.ventilationPEEP5:
        return 'PEEP-5';
      case PhysicalTreatmentTypeEnum.ventilationPEEP15:
        return 'PEEP-15';
      case PhysicalTreatmentTypeEnum.bandageBurn:
        return 'Bandage Burn';
      case PhysicalTreatmentTypeEnum.releaseCompartmentalPressure:
        return 'Fasciotomy';
      case PhysicalTreatmentTypeEnum.releaseSkinPressure:
        return 'Release Skin Pressure';
      case PhysicalTreatmentTypeEnum.coverEye:
        return 'Cover Eye';
    }
  }

  PhysicalTreatmentCategoryEnum get category {
    switch (this) {
      case PhysicalTreatmentTypeEnum.openNasalAirway:
        return PhysicalTreatmentCategoryEnum.airway;
      case PhysicalTreatmentTypeEnum.openTrachealAirway:
        return PhysicalTreatmentCategoryEnum.airway;
      case PhysicalTreatmentTypeEnum.stopHemorrhage:
        return PhysicalTreatmentCategoryEnum.massivehemorrhage;
      case PhysicalTreatmentTypeEnum.releaseIntrapleuralPressure:
        return PhysicalTreatmentCategoryEnum.respiration;
      case PhysicalTreatmentTypeEnum.stabilizeOrthopedicFracture:
        return PhysicalTreatmentCategoryEnum.general;
      case PhysicalTreatmentTypeEnum.immobilizeSpine:
        return PhysicalTreatmentCategoryEnum.general;
      case PhysicalTreatmentTypeEnum.cleanWound:
        return PhysicalTreatmentCategoryEnum.general;
      case PhysicalTreatmentTypeEnum.elevateHead:
        return PhysicalTreatmentCategoryEnum.airway;
      case PhysicalTreatmentTypeEnum.sealChestWound:
        return PhysicalTreatmentCategoryEnum.respiration;
      case PhysicalTreatmentTypeEnum.warmPatient:
        return PhysicalTreatmentCategoryEnum.hypothermia;
      case PhysicalTreatmentTypeEnum.catheterize:
        return PhysicalTreatmentCategoryEnum.general;
      case PhysicalTreatmentTypeEnum.ventilationManual:
        return PhysicalTreatmentCategoryEnum.respiration;
      case PhysicalTreatmentTypeEnum.chestCompression:
        return PhysicalTreatmentCategoryEnum.circulation;
      case PhysicalTreatmentTypeEnum.defibrillate:
        return PhysicalTreatmentCategoryEnum.circulation;
      case PhysicalTreatmentTypeEnum.ventilationHyper:
        return PhysicalTreatmentCategoryEnum.respiration;
      case PhysicalTreatmentTypeEnum.ventilationPEEP5:
        return PhysicalTreatmentCategoryEnum.respiration;
      case PhysicalTreatmentTypeEnum.ventilationPEEP15:
        return PhysicalTreatmentCategoryEnum.respiration;
      case PhysicalTreatmentTypeEnum.bandageBurn:
        return PhysicalTreatmentCategoryEnum.general;
      case PhysicalTreatmentTypeEnum.releaseCompartmentalPressure:
        return PhysicalTreatmentCategoryEnum.respiration;
      case PhysicalTreatmentTypeEnum.releaseSkinPressure:
        return PhysicalTreatmentCategoryEnum.general;
      case PhysicalTreatmentTypeEnum.coverEye:
        return PhysicalTreatmentCategoryEnum.general;
    }
  }

  // // Optional: for consistent JSON keys
  // String get jsonValue {
  //   return toString().split('.').last;
  // }
}

class Treatments {
  final Map<String, bool> _enabledMap = {};

  Treatments(List<String>? enabled) {
    for (var value in enabled ?? []) {
      _enabledMap[value] = true;
    }
  }

  Treatments._fromMap(Map<String, bool> source) {
    _enabledMap.addAll(source);
  }

  Treatments copyWith({List<String>? enable, List<String>? disable}) {
    final newMap = Map<String, bool>.from(_enabledMap);
    for (var value in enable ?? []) {
      newMap[value] = true;
    }
    for (var value in disable ?? []) {
      newMap[value] = false;
    }
    return Treatments._fromMap(newMap);
  }

  bool isEnabled(String enumConstant) => _enabledMap[enumConstant] ?? false;

  List<String> getEnabledTypes() => _enabledMap.entries
      .where((entry) => entry.value)
      .map((e) => e.key)
      .toList();

  @override
  String toString() => _enabledMap.toString();
}

enum MedicationCategoryEnum {
  none,
  fluid,
  drug,
  antiInfection,
}

extension MedicationCategoryEnumExtension on MedicationCategoryEnum {
  String get label {
    switch (this) {
      case MedicationCategoryEnum.none:
        return 'None';
      case MedicationCategoryEnum.fluid:
        return 'Fluid';
      case MedicationCategoryEnum.drug:
        return 'Drug';
      case MedicationCategoryEnum.antiInfection:
        return 'Anti-Infection';
    }
  }
}

enum MedicationEnum {
  notApplicable,
  saline09,
  saline3,
  morphine,
  ketamine,
  epinephrine,
  dextrose,
  lactatedRingers,
  oxygen,
  aspirin,
  calciumGluconate,
  sodiumChloride,
  midazolamHydrochloride,
  diphenhydramine,
  acetaminophen,
  moxifloxacin,
  ertapenem,
  meloxicam,
  ondansetron,
  fentanylCitrate,
  methylprednisolone,
  naloxone,
  tranexamicAcid,
  atropine,
  lidocaine,
  adenosine,
  hextend,
  freshWholeBlood,
  plasma,
  redBloodCells,
  plasmalyteA,
  clindamycin,
  acyclovir,
  narcan,
  ibuprofen
}

extension MedicationEnumExtension on MedicationEnum {
  String get label {
    switch (this) {
      case MedicationEnum.notApplicable:
        return 'Not Applicable';
      case MedicationEnum.saline09:
        return 'Saline 0.9%';
      case MedicationEnum.saline3:
        return 'Saline 3%';
      case MedicationEnum.morphine:
        return 'Morphine';
      case MedicationEnum.ketamine:
        return 'Ketamine';
      case MedicationEnum.epinephrine:
        return 'Epinephrine';
      case MedicationEnum.dextrose:
        return 'Dextrose';
      case MedicationEnum.lactatedRingers:
        return 'Lactated Ringers';
      case MedicationEnum.oxygen:
        return 'Oxygen';
      case MedicationEnum.aspirin:
        return 'Aspirin';
      case MedicationEnum.calciumGluconate:
        return 'Calcium Gluconate';
      case MedicationEnum.sodiumChloride:
        return 'Sodium Cl';
      case MedicationEnum.midazolamHydrochloride:
        return 'Midazolam Hcl';
      case MedicationEnum.diphenhydramine:
        return 'Diphenhydramine';
      case MedicationEnum.acetaminophen:
        return 'Acetaminophen';
      case MedicationEnum.moxifloxacin:
        return 'Moxifloxacin';
      case MedicationEnum.ertapenem:
        return 'Ertapenem';
      case MedicationEnum.meloxicam:
        return 'Meloxicam';
      case MedicationEnum.ondansetron:
        return 'Ondansetron';
      case MedicationEnum.fentanylCitrate:
        return 'Fentanyl Citrate';
      case MedicationEnum.methylprednisolone:
        return 'Methyl Prednisolone';
      case MedicationEnum.naloxone:
        return 'Naloxone';
      case MedicationEnum.tranexamicAcid:
        return 'TXA';
      case MedicationEnum.atropine:
        return 'Atropine';
      case MedicationEnum.lidocaine:
        return 'Lidocaine';
      case MedicationEnum.adenosine:
        return 'Adenosine';
      case MedicationEnum.hextend:
        return 'Hextend';
      case MedicationEnum.freshWholeBlood:
        return 'Fresh Whole Blood';
      case MedicationEnum.plasma:
        return 'Plasma';
      case MedicationEnum.redBloodCells:
        return 'RBCs';
      case MedicationEnum.plasmalyteA:
        return 'PlasmalyteA';
      case MedicationEnum.clindamycin:
        return 'Clindamycin';
      case MedicationEnum.acyclovir:
        return 'Acyclovir';
      case MedicationEnum.narcan:
        return 'Narcan';
      case MedicationEnum.ibuprofen:
        return 'Ibuprofen';
    }
  }

  MedicationCategoryEnum get category {
    switch (this) {
      case MedicationEnum.notApplicable:
        return MedicationCategoryEnum.none;
      case MedicationEnum.saline09:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.saline3:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.morphine:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.ketamine:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.epinephrine:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.dextrose:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.lactatedRingers:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.oxygen:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.aspirin:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.calciumGluconate:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.sodiumChloride:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.midazolamHydrochloride:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.diphenhydramine:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.acetaminophen:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.moxifloxacin:
        return MedicationCategoryEnum.antiInfection;
      case MedicationEnum.ertapenem:
        return MedicationCategoryEnum.antiInfection;
      case MedicationEnum.meloxicam:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.ondansetron:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.fentanylCitrate:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.methylprednisolone:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.naloxone:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.tranexamicAcid:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.atropine:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.lidocaine:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.adenosine:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.hextend:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.freshWholeBlood:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.plasma:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.redBloodCells:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.plasmalyteA:
        return MedicationCategoryEnum.fluid;
      case MedicationEnum.clindamycin:
        return MedicationCategoryEnum.antiInfection;
      case MedicationEnum.acyclovir:
        return MedicationCategoryEnum.antiInfection;
      case MedicationEnum.narcan:
        return MedicationCategoryEnum.drug;
      case MedicationEnum.ibuprofen:
        return MedicationCategoryEnum.drug;
    }
  }

  // // Optional: for consistent JSON keys
  // String get jsonValue {
  //   return toString().split('.').last;
  // }
}

class Medications {
  final Map<String, bool> _enabledMap = {};

  Medications(List<String>? enabled) {
    for (var value in enabled ?? []) {
      _enabledMap[value] = true;
    }
  }

  Medications._fromMap(Map<String, bool> source) {
    _enabledMap.addAll(source);
  }

  Medications copyWith({List<String>? enable, List<String>? disable}) {
    final newMap = Map<String, bool>.from(_enabledMap);
    for (var value in enable ?? []) {
      newMap[value] = true;
    }
    for (var value in disable ?? []) {
      newMap[value] = false;
    }
    return Medications._fromMap(newMap);
  }

  bool isEnabled(String enumConstant) => _enabledMap[enumConstant] ?? false;

  List<String> getEnabledTypes() => _enabledMap.entries
      .where((entry) => entry.value)
      .map((e) => e.key)
      .toList();

  @override
  String toString() => _enabledMap.toString();
}

class InitialVitalSigns {
  int? hr; // heart rate
  int? sbp; // systolic blood pressure
  int? dbp; // diastolic blood pressure
  double? spo2; // peripheral oxygen saturation
  double? temp; // temperature
  double? etco2; // end-tidal carbon dioxide
  double? rr; // respiratory rate

  InitialVitalSigns(
      {this.hr, this.sbp, this.dbp, this.spo2, this.temp, this.etco2, this.rr});

  @override
  String toString() {
    return 'Initial vitals signs (hr: $hr, sbp: $sbp, dbp: $dbp, spo2: $spo2, temp: $temp etco2: $etco2 rr: $rr )';
  }

  InitialVitalSigns copyWith({
    int? hr,
    int? sbp,
    int? dbp,
    double? spo2,
    double? temp,
    double? etco2,
    double? rr,
  }) {
    return InitialVitalSigns(
      hr: hr ?? this.hr,
      sbp: sbp ?? this.sbp,
      dbp: dbp ?? this.dbp,
      spo2: spo2 ?? this.spo2,
      temp: temp ?? this.temp,
      etco2: etco2 ?? this.etco2,
      rr: rr ?? this.rr,
    );
  }
}

enum TreatmentDeviceEnum {
  notApplicable,
  cervicalCollar,
  extremityTourniquet,
  junctionalTourniquet,
  spineBoard,
  litter,
  bandage,
  gauze,
  ventedOcclusiveDressing,
  occlusiveDressing,
  mylarBlanket,
  chestTube,
  chestNeedleDecompression,
  foleyCatheter,
  oropharyngealAirway,
  nasopharyngealAirway,
  endotrachealTube,
  laryngealTube,
  supraglotticDevice,
  laryngoscope,
  endovascularBalloon,
  eyeShield,
  splint,
  oxygenMask,
  isopropylAlcoholPad,
  cricothyroidotomyKit,
}

extension TreatmentDeviceEnumExtension on TreatmentDeviceEnum {
  Future<String> get label async {
    await MetadataStore().loadMetadata();
    final metadata = MetadataStore().metadata;
    final enumName = toString().split('.').last;

    try {
      final entry =
          metadata?.treatmentDevice?.firstWhere((e) => e.name == enumName);
      return entry?.displayName ?? enumName;
    } catch (_) {
      return enumName;
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'treatmentDevice'); // in metadata
  }
}

enum AdministrationRouteEnum {
  unknown,
  intravenousDrip,
  intravenousBolus,
  intramuscular,
  intraosseousDrip,
  intraosseousBolus,
  oral,
  rectal,
  sublingual,
  buccal,
  intradermal,
}

extension AdministrationRouteEnumExtension on AdministrationRouteEnum {
  Future<String> get label async {
    await MetadataStore().loadMetadata();
    final metadata = MetadataStore().metadata;
    final enumName = toString().split('.').last;

    try {
      final entry =
          metadata?.administrationRoute?.firstWhere((e) => e.name == enumName);
      return entry?.displayName ?? enumName;
    } catch (_) {
      return enumName;
    }
  }

  String get enumValue {
    final enumName = toString().split('.').last;
    return resolveEnumValueSync(enumName, 'administrationRoute'); // in metadata
  }
}

class EnumUtils {
  /// A generic helper to convert a raw string [value] to an enum from [values],
  /// using a custom mapping function [mapFn] and a fallback [defaultValue].
  static T fromMetadataValue<T>(
    List<T> values,
    String? value,
    String Function(T) mapFn, {
    required T defaultValue,
  }) {
    if (value == null) return defaultValue;
    try {
      return values.firstWhere((e) => mapFn(e) == value);
    } catch (_) {
      debugPrint('EnumUtils: WARNING, could not find match for $value');
      return defaultValue;
    }
  }
}

T parseEnumValue<T extends Object>(
  List<T> values,
  String? value,
  String Function(T) getEnumValue,
  T fallback,
) {
  if (value == null || value.trim().isEmpty) return fallback;
  return values.firstWhere(
    (e) => getEnumValue(e) == value,
    orElse: () => fallback,
  );
}
