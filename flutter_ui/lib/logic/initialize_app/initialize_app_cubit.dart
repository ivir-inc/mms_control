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

import 'package:bloc/bloc.dart';
import 'package:flutter_ui/data/model/magic_transfer/magic_transfer.dart';
import 'package:flutter_ui/data/model/patient_transfer/patient_transfer.dart';
import 'package:flutter_ui/data/model/recent_events/recent_events_model.dart';
import 'package:flutter_ui/data/model/vitals/vitals_model.dart';
import 'package:flutter_ui/data/services/all_raw_data_store.dart';
import 'package:flutter_ui/data/provider/networking/common_ws.dart';
import 'package:flutter_ui/data/storage/metadata_store.dart';
import 'package:flutter_ui/shared/logging/logger.dart';
import 'package:flutter_ui/data/model/config/app_config.dart';
import 'package:flutter_ui/data/repositories/config/app_config_repository.dart';
import 'package:flutter_ui/modules/federation/data/models/sim_model.dart';
import 'package:flutter_ui/modules/aar/presentation/widgets/aar_widget.dart';
import 'package:flutter_ui/modules/handoff/data/models/handoff_image_details_model.dart';
import 'package:flutter_ui/modules/handoff/data/models/handoff_ready_checks_model.dart';
import 'package:flutter_ui/modules/onesaf/data/models/injury_model.dart';
import 'package:flutter_ui/modules/onesaf/data/models/medevac_model.dart';
import 'package:flutter_ui/modules/stethoscope/data/models/sounds_model.dart';

part 'initialize_app_state.dart';

Logger _logger = Logger("InitializeAppCubit");

class InitializeAppCubit extends Cubit<InitializeAppState> {
  final AppConfigRepository appConfigRepository = AppConfigRepository();

  static bool _didInit = false;
  static Future<void>? _inFlight;

  InitializeAppCubit()
      : super(InitializeAppState(status: InitializationStatusEnum.notStarted)) {
    if (_didInit) {
      _logger.logDebug(1, "Initialize skipped (already ran once).");
      return;
    }
    if (_inFlight != null) return; // de-dupe overlapping calls
    _inFlight = initialize().whenComplete(() {
      _didInit = true;
      _inFlight = null;
    });
  }

  Future<void> initialize() async {
    _logger.logDebug(1, "InitalizeAppCubit.initialize triggered");
    emit(InitializeAppState(status: InitializationStatusEnum.initalizing));
    final appConfig = appConfigRepository.getAppConfig();

    // Start the WebSocket client
    _logger.logDebug(1, "Starting WebSocket client...");
    final wsStarted = await MmsWsClient().begin();
    _logger.logDebug(
        1,
        wsStarted
            ? "[WebSocket] client successfully started."
            : "[WebSocket] client failed to start.");

    if (appConfig.includeWsTestTab) {
      AllRawDataStore(); // Register with WS for all raw data
    }
    if (appConfig.includeAar) {
      AarTimelineWidget.initStores();
    }

    SimDateTimeModelStore(); // Register with WS for DateTime data
    RecentEventsStore(); // Register with WS for Recent Events data
    VitalsValuesStore();
    PatientTransferStore(); // Register with WS for Patient Transfer data
    MagicTransferStore(); // Register with WS for Magic Transfer data

    if (appConfig.includeScope) {
      SoundsInfoStore(); // Register with WS for ScopeSound data
    }
    if (appConfig.allowHandoffInit || appConfig.allowHandoffReceive) {
      MmsHandoffStatusForReceiverStore();
      MmsHandoffStatusForInitiatorStore();
      HandoffImageDetailsStore(); // Another registration for DocumentList data
      //HandoffAvailableImagesStore(); // Register with WS for DocumentList data (images)
      //InstructorControlStore(); // Register with WS for Instructor Control data (facility id)
      //HandoffStatusStore(); // Register with WS for HandoffStatus data
    }
    if (appConfig.includeOnesaf) {
      InjuryDetailsStore(); // Register with WS for Injury data
      OnesafMedevacResponseStore(); // Register for Medevac response data
    }

    MetadataStore().loadMetadata();

    emit(InitializeAppState(
        status: InitializationStatusEnum.completed, appConfig: appConfig));
  }
}
