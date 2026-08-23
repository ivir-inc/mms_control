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
import 'package:flutter_ui/data/model/tccc/tccc_record.dart';
import 'package:flutter_ui/logic/tccc/tccc_bloc.dart';
import 'package:flutter_ui/logic/tccc/tccc_event.dart';
import 'package:flutter_ui/logic/tccc/tccc_state.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/dialogs/dismissible_screen.dart';
import 'package:flutter_ui/presentation/widgets/general/panels/rounded_barless_panel.dart';

/// Small dashboard panel for TCCC / DD1380 (lives on the Patient screen).
/// - Matches your panel pattern (MmsRoundedBarlessPanel)
/// - Whole card is tappable; opens a full viewer popup
/// - Watches DD1380 per-patient via TcccBloc
class TcccDashboardWidget extends StatefulWidget {
  final String patientId;
  const TcccDashboardWidget({super.key, required this.patientId});

  @override
  State<TcccDashboardWidget> createState() => _TcccDashboardWidgetState();
}

class _TcccDashboardWidgetState extends State<TcccDashboardWidget> {
  @override
  void initState() {
    super.initState();
    context.read<TcccBloc>().add(StartWatchingTccc(widget.patientId));
  }

  @override
  void didUpdateWidget(covariant TcccDashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      context.read<TcccBloc>().add(StopWatchingTccc(oldWidget.patientId));
      context.read<TcccBloc>().add(StartWatchingTccc(widget.patientId));
    }
  }

  @override
  void dispose() {
    context.read<TcccBloc>().add(StopWatchingTccc(widget.patientId));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final rec = context.read<TcccBloc>().state.forPatient(widget.patientId);
        if (rec == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DD1380 not available yet.')),
          );
          return;
        }
        final viewerKey = GlobalKey<_TcccViewerScreenState>();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MmsDismissibleScreen(
            ValueKey('TcccViewerScreen-${widget.patientId}'),
            TcccViewerScreen(key: viewerKey, record: rec),
            scrollable: true,
            onAttemptDismiss: () async => true,
          ),
        ));
      },
      child: MmsRoundedBarlessPanel(
        width: 300,
        caption: "TCCC Casualty Card",
        widget: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: BlocBuilder<TcccBloc, TcccState>(
            // avoid flicker from isLoading toggles
            buildWhen: (prev, next) {
              final id = widget.patientId;
              return prev.forPatient(id) != next.forPatient(id);
            },
            builder: (context, state) {
              final rec = state.forPatient(widget.patientId);
              return _PanelContent(record: rec);
            },
          ),
        ),
      ),
    );
  }
}

class _PanelContent extends StatelessWidget {
  final TcccRecord? record;
  const _PanelContent({required this.record});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // shows “Tap for details” when record != null, else “Awaiting DD1380”
        _StatusRow(ready: record != null),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final bool ready;
  const _StatusRow({required this.ready});

  @override
  Widget build(BuildContext context) {
    final label = ready ? 'Tap for details' : 'Awaiting DD1380';

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ready ? Icons.check_box : Icons.hourglass_bottom_outlined,
            size: 18,
            color: MmsColors.black,
          ),
          const SizedBox(width: 6),
          Text(label),
          if (ready) ...[
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

Color _evacColor(EvacPriority? e) {
  switch (e) {
    case EvacPriority.routine:
      return const Color(0xFF2E7D32); // green
    case EvacPriority.priority:
      return const Color(0xFFEDB300); // amber
    case EvacPriority.urgent:
      return const Color(0xFFB00020); // red
    default:
      return Colors.grey;
  }
}

String _evacLabel(EvacPriority? e) {
  switch (e) {
    case EvacPriority.routine:
      return 'ROUTINE';
    case EvacPriority.priority:
      return 'PRIORITY';
    case EvacPriority.urgent:
      return 'URGENT';
    default:
      return '—';
  }
}

/// Full-screen viewer shown in an MmsDismissibleScreen.
/// Dark style + section boxes to match other editors.
class TcccViewerScreen extends StatefulWidget {
  final TcccRecord record;
  const TcccViewerScreen({super.key, required this.record});

  @override
  State<TcccViewerScreen> createState() => _TcccViewerScreenState();
}

class _TcccViewerScreenState extends State<TcccViewerScreen> {
// tiny helpers so we don't pull in intl
  String _fmt2(int n) => n.toString().padLeft(2, '0');
  String _fmtDateTime(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.year}-${_fmt2(dt.month)}-${_fmt2(dt.day)} '
        '${_fmt2(dt.hour)}:${_fmt2(dt.minute)}';
  }

  String _titleCase(String s) =>
      s.isEmpty ? '—' : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final r = widget.record;

    // Outer chrome is fixed; only the panel body (below caption) scrolls.
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
      child: Column(
        children: [
          // Fill the available height with the panel
          Expanded(
            child: MmsRoundedBarlessPanel(
              caption: 'DD1380 Casualty Card - ${r.patientId}',
              // Only this inner content scrolls
              widget: Scrollbar(
                thumbVisibility: false, // default behavior: auto-hide
                trackVisibility: false, // ensure track doesn’t stick around
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Patient
                      _section(
                        'Patient',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _kv('Name', '${r.lastName}, ${r.firstName}'),
                            _kv('Patient ID', r.patientId),
                            _kv('Roster #', r.rosterNumber),
                            _kv('SSAN',
                                r.patientSsan.isNotEmpty ? r.patientSsan : '—'),
                            _kv('Gender', _titleCase(r.gender)),
                            _kv('Date / Time', _fmtDateTime(r.dateTimeLocal)),
                            _kv('Service/Unit', '${r.service} / ${r.unit}'),
                            _kv('Allergies',
                                r.allergies.isEmpty ? 'NKA' : r.allergies),
                          ],
                        ),
                        overlayTopRight: _evacPill(r.evac),
                      ),

                      // Mechanism of Injury
                      _section(
                        'Mechanism of Injury',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: r.moi.entries.map((e) {
                            final on = e.value == true;
                            return _pillSelectable(
                              e.key.toUpperCase(),
                              selected: on,
                              selectedBg: const Color(0xFF0F4C75),
                              selectedBorder: const Color(0xFF7FDBFF),
                            );
                          }).toList(),
                        ),
                      ),

                      // Signs & Symptoms
                      _section(
                        'Signs & Symptoms',
                        Column(
                          children: [
                            _kv('Pulse', r.pulse?.toString() ?? '--'),
                            _kv('BP', r.bp ?? '--'),
                            _kv('Resp', r.resp?.toString() ?? '--'),
                            _kv('SpO2', r.spo2 != null ? '${r.spo2}%' : '--'),
                            _kv('AVPU', r.avpu ?? '--'),
                            _kv('Pain', r.pain != null ? '${r.pain}/10' : '--'),
                          ],
                        ),
                      ),

                      // Treatments (MARCH)
                      _section('Treatments (MARCH)', _treatments(r)),

                      // Tourniquet Sites
                      _section(
                        'Tourniquet Sites',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _tqSitePill('Left Arm', r.tqLeftArm),
                            _tqSitePill('Right Arm', r.tqRightArm),
                            _tqSitePill('Left Leg', r.tqLeftLeg),
                            _tqSitePill('Right Leg', r.tqRightLeg),
                            if (!(r.tqLeftArm.hasData ||
                                r.tqRightArm.hasData ||
                                r.tqLeftLeg.hasData ||
                                r.tqRightLeg.hasData))
                              const Text('—',
                                  style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),

                      if (r.injuryAnnotationList.isNotEmpty)
                        _section(
                          'Injury Notes',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: r.injuryAnnotationList
                                .map((txt) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text('• $txt',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ))
                                .toList(),
                          ),
                        ),

                      // Breathing
                      _section(
                        'Breathing',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (r.oxygenAdministered)
                              _pillSelectable('Oxygen', selected: true),
                            if (r.needleDecompression)
                              _pillSelectable('Needle Decompression',
                                  selected: true),
                            if (r.chestTube)
                              _pillSelectable('Chest Tube', selected: true),
                            if (r.chestSeal)
                              _pillSelectable('Chest Seal', selected: true),
                            if (!(r.oxygenAdministered ||
                                r.needleDecompression ||
                                r.chestTube ||
                                r.chestSeal))
                              const Text('—',
                                  style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),

                      // Dressings
                      _section(
                        'Dressings',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (r.dressingHemostatic)
                              _pillSelectable('Hemostatic', selected: true),
                            if (r.dressingPressure)
                              _pillSelectable('Pressure', selected: true),
                            if (!(r.dressingHemostatic || r.dressingPressure))
                              const Text('—',
                                  style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),

                      // Other
                      _section(
                        'Other',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (r.combatPill)
                              _pillSelectable('Combat Pill', selected: true),
                            if (r.hypothermiaBlanket)
                              _pillSelectable('Hypothermia Blanket',
                                  selected: true),
                            if (r.eyeShieldRight)
                              _pillSelectable('Eye Shield (R)', selected: true),
                            if (r.eyeShieldLeft)
                              _pillSelectable('Eye Shield (L)', selected: true),
                            if (r.splint)
                              _pillSelectable('Splint', selected: true),
                            if ((r.otherType ?? '').isNotEmpty)
                              _pillSelectable(r.otherType!, selected: true),
                            if (!(r.combatPill ||
                                r.hypothermiaBlanket ||
                                r.eyeShieldRight ||
                                r.eyeShieldLeft ||
                                r.splint ||
                                (r.otherType ?? '').isNotEmpty))
                              const Text('—',
                                  style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),

                      // Fluids & Blood
                      _section(
                        'Fluids & Blood',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (r.fluids.isNotEmpty) ...[
                              const Text('Fluids',
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: r.fluids.map((f) {
                                  final vol =
                                      f.volume != null ? ' ${f.volume}mL' : '';
                                  final route = (f.route ?? '').isNotEmpty
                                      ? ' ${f.route}'
                                      : '';
                                  final time = (f.time ?? '').isNotEmpty
                                      ? ' @ ${f.time}'
                                      : '';
                                  return _pillSelectable(
                                      '${f.name}$vol$route$time',
                                      selected: true);
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (r.bloodProducts.isNotEmpty) ...[
                              const Text('Blood Products',
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: r.bloodProducts.map((p) {
                                  final vol =
                                      p.volume != null ? ' ${p.volume}mL' : '';
                                  final route = (p.route ?? '').isNotEmpty
                                      ? ' ${p.route}'
                                      : '';
                                  final time = (p.time ?? '').isNotEmpty
                                      ? ' @ ${p.time}'
                                      : '';
                                  return _pillSelectable(
                                      '${p.name}$vol$route$time',
                                      selected: true);
                                }).toList(),
                              ),
                            ],
                            if (r.fluids.isEmpty && r.bloodProducts.isEmpty)
                              const Text('—',
                                  style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),

                      // Medications
                      _section(
                        'Medications',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (r.medsAnalgesic.isNotEmpty) ...[
                              const Text('Analgesic',
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: r.medsAnalgesic.map((m) {
                                  final d = (m.dosage ?? '').isNotEmpty
                                      ? ' ${m.dosage}'
                                      : '';
                                  final route = (m.route ?? '').isNotEmpty
                                      ? ' ${m.route}'
                                      : '';
                                  final time = (m.time ?? '').isNotEmpty
                                      ? ' @ ${m.time}'
                                      : '';
                                  return _pillSelectable(
                                      '${m.name}$d$route$time',
                                      selected: true);
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (r.medsAntibiotic.isNotEmpty) ...[
                              const Text('Antibiotic',
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: r.medsAntibiotic.map((m) {
                                  final d = (m.dosage ?? '').isNotEmpty
                                      ? ' ${m.dosage}'
                                      : '';
                                  final route = (m.route ?? '').isNotEmpty
                                      ? ' ${m.route}'
                                      : '';
                                  final time = (m.time ?? '').isNotEmpty
                                      ? ' @ ${m.time}'
                                      : '';
                                  return _pillSelectable(
                                      '${m.name}$d$route$time',
                                      selected: true);
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (r.medsOther.isNotEmpty) ...[
                              const Text('Other',
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: r.medsOther.map((m) {
                                  final d = (m.dosage ?? '').isNotEmpty
                                      ? ' ${m.dosage}'
                                      : '';
                                  final route = (m.route ?? '').isNotEmpty
                                      ? ' ${m.route}'
                                      : '';
                                  final time = (m.time ?? '').isNotEmpty
                                      ? ' @ ${m.time}'
                                      : '';
                                  return _pillSelectable(
                                      '${m.name}$d$route$time',
                                      selected: true);
                                }).toList(),
                              ),
                            ],
                            if (r.medsAnalgesic.isEmpty &&
                                r.medsAntibiotic.isEmpty &&
                                r.medsOther.isEmpty)
                              const Text('—',
                                  style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),

                      // Notes
                      _section(
                        'Notes',
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(r.notes,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),

                      // First Responder
                      _section(
                        'First Responder',
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _responderLine(r),
                              style: const TextStyle(color: Colors.white70),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child, {Widget? overlayTopRight}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF163A57),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Stack(
        children: [
          // Main content (title + body)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),

          // Optional floating overlay in the top-right
          if (overlayTopRight != null)
            Positioned(
              top: 6,
              right: 6,
              child: overlayTopRight,
            ),
        ],
      ),
    );
  }

  static Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
              width: 140,
              child: Text(k, style: const TextStyle(color: Colors.white70))),
          Expanded(child: Text(v, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  // --- Treatments (MARCH) ------------------------------------------------------
  Widget _treatments(TcccRecord r) {
    final pills = <Widget>[];

    // Tourniquet summary
    if (r.tqExtremity ||
        r.tqJunctional ||
        r.tqTruncal ||
        (r.tqType?.isNotEmpty ?? false)) {
      final locs = [
        if (r.tqExtremity) 'Extremity',
        if (r.tqJunctional) 'Junctional',
        if (r.tqTruncal) 'Truncal',
      ].join('/');
      final type = (r.tqType?.isNotEmpty ?? false) ? ' ${r.tqType}' : '';
      final label =
          locs.isNotEmpty ? 'Tourniquet ($locs)$type' : 'Tourniquet$type';
      pills.add(_pillSelectable(label, selected: true));
    }

    // Good state → green + check
    if (r.airwayIntact) {
      pills.add(_pillSelectable('Airway Intact', selected: true));
    } else {
      // Bad state → red + warning icon, NO check
      pills.add(_pillSelectable(
        'Airway Compromised',
        selected: true,
        selectedBg: const Color(0xFF6A1B1A),
        selectedBorder: const Color(0xFFEF9A9A),
        showCheck: false,
        leadingIcon: Icons.error_outline_rounded,
      ));
    }

    if (r.npa) pills.add(_pillSelectable('NPA', selected: true));
    if (r.cric) pills.add(_pillSelectable('CRIC', selected: true));
    if (r.ett) pills.add(_pillSelectable('ET Tube', selected: true));
    if (r.sga) pills.add(_pillSelectable('SGA', selected: true));

    // Fluids (one pill per infusion)
    for (final f in r.fluids) {
      final parts = <String>[];
      if (f.name.isNotEmpty) parts.add(f.name);
      if (f.volume != null) parts.add('${f.volume}mL');
      if ((f.route ?? '').isNotEmpty) parts.add(f.route!);
      if ((f.time ?? '').isNotEmpty) parts.add('@ ${f.time}');
      if (parts.isNotEmpty) {
        pills
            .add(_pillSelectable('Fluids: ${parts.join(' ')}', selected: true));
      }
    }

    // Blood products
    for (final b in r.bloodProducts) {
      final parts = <String>[];
      if (b.name.isNotEmpty) parts.add(b.name);
      if (b.volume != null) parts.add('${b.volume}mL');
      if ((b.route ?? '').isNotEmpty) parts.add(b.route!);
      if ((b.time ?? '').isNotEmpty) parts.add('@ ${b.time}');
      if (parts.isNotEmpty) {
        pills.add(_pillSelectable('Blood: ${parts.join(' ')}', selected: true));
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pills.isNotEmpty
          ? pills
          : const [Text('—', style: TextStyle(color: Colors.white70))],
    );
  }

  Widget _pillSelectable(
    String text, {
    required bool selected,
    Color? selectedBg,
    Color? selectedBorder,
    IconData? leadingIcon,
    bool showCheck = true,
  }) {
    final bg = selected
        ? (selectedBg ?? const Color(0xFF0F4C75))
        : const Color(0xFF1B2B3A);
    final border =
        selected ? (selectedBorder ?? const Color(0xFF7FDBFF)) : Colors.white24;
    final txt = Colors.white; // high contrast

    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: selected ? 2 : 1),
        boxShadow: selected
            ? [BoxShadow(color: border.withOpacity(.22), blurRadius: 8)]
            : const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
          ] else if (selected && showCheck) ...[
            const Icon(Icons.check_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: txt,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: false,
      child: MouseRegion(cursor: SystemMouseCursors.basic, child: pill),
    );
  }

  Widget _evacBadge(Color evacColor, String evacText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: evacColor.withOpacity(0.18),
        border: Border.all(color: evacColor, width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: evacColor.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        evacText,
        style: TextStyle(color: evacColor, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _evacPill(EvacPriority p) {
    switch (p) {
      case EvacPriority.routine:
        return _pillSelectable(
          'ROUTINE',
          selected: true,
          selectedBg: const Color(0xFF1B5E20),
          selectedBorder: const Color(0xFFA5D6A7),
        );
      case EvacPriority.priority:
        return _pillSelectable(
          'PRIORITY',
          selected: true,
          selectedBg: const Color(0xFF6D4C00),
          selectedBorder: const Color(0xFFFFE082),
          leadingIcon: Icons.priority_high_rounded,
          showCheck: false,
        );
      case EvacPriority.urgent:
        return _pillSelectable(
          'URGENT',
          selected: true,
          selectedBg: const Color(0xFF6A1B1A),
          selectedBorder: const Color(0xFFEF9A9A),
          leadingIcon: Icons.warning_amber_rounded,
          showCheck: false,
        );
      default:
        return _pillSelectable(
          '—',
          selected: true,
          selectedBg: const Color(0xFF37474F),
          selectedBorder: Colors.white30,
          showCheck: false,
        );
    }
  }

  Widget _tqSitePill(String limb, TqSite site) {
    if (!site.hasData) return const SizedBox.shrink();
    final details = [
      if ((site.type ?? '').isNotEmpty) site.type!,
      if ((site.time ?? '').isNotEmpty) '@ ${site.time}',
    ].join(' ');
    return _pillSelectable(
      '$limb${details.isNotEmpty ? ': $details' : ''}',
      selected: true,
    );
  }

  String _responderLine(TcccRecord r) {
    final first = r.responderFirst.trim();
    final last = r.responderLast.trim();
    final ssan = r.responderSsan.trim();
    final name = [last, first].where((s) => s.isNotEmpty).join(', ');
    if (name.isEmpty && ssan.isEmpty) return '—';
    if (ssan.isEmpty) return name.isEmpty ? '—' : name;
    return '$name (SSAN $ssan)';
  }
}
