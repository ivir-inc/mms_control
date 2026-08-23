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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/config.dart';
import 'package:flutter_ui/data/model/metadata/metadata_store_access.dart';
import 'package:flutter_ui/data/model/recent_events/recent_events_model.dart';
import 'package:flutter_ui/data/model/vitals/vitals_model.dart';
import 'package:flutter_ui/data/provider/casualty_state/casualty_state_rest.dart';
import 'package:flutter_ui/data/provider/facilities/facility_rest.dart';
import 'package:flutter_ui/data/provider/handoff/handoff_rest.dart';
import 'package:flutter_ui/data/provider/networking/common_ws.dart';
import 'package:flutter_ui/data/provider/tccc/tccc_wire_store.dart';
import 'package:flutter_ui/data/repositories/casualty_states/casualty_state_repository.dart';
import 'package:flutter_ui/data/repositories/facilities/facility_repository.dart';
import 'package:flutter_ui/data/repositories/handoff/handoff_repository.dart';
import 'package:flutter_ui/data/services/unstructured_data_stores.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_event.dart';
import 'package:flutter_ui/logic/facility/facility_bloc.dart';
import 'package:flutter_ui/logic/facility/facility_event.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_bloc.dart';
import 'package:flutter_ui/logic/handoff/handoff_bloc.dart';
import 'package:flutter_ui/presentation/state/source_color_cubit.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb detection
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/logic/initialize_app/initialize_app_cubit.dart';
import 'package:flutter_ui/logic/patient_control_dashboard_widget_visibility/patient_control_dashboard_widget_visibility_bloc.dart';
import 'package:flutter_ui/data/repositories/patient_control_dashboard_widget_visibility/patient_control_dashboard_widget_visibility_repository.dart';
import 'package:flutter_ui/logic/qr_code/qr_code_bloc.dart';
import 'package:flutter_ui/data/repositories/qr_code/qr_code_preferences_repository.dart';
import 'package:flutter_ui/presentation/widgets/layouts/mms_main_sidebar_tabbed_layout.dart';
import 'package:flutter_ui/logic/patient_management/patient_management_bloc.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/data/repositories/patients/patient_repository.dart';
import 'package:flutter_ui/data/repositories/patient_cases/patient_case_repository.dart';
import 'package:flutter_ui/data/provider/patients/patient_rest.dart';
import 'package:flutter_ui/data/provider/patient_cases/patient_case_rest.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ui/modules/stethoscope/data/models/sounds_model.dart';
import 'package:flutter_ui/data/provider/tccc/tccc_rest.dart';
import 'package:flutter_ui/data/repositories/tccc/tccc_repository.dart';
import 'package:flutter_ui/logic/tccc/tccc_bloc.dart';
import 'package:flutter_ui/data/provider/injury/injury_rest.dart';
import 'package:flutter_ui/data/repositories/injury/injury_repository.dart';
import 'package:flutter_ui/logic/injury/injury_bloc.dart';
import 'package:flutter_ui/logic/treatment_layout/treatment_layout_bloc.dart';
import 'package:flutter_ui/logic/treatment_layout/treatment_layout_event.dart';

class HotReloadGuard extends StatefulWidget {
  final Widget child;
  const HotReloadGuard({super.key, required this.child});
  @override
  State<HotReloadGuard> createState() => _HotReloadGuardState();
}

class _HotReloadGuardState extends State<HotReloadGuard> {
  @override
  void reassemble() {
    super.reassemble();
    // Tear down old socket
    unawaited(MmsWsClient().dispose());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void main() async {
  // Ensure widget binding is initialized before HydratedStorage
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedStorage
  HydratedStorage storage;

  // Check if running on the web
  if (kIsWeb) {
    storage = await HydratedStorage.build(
        storageDirectory: HydratedStorage.webStorageDirectory);
  } else {
    // For mobile platforms
    final appDocDirectory = await getApplicationDocumentsDirectory();
    storage = await HydratedStorage.build(storageDirectory: appDocDirectory);
  }

  // Assign HydratedStorage globally
  HydratedBloc.storage = storage;

  configureFeatureFlags();

  // Run the app
  runApp(const HotReloadGuard(child: MyApp()));
}

void configureFeatureFlags() {
  PrimitivesStore().storeBoolByDataType(
    Config.patientDashboardParm,
    Config.appWideKey,
    true, // Enables the Patient Dashboard. Set to true for dev. Set to
    // false while making builds for external parties who do not
    // have FOM v4. Set to true permanently once FOM v4 generally
    // available.
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the shared patient service
    final patientRest = PatientRest();
    final patientCaseRest = PatientCaseRest();
    final facilityRest = FacilityRest();
    final casualtyStateRest = CasualtyStateRest();
    final handoffRest = HandoffRest();
    final tcccRest = TcccRest();
    final tcccRepo = TcccRepository(tcccRest, TcccWireStore.instance);
    final injuryRest = InjuryRest();
    final injuryRepo = InjuryRepository(injuryRest);
    final base = ThemeData(
      useMaterial3: false,
      fontFamily: 'MmsSans',
    );

    return MultiProvider(
      providers: [
        // Bloc-based state management
        BlocProvider<InitializeAppCubit>(
          lazy: false,
          create: (context) => InitializeAppCubit(),
        ),
        BlocProvider<PatientControlDashboardWidgetVisibilityBloc>(
          lazy: false,
          create: (context) => PatientControlDashboardWidgetVisibilityBloc(
            repository: PatientControlDashboardWidgetVisibilityRepository(
              storage: HydratedBloc.storage,
            ),
          ),
        ),
        BlocProvider<QrCodeBloc>(
          lazy: false,
          create: (context) => QrCodeBloc(
            repository: QrCodePreferencesRepository(
              storage: HydratedBloc.storage,
            ),
          ),
        ),
        BlocProvider<PatientManagementBloc>(
          lazy: false,
          create: (context) => PatientManagementBloc(
            PatientRepository(patientRest),
          )..add(const PatientManagementEvent(
              PatientManagementAction.initialize, [])),
        ),
        BlocProvider<PatientCaseBuilderBloc>(
          lazy: false,
          create: (context) => PatientCaseBuilderBloc(
            PatientCaseRepository(patientCaseRest),
          )..add(const PatientCaseBuilderEvent(
              PatientCaseBuilderAction.initialize,
              patientCases: [])),
        ),
        BlocProvider<FacilityBloc>(
          lazy: false,
          create: (context) => FacilityBloc(
            FacilityRepository(facilityRest),
          )..add(const LoadSavedFacilities()),
        ),
        BlocProvider<CasualtyStateBloc>(
          lazy: false,
          create: (context) => CasualtyStateBloc(
            CasualtyStateRepository(casualtyStateRest),
          )..add(const LoadCasualtyStates()),
        ),
        BlocProvider<HandoffBloc>(
          lazy: false,
          create: (context) => HandoffBloc(HandoffRepository(handoffRest),
              onRefreshCasualtyStates: () {
            final bloc = context.read<CasualtyStateBloc>(); // capture now
            Future.delayed(const Duration(milliseconds: 300), () {
              bloc.add(const LoadCasualtyStates());
            });
          }, onRefreshPatientList: () {
            final bloc = context.read<PatientManagementBloc>(); // capture now
            Future.delayed(const Duration(milliseconds: 300), () {
              bloc.add(const PatientManagementEvent(
                PatientManagementAction.refreshFromServer,
                [],
              ));
            });
          }),
        ),
        BlocProvider(
          create: (_) => SourceColorCubit(),
        ),
        BlocProvider<TcccBloc>(
          lazy: false,
          create: (context) => TcccBloc(tcccRepo),
        ),
        BlocProvider<InjuryBloc>(
          lazy: false,
          create: (context) => InjuryBloc(injuryRepo),
        ),
        BlocProvider<TreatmentLayoutBloc>(
          lazy: false,
          create: (context) => TreatmentLayoutBloc()..add(const LoadLayout()),
        ),
        // Add SoundsInfoStoreAccess provider for sounds management
        ChangeNotifierProvider<SoundsInfoStoreAccess>(
          create: (_) => SoundsInfoStoreAccess(),
        ),

        ChangeNotifierProvider<MetadataStoreAccess>(
          create: (_) => MetadataStoreAccess(),
        ),

        ChangeNotifierProvider<RecentEventsStoreAccess>(
          create: (_) => RecentEventsStoreAccess(),
        ),
        // Vitals live-update provider (app-wide)
        ChangeNotifierProvider<VitalsValuesStoreAccess>(
          create: (_) => VitalsValuesStoreAccess(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: MmsMainSidebarTabbedLayout.title,
        home: const MmsMainSidebarTabbedLayout(),
        theme: base.copyWith(
          dividerColor: Colors.white54,
          dividerTheme: const DividerThemeData(
            color: Colors.white54,
            thickness: 3.0,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: MmsColors.black,
            shadowColor: MmsColors.dkBlue,
            foregroundColor: Colors.white, // ensure visible text/icons
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.black87,
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'MmsSans',
            ),
          ),

          // apply MmsSans to ALL text styles, then re-apply colors
          textTheme: base.textTheme.apply(fontFamily: 'MmsSans').copyWith(
                bodyLarge:
                    base.textTheme.bodyLarge?.copyWith(color: MmsColors.white),
                bodyMedium:
                    base.textTheme.bodyMedium?.copyWith(color: MmsColors.black),
                labelLarge: base.textTheme.labelLarge?.copyWith(
                  fontFamily: 'MmsSans',
                  fontWeight: FontWeight.w500, // map to Roboto-Medium.ttf
                ),
              ),
          // keep primaryTextTheme in sync (AppBar, etc.)
          primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'MmsSans'),

          scaffoldBackgroundColor: MmsColors.appBackgroundColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,

          // make sure buttons use MmsSans family
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'MmsSans',
                fontWeight: FontWeight.w500, // same as labelLarge
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
