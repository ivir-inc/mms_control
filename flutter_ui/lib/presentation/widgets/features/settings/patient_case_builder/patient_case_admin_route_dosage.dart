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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/metadata/metadata.dart';
import 'package:flutter_ui/data/model/metadata/metadata_store_access.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_ui/modules/treatments/data/storage/last_treatment_store.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';

class AdministrationRouteAndDosage extends StatefulWidget {
  final String medicationDisplayName;
  final String medicationName;
  final String patientId;

  const AdministrationRouteAndDosage(
      {super.key,
      required this.medicationDisplayName,
      required this.medicationName,
      required this.patientId});

  @override
  State<AdministrationRouteAndDosage> createState() =>
      _AdministrationRouteAndDosageState();
}

class _AdministrationRouteAndDosageState
    extends State<AdministrationRouteAndDosage> {
  List<AdministrationRouteItem> allRoutes = [];
  List<String> routesLeft = [];
  List<String> routesMiddle = [];
  List<String> routesRight = [];

  AdministrationRouteItem? selectedRouteItem;
  String? selectedUnit;
  String amount = "";
  int dosageTimePeriod = -1;

  bool showUnitResetNotice = false;
  Timer? _unitResetTimer;

  @override
  void initState() {
    super.initState();

    final metadata = context.read<MetadataStoreAccess>().store.metadata;
    if (metadata != null) {
      allRoutes = metadata.administrationRoute ?? [];

      final displayNames = allRoutes
          .where((route) =>
              route.displayName != null && route.displayName!.isNotEmpty)
          .toList()
        ..sort(
            (a, b) => a.ordinal!.compareTo(b.ordinal!)); // Ensure stable order

      // Assign to columns in thirds (or however you want to group them)
      final total = displayNames.length;
      final split = (total / 3).ceil();

      routesLeft = displayNames.take(split).map((e) => e.displayName!).toList();
      routesMiddle = displayNames
          .skip(split)
          .take(split)
          .map((e) => e.displayName!)
          .toList();
      routesRight =
          displayNames.skip(2 * split).map((e) => e.displayName!).toList();
    }
  }

  bool isDripRoute(String? enumValue) {
    const dripEnums = {'INTRAVENOUS_DRIP', 'INTRAOSSEOUS_DRIP'};
    return enumValue != null && dripEnums.contains(enumValue);
  }

  List<String> getUnitOptions(AdministrationRouteItem? route) {
    if (route == null) return [];
    return isDripRoute(route.enumConstant)
        ? ['mL/min', 'mg/min']
        : ['mL', 'mg'];
  }

  void updateRoute(String displayName) {
    final match = allRoutes.firstWhere(
      (r) => r.displayName == displayName,
      orElse: () => AdministrationRouteItem(displayName: displayName),
    );

    final newIsDrip = isDripRoute(match.enumConstant);
    final oldIsDrip = isDripRoute(selectedRouteItem?.enumConstant);

    final shouldResetUnit = newIsDrip != oldIsDrip;
    final hadSelectedUnit = selectedUnit != null;

    // Cancel any previous timer
    _unitResetTimer?.cancel();
    _unitResetTimer = null;

    setState(() {
      selectedRouteItem = match;

      if (shouldResetUnit) {
        if (hadSelectedUnit) {
          showUnitResetNotice = true;

          _unitResetTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => showUnitResetNotice = false);
            }
          });
        }
        selectedUnit = null;
      } else {
        showUnitResetNotice = false;
      }

      dosageTimePeriod = newIsDrip ? 1 : 0;
    });
  }

  bool isValidFloat(String value) {
    return double.tryParse(value) != null;
  }

  @override
  Widget build(BuildContext context) {
    final unitOptions = getUnitOptions(selectedRouteItem);

    return BlocListener<PatientCaseBuilderBloc, PatientCaseBuilderState>(
      listener: (context, state) {
        if (state.requestStatus == RequestStatus.success) {
          Navigator.of(context).pop(); // Dismiss dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medication sent successfully')),
          );
          LastTreatmentStore()
              .putLastTreatment(widget.patientId, widget.medicationDisplayName);
        } else if (state.requestStatus == RequestStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(state.errorMessage ?? 'Failed to send medication')),
          );
        }
      },
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
        child: MmsRoundedBarlessPanel(
          caption:
              "${widget.medicationDisplayName} - Select Administration and Dosage",
          widget: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Scrollable main content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Administration Route',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: _buildRadioList(routesLeft)),
                                      Expanded(
                                          child: _buildRadioList(routesMiddle)),
                                      Expanded(
                                          child: _buildRadioList(routesRight)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text('Dosage',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top:
                                                14), // Align with center of text field
                                        child: Text("Amount:"),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 150,
                                        child: TextField(
                                          enabled: selectedRouteItem != null,
                                          onChanged: (val) =>
                                              setState(() => amount = val),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]')),
                                            _DecimalInputFormatter(),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: selectedRouteItem == null
                                                ? "Select Route"
                                                : "Enter amount",
                                            border: const OutlineInputBorder(),
                                          ),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DropdownButton<String>(
                                            value: selectedUnit,
                                            items: unitOptions
                                                .map((unit) => DropdownMenuItem(
                                                      value: unit,
                                                      child: Text(unit),
                                                    ))
                                                .toList(),
                                            onChanged: selectedRouteItem != null
                                                ? (val) => setState(
                                                    () => selectedUnit = val)
                                                : null,
                                            hint: const Text("Unit"),
                                          ),
                                          const SizedBox(height: 4),
                                          SizedBox(
                                            height: 16,
                                            child: AnimatedOpacity(
                                              opacity: showUnitResetNotice
                                                  ? 1.0
                                                  : 0.0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: const Text(
                                                "Unit reset due to route change",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.redAccent),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Fixed bottom action buttons
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: (selectedRouteItem != null &&
                                        selectedUnit != null &&
                                        isValidFloat(amount))
                                    ? () {
                                        // Example publish:
                                        // debugPrint(
                                        //     "medication: ${widget.medicationName}");
                                        // debugPrint(
                                        //     "patientId: ${widget.patientId}");
                                        // debugPrint(
                                        //     "route: ${selectedRouteItem!.name}");
                                        // debugPrint(
                                        //     "Amount: ${double.parse(amount)}");
                                        // debugPrint("unit: $selectedUnit");
                                        // debugPrint(
                                        //     "dosageTimePeriod: $dosageTimePeriod");

                                        context
                                            .read<PatientCaseBuilderBloc>()
                                            .add(
                                              PatientCaseBuilderEvent(
                                                PatientCaseBuilderAction
                                                    .sendMedication,
                                                dynamicMedicationName:
                                                    widget.medicationName,
                                                patientId: widget.patientId,
                                                administrationRoute:
                                                    selectedRouteItem?.name ??
                                                        '',
                                                dosageValue:
                                                    double.parse(amount),
                                                dosageTimePeriod:
                                                    dosageTimePeriod,
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
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioList(List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: 0,
          leading: Radio<String>(
            value: option,
            groupValue: selectedRouteItem?.displayName,
            onChanged: (val) => updateRoute(val!),
          ),
          title: GestureDetector(
            onTap: () => updateRoute(option),
            child: Text(option),
          ),
          onTap: () => updateRoute(option),
        );
      }).toList(),
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If new input has more than one '.', block it
    int dotCount = '.'.allMatches(newValue.text).length;
    if (dotCount > 1) {
      // Reject change: return previous value (text + selection)
      return oldValue;
    }

    return newValue;
  }
}
