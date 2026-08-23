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

class LayoutColumn extends Equatable {
  final String? name;
  final List<String> items;

  const LayoutColumn({this.name, required this.items});

  factory LayoutColumn.fromJson(Map<String, dynamic> json) => LayoutColumn(
        name: json['name'] as String?,
        items: (json['treatments'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'treatments': items,
      };

  LayoutColumn copyWith({String? name, List<String>? items}) => LayoutColumn(
        name: name ?? this.name,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [name, items];
}

class LayoutCategory extends Equatable {
  final String name;
  final List<LayoutColumn> columns;

  const LayoutCategory({required this.name, required this.columns});

  factory LayoutCategory.fromJson(Map<String, dynamic> json) => LayoutCategory(
        name: json['name'] as String? ?? '',
        columns: (json['columns'] as List<dynamic>?)
                ?.map((e) => LayoutColumn.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'columns': columns.map((c) => c.toJson()).toList(),
      };

  LayoutCategory copyWith({String? name, List<LayoutColumn>? columns}) =>
      LayoutCategory(
        name: name ?? this.name,
        columns: columns ?? this.columns,
      );

  List<String> get allItems => columns.expand((c) => c.items).toList();
  bool get isEmpty => allItems.isEmpty;

  @override
  List<Object?> get props => [name, columns];
}

class TreatmentLayoutConfig extends Equatable {
  final List<LayoutCategory> treatments;
  final List<LayoutCategory> medications;

  const TreatmentLayoutConfig({
    required this.treatments,
    required this.medications,
  });

  factory TreatmentLayoutConfig.fromJson(Map<String, dynamic> json) =>
      TreatmentLayoutConfig(
        treatments: (json['treatments'] as List<dynamic>?)
                ?.map((e) => LayoutCategory.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        medications: (json['medications'] as List<dynamic>?)
                ?.map((e) => LayoutCategory.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'treatments': treatments.map((c) => c.toJson()).toList(),
        'medications': medications.map((c) => c.toJson()).toList(),
      };

  TreatmentLayoutConfig copyWith({
    List<LayoutCategory>? treatments,
    List<LayoutCategory>? medications,
  }) =>
      TreatmentLayoutConfig(
        treatments: treatments ?? this.treatments,
        medications: medications ?? this.medications,
      );

  @override
  List<Object?> get props => [treatments, medications];
}
