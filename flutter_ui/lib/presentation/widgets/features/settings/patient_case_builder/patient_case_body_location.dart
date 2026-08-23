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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/metadata/metadata.dart'
    show PhysicalTreatmentTypeItem;
import 'package:flutter_ui/data/model/metadata/metadata_store_access.dart';
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/modules/treatments/data/storage/last_treatment_store.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';

// Category Colors (Global Constants)
const Color headColor = Color(0xFFFEFFCC);
const Color torsoColor = Color(0xFFC3ABD0);
const Color armsColor = Color(0xFFFFB670);
const Color legsColor = Color(0xFF399A1D);
const double baseWidth = 255; // Original width
const double baseHeight = 510; // Original height
const double targetWidth = 217; // New width
const double targetHeight = 434; // New height

class PatientCaseBodyLocation extends StatefulWidget {
  final bool editMode;
  final String? treatmentSelected; // the treatment enum
  final String?
      patientId; // used while editMode == false for sending physical treatment events

  const PatientCaseBodyLocation(
      {super.key,
      this.editMode = false,
      this.treatmentSelected,
      this.patientId});

  @override
  State<PatientCaseBodyLocation> createState() =>
      _PatientCaseBodyLocationState();
}

class _PatientCaseBodyLocationState extends State<PatientCaseBodyLocation>
    with TickerProviderStateMixin {
  String selectedProfile = 'front';
  BiologicalSexEnum selectedSex = BiologicalSexEnum.female;
  bool _sexInitialized = false;
  String? selectedArea;
  String? selectedProfileForArea;
  String selectedTissueType =
      RegionTissueTypeEnum.values.map((e) => e.label).first;
  bool selectedTissueTypeInitialValueSet = false;
  bool initialLoadComplete = false;
  List<DropdownMenuItem<String>> deviceTypeItems = [];
  String? selectedDeviceType;
  String? treatmentDisplayName;
  String? treatmentName;
  String? treatmentSelectedCamelCase;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );
    _controller.forward();

    final metadata = context.read<MetadataStoreAccess>().store.metadata;

    if (metadata != null) {
      if (!widget.editMode && widget.treatmentSelected != null) {
        // Lookup the display name
        final treatment = metadata.physicalTreatmentType?.firstWhere(
          (item) => item.enumConstant == widget.treatmentSelected,
          orElse: () =>
              PhysicalTreatmentTypeItem(name: widget.treatmentSelected),
        );
        treatmentDisplayName =
            treatment?.displayName ?? widget.treatmentSelected;
        treatmentSelectedCamelCase =
            treatment?.name ?? widget.treatmentSelected;

        // Get allowed devices for this treatment
        final allowedDeviceEnums =
            metadata.deviceMapByTreatment[widget.treatmentSelected!] ?? [];

        final allowedDevices = metadata.treatmentDevice!
            .where((device) => allowedDeviceEnums.contains(device.enumConstant))
            .toList();

        // Build device dropdown items (only if valid)
        deviceTypeItems = allowedDevices
            .map((e) => DropdownMenuItem<String>(
                  value: e.name!,
                  child: Text(e.displayName ?? e.name!),
                ))
            .toList();

        // Rule 1: Auto-select if there's only one allowed device
        if (allowedDevices.length == 1) {
          selectedDeviceType = allowedDevices.first.name!;
        }

        // Rule 2: If all allowed devices are 'notApplicable', hide dropdown
        if (allowedDevices.isNotEmpty &&
            allowedDevices.every((d) => d.enumConstant == 'notApplicable')) {
          deviceTypeItems = [];
          selectedDeviceType = null;
        }
      } else {
        // Edit mode or no treatment selected: show all devices
        deviceTypeItems = metadata.treatmentDevice!
            .map((e) => DropdownMenuItem<String>(
                  value: e.name!,
                  child: Text(e.displayName ?? e.name!),
                ))
            .toList();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize selectedSex from the active patient case (both edit and run mode)
    if (!_sexInitialized) {
      final blocState = context.read<PatientCaseBuilderBloc>().state;
      try {
        final patientCase = blocState.patientCases.firstWhere(
          (pc) => pc.name == blocState.patientCaseUnderEditOrDisplay,
        );
        selectedSex = patientCase.biologicalSex ?? BiologicalSexEnum.female;
        _sexInitialized = true;
      } catch (_) {}
    }

    if (!widget.editMode) return; // Rest of setup is edit-mode only

    final state = context.read<PatientCaseBuilderBloc>().state;
    final patientCase = state.patientCases.firstWhere(
      (pc) => pc.name == state.patientCaseUnderEditOrDisplay,
    );

    final injury = patientCase.injuries
        ?.where((inj) => inj.id == state.injuryIdUnderEdit)
        .cast<Injury?>()
        .firstOrNull;

    if (injury == null) return;

    var injLocation = injury.location;

    if (injLocation != null) {
      if (!initialLoadComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setSelectedAreaFromBodyLocation(injLocation);
          initialLoadComplete = true;
        });
      }

      if (!selectedTissueTypeInitialValueSet) {
        selectedTissueType = injLocation.regionTissueType.label;
        selectedTissueTypeInitialValueSet = true;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final Map<String, List<Map<String, dynamic>>> bodyLocationPointsByProfile = {
    'front': [
      {
        'label': 'Head (Anterior)',
        'sagittalPlane': SagittalPlaneEnum.notApplicable,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.head,
        'leftPx': 77,
        'topPx': 20,
        'color': headColor,
        'useCallout': true,
        'calloutOffset': const Offset(40, 13)
      },
      {
        'label': 'Face',
        'sagittalPlane': SagittalPlaneEnum.notApplicable,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.face,
        'leftPx': 75,
        'topPx': 52,
        'color': headColor,
        'useCallout': true,
        'calloutOffset': const Offset(51, 10)
      },
      {
        'label': 'Neck (Anterior)',
        'sagittalPlane': SagittalPlaneEnum.notApplicable,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.neck,
        'leftPx': 63,
        'topPx': 83,
        'color': headColor,
        'useCallout': true,
        'calloutOffset': const Offset(65, 5)
      },
      {
        'label': 'Thorax (Anterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.thorax,
        'leftPx': 113,
        'topPx': 119,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Thorax (Anterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.thorax,
        'leftPx': 141,
        'topPx': 119,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Shoulder (Anterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.shoulder,
        'leftPx': 86,
        'topPx': 105,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Shoulder (Anterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.shoulder,
        'leftPx': 170,
        'topPx': 105,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Upper Arm (Anterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.upperArm,
        'leftPx': 74,
        'topPx': 136,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Upper Arm (Anterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.upperArm,
        'leftPx': 181,
        'topPx': 136,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Elbow (Anterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.elbow,
        'leftPx': 39,
        'topPx': 145,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(28, 27)
      },
      {
        'label': 'Elbow (Anterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.elbow,
        'leftPx': 216,
        'topPx': 145,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-14, 24)
      },
      {
        'label': 'Forearm (Anterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.forearm,
        'leftPx': 58,
        'topPx': 197,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Forearm (Anterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.forearm,
        'leftPx': 197,
        'topPx': 197,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Wrist (Anterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.wrist,
        'leftPx': 25,
        'topPx': 192,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(26, 28)
      },
      {
        'label': 'Wrist (Anterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.wrist,
        'leftPx': 230,
        'topPx': 192,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-9, 25)
      },
      {
        'label': 'Hand (Anterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.hand,
        'leftPx': 71,
        'topPx': 264,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-14, -14)
      },
      {
        'label': 'Hand (Anterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.hand,
        'leftPx': 185,
        'topPx': 263,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(28, -16)
      },
      {
        'label': 'Fingers (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.fingers,
        'leftPx': 40,
        'topPx': 296,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(4, -21)
      },
      {
        'label': 'Fingers (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.fingers,
        'leftPx': 210,
        'topPx': 292,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(14, -22)
      },
      {
        'label': 'Abdomen (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.abdomen,
        'leftPx': 113,
        'topPx': 179,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Abdomen (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.abdomen,
        'leftPx': 141,
        'topPx': 179,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Genitalia (Female)',
        'sagittalPlane': SagittalPlaneEnum.notApplicable,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.genitaliaFemale,
        'leftPx': 128,
        'topPx': 257,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Pelvis (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.pelvis,
        'leftPx': 113,
        'topPx': 230,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Pelvis (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.pelvis,
        'leftPx': 141,
        'topPx': 230,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Hip (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.hip,
        'leftPx': 97,
        'topPx': 249,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Hip (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.hip,
        'leftPx': 160,
        'topPx': 249,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Thigh (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.thigh,
        'leftPx': 107,
        'topPx': 298,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Thigh (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.thigh,
        'leftPx': 149,
        'topPx': 298,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Knee (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.knee,
        'leftPx': 112,
        'topPx': 358,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Knee (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.knee,
        'leftPx': 144,
        'topPx': 358,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Lower Leg (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.lowerLeg,
        'leftPx': 110,
        'topPx': 410,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Lower Leg (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.anterior,
        'generalRegion': GeneralRegionEnum.lowerLeg,
        'leftPx': 146,
        'topPx': 410,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Ankle (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.ankle,
        'leftPx': 78,
        'topPx': 433,
        'color': legsColor,
        'useCallout': true,
        'calloutOffset': const Offset(36, 31)
      },
      {
        'label': 'Ankle (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.ankle,
        'leftPx': 178,
        'topPx': 431,
        'color': legsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-20, 31)
      },
      {
        'label': 'Foot (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.foot,
        'leftPx': 61,
        'topPx': 459,
        'color': legsColor,
        'useCallout': true,
        'calloutOffset': const Offset(49, 17)
      },
      {
        'label': 'Foot (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.foot,
        'leftPx': 195,
        'topPx': 458,
        'color': legsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-30, 17)
      },
      {
        'label': 'Toes (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.toes,
        'leftPx': 44,
        'topPx': 483,
        'color': legsColor,
        'useCallout': true,
        'calloutOffset': const Offset(61, 4)
      },
      {
        'label': 'Toes (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.toes,
        'leftPx': 213,
        'topPx': 481,
        'color': legsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-41, 4)
      },
    ],
    'back': [
      {
        'label': 'Head (Posterior)',
        'sagittalPlane': SagittalPlaneEnum.notApplicable,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.head,
        'leftPx': 77,
        'topPx': 20,
        'color': headColor,
        'useCallout': true,
        'calloutOffset': const Offset(40, 13)
      },
      {
        'label': 'Neck (Posterior)',
        'sagittalPlane': SagittalPlaneEnum.notApplicable,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.neck,
        'leftPx': 179,
        'topPx': 64,
        'color': headColor,
        'useCallout': true,
        'calloutOffset': const Offset(-34, 20)
      },
      {
        'label': 'Shoulder (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.shoulder,
        'leftPx': 86,
        'topPx': 105,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Shoulder (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.shoulder,
        'leftPx': 170,
        'topPx': 105,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Thorax (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.thorax,
        'leftPx': 110,
        'topPx': 130,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Thorax (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.thorax,
        'leftPx': 146,
        'topPx': 130,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Abdomen (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.abdomen,
        'leftPx': 113,
        'topPx': 179,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Abdomen (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.abdomen,
        'leftPx': 141,
        'topPx': 179,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Pelvis (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.pelvis,
        'leftPx': 113,
        'topPx': 230,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Pelvis (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.pelvis,
        'leftPx': 141,
        'topPx': 230,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Hip (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.hip,
        'leftPx': 97,
        'topPx': 249,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Hip (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.hip,
        'leftPx': 160,
        'topPx': 249,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Thigh (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.thigh,
        'leftPx': 107,
        'topPx': 298,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Thigh (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.thigh,
        'leftPx': 149,
        'topPx': 298,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Knee (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.knee,
        'leftPx': 112,
        'topPx': 358,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Knee (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.knee,
        'leftPx': 144,
        'topPx': 358,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Lower Leg (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.lowerLeg,
        'leftPx': 110,
        'topPx': 410,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Lower Leg (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.lowerLeg,
        'leftPx': 146,
        'topPx': 410,
        'color': legsColor,
        'useCallout': false
      },
      {
        'label': 'Upper Arm (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.upperArm,
        'leftPx': 74,
        'topPx': 136,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Upper Arm (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.upperArm,
        'leftPx': 181,
        'topPx': 136,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Elbow (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.elbow,
        'leftPx': 39,
        'topPx': 145,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(28, 27)
      },
      {
        'label': 'Elbow (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.elbow,
        'leftPx': 216,
        'topPx': 145,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-14, 24)
      },
      {
        'label': 'Forearm (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.forearm,
        'leftPx': 58,
        'topPx': 197,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Forearm (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.forearm,
        'leftPx': 197,
        'topPx': 197,
        'color': armsColor,
        'useCallout': false,
      },
      {
        'label': 'Wrist (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.wrist,
        'leftPx': 25,
        'topPx': 192,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(26, 28)
      },
      {
        'label': 'Wrist (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.wrist,
        'leftPx': 230,
        'topPx': 192,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-9, 25)
      },
      {
        'label': 'Hand (Posterior, Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.hand,
        'leftPx': 71,
        'topPx': 264,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(-14, -14)
      },
      {
        'label': 'Hand (Posterior, Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.posterior,
        'generalRegion': GeneralRegionEnum.hand,
        'leftPx': 185,
        'topPx': 263,
        'color': armsColor,
        'useCallout': true,
        'calloutOffset': const Offset(28, -16)
      },
    ],
    'left': [
      {
        'label': 'Head (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.head,
        'leftPx': 134,
        'topPx': 40.8,
        'color': headColor,
        'useCallout': false
      },
      {
        'label': 'Neck (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.neck,
        'leftPx': 177,
        'topPx': 80,
        'color': headColor,
        'useCallout': true,
        'calloutOffset': const Offset(-22, 8)
      },
      {
        'label': 'Thorax (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.thorax,
        'leftPx': 119,
        'topPx': 144,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Abdomen (Left)',
        'sagittalPlane': SagittalPlaneEnum.left,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.abdomen,
        'leftPx': 119,
        'topPx': 179,
        'color': torsoColor,
        'useCallout': false
      },
    ],
    'right': [
      {
        'label': 'Head (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.head,
        'leftPx': 125,
        'topPx': 40.8,
        'color': headColor,
        'useCallout': false
      },
      {
        'label': 'Neck (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.neck,
        'leftPx': 84,
        'topPx': 79,
        'color': headColor,
        'useCallout': true,
        'calloutOffset': const Offset(37, 8)
      },
      {
        'label': 'Thorax (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.thorax,
        'leftPx': 137,
        'topPx': 144,
        'color': torsoColor,
        'useCallout': false
      },
      {
        'label': 'Abdomen (Right)',
        'sagittalPlane': SagittalPlaneEnum.right,
        'transversePlane': TransversePlaneEnum.notApplicable,
        'coronalPlane': CoronalPlaneEnum.notApplicable,
        'generalRegion': GeneralRegionEnum.abdomen,
        'leftPx': 137,
        'topPx': 179,
        'color': torsoColor,
        'useCallout': false
      },
    ],
  };

  // Male points — same structure, coordinates adjusted for broader shoulders/narrower hips.
  // TODO: tune pixel coordinates against the actual rendered male images.
  final Map<String, List<Map<String, dynamic>>> bodyLocationPointsByProfileMale = {
    'front': [
      {'label': 'Head (Anterior)', 'sagittalPlane': SagittalPlaneEnum.notApplicable, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.head, 'leftPx': 77, 'topPx': 20, 'color': headColor, 'useCallout': true, 'calloutOffset': const Offset(40, 13)},
      {'label': 'Face', 'sagittalPlane': SagittalPlaneEnum.notApplicable, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.face, 'leftPx': 75, 'topPx': 52, 'color': headColor, 'useCallout': true, 'calloutOffset': const Offset(51, 12)},
      {'label': 'Neck (Anterior)', 'sagittalPlane': SagittalPlaneEnum.notApplicable, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.neck, 'leftPx': 63, 'topPx': 83, 'color': headColor, 'useCallout': true, 'calloutOffset': const Offset(65, 11)},
      {'label': 'Thorax (Anterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.thorax, 'leftPx': 108, 'topPx': 129, 'color': torsoColor, 'useCallout': false},
      {'label': 'Thorax (Anterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.thorax, 'leftPx': 147, 'topPx': 129, 'color': torsoColor, 'useCallout': false},
      {'label': 'Shoulder (Anterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.shoulder, 'leftPx': 73, 'topPx': 108, 'color': armsColor, 'useCallout': false},
      {'label': 'Shoulder (Anterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.shoulder, 'leftPx': 182, 'topPx': 108, 'color': armsColor, 'useCallout': false},
      {'label': 'Upper Arm (Anterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.upperArm, 'leftPx': 63, 'topPx': 146, 'color': armsColor, 'useCallout': false},
      {'label': 'Upper Arm (Anterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.upperArm, 'leftPx': 192, 'topPx': 146, 'color': armsColor, 'useCallout': false},
      {'label': 'Elbow (Anterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.elbow, 'leftPx': 38, 'topPx': 164, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(31, 21)},
      {'label': 'Elbow (Anterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.elbow, 'leftPx': 217, 'topPx': 163, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(-14, 19)},
      {'label': 'Forearm (Anterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.forearm, 'leftPx': 60, 'topPx': 210, 'color': armsColor, 'useCallout': false},
      {'label': 'Forearm (Anterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.forearm, 'leftPx': 195, 'topPx': 210, 'color': armsColor, 'useCallout': false},
      {'label': 'Wrist (Anterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.wrist, 'leftPx': 32, 'topPx': 217, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(24, 18)},
      {'label': 'Wrist (Anterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.wrist, 'leftPx': 223, 'topPx': 217, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(-7, 15)},
      {'label': 'Hand (Anterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.hand, 'leftPx': 70, 'topPx': 282, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(-8, -11)},
      {'label': 'Hand (Anterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.hand, 'leftPx': 185, 'topPx': 281, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(23, -14)},
      {'label': 'Fingers (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.fingers, 'leftPx': 48, 'topPx': 316, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(4, -21)},
      {'label': 'Fingers (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.fingers, 'leftPx': 203, 'topPx': 312, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(14, -22)},
      {'label': 'Abdomen (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.abdomen, 'leftPx': 108, 'topPx': 179, 'color': torsoColor, 'useCallout': false},
      {'label': 'Abdomen (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.abdomen, 'leftPx': 147, 'topPx': 179, 'color': torsoColor, 'useCallout': false},
      {'label': 'Genitalia (Male)', 'sagittalPlane': SagittalPlaneEnum.notApplicable, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.genitaliaMale, 'leftPx': 128, 'topPx': 262, 'color': torsoColor, 'useCallout': false},
      {'label': 'Pelvis (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.pelvis, 'leftPx': 113, 'topPx': 235, 'color': torsoColor, 'useCallout': false},
      {'label': 'Pelvis (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.pelvis, 'leftPx': 141, 'topPx': 235, 'color': torsoColor, 'useCallout': false},
      {'label': 'Hip (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.hip, 'leftPx': 94, 'topPx': 260, 'color': legsColor, 'useCallout': false},
      {'label': 'Hip (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.hip, 'leftPx': 161, 'topPx': 260, 'color': legsColor, 'useCallout': false},
      {'label': 'Thigh (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.thigh, 'leftPx': 107, 'topPx': 306, 'color': legsColor, 'useCallout': false},
      {'label': 'Thigh (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.thigh, 'leftPx': 149, 'topPx': 306, 'color': legsColor, 'useCallout': false},
      {'label': 'Knee (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.knee, 'leftPx': 109, 'topPx': 362, 'color': legsColor, 'useCallout': false},
      {'label': 'Knee (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.knee, 'leftPx': 147, 'topPx': 362, 'color': legsColor, 'useCallout': false},
      {'label': 'Lower Leg (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.lowerLeg, 'leftPx': 106, 'topPx': 413, 'color': legsColor, 'useCallout': false},
      {'label': 'Lower Leg (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.anterior, 'generalRegion': GeneralRegionEnum.lowerLeg, 'leftPx': 148, 'topPx': 413, 'color': legsColor, 'useCallout': false},
      {'label': 'Ankle (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.ankle, 'leftPx': 73, 'topPx': 431, 'color': legsColor, 'useCallout': true, 'calloutOffset': const Offset(36, 31)},
      {'label': 'Ankle (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.ankle, 'leftPx': 183, 'topPx': 429, 'color': legsColor, 'useCallout': true, 'calloutOffset': const Offset(-20, 31)},
      {'label': 'Foot (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.foot, 'leftPx': 57, 'topPx': 457, 'color': legsColor, 'useCallout': true, 'calloutOffset': const Offset(49, 17)},
      {'label': 'Foot (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.foot, 'leftPx': 199, 'topPx': 456, 'color': legsColor, 'useCallout': true, 'calloutOffset': const Offset(-30, 17)},
      {'label': 'Toes (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.toes, 'leftPx': 39, 'topPx': 483, 'color': legsColor, 'useCallout': true, 'calloutOffset': const Offset(61, 4)},
      {'label': 'Toes (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.toes, 'leftPx': 218, 'topPx': 481, 'color': legsColor, 'useCallout': true, 'calloutOffset': const Offset(-41, 4)},
    ],
    'back': [
      {'label': 'Head (Posterior)', 'sagittalPlane': SagittalPlaneEnum.notApplicable, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.head, 'leftPx': 77, 'topPx': 20, 'color': headColor, 'useCallout': true, 'calloutOffset': const Offset(40, 13)},
      {'label': 'Neck (Posterior)', 'sagittalPlane': SagittalPlaneEnum.notApplicable, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.neck, 'leftPx': 179, 'topPx': 64, 'color': headColor, 'useCallout': true, 'calloutOffset': const Offset(-34, 20)},
      {'label': 'Shoulder (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.shoulder, 'leftPx': 72, 'topPx': 109, 'color': armsColor, 'useCallout': false},
      {'label': 'Shoulder (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.shoulder, 'leftPx': 182, 'topPx': 108, 'color': armsColor, 'useCallout': false},
      {'label': 'Thorax (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.thorax, 'leftPx': 108, 'topPx': 135, 'color': torsoColor, 'useCallout': false},
      {'label': 'Thorax (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.thorax, 'leftPx': 147, 'topPx': 135, 'color': torsoColor, 'useCallout': false},
      {'label': 'Abdomen (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.abdomen, 'leftPx': 108, 'topPx': 189, 'color': torsoColor, 'useCallout': false},
      {'label': 'Abdomen (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.abdomen, 'leftPx': 147, 'topPx': 189, 'color': torsoColor, 'useCallout': false},
      {'label': 'Pelvis (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.pelvis, 'leftPx': 113, 'topPx': 235, 'color': torsoColor, 'useCallout': false},
      {'label': 'Pelvis (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.pelvis, 'leftPx': 141, 'topPx': 235, 'color': torsoColor, 'useCallout': false},
      {'label': 'Hip (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.hip, 'leftPx': 94, 'topPx': 260, 'color': legsColor, 'useCallout': false},
      {'label': 'Hip (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.hip, 'leftPx': 161, 'topPx': 260, 'color': legsColor, 'useCallout': false},
      {'label': 'Thigh (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.thigh, 'leftPx': 107, 'topPx': 306, 'color': legsColor, 'useCallout': false},
      {'label': 'Thigh (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.thigh, 'leftPx': 149, 'topPx': 306, 'color': legsColor, 'useCallout': false},
      {'label': 'Knee (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.knee, 'leftPx': 109, 'topPx': 362, 'color': legsColor, 'useCallout': false},
      {'label': 'Knee (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.knee, 'leftPx': 147, 'topPx': 362, 'color': legsColor, 'useCallout': false},
      {'label': 'Lower Leg (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.lowerLeg, 'leftPx': 106, 'topPx': 413, 'color': legsColor, 'useCallout': false},
      {'label': 'Lower Leg (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.lowerLeg, 'leftPx': 148, 'topPx': 413, 'color': legsColor, 'useCallout': false},
      {'label': 'Upper Arm (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.upperArm, 'leftPx': 65, 'topPx': 141, 'color': armsColor, 'useCallout': false},
      {'label': 'Upper Arm (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.upperArm, 'leftPx': 190, 'topPx': 141, 'color': armsColor, 'useCallout': false},
      {'label': 'Elbow (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.elbow, 'leftPx': 41, 'topPx': 156, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(28, 27)},
      {'label': 'Elbow (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.elbow, 'leftPx': 216, 'topPx': 156, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(-14, 24)},
      {'label': 'Forearm (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.forearm, 'leftPx': 59, 'topPx': 215, 'color': armsColor, 'useCallout': false},
      {'label': 'Forearm (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.forearm, 'leftPx': 196, 'topPx': 215, 'color': armsColor, 'useCallout': false},
      {'label': 'Wrist (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.wrist, 'leftPx': 28, 'topPx': 210, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(26, 28)},
      {'label': 'Wrist (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.wrist, 'leftPx': 227, 'topPx': 210, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(-9, 25)},
      {'label': 'Hand (Posterior, Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.hand, 'leftPx': 69, 'topPx': 282, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(-9, -13)},
      {'label': 'Hand (Posterior, Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.posterior, 'generalRegion': GeneralRegionEnum.hand, 'leftPx': 186, 'topPx': 281, 'color': armsColor, 'useCallout': true, 'calloutOffset': const Offset(24, -16)},
    ],
    'left': [
      {'label': 'Head (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.head, 'leftPx': 134, 'topPx': 40.8, 'color': headColor, 'useCallout': false},
      {'label': 'Neck (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.neck, 'leftPx': 177, 'topPx': 80, 'color': headColor, 'useCallout': true, 'calloutOffset': const Offset(-22, 8)},
      {'label': 'Thorax (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.thorax, 'leftPx': 119, 'topPx': 150, 'color': torsoColor, 'useCallout': false},
      {'label': 'Abdomen (Left)', 'sagittalPlane': SagittalPlaneEnum.left, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.abdomen, 'leftPx': 119, 'topPx': 194, 'color': torsoColor, 'useCallout': false},
    ],
    'right': [
      {'label': 'Head (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.head, 'leftPx': 125, 'topPx': 40.8, 'color': headColor, 'useCallout': false},
      {'label': 'Neck (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.neck, 'leftPx': 84, 'topPx': 79, 'color': headColor, 'useCallout': true, 'calloutOffset': const Offset(37, 8)},
      {'label': 'Thorax (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.thorax, 'leftPx': 137, 'topPx': 150, 'color': torsoColor, 'useCallout': false},
      {'label': 'Abdomen (Right)', 'sagittalPlane': SagittalPlaneEnum.right, 'transversePlane': TransversePlaneEnum.notApplicable, 'coronalPlane': CoronalPlaneEnum.notApplicable, 'generalRegion': GeneralRegionEnum.abdomen, 'leftPx': 137, 'topPx': 194, 'color': torsoColor, 'useCallout': false},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientCaseBuilderBloc, PatientCaseBuilderState>(
      listener: (context, state) {
        if (!widget.editMode) {
          if (state.requestStatus == RequestStatus.success) {
            Navigator.of(context).pop(); // Dismiss dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Treatment sent successfully')),
            );
            LastTreatmentStore().putLastTreatment(
                widget.patientId ?? "", treatmentDisplayName ?? '');
          } else if (state.requestStatus == RequestStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Failed to send treatment')),
            );
          }
        }
      },
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: MmsColors.mainBodyBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: MmsColors.translucentBlack,
                offset: Offset(1, 1),
                blurRadius: 1,
                spreadRadius: 2,
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height - 42,
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
            builder: (context, state) {
              return MmsRoundedBarlessPanel(
                caption: widget.editMode
                    ? "Select Injury Location ${state.saving == SaveStatus.saving ? '(saving)' : '(saved)'}"
                    : "${treatmentDisplayName ?? "Select"} - Select Treatment Location",
                widget: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 0), // give room for buttons
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Spacer(),
                                    SizedBox(
                                        width: 260,
                                        child: _buildProfileSelector()),
                                    const SizedBox(width: 30),
                                    _buildBodyImageWithPoints(),
                                    const SizedBox(width: 60),
                                    SizedBox(
                                        width: 260,
                                        child: _buildAreaInfoAndDropdown()),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.editMode)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        left: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: (selectedArea != null &&
                                      (deviceTypeItems.isEmpty ||
                                          selectedDeviceType != null))
                                  ? () {
                                      final treatment =
                                          treatmentSelectedCamelCase; // already validated to be non-null
                                      final deviceUsed = selectedDeviceType ??
                                          'notApplicable'; // fallback if null

                                      final targetPoint =
                                          _getSelectedBodyLocationPoint();
                                      if (targetPoint == null) return;

                                      final treatmentLocation =
                                          BodyLocationRecord(
                                        generalRegion:
                                            targetPoint['generalRegion']
                                                as GeneralRegionEnum,
                                        sagittalPlane:
                                            targetPoint['sagittalPlane']
                                                as SagittalPlaneEnum,
                                        coronalPlane:
                                            targetPoint['coronalPlane']
                                                as CoronalPlaneEnum,
                                      );

                                      context
                                          .read<PatientCaseBuilderBloc>()
                                          .add(
                                            PatientCaseBuilderEvent(
                                              PatientCaseBuilderAction
                                                  .sendPhysicalTreatment,
                                              patientId: widget.patientId,
                                              dynamicTreatmentName: treatment,
                                              dynamicDeviceName: deviceUsed,
                                              bodyLocation: treatmentLocation,
                                              context: context,
                                            ),
                                          );
                                    }
                                  : null,
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAreaInfoAndDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Area Selected:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 260,
          child: Text(
            _getSelectedAreaLabel(),
            softWrap: true,
          ),
        ),
        if (widget.editMode) ...[
          const SizedBox(height: 30),
          const Text(
            'Select Tissue Type:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedArea != null ? selectedTissueType : null,
            hint: const Text("No tissue type (no area selected)"),
            onChanged: selectedArea != null
                ? (newValue) {
                    setState(() {
                      selectedTissueType = newValue!;
                    });
                    final state = context.read<PatientCaseBuilderBloc>().state;
                    fireBodyLocationUpdateEvent(
                      context: context,
                      state: state,
                    );
                  }
                : null,
            items: RegionTissueTypeEnum.values
                .map((e) => DropdownMenuItem(
                      value: e.label,
                      child: Text(e.label),
                    ))
                .toList(),
          ),
        ],
        if (!widget.editMode && deviceTypeItems.isNotEmpty) ...[
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Device Type:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedDeviceType,
                  hint: const Text("None"),
                  items: deviceTypeItems,
                  onChanged: (value) {
                    setState(() {
                      selectedDeviceType = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Choose Profile:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildProfileButton('Front'),
        _buildProfileButton('Back'),
        _buildProfileButton('Left'),
        _buildProfileButton('Right'),
      ],
    );
  }

  Widget _buildBodyImageWithPoints() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;

        // Calculate scaleFactor but NEVER go below targetHeight
        double scaleFactor = (availableHeight / baseHeight)
            .clamp(targetHeight / baseHeight, 1.0);

        double renderWidth = baseWidth * scaleFactor;
        double renderHeight = baseHeight * scaleFactor;

        // If we hit minimum, force fixed size & enable scroll
        bool needsScroll = scaleFactor == (targetHeight / baseHeight);

        Widget content = SizedBox(
          width: renderWidth,
          height: renderHeight,
          child: BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
            builder: (context, state) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'images/homunculus_${selectedSex.value}_${selectedProfile.toLowerCase()}.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  ..._buildPoints(context, state, scaleFactor),
                ],
              );
            },
          ),
        );

        return ClipRect(
          child: needsScroll
              ? SingleChildScrollView(child: content)
              : Align(
                  alignment: Alignment.topCenter,
                  child: content,
                ),
        );
      },
    );
  }

  Widget _buildProfileButton(String label) {
    bool isSelected = selectedProfile == label.toLowerCase();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedProfile = label.toLowerCase();
            _controller.reset();
            _controller.forward();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          side: BorderSide(color: Colors.grey.shade400),
        ),
        child: Text(label),
      ),
    );
  }

  List<Widget> _buildPoints(
      BuildContext context, PatientCaseBuilderState state, double scaleFactor) {
    final pointMap = selectedSex == BiologicalSexEnum.male
        ? bodyLocationPointsByProfileMale
        : bodyLocationPointsByProfile;
    final points = pointMap[selectedProfile] ?? [];
    const double baseCircleSize = 20;
    const double strokeWidth = 2;

    return points.map((point) {
      final isSelected = selectedArea == point['label'] &&
          selectedProfile == selectedProfileForArea;
      final Color pointColor = point['color'];
      final bool useCallout = point['useCallout'] ?? false;

      final double targetTop = point['topPx'] * scaleFactor;
      final double targetLeft = point['leftPx'] * scaleFactor;

      final Offset rawCalloutOffset = point['calloutOffset'] ?? Offset.zero;
      final Offset scaledCalloutOffset = Offset(
          rawCalloutOffset.dx * scaleFactor, rawCalloutOffset.dy * scaleFactor);

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double animatedTop = -50 + (targetTop + 50) * _controller.value;
          double animatedLeft = (baseWidth / 2) * scaleFactor +
              (targetLeft - (baseWidth / 2) * scaleFactor) * _controller.value;

          return Stack(
            children: [
              if (useCallout)
                Positioned(
                  top: animatedTop + _edgeOffset(scaledCalloutOffset).dy,
                  left: animatedLeft + _edgeOffset(scaledCalloutOffset).dx,
                  child: CustomPaint(
                    size: Size(scaledCalloutOffset.dx.abs(),
                        scaledCalloutOffset.dy.abs()),
                    painter: CalloutLinePainter(
                      start: Offset.zero,
                      end: Offset(
                          scaledCalloutOffset.dx - 10, scaledCalloutOffset.dy),
                      color: pointColor,
                      strokeWidth: strokeWidth,
                    ),
                  ),
                ),
              Positioned(
                top: animatedTop - (baseCircleSize * scaleFactor) / 2,
                left: animatedLeft - (baseCircleSize * scaleFactor) / 2,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedArea == point['label'] &&
                          selectedProfile == selectedProfileForArea) {
                        selectedArea = null;
                        selectedDeviceType = null;
                        selectedProfileForArea = null;
                      } else {
                        selectedArea = point['label'];
                        selectedProfileForArea = selectedProfile;
                      }
                      if (!widget.editMode) return;
                      fireBodyLocationUpdateEvent(
                          context: context, state: state);
                    });
                  },
                  child: Container(
                    width: baseCircleSize * scaleFactor,
                    height: baseCircleSize * scaleFactor,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? pointColor : Colors.transparent,
                      border: Border.all(color: pointColor, width: strokeWidth),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }).toList();
  }

  void fireBodyLocationUpdateEvent({
    required BuildContext context,
    required PatientCaseBuilderState state,
  }) {
    final tissueType = _getSelectedTissueType();
    final targetPoint = _getSelectedBodyLocationPoint();

    if (targetPoint != null) {
      // Full update with body location and tissue type
      _dispatchFullBodyLocationUpdate(context, state, targetPoint, tissueType);
    } else {
      // No point selected — clear location entirely
      _dispatchClearLocation(context, state);
    }
  }

  void _dispatchClearLocation(
    BuildContext context,
    PatientCaseBuilderState state,
  ) {
    context.read<PatientCaseBuilderBloc>().add(
          PatientCaseBuilderEvent(
            PatientCaseBuilderAction.updateInjuryLocation,
            patientCaseName: state.patientCaseUnderEditOrDisplay,
            injuryId: state.injuryIdUnderEdit,
            bodyLocation: null, // Clear location fully
            context: context,
          ),
        );
  }

  RegionTissueTypeEnum _getSelectedTissueType() {
    return RegionTissueTypeEnumExtension.fromLabel(selectedTissueType);
  }

  Map<String, dynamic>? _getSelectedBodyLocationPoint() {
    final pointMap = selectedSex == BiologicalSexEnum.male
        ? bodyLocationPointsByProfileMale
        : bodyLocationPointsByProfile;
    final profilePoints = pointMap[selectedProfile] ?? [];

    final target = profilePoints.firstWhere(
      (element) => element['label'] == selectedArea,
      orElse: () => <String, dynamic>{},
    );

    return target.isNotEmpty ? target : null;
  }

  void _dispatchFullBodyLocationUpdate(
    BuildContext context,
    PatientCaseBuilderState state,
    Map<String, dynamic> targetPoint,
    RegionTissueTypeEnum tissueType,
  ) {
    final updatedLocation = BodyLocationRecord(
      generalRegion: targetPoint['generalRegion'],
      regionTissueType: tissueType,
      sagittalPlane: targetPoint['sagittalPlane'],
      coronalPlane: targetPoint['coronalPlane'],
    );

    context.read<PatientCaseBuilderBloc>().add(
          PatientCaseBuilderEvent(
            PatientCaseBuilderAction.updateInjuryLocation,
            patientCaseName: state.patientCaseUnderEditOrDisplay,
            injuryId: state.injuryIdUnderEdit,
            bodyLocation: updatedLocation,
            context: context,
          ),
        );
  }

  void setSelectedAreaFromBodyLocation(BodyLocationRecord record) {
    // If user has already selected an area, do NOT overwrite
    if (selectedArea != null) {
      return;
    }

    final pointMap = selectedSex == BiologicalSexEnum.male
        ? bodyLocationPointsByProfileMale
        : bodyLocationPointsByProfile;
    for (var entry in pointMap.entries) {
      String profileKey = entry.key;
      List<Map<String, dynamic>> points = entry.value;

      var matchingPoint = points.firstWhere(
        (point) =>
            point['generalRegion'] == record.generalRegion &&
            point['sagittalPlane'] == record.sagittalPlane &&
            point['coronalPlane'] == record.coronalPlane,
        orElse: () => <String, dynamic>{},
      );

      if (matchingPoint.isNotEmpty) {
        setState(() {
          selectedProfile = profileKey;
          selectedArea = matchingPoint['label'];
          selectedProfileForArea = profileKey;
          _controller.reset();
          _controller.forward();
        });

        return;
      }
    }

    debugPrint(
        'No matching area found for the given BodyLocationRecord: $record');
  }

  Offset _edgeOffset(Offset callout) {
    if (callout == Offset.zero) return Offset.zero;

    const double radius = 10; // circleSize / 2
    final double length = callout.distance;

    return Offset(
      (callout.dx / length) * radius,
      (callout.dy / length) * radius,
    );
  }

  String _getSelectedAreaLabel() {
    if (selectedArea == null || selectedProfileForArea == null) return 'None';

    final pointMap = selectedSex == BiologicalSexEnum.male
        ? bodyLocationPointsByProfileMale
        : bodyLocationPointsByProfile;
    final points = pointMap[selectedProfileForArea!] ?? [];

    final point = points.firstWhere(
      (p) => p['label'] == selectedArea,
      orElse: () => {},
    );

    if (point.isEmpty) return 'None';

    return BodyLocationRecord.generateLabel(
      sagittal: point['sagittalPlane'],
      coronal: point['coronalPlane'],
      region: point['generalRegion'],
    );
  }
}

class CalloutLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  CalloutLinePainter({
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
