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

import 'tccc_record.dart';

TcccRecord mapSampleToTccc(Map<String, dynamic> src) {
  // Helpers
  String s(dynamic v) => (v ?? '').toString();
  int? i(dynamic v) => (v == null) ? null : int.tryParse(v.toString());
  bool b(dynamic v) => v == true;
  String? nonEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  // Parse "28-SEP-18" + "1330 L" -> DateTime
  DateTime? parseDayMonYYTimeLocal(String? d, String? t) {
    if (d == null || d.isEmpty) return null;
    final months = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MAY': 5,
      'JUN': 6,
      'JUL': 7,
      'AUG': 8,
      'SEP': 9,
      'OCT': 10,
      'NOV': 11,
      'DEC': 12,
    };
    try {
      final parts = d.split('-'); // 28-SEP-18
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final mon = months[parts[1].toUpperCase()] ?? 0;
      final year = 2000 + int.parse(parts[2]);
      int hh = 0, mm = 0;
      if (t != null && t.isNotEmpty) {
        final clean = t.replaceAll('L', '').trim(); // "1330"
        if (clean.length >= 3) {
          hh = int.parse(clean.substring(0, clean.length - 2));
          mm = int.parse(clean.substring(clean.length - 2));
        }
      }
      return DateTime(year, mon, day, hh, mm);
    } catch (_) {
      return null;
    }
  }

  final signs = (src['Signs and Symptons']?['Record'] ?? {}) as Map;
  final mech = (src['Mechanism Of Injury'] ?? {}) as Map;

  final treat = (src['Treatments'] ?? {}) as Map;
  final tq = (treat['C'] ?? {}) as Map;
  final airway = (treat['A'] ?? {}) as Map;

  // sample uses "C:" then "Fluid"
  final circ2 = (treat['C:']?['Fluid'] ?? {}) as Map;

  final dt = parseDayMonYYTimeLocal(s(src['Date']), s(src['Time']));

  // Be tolerant about BP key casing/placement
  final bpVal =
      s(signs['BP'] ?? signs['Bp'] ?? signs['BloodPressure'] ?? src['BP'])
          .trim();

  // SpO2 might be 0..1 or 0..100 in other sources; here it seems integer already
  int? spo2Int(dynamic v) {
    if (v == null) return null;
    if (v is num) return v <= 1 ? (v * 100).round() : v.round();
    final n = num.tryParse(v.toString());
    if (n == null) return null;
    return n <= 1 ? (n * 100).round() : n.round();
  }

  // ---- Build fluids list from the sample’s single fluid block ----------
  final sampleFluids = <Infusion>[];
  final fName = s(circ2['Name']).trim();
  final fVol = i(circ2['Volume']);
  final fRoute = s(circ2['Route']).trim();
  final fTime = s(circ2['Time']).trim();
  final hasAny =
      fName.isNotEmpty || fVol != null || fRoute.isNotEmpty || fTime.isNotEmpty;
  if (hasAny) {
    sampleFluids.add(Infusion(
      name: fName,
      volume: fVol,
      route: nonEmpty(fRoute),
      time: nonEmpty(fTime),
    ));
  }

  return TcccRecord(
    patientId: s(src['Patient ID']),
    rosterNumber: s(src['Battle Roster Number']),

    // use EvacPriority mapper
    evac: evacFromAny(s(src['EVAC routine'] ?? src['EVAC'] ?? src['Evac'])),

    lastName: s(src['Last Name']),
    firstName: s(src['First Name']),
    service: s(src['Service']),
    unit: s(src['Unit']),
    allergies: s(src['Allergies']),

    dateTimeLocal: dt,

    // Mechanism of Injury -> Map<String,bool>
    moi: mech.map((k, v) => MapEntry(k.toString(), b(v))),

    // Vitals
    pulse: i(signs['Pulse']),
    bp: bpVal.isEmpty ? null : bpVal,
    resp: i(signs['Respiratory']),
    spo2: spo2Int(signs['O2']),
    avpu: s(signs['AVPU']).trim().isEmpty ? null : s(signs['AVPU']),
    pain: i(signs['Pain']),

    // Treatments - TQ
    tqExtremity: b(tq['TQ- Extremity']),
    tqJunctional: b(tq['Junctional']),
    tqTruncal: b(tq['Truncal']),
    tqType: () {
      final v = s(tq['Type']).trim();
      return v.isEmpty ? null : v;
    }(),

    // Airway
    airwayIntact: b(airway['Intact']),
    npa: b(airway['NPA']),
    cric: b(airway['CRIC']),
    ett: b(airway['ET-Tube']),
    sga: b(airway['SGA']),

    fluids: sampleFluids,
    bloodProducts: const [],

    // Notes & responder
    notes: s(src['NOTES']),
    responderFirst: s(src['First Responder']?['First Name']),
    responderLast: s(src['First Responder']?['Last Name']),
    responderSsan: s(src['First Responder']?['SSAN']),
  );
}
