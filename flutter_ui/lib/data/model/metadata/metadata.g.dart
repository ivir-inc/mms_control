// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhysicalTreatmentTypeItem _$PhysicalTreatmentTypeItemFromJson(
        Map<String, dynamic> json) =>
    PhysicalTreatmentTypeItem(
      displayName: json['displayName'] as String?,
      name: json['name'] as String?,
      catOrder: (json['catOrder'] as num?)?.toInt(),
      category: json['category'] as String?,
      enumConstant: json['enum'] as String?,
      ordinal: (json['ordinal'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PhysicalTreatmentTypeItemToJson(
        PhysicalTreatmentTypeItem instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'name': instance.name,
      'catOrder': instance.catOrder,
      'category': instance.category,
      'enum': instance.enumConstant,
      'ordinal': instance.ordinal,
    };

TreatmentDeviceItem _$TreatmentDeviceItemFromJson(Map<String, dynamic> json) =>
    TreatmentDeviceItem(
      displayName: json['displayName'] as String?,
      name: json['name'] as String?,
      enumConstant: json['enum'] as String?,
      ordinal: (json['ordinal'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TreatmentDeviceItemToJson(
        TreatmentDeviceItem instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'name': instance.name,
      'enum': instance.enumConstant,
      'ordinal': instance.ordinal,
    };

MedicationItem _$MedicationItemFromJson(Map<String, dynamic> json) =>
    MedicationItem(
      displayName: json['displayName'] as String?,
      name: json['name'] as String?,
      catOrder: (json['catOrder'] as num?)?.toInt(),
      category: json['category'] as String?,
      enumConstant: json['enum'] as String?,
      ordinal: (json['ordinal'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MedicationItemToJson(MedicationItem instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'name': instance.name,
      'catOrder': instance.catOrder,
      'category': instance.category,
      'enum': instance.enumConstant,
      'ordinal': instance.ordinal,
    };

AdministrationRouteItem _$AdministrationRouteItemFromJson(
        Map<String, dynamic> json) =>
    AdministrationRouteItem(
      displayName: json['displayName'] as String?,
      name: json['name'] as String?,
      abbreviation: json['abbreviation'] as String?,
      enumConstant: json['enum'] as String?,
      ordinal: (json['ordinal'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdministrationRouteItemToJson(
        AdministrationRouteItem instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'name': instance.name,
      'abbreviation': instance.abbreviation,
      'enum': instance.enumConstant,
      'ordinal': instance.ordinal,
    };

SimpleEnumItem _$SimpleEnumItemFromJson(Map<String, dynamic> json) =>
    SimpleEnumItem(
      name: json['name'] as String?,
      enumConstant: json['enum'] as String?,
      ordinal: (json['ordinal'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SimpleEnumItemToJson(SimpleEnumItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'enum': instance.enumConstant,
      'ordinal': instance.ordinal,
    };
