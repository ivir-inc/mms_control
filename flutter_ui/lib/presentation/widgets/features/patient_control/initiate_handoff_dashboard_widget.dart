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
import 'package:flutter_ui/logic/handoff/handoff_bloc.dart';
import 'package:flutter_ui/logic/handoff/handoff_phase.dart';
import 'package:flutter_ui/logic/utils/string_utils.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_bloc.dart';
import 'package:flutter_ui/logic/casualty_state/casualty_state_state.dart';
import 'package:flutter_ui/logic/facility/facility_bloc.dart';
import 'package:flutter_ui/logic/facility/facility_state.dart';

class InitiateHandoffDashboardWidget extends StatefulWidget {
  final String patientId;
  const InitiateHandoffDashboardWidget({super.key, required this.patientId});

  @override
  State<InitiateHandoffDashboardWidget> createState() =>
      _InitiateHandoffDashboardWidgetState();
}

class _InitiateHandoffDashboardWidgetState
    extends State<InitiateHandoffDashboardWidget> {
  @override
  void initState() {
    super.initState();
    // subscribe + seed state for this patient immediately
    context.read<HandoffBloc>().add(HandoffLoad(widget.patientId));
  }

  @override
  void didUpdateWidget(covariant InitiateHandoffDashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if the tile is reused for a different patient, rewire the stream
    if (oldWidget.patientId != widget.patientId) {
      context.read<HandoffBloc>().add(HandoffLoad(widget.patientId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pid = widget.patientId;

    return InkWell(
      onTap: () {
        final bloc = context.read<HandoffBloc>();
        final pid = widget.patientId;

        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (_) => MmsDismissibleScreen(
            const ValueKey("InitiateHandoffEditorDismissible"),
            InitiateHandoffEditor(
              patientId: pid,
              initialDestinationId: bloc.state.view(pid).destinationId,
              initialPhase: bloc.state.view(pid).phase,
              phaseStream: bloc.phaseStreamFor(pid),
              onStart: (dest) {
                bloc.add(HandoffDestinationSelected(pid, dest));
                bloc.add(HandoffStartRequested(pid));
              },
            ),
            scrollable: true,
          ),
        ))
            .then((_) {
          // If we finished while the sheet was open, reset immediately.
          if (bloc.state.view(pid).phase == HandoffPhase.complete) {
            bloc.add(HandoffResetLocal(pid));
          }
        });
      },
      child: MmsRoundedBarlessPanel(
        width: 300,
        caption: 'Initiate Handoff',
        widget: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: BlocBuilder<HandoffBloc, HandoffState>(
            buildWhen: (prev, curr) => prev.view(pid) != curr.view(pid),
            builder: (_, state) {
              final v = state.view(pid);
              final phaseLabel = switch (v.phase) {
                HandoffPhase.start => 'Origin',
                HandoffPhase.holding => 'Holding',
                HandoffPhase.complete => 'Destination',
                _ => 'Tap to Start',
              };
              final dest = v.destinationId ?? 'Destination';
              final summary = (v.phase == HandoffPhase.none)
                  ? phaseLabel
                  : '$dest • $phaseLabel';

              return Center(
                child: Text(summary,
                    style: const TextStyle(color: MmsColors.black)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class InitiateHandoffEditor extends StatefulWidget {
  final String patientId;
  final String? initialDestinationId;
  final HandoffPhase initialPhase;

  /// Called when user presses Start (send API command here).
  /// UI phase will update from `phaseStream` (recommended) or, if the
  /// optimistic setState is kept below, it will also move to Start immediately.
  final void Function(String? destinationId) onStart;

  /// Optional: live phase updates from backend (Bloc/WebSocket).
  /// If provided, the editor listens and renders the current phase read-only.
  final Stream<HandoffPhase> phaseStream;

  const InitiateHandoffEditor({
    super.key,
    required this.patientId,
    required this.onStart,
    this.initialDestinationId,
    this.initialPhase = HandoffPhase.none,
    required this.phaseStream,
  });

  @override
  State<InitiateHandoffEditor> createState() => _InitiateHandoffEditorState();
}

class _InitiateHandoffEditorState extends State<InitiateHandoffEditor> {
  late final HandoffBloc _handoffBloc; // cache bloc
  String? _destinationId;
  late HandoffPhase _phase;
  StreamSubscription<HandoffPhase>? _sub;
  static const double _kDetailAreaHeight = 48.0; // one line + comfy padding

  @override
  void initState() {
    super.initState();
    _handoffBloc = context.read<HandoffBloc>(); // grab cached bloc
    _destinationId = widget.initialDestinationId;
    _phase = widget.initialPhase;
    context
        .read<HandoffBloc>()
        .add(HandoffEditorVisible(widget.patientId, true));

    _sub = widget.phaseStream.listen((p) {
      if (mounted) setState(() => _phase = p);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    // If this handoff reached Complete, reset local view when closing.
    // SAFE: use the cached bloc, not context.read(...)
    final v = _handoffBloc.state.view(widget.patientId);
    if (v.phase == HandoffPhase.complete) {
      _handoffBloc.add(HandoffResetLocal(widget.patientId));
    }
    _handoffBloc.add(HandoffEditorVisible(widget.patientId, false));
    super.dispose();
  }

  int _phaseIndex(HandoffPhase p) {
    switch (p) {
      case HandoffPhase.start:
        return 1;
      case HandoffPhase.holding:
        return 2;
      case HandoffPhase.complete:
        return 3;
      default:
        return 0; // none
    }
  }

  bool _isLit(HandoffPhase target) =>
      _phaseIndex(_phase) >= _phaseIndex(target);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      // listen for this patient's phase → Complete
      child: BlocListener<HandoffBloc, HandoffState>(
        listenWhen: (prev, curr) {
          final pid = widget.patientId;
          final before = prev.view(pid).phase;
          final after = curr.view(pid).phase;
          return before != after && after == HandoffPhase.complete;
        },
        listener: (context, state) {
          final sm = ScaffoldMessenger.maybeOf(context);
          if (sm != null) {
            sm.hideCurrentSnackBar(); // avoid stacking if something was already showing
            sm.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating, // overlay, no layout jump
                duration: const Duration(seconds: 2),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 10),
                    Expanded(
                        child: Text('Handoff complete — Facility updated')),
                  ],
                ),
              ),
            );
          }
        },
        child: MmsRoundedBarlessPanel(
          caption: 'Initiate Handoff - ${widget.patientId}',
          widget: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                _topBar(context),
                const SizedBox(height: 12),

                // Big, centered, READ-ONLY state circles with arrows
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, c) {
                      final maxW = c.maxWidth;
                      final diameter = (maxW - 160) / 3;
                      final d = diameter.clamp(120.0, 160.0);
                      return Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _stateCircle('Origin',
                              lit: _isLit(HandoffPhase.start), diameter: d),
                          _arrow(d),
                          _stateCircle('Holding',
                              lit: _isLit(HandoffPhase.holding), diameter: d),
                          _arrow(d),
                          _stateCircle('Destination',
                              lit: _isLit(HandoffPhase.complete), diameter: d),
                        ],
                      ));
                    },
                  ),
                ),
                // Latest detail message (fixed-height to prevent layout shift)
                SizedBox(
                  height: _kDetailAreaHeight,
                  child: BlocBuilder<HandoffBloc, HandoffState>(
                    buildWhen: (a, b) =>
                        a.view(widget.patientId).details !=
                        b.view(widget.patientId).details,
                    builder: (_, s) {
                      final details = s.view(widget.patientId).details;
                      final latest = details.isEmpty ? null : details.last;

                      return Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: (latest == null)
                              // Keep size stable: outer SizedBox fixes height; we switch child only.
                              ? const SizedBox(key: ValueKey('empty'))
                              : Padding(
                                  key: ValueKey(latest),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    '[${StringUtils.sentenceCaseUnderscored(latest)}]',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── top bar ─────────────────────
  Widget _topBar(BuildContext context) {
    final left = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<CasualtyStateBloc, CasualtyStateState>(
          builder: (context, csState) {
            final id =
                csState.getByPatientId(widget.patientId)?.facilityId ?? '';
            return Text(
              'Current Facility: ${id.isEmpty ? '-' : id}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            );
          },
        ),
        const SizedBox(width: 24),
        const Text('Destination:',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        SizedBox(
          width: 260,
          child: BlocBuilder<FacilityBloc, FacilityState>(
            builder: (context, fState) {
              final ids = fState.savedFacilities
                  .where((f) => f.active == true)
                  .map((f) => f.facilityId)
                  .toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
              return DropdownButtonFormField<String>(
                value: _destinationId,
                isExpanded: true,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                hint: const Text('Select destination'),
                items: ids
                    .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                    .toList(),
                onChanged: _phase == HandoffPhase.none
                    ? (v) {
                        setState(() => _destinationId = v);
                        context.read<HandoffBloc>().add(
                            HandoffDestinationSelected(widget.patientId, v));
                      }
                    : null,
              );
            },
          ),
        ),
      ],
    );

    final canStart = _destinationId != null && _phase == HandoffPhase.none;

    final right = ElevatedButton(
      onPressed: canStart
          ? () {
              widget.onStart(_destinationId);
              setState(() => _phase = HandoffPhase.start);
            }
          : null,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Text('Start'),
      ),
    );

    return Row(
      children: [
        Expanded(child: Align(alignment: Alignment.centerLeft, child: left)),
        const SizedBox(width: 12),
        right,
      ],
    );
  }

  // ───────────────────── read-only circle ─────────────────────
  Widget _stateCircle(String label,
      {required bool lit, required double diameter}) {
    // 0.0 = pure white, 1.0 = same as ring. Try 0.55 for a medium, obvious fill.
    const double kFillStrength = 0.42;

    final ring = MmsColors.ltGreen;
    final fill =
        lit ? Color.lerp(Colors.white, ring, kFillStrength)! : Colors.white;
    final border = lit ? ring : Colors.grey.shade400;

    final text = TextStyle(
      fontWeight: FontWeight.w700,
      color: lit ? MmsColors.dkBlue : MmsColors.black,
      fontSize: 18,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: lit ? 3 : 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Center(child: Text(label, style: text)),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _arrow(double d) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: d * 0.1),
      child: Icon(Icons.arrow_forward, size: d * 0.28, color: MmsColors.black),
    );
  }
}

extension _ColorLighten on Color {
  Color lighten([double amount = .12]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
