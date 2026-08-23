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

// HydratedCubit wrapper around StableColorAllocator
// Persists the source->OKLCH mapping in HydratedStorage under this cubit's key.
// Requires: hydrated_bloc: ^9.x, flutter_bloc: ^8.16

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_ui/presentation/util/stable_color_allocator.dart';

class SourceColorCubit extends HydratedCubit<Map<String, dynamic>> {
  final StableColorAllocator _alloc;

  SourceColorCubit({StableColorAllocator? allocator})
      : _alloc = allocator ?? StableColorAllocator(minContrastOnWhite: 4.5),
        super(const {});

  /// Get a stable, contrast-safe color for a source ID. Emits when a new
  /// assignment is created so HydratedStorage persists it.
  Color colorFor(String id,
      {String? neighborId, List<String> visibleIds = const []}) {
    final hadBefore = state.containsKey(id);
    final color =
        _alloc.getColor(id, neighborId: neighborId, visibleIds: visibleIds);
    if (!hadBefore) emit(_alloc.toJson());
    return color;
  }

  /// Optionally prewarm several IDs at once (useful on initial list load).
  void ensureFor(Iterable<String> ids) {
    var changed = false;
    for (final id in ids) {
      if (!state.containsKey(id)) {
        _alloc.getColor(id);
        changed = true;
      }
    }
    if (changed) emit(_alloc.toJson());
  }

  // HydratedCubit -----------------------------------------------------------
  @override
  Map<String, dynamic>? fromJson(Map<String, dynamic> json) {
    try {
      _alloc.loadFromJson(json);
      return Map<String, dynamic>.from(json);
    } catch (_) {
      return const {};
    }
  }

  @override
  Map<String, dynamic>? toJson(Map<String, dynamic> state) {
    return _alloc.toJson();
  }
}
