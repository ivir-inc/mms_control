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
import 'package:flutter_ui/data/model/metadata/metadata.dart';
import 'package:flutter_ui/data/model/metadata/metadata_store_access.dart';
import 'package:flutter_ui/data/model/patient_cases/patient_case.dart';
import 'package:flutter_ui/data/model/treatment_layout/treatment_layout_config.dart';
import 'package:flutter_ui/logic/treatment_layout/treatment_layout_bloc.dart';
import 'package:flutter_ui/logic/treatment_layout/treatment_layout_event.dart';
import 'package:flutter_ui/logic/treatment_layout/treatment_layout_state.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/features/settings/patient_case_builder/patient_case_admin_route_dosage.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/logic/patient_case_builder/patient_case_builder_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class _DragData {
  final String itemName;
  final int fromCategoryIndex;
  const _DragData(this.itemName, this.fromCategoryIndex);
}

class PatientCaseMedications extends StatefulWidget {
  // editMode: true → toggle medications on/off in the patient case builder.
  //           false → show only enabled medications; tapping opens admin/dosage panel.
  // embeddedMode: true → no chrome wrapper (for use inside a tab/subtab).
  // layoutEditMode: true → show all 6 category slots with drag-and-drop + rename.
  final bool editMode;
  final bool embeddedMode;
  final bool layoutEditMode;
  final String? patientId;

  const PatientCaseMedications({
    super.key,
    this.editMode = false,
    this.embeddedMode = false,
    this.layoutEditMode = false,
    this.patientId,
  });

  @override
  State<PatientCaseMedications> createState() => _PatientCaseMedicationsState();
}

class _PatientCaseMedicationsState extends State<PatientCaseMedications> {
  int? _editingCategoryIndex;
  final _renameController = TextEditingController();
  String? _activeDragItemName;
  int? _activeDragCategoryIndex;
  int? _hoverCategoryIndex;
  int? _hoverDropIndex;
  int? _highlightedCategoryIndex;
  bool _dragCancelled = false;
  final _dragCancelledNotifier = ValueNotifier<bool>(false);
  final _dragFocusNode = FocusNode();
  final _itemDragKeys = <String, GlobalKey>{};
  GlobalKey _keyFor(String name) =>
      _itemDragKeys.putIfAbsent(name, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    if (widget.layoutEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dragFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _dragFocusNode.dispose();
    _dragCancelledNotifier.dispose();
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TreatmentLayoutBloc, TreatmentLayoutState>(
      builder: (context, layoutState) {
        return BlocBuilder<PatientCaseBuilderBloc, PatientCaseBuilderState>(
          builder: (context, caseState) {
            final content = _buildContent(layoutState, caseState);
            final screen = widget.embeddedMode
                ? content
                : _wrapWithChrome(content, caseState);
            if (!widget.layoutEditMode) return screen;
            return Focus(
              focusNode: _dragFocusNode,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape &&
                    _activeDragItemName != null) {
                  _dragCancelledNotifier.value = true;
                  setState(() {
                    _dragCancelled = true;
                    _activeDragItemName = null;
                    _activeDragCategoryIndex = null;
                    _hoverCategoryIndex = null;
                    _hoverDropIndex = null;
                    _highlightedCategoryIndex = null;
                  });
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: screen,
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
      TreatmentLayoutState layoutState, PatientCaseBuilderState caseState) {
    if (layoutState.isLoading || layoutState.config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.layoutEditMode && !widget.embeddedMode) {
      if (caseState.patientCases.isEmpty ||
          caseState.patientCaseUnderEditOrDisplay == null) {
        return const Center(child: CircularProgressIndicator());
      }
    }

    final metadata = context.read<MetadataStoreAccess>().store.metadata;
    if (metadata == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final metadataMap = <String, MedicationItem>{
      for (var item in metadata.medication ?? [])
        if (item.name != null) item.name!: item,
    };

    PatientCase? patientCase;
    if (!widget.layoutEditMode) {
      try {
        patientCase = caseState.patientCases.firstWhere(
          (pc) => pc.name == caseState.patientCaseUnderEditOrDisplay,
        );
      } catch (_) {}
      if (patientCase == null) {
        return const Center(child: Text("No Patient Case Selected"));
      }
    }

    // In dashboard mode (editMode: false, not layoutEditMode), only show enabled items.
    Set<String>? enabledNames;
    if (!widget.editMode && !widget.layoutEditMode) {
      enabledNames =
          (patientCase!.medications?.getEnabledTypes() ?? <String>[]).toSet();
    }

    // Build categories from the layout config. Defensively merge in any
    // metadata items not yet assigned to a layout slot.
    var categories = _mergeWithMetadata(
        layoutState.config!.medications, metadataMap.keys.toSet());

    if (widget.layoutEditMode) {
      while (categories.length < 6) {
        categories.add(const LayoutCategory(name: '', columns: []));
      }
      categories = categories.take(6).toList();
    } else {
      // Only show categories that have at least one item that will actually
      // render: known to metadata, and — in dashboard mode — also enabled for
      // this patient case. Matches the displayItems computation below so a
      // category never shows with an empty grid underneath.
      categories = categories
          .where((c) => c.allItems.any((n) =>
              metadataMap.containsKey(n) &&
              (enabledNames == null || enabledNames.contains(n))))
          .toList();
    }

    if (categories.isEmpty && !widget.layoutEditMode) {
      return Container(
        color: MmsColors.translucentWhite,
        height: MediaQuery.of(context).size.height - 160,
        alignment: Alignment.center,
        child: const Text(
          'No Medications Listed',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: maxHeight),
            child: Container(
              color: MmsColors.translucentWhite,
              padding: widget.embeddedMode
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, inner) {
                  final colWidth = (inner.maxWidth - 40) / 3;
                  final counts = categories
                      .map((c) => c.allItems
                          .map((n) => metadataMap[n])
                          .whereType<MedicationItem>()
                          .length)
                      .toList();
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: categories.asMap().entries.map((entry) {
                      final i = entry.key;
                      final rowStart = (i ~/ 3) * 3;
                      final rowEnd =
                          (rowStart + 3).clamp(0, categories.length);
                      final rowMax = counts
                          .sublist(rowStart, rowEnd)
                          .fold(0, (a, b) => a > b ? a : b);
                      final minCells =
                          (rowMax % 2 == 0 ? rowMax : rowMax + 1).clamp(2, 50);
                      return SizedBox(
                        width: colWidth,
                        child: _buildCategoryBlock(
                          context,
                          i,
                          entry.value,
                          metadataMap,
                          patientCase,
                          enabledNames,
                          minCells: minCells,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBlock(
    BuildContext context,
    int index,
    LayoutCategory category,
    Map<String, MedicationItem> metadataMap,
    PatientCase? patientCase,
    Set<String>? enabledNames, {
    int minCells = 2,
  }) {
    final isRenaming = _editingCategoryIndex == index;

    final header = Container(
      height: 40,
      color: const Color(0xFF0E2A47),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: widget.layoutEditMode
          ? Row(children: [
              Expanded(
                child: isRenaming
                    ? TextField(
                        controller: _renameController,
                        maxLength: 30,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          hintText: 'Category name',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        onSubmitted: (_) => _commitRename(context, index),
                      )
                    : Text(
                        category.name.isEmpty ? '(empty)' : category.name,
                        style: TextStyle(
                          color: category.name.isEmpty
                              ? Colors.white54
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isRenaming ? Icons.create_sharp : Icons.create_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  if (isRenaming) {
                    _commitRename(context, index);
                  } else {
                    setState(() {
                      _editingCategoryIndex = index;
                      _renameController.text = category.name;
                    });
                  }
                },
              ),
            ])
          : Text(
              category.name.isEmpty ? '(unnamed)' : category.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
    );

    final allItems = category.allItems
        .map((n) => metadataMap[n])
        .whereType<MedicationItem>()
        .toList();

    final displayItems = enabledNames != null
        ? allItems
            .where((item) =>
                item.name != null && enabledNames.contains(item.name))
            .toList()
        : allItems;

    Widget body;
    if (widget.layoutEditMode) {
      // Compute drag/gap state for this category.
      final isDraggingFromHere =
          _activeDragCategoryIndex == index && _activeDragItemName != null;
      final crossCategoryHover = _highlightedCategoryIndex == index &&
          _activeDragCategoryIndex != null &&
          _activeDragCategoryIndex != index;
      final isDragActive = _activeDragCategoryIndex != null &&
          _activeDragCategoryIndex != index;

      final allItemsWithoutDragged = isDraggingFromHere
          ? allItems.where((i) => i.name != _activeDragItemName).toList()
          : allItems;
      final draggedItem = isDraggingFromHere
          ? allItems.where((i) => i.name == _activeDragItemName).firstOrNull
          : null;
      final originalDraggedIndex = isDraggingFromHere
          ? allItems.indexWhere((i) => i.name == _activeDragItemName)
          : -1;

      // Resolve a display-space drop index to the name of the item the drop
      // lands in front of (null = append). The bloc needs a name anchor, not
      // an index: the stored flat list can contain ghost names missing from
      // the metadata, so display indexes don't line up with stored indexes.
      String? beforeNameFor(int? dropIndex) {
        if (dropIndex == null) return null;
        if (dropIndex < 0 || dropIndex >= allItemsWithoutDragged.length) {
          return null;
        }
        return allItemsWithoutDragged[dropIndex].name;
      }

      final showGap = isDraggingFromHere &&
          _hoverCategoryIndex == index &&
          _hoverDropIndex != null;
      List<MedicationItem?> gridItems;
      if (showGap) {
        final gapPos = _hoverDropIndex!.clamp(0, allItemsWithoutDragged.length);
        gridItems = [
          ...allItemsWithoutDragged.sublist(0, gapPos).cast<MedicationItem?>(),
          null,
          ...allItemsWithoutDragged.sublist(gapPos).cast<MedicationItem?>(),
        ];
      } else {
        gridItems = allItemsWithoutDragged.cast<MedicationItem?>().toList();
      }

      body = DragTarget<_DragData>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (d) {
          if (!_dragCancelled) {
            if (d.data.fromCategoryIndex == index) {
              context.read<TreatmentLayoutBloc>().add(MoveItem(
                    itemName: d.data.itemName,
                    fromCategoryIndex: index,
                    toCategoryIndex: index,
                    isMedication: true,
                    sameCategoryReorder: true,
                    beforeItemName: beforeNameFor(_hoverDropIndex),
                  ));
            } else {
              context.read<TreatmentLayoutBloc>().add(MoveItem(
                    itemName: d.data.itemName,
                    fromCategoryIndex: d.data.fromCategoryIndex,
                    toCategoryIndex: index,
                    isMedication: true,
                  ));
            }
          }
          setState(() {
            _hoverCategoryIndex = null;
            _hoverDropIndex = null;
            _highlightedCategoryIndex = null;
          });
        },
        onMove: (d) {
          if (_dragCancelled) return;
          if (_highlightedCategoryIndex != index) {
            setState(() => _highlightedCategoryIndex = index);
          }
        },
        builder: (context, _, __) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 48),
            decoration: _highlightedCategoryIndex == index &&
                    _activeDragCategoryIndex != index
                ? BoxDecoration(
                    border: Border.all(
                        color: Colors.lightBlue.shade300, width: 2),
                    color: Colors.lightBlue.shade50,
                  )
                : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (gridItems.isEmpty && !isDragActive) return const SizedBox(height: 48);
                final cellWidth = (constraints.maxWidth - 6) / 2;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (draggedItem != null)
                      Offstage(
                        offstage: true,
                        child: KeyedSubtree(
                          key: _keyFor(draggedItem.name!),
                          child: _draggableGridCell(
                            item: draggedItem,
                            dropIndex: 0,
                            dropBeforeName: null,
                            categoryIndex: index,
                            cellWidth: cellWidth,
                          ),
                        ),
                      ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: constraints.maxWidth / 2 / 40,
                      children: [
                        ...gridItems.map((item) {
                          if (item == null) {
                            return KeyedSubtree(
                              key: const ValueKey('__gap__'),
                              child: _gapPlaceholder(_hoverDropIndex!, index,
                                  beforeNameFor(_hoverDropIndex)),
                            );
                          }
                          final withoutDraggedIndex =
                              allItemsWithoutDragged.indexOf(item);
                          final dropIndex = isDraggingFromHere &&
                                  originalDraggedIndex <
                                      allItems.indexOf(item)
                              ? withoutDraggedIndex + 1
                              : withoutDraggedIndex;
                          return KeyedSubtree(
                            key: _keyFor(item.name!),
                            child: _draggableGridCell(
                              item: item,
                              dropIndex: dropIndex,
                              dropBeforeName: beforeNameFor(dropIndex),
                              categoryIndex: index,
                              cellWidth: cellWidth,
                            ),
                          );
                        }),
                        ...() {
                          final padCount =
                              (minCells - gridItems.length).clamp(0, 50);
                          final rawExtra =
                              (8 - gridItems.length - padCount).clamp(0, 50);
                          final extraCells = crossCategoryHover
                              ? (rawExtra == 0 && padCount == 0 ? 2 : rawExtra)
                              : (isDragActive && gridItems.isEmpty
                                  ? rawExtra
                                  : 0);
                          return List.generate(
                            padCount + extraCells,
                            (i) => KeyedSubtree(
                              key: ValueKey('__pad__$i'),
                              child: _appendPlaceholder(index,
                                  () => beforeNameFor(_hoverDropIndex)),
                            ),
                          );
                        }(),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: constraints.maxWidth / 2 / 40,
            children: displayItems
                .map((item) => _actionButton(item, patientCase))
                .toList(),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 8),
        body,
      ],
    );
  }

  void _commitRename(BuildContext context, int index) {
    final newName = _renameController.text.trim();
    if (newName.isNotEmpty) {
      context
          .read<TreatmentLayoutBloc>()
          .add(RenameMedicationCategory(index, newName));
    }
    setState(() => _editingCategoryIndex = null);
  }

  Widget _draggableGridCell({
    required MedicationItem item,
    required int dropIndex,
    required String? dropBeforeName,
    required int categoryIndex,
    required double cellWidth,
  }) {
    return DragTarget<_DragData>(
      onWillAcceptWithDetails: (d) =>
          d.data.fromCategoryIndex == categoryIndex,
      onMove: (d) {
        if (_dragCancelled) return;
        // Skip if pointer is still over the dragged item's own old cell —
        // this fires for one frame before Offstage removes it from hit-testing,
        // and would set _hoverDropIndex to the item's own position (wrong for
        // forward drags, causing a no-op drop).
        if (d.data.itemName == item.name) return;
        if (_hoverCategoryIndex != categoryIndex ||
            _hoverDropIndex != dropIndex ||
            _highlightedCategoryIndex != categoryIndex) {
          setState(() {
            _hoverCategoryIndex = categoryIndex;
            _hoverDropIndex = dropIndex;
            _highlightedCategoryIndex = categoryIndex;
          });
        }
      },
      onAcceptWithDetails: (d) {
        if (!_dragCancelled && d.data.itemName != item.name) {
          context.read<TreatmentLayoutBloc>().add(MoveItem(
                itemName: d.data.itemName,
                fromCategoryIndex: categoryIndex,
                toCategoryIndex: categoryIndex,
                isMedication: true,
                sameCategoryReorder: true,
                beforeItemName: dropBeforeName,
              ));
        }
        setState(() {
          _hoverCategoryIndex = null;
          _hoverDropIndex = null;
          _highlightedCategoryIndex = null;
        });
      },
      builder: (context, candidateData, _) {
        return LongPressDraggable<_DragData>(
          data: _DragData(item.name!, categoryIndex),
          delay: const Duration(milliseconds: 75),
          onDragStarted: () {
            setState(() {
              _activeDragItemName = item.name;
              _activeDragCategoryIndex = categoryIndex;
            });
          },
          onDragEnd: (_) {
            _dragCancelledNotifier.value = false;
            setState(() {
              _activeDragItemName = null;
              _activeDragCategoryIndex = null;
              _hoverCategoryIndex = null;
              _hoverDropIndex = null;
              _highlightedCategoryIndex = null;
              _dragCancelled = false;
            });
          },
          // ValueListenableBuilder is required here (not setState) because the
          // feedback widget lives in an Overlay subtree that doesn't rebuild
          // with the parent. The notifier lets us collapse it on Escape.
          feedback: ValueListenableBuilder<bool>(
            valueListenable: _dragCancelledNotifier,
            builder: (context, cancelled, _) {
              if (cancelled) return const SizedBox.shrink();
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: cellWidth,
                  height: 40,
                  child:
                      _layoutButton(item.displayName ?? '', highlighted: false),
                ),
              );
            },
          ),
          // Show the real button in place when the drag is cancelled via
          // Escape so the item immediately reappears in its grid slot.
          childWhenDragging: ValueListenableBuilder<bool>(
            valueListenable: _dragCancelledNotifier,
            builder: (ctx, cancelled, _) => cancelled
                ? _layoutButton(item.displayName ?? '', highlighted: false)
                : const SizedBox.shrink(),
          ),
          // No candidate highlight: the gap placeholder already shows the
          // drop position, and the washed-out highlight style made cells that
          // reflowed under the pointer look like they had vanished.
          child: _layoutButton(item.displayName ?? '', highlighted: false),
        );
      },
    );
  }

  Widget _gapPlaceholder(
      int dropIndex, int categoryIndex, String? beforeName) {
    return DragTarget<_DragData>(
      onWillAcceptWithDetails: (d) => d.data.fromCategoryIndex == categoryIndex,
      onMove: (_) {
        if (_dragCancelled) return;
        // Re-confirm _hoverDropIndex while pointer is over the gap so a
        // neighboring cell's onMove can't leave a stale value at drop time.
        if (_highlightedCategoryIndex != categoryIndex ||
            _hoverCategoryIndex != categoryIndex ||
            _hoverDropIndex != dropIndex) {
          setState(() {
            _highlightedCategoryIndex = categoryIndex;
            _hoverCategoryIndex = categoryIndex;
            _hoverDropIndex = dropIndex;
          });
        }
      },
      onAcceptWithDetails: (d) {
        if (!_dragCancelled) {
          context.read<TreatmentLayoutBloc>().add(MoveItem(
                itemName: d.data.itemName,
                fromCategoryIndex: categoryIndex,
                toCategoryIndex: categoryIndex,
                isMedication: true,
                sameCategoryReorder: true,
                beforeItemName: beforeName,
              ));
        }
        setState(() {
          _hoverCategoryIndex = null;
          _hoverDropIndex = null;
          _highlightedCategoryIndex = null;
        });
      },
      builder: (context, candidateData, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: candidateData.isNotEmpty
                ? Colors.lightBlue
                : Colors.lightBlue.shade200,
            width: 2,
          ),
          color: Colors.lightBlue.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  // sameCategoryBeforeName resolves at drop time so it reflects the latest
  // _hoverDropIndex rather than the value captured at build.
  Widget _appendPlaceholder(
      int categoryIndex, String? Function() sameCategoryBeforeName) {
    return DragTarget<_DragData>(
      onWillAcceptWithDetails: (_) => true,
      onMove: (_) {
        if (_dragCancelled) return;
        if (_highlightedCategoryIndex != categoryIndex) {
          setState(() => _highlightedCategoryIndex = categoryIndex);
        }
      },
      onAcceptWithDetails: (d) {
        if (!_dragCancelled) {
          if (d.data.fromCategoryIndex == categoryIndex) {
            context.read<TreatmentLayoutBloc>().add(MoveItem(
                  itemName: d.data.itemName,
                  fromCategoryIndex: categoryIndex,
                  toCategoryIndex: categoryIndex,
                  isMedication: true,
                  sameCategoryReorder: true,
                  beforeItemName: sameCategoryBeforeName(),
                ));
          } else {
            context.read<TreatmentLayoutBloc>().add(MoveItem(
                  itemName: d.data.itemName,
                  fromCategoryIndex: d.data.fromCategoryIndex,
                  toCategoryIndex: categoryIndex,
                  isMedication: true,
                ));
          }
        }
        setState(() {
          _hoverCategoryIndex = null;
          _hoverDropIndex = null;
          _highlightedCategoryIndex = null;
        });
      },
      builder: (context, _, __) => const SizedBox.expand(),
    );
  }

  Widget _layoutButton(String label, {bool highlighted = false}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor:
            highlighted ? Colors.lightBlue.shade200 : Colors.lightBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        textStyle: const TextStyle(fontSize: 14),
        side: highlighted
            ? const BorderSide(color: Colors.white, width: 2)
            : null,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        softWrap: true,
        style: const TextStyle(
          fontFamily: 'MmsSans',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: null,
        ),
      ),
    );
  }

  Widget _actionButton(MedicationItem medication, PatientCase? patientCase) {
    final isActive =
        patientCase?.medications?.isEnabled(medication.name!) ?? false;

    return ElevatedButton(
      onPressed: () {
        if (!widget.editMode) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MmsDismissibleScreen(
                    const ValueKey("AdministrationRouteAndDosage"),
                    AdministrationRouteAndDosage(
                      medicationDisplayName: medication.displayName!,
                      medicationName: medication.name!,
                      patientId: widget.patientId ?? '',
                    ),
                    scrollable: true,
                  )));
        } else {
          context.read<PatientCaseBuilderBloc>().add(
                PatientCaseBuilderEvent(
                  isActive
                      ? PatientCaseBuilderAction.disableMedication
                      : PatientCaseBuilderAction.enableMedication,
                  dynamicMedicationName: medication.name,
                ),
              );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.lightBlue : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        textStyle: const TextStyle(fontSize: 14),
      ),
      child: Center(
        child: Text(
          medication.displayName ?? '',
          textAlign: TextAlign.center,
          softWrap: true,
          style: const TextStyle(
            fontFamily: 'MmsSans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: null,
          ),
        ),
      ),
    );
  }

  Widget _wrapWithChrome(Widget child, PatientCaseBuilderState state) {
    final caption = widget.layoutEditMode
        ? "Edit Medication Layout"
        : "Edit Medications - ${state.patientCaseUnderEditOrDisplay} "
            "${state.saving == SaveStatus.saving ? '(saving)' : '(saved)'}";

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
        height: MediaQuery.of(context).size.height - 42,
        padding: const EdgeInsets.all(20),
        child: MmsRoundedBarlessPanel(
          caption: caption,
          widget: child,
        ),
      ),
    );
  }

  List<LayoutCategory> _mergeWithMetadata(
    List<LayoutCategory> configCategories,
    Set<String> allMetadataNames,
  ) {
    final allLayoutNames =
        configCategories.expand((c) => c.allItems).toSet();
    final missing =
        allMetadataNames.where((n) => !allLayoutNames.contains(n)).toList();

    if (missing.isEmpty || configCategories.isEmpty) {
      return List<LayoutCategory>.from(configCategories);
    }

    final categories = List<LayoutCategory>.from(configCategories);
    final first = categories[0];
    final cols = List<LayoutColumn>.from(first.columns);
    if (cols.isEmpty) {
      cols.add(LayoutColumn(name: null, items: missing));
    } else {
      cols[0] = cols[0].copyWith(items: [...cols[0].items, ...missing]);
    }
    categories[0] = first.copyWith(columns: cols);
    return categories;
  }
}
