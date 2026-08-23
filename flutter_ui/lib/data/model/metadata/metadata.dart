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

import 'package:json_annotation/json_annotation.dart';

// Note, if members of any class annotated with "@JsonSerializable()" are modified,
// flutter_ui/lib/data/services/metadata_rest_service.g.dart should be regenerated.
// execute 'dart run build_runner build' in mms_control/flutter_ui/ to regenerate
// See https://pub.dev/packages/json_serializable for more info
//
part 'metadata.g.dart'; // Needed for json_serializable

@JsonSerializable()
class PhysicalTreatmentTypeItem {
  final String? displayName;
  final String? name;
  final int? catOrder;
  final String? category;
  @JsonKey(name: 'enum')
  final String? enumConstant;
  final int? ordinal;

  PhysicalTreatmentTypeItem({
    this.displayName,
    this.name,
    this.catOrder,
    this.category,
    this.enumConstant,
    this.ordinal,
  });

  factory PhysicalTreatmentTypeItem.fromJson(Map<String, dynamic> json) =>
      _$PhysicalTreatmentTypeItemFromJson(json);
  Map<String, dynamic> toJson() => _$PhysicalTreatmentTypeItemToJson(this);

  @override
  String toString() {
    return 'PhysicalTreatmentTypeItem('
        'displayName: $displayName, '
        'name: $name, '
        'catOrder: $catOrder, '
        'category: $category, '
        'enumConstant: $enumConstant, '
        'ordinal: $ordinal'
        ')';
  }
}

@JsonSerializable()
class TreatmentDeviceItem {
  final String? displayName;
  final String? name;
  @JsonKey(name: 'enum')
  final String? enumConstant;
  final int? ordinal;

  TreatmentDeviceItem({
    this.displayName,
    this.name,
    this.enumConstant,
    this.ordinal,
  });

  factory TreatmentDeviceItem.fromJson(Map<String, dynamic> json) =>
      _$TreatmentDeviceItemFromJson(json);
  Map<String, dynamic> toJson() => _$TreatmentDeviceItemToJson(this);

  @override
  String toString() {
    return 'TreatmentDeviceItem('
        'displayName: $displayName, '
        'name: $name, '
        'enumConstant: $enumConstant, '
        'ordinal: $ordinal'
        ')';
  }
}

// For the medication array (similar to PhysicalTreatmentTypeItem but optional category):
@JsonSerializable()
class MedicationItem {
  final String? displayName;
  final String? name;
  final int? catOrder;
  final String? category;
  @JsonKey(name: 'enum')
  final String? enumConstant;
  final int? ordinal;

  MedicationItem(
      {this.displayName,
      this.name,
      this.catOrder,
      this.category,
      this.enumConstant,
      this.ordinal});

  factory MedicationItem.fromJson(Map<String, dynamic> json) =>
      _$MedicationItemFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationItemToJson(this);

  @override
  String toString() {
    return 'MedicationItem('
        'displayName: $displayName, '
        'name: $name, '
        'catOrder: $catOrder, '
        'category: $category, '
        'enumConstant: $enumConstant, '
        'ordinal: $ordinal'
        ')';
  }
}

// For administrationRoute (has abbreviation):
@JsonSerializable()
class AdministrationRouteItem {
  final String? displayName;
  final String? name;
  final String? abbreviation;
  @JsonKey(name: 'enum')
  final String? enumConstant;
  final int? ordinal;

  AdministrationRouteItem(
      {this.displayName,
      this.name,
      this.abbreviation,
      this.enumConstant,
      this.ordinal});

  factory AdministrationRouteItem.fromJson(Map<String, dynamic> json) =>
      _$AdministrationRouteItemFromJson(json);
  Map<String, dynamic> toJson() => _$AdministrationRouteItemToJson(this);
}

// Use SimpleEnumItem for:
// detailedAnatomy
// skeletalSystem
// coronalPlane
// transversePlane
// sagittalPlane
// internalAnatomy
// regionTissueType
// generalRegion
@JsonSerializable()
class SimpleEnumItem {
  final String? name;
  @JsonKey(name: 'enum')
  final String? enumConstant;
  final int? ordinal;

  SimpleEnumItem({this.name, this.enumConstant, this.ordinal});

  factory SimpleEnumItem.fromJson(Map<String, dynamic> json) =>
      _$SimpleEnumItemFromJson(json);
  Map<String, dynamic> toJson() => _$SimpleEnumItemToJson(this);

  @override
  String toString() {
    return '[name: $name, enumConstant: $enumConstant ordinal: $ordinal]';
  }
}

// For deviceMap, which is a list of maps where each key is a treatment enum
// and value is a list of device enums:
class DeviceMapItem {
  final String? treatmentEnum;
  final List<String>? deviceEnums;

  DeviceMapItem({this.treatmentEnum, this.deviceEnums});

  factory DeviceMapItem.fromJson(Map<String, dynamic> json) {
    final key = json.keys.first;
    return DeviceMapItem(
      treatmentEnum: key,
      deviceEnums: List<String>.from(json[key]),
    );
  }

  // Note: toJson assumes treatmentEnum is non-null when calling
  Map<String, dynamic> toJson() => {
        treatmentEnum!: deviceEnums,
      };
}

class Metadata {
  final List<PhysicalTreatmentTypeItem>? physicalTreatmentType;
  final List<TreatmentDeviceItem>? treatmentDevice;
  final List<MedicationItem>? medication;
  final List<AdministrationRouteItem>? administrationRoute;
  final List<SimpleEnumItem>? detailedAnatomy;
  final List<SimpleEnumItem>? skeletalSystem;
  final List<SimpleEnumItem>? coronalPlane;
  final List<SimpleEnumItem>? transversePlane;
  final List<SimpleEnumItem>? sagittalPlane;
  final List<SimpleEnumItem>? internalAnatomy;
  final List<SimpleEnumItem>? regionTissueType;
  final List<SimpleEnumItem>? generalRegion;
  final List<DeviceMapItem>? deviceMap;

  Metadata({
    this.physicalTreatmentType,
    this.treatmentDevice,
    this.medication,
    this.administrationRoute,
    this.detailedAnatomy,
    this.skeletalSystem,
    this.coronalPlane,
    this.transversePlane,
    this.sagittalPlane,
    this.internalAnatomy,
    this.regionTissueType,
    this.generalRegion,
    this.deviceMap,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    Metadata metadata = Metadata(
      physicalTreatmentType: (json['physicalTreatmentType'] as List)
          .map((i) => PhysicalTreatmentTypeItem.fromJson(i))
          .toList(),
      treatmentDevice: (json['treatmentDevice'] as List)
          .map((i) => TreatmentDeviceItem.fromJson(i))
          .toList(),
      medication: (json['medication'] as List)
          .map((i) => MedicationItem.fromJson(i))
          .toList(),
      administrationRoute: (json['administrationRoute'] as List)
          .map((i) => AdministrationRouteItem.fromJson(i))
          .toList(),
      detailedAnatomy: (json['detailedAnatomy'] as List)
          .map((i) => SimpleEnumItem.fromJson(i))
          .toList(),
      skeletalSystem: (json['skeletalSystem'] as List)
          .map((i) => SimpleEnumItem.fromJson(i))
          .toList(),
      coronalPlane: (json['coronalPlane'] as List)
          .map((i) => SimpleEnumItem.fromJson(i))
          .toList(),
      transversePlane: (json['transversePlane'] as List)
          .map((i) => SimpleEnumItem.fromJson(i))
          .toList(),
      sagittalPlane: (json['sagittalPlane'] as List)
          .map((i) => SimpleEnumItem.fromJson(i))
          .toList(),
      internalAnatomy: (json['internalAnatomy'] as List)
          .map((i) => SimpleEnumItem.fromJson(i))
          .toList(),
      regionTissueType: (json['regionTissueType'] as List)
          .map((i) => SimpleEnumItem.fromJson(i))
          .toList(),
      generalRegion: (json['generalRegion'] as List)
          .map((i) => SimpleEnumItem.fromJson(i))
          .toList(),
      deviceMap: (json['deviceMap'] as List)
          .map((i) => DeviceMapItem.fromJson(i))
          .toList(),
    );
    return metadata;
  }

  @override
  String toString() {
    return '''
Metadata(
  physicalTreatmentType: ${physicalTreatmentType?.length ?? 0} items,
  treatmentDevice: ${treatmentDevice?.length ?? 0} items,
  medication: ${medication?.length ?? 0} items,
  administrationRoute: ${administrationRoute?.length ?? 0} items,
  detailedAnatomy: ${detailedAnatomy?.length ?? 0} items,
  skeletalSystem: ${skeletalSystem?.length ?? 0} items,
  coronalPlane: ${coronalPlane?.length ?? 0} items,
  transversePlane: ${transversePlane?.length ?? 0} items,
  sagittalPlane: ${sagittalPlane?.length ?? 0} items,
  internalAnatomy: ${internalAnatomy?.length ?? 0} items,
  regionTissueType: ${regionTissueType?.length ?? 0} items,
  generalRegion: ${generalRegion?.length ?? 0} items,
  deviceMap: ${deviceMap?.length ?? 0} items
)''';
  }

  Map<String, List<String>> get deviceMapByTreatment {
    final Map<String, List<String>> result = {};

    if (deviceMap != null) {
      for (final item in deviceMap!) {
        if (item.treatmentEnum != null && item.deviceEnums != null) {
          result[item.treatmentEnum!] = item.deviceEnums!;
        }
      }
    }

    return result;
  }
}
