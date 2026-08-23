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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/facility/facility.dart';
import 'package:flutter_ui/logic/facility/facility_bloc.dart';
import 'package:flutter_ui/logic/facility/facility_event.dart';
import 'package:flutter_ui/logic/facility/facility_state.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/facilities_management/display_helpers.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text_field_with_blur.dart';

class FacilityEditor extends StatefulWidget {
  const FacilityEditor({super.key});

  @override
  State<FacilityEditor> createState() => FacilityEditorState();
}

class FacilityEditorState extends State<FacilityEditor> {
  String? _selectedRoleOfCare;
  String? _selectedFacilityType;
  String? _capacityError;
  bool _isEditingCapacity = false;
  final FocusNode _capacityFocus = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<FacilityBloc>().state;
    final currentFacility = state.facilityBeingEdited;
    if (currentFacility != null) {
      _selectedRoleOfCare = currentFacility.roleOfCare;
      _selectedFacilityType = currentFacility.facilityType;
    }
  }

  void _updateFacility(FacilityState state, Facility updated) {
    context.read<FacilityBloc>().add(UpdateFacility(updated));
  }

  Widget _capacityInput(FacilityState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFieldWithBlur(
          controller: TextEditingController(
            text: state.facilityBeingEdited?.capacity != null &&
                    state.facilityBeingEdited!.capacity > 0
                ? state.facilityBeingEdited!.capacity.toString()
                : '',
          ),
          focusNode: _capacityFocus,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          ),
          callback: (value) {
            final capacity = int.tryParse(value);
            setState(() {
              if (capacity == null || capacity < 1 || capacity > 1000) {
                _capacityError = 'Enter a number 1–1000';
              } else {
                _capacityError = null;
                if (state.facilityBeingEdited != null) {
                  final updated =
                      state.facilityBeingEdited!.copyWith(capacity: capacity);
                  _updateFacility(state, updated);
                }
              }
            });
          },
          onFocusChanged: (hasFocus) {
            setState(() {
              _isEditingCapacity = hasFocus;
            });
          },
        ),
        if (_capacityError != null) ...[
          const SizedBox(height: 4),
          Text(
            _capacityError!,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.red,
              height: 1.2,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ],
      ],
    );
  }

  /// Validates the Facility Editor's current state before allowing it to close.
  Future<bool> validateBeforeDismiss() async {
    // Capture before any await
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (_isEditingCapacity) {
      _capacityFocus.unfocus();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (_capacityError != null) {
      // Guard just in case the widget was disposed in the meantime
      if (mounted) {
        messenger?.showSnackBar(
          const SnackBar(
            content: Text("Please fix capacity before closing."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
        height: MediaQuery.of(context).size.height - 42, // Ensure finite height
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<FacilityBloc, FacilityState>(
          builder: (context, state) {
            final currentName =
                state.facilityBeingEdited?.facilityId ?? 'Loading';

            final edited = state.facilityBeingEdited;
            if (edited != null) {
              // Sync from bloc if backend/bloc changed it externally
              if (_selectedRoleOfCare != edited.roleOfCare) {
                _selectedRoleOfCare = edited.roleOfCare;
              }
              if (_selectedFacilityType != edited.facilityType) {
                _selectedFacilityType = edited.facilityType;
              }
            }

            return MmsRoundedBarlessPanel(
              caption:
                  "Facility Editor - $currentName ${state.isLoadingSaved ? '(saving)' : '(saved)'}",
              widget: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCard(
                            title: 'Role of Care',
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedRoleOfCare,
                              hint: const Text('Role of Care'),
                              items: const [
                                'ROLE1',
                                'ROLE2',
                                'ROLE3',
                                'EN_ROUTE',
                              ].map((code) {
                                return DropdownMenuItem(
                                  value: code,
                                  child: Text(displayRoleOfCare(code)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoleOfCare = value;
                                });
                                if (value != null &&
                                    state.facilityBeingEdited != null) {
                                  final updated = state.facilityBeingEdited!
                                      .copyWith(roleOfCare: value);
                                  _updateFacility(state, updated);
                                }
                              },
                            ),
                          ),
                          _buildCard(
                            title: 'Facility Type',
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedFacilityType,
                              hint: const Text('Facility Type'),
                              items: const [
                                'GROUND',
                                'FIXED',
                                'AIR',
                              ].map((code) {
                                return DropdownMenuItem(
                                  value: code,
                                  child: Text(displayFacilityType(code)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedFacilityType = value;
                                });
                                if (value != null &&
                                    state.facilityBeingEdited != null) {
                                  final updated = state.facilityBeingEdited!
                                      .copyWith(facilityType: value);
                                  _updateFacility(state, updated);
                                }
                              },
                            ),
                          ),
                          _buildCard(
                            title: 'Capacity',
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _capacityInput(state)),
                                const SizedBox(width: 8),
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text('1–1000'),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: 150,
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _capacityFocus.dispose();
    super.dispose();
  }
}
