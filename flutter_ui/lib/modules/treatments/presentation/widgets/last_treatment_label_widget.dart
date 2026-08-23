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
import 'package:flutter_ui/data/model/recent_events/recent_events_model.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

import '../../data/storage/last_treatment_store.dart';

class LastTreatmentLabelWidget extends StatelessWidget {
  final String patientId;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  const LastTreatmentLabelWidget(
    this.patientId, {
    super.key,
    this.textStyle,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<RecentEventsStoreAccess, String?>(
      // Compute a compact label for THIS patient only.
      selector: (_, access) {
        final list = access.store.eventsList; // newest-first
        for (final e in list) {
          if (e.patientId == patientId && e.type == 'TREATMENT') {
            return e.notes;
          }
        }
        return null; // none yet
      },
      // Only rebuild label when the derived string changes.
      shouldRebuild: (prev, next) => prev != next,
      builder: (_, label, __) => Text(
        label ?? '--',
        textAlign: textAlign ?? TextAlign.left,
        style: textStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
