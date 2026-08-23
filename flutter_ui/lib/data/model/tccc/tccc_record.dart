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

import 'package:equatable/equatable.dart';

enum EvacPriority { routine, priority, urgent, unknown }

EvacPriority evacFromAny(dynamic v) {
  final s = (v ?? '').toString().trim().toLowerCase();
  if (s.contains('routine')) return EvacPriority.routine;
  if (s.contains('priority')) return EvacPriority.priority;
  if (s.contains('urgent')) return EvacPriority.urgent;
  return EvacPriority.unknown;
}

/// Simple DTO for IV fluids / blood products
class Infusion extends Equatable {
  final String name;
  final int? volume; // mL
  final String? route; // e.g., IV/IO
  final String? time; // free text like "14:30"
  const Infusion({required this.name, this.volume, this.route, this.time});

  @override
  List<Object?> get props => [name, volume, route, time];
}

/// Simple DTO for medications
class Medication extends Equatable {
  final String name;
  final String? dosage;
  final String? route;
  final String? time;
  const Medication({required this.name, this.dosage, this.route, this.time});

  @override
  List<Object?> get props => [name, dosage, route, time];
}

class TcccRecord extends Equatable {
  final String patientId;
  final String rosterNumber;
  final EvacPriority evac;
  final String patientSsan;
  final String gender;

  final String lastName;
  final String firstName;
  final String service;
  final String unit;
  final String allergies;

  final DateTime? dateTimeLocal;

  // Mechanism of Injury (keyed flags)
  final Map<String, bool> moi;

  // Vitals
  final int? pulse;
  final String? bp;
  final int? resp;
  final int? spo2;
  final String? avpu;
  final int? pain;

  // Tourniquets
  final bool tqExtremity;
  final bool tqJunctional;
  final bool tqTruncal;
  final String? tqType;

  // Airway (flattened from treatmentAirway)
  final bool airwayIntact;
  final bool npa;
  final bool cric;
  final bool ett;
  final bool sga;

  // Breathing (from treatmentBreathing)
  final bool oxygenAdministered;
  final bool needleDecompression;
  final bool chestTube;
  final bool chestSeal;

  // Dressings (from treatmentCirculatoryDressing)
  final bool dressingHemostatic;
  final bool dressingPressure;

  // Fluids & blood products
  final List<Infusion> fluids;
  final List<Infusion> bloodProducts;

  // Medications
  final List<Medication> medsAnalgesic;
  final List<Medication> medsAntibiotic;
  final List<Medication> medsOther;

  final String notes;
  final String responderLast;
  final String responderFirst;
  final String responderSsan;

  // Injury annotation (per-limb tourniquet sites + freeform list)
  final TqSite tqRightArm;
  final TqSite tqLeftArm;
  final TqSite tqRightLeg;
  final TqSite tqLeftLeg;
  final List<String> injuryAnnotationList;

  // Other treatments / adjuncts
  final bool combatPill;
  final bool hypothermiaBlanket;
  final bool eyeShieldRight;
  final bool eyeShieldLeft;
  final bool splint;
  final String? otherType; // free-text "type"

  const TcccRecord({
    required this.patientId,
    required this.rosterNumber,
    required this.evac,
    this.patientSsan = '',
    this.gender = '',
    required this.lastName,
    required this.firstName,
    required this.service,
    required this.unit,
    required this.allergies,
    this.dateTimeLocal,
    required this.moi,
    this.pulse,
    this.bp,
    this.resp,
    this.spo2,
    this.avpu,
    this.pain,
    this.tqExtremity = false,
    this.tqJunctional = false,
    this.tqTruncal = false,
    this.tqType,
    this.airwayIntact = true,
    this.npa = false,
    this.cric = false,
    this.ett = false,
    this.sga = false,
    this.oxygenAdministered = false,
    this.needleDecompression = false,
    this.chestTube = false,
    this.chestSeal = false,
    this.dressingHemostatic = false,
    this.dressingPressure = false,
    this.fluids = const [],
    this.bloodProducts = const [],
    this.medsAnalgesic = const [],
    this.medsAntibiotic = const [],
    this.medsOther = const [],
    this.notes = '',
    this.responderLast = '',
    this.responderFirst = '',
    this.responderSsan = '',
    this.tqRightArm = const TqSite(),
    this.tqLeftArm = const TqSite(),
    this.tqRightLeg = const TqSite(),
    this.tqLeftLeg = const TqSite(),
    this.injuryAnnotationList = const [],
    this.combatPill = false,
    this.hypothermiaBlanket = false,
    this.eyeShieldRight = false,
    this.eyeShieldLeft = false,
    this.splint = false,
    this.otherType,
  });

  factory TcccRecord.fromApiJson(Map<String, dynamic> j) {
    Map<String, bool> parseMoi(Map? m) =>
        (m ?? const {}).map((k, v) => MapEntry(k.toString(), v == true));

    int? toInt(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    String? nonEmpty(dynamic v) {
      final s = (v ?? '').toString().trim();
      return s.isEmpty ? null : s;
    }

    TqSite parseTqSite(Map? m) => TqSite(
          type: nonEmpty(m?['type']),
          time: nonEmpty(m?['time']),
        );

    final inj = (j['injuryAnnotation'] as Map?) ?? const {};
    final rightArm = parseTqSite(inj['rightArmTourniquet'] as Map?);
    final leftArm = parseTqSite(inj['leftArmTourniquet'] as Map?);
    final rightLeg = parseTqSite(inj['rightLegTourniquet'] as Map?);
    final leftLeg = parseTqSite(inj['leftLegTourniquet'] as Map?);

    final annList = (inj['annotationList'] is List)
        ? (inj['annotationList'] as List).map((e) => e.toString()).toList()
        : const <String>[];

    int? parseSpo2(dynamic v) {
      if (v == null) return null;
      if (v is num) return v <= 1.0 ? (v * 100).round() : v.round();
      final n = num.tryParse(v.toString());
      if (n == null) return null;
      return n <= 1.0 ? (n * 100).round() : n.round();
    }

    Map ss = const {};
    final ssList = j['signsSymptoms'];
    if (ssList is List) {
      // take the last entry (assumed most recent)
      for (final e in ssList) {
        if (e is Map) ss = e;
      }
    }

    int? _nzInt(dynamic v) {
      final n = toInt(v);
      if (n == null) return null;
      return n > 0 ? n : null; // treat 0 as unknown
    }

    String? _bpFromSs() {
      final sys = _nzInt(ss['systolicBloodPressure']);
      final dia = _nzInt(ss['diastolicBloodPressure']);
      if (sys != null && dia != null) return '$sys/$dia';
      return null;
    }

    String? _avpuFromLevel() {
      final n = toInt(ss['alertnessLevel']);
      switch (n) {
        case 1:
          return 'A';
        case 2:
          return 'V';
        case 3:
          return 'P';
        case 4:
          return 'U';
        default:
          return null; // unknown / 0
      }
    }

    List<Infusion> parseInfusions(dynamic arr) {
      if (arr is! List) return const [];
      return arr.map((e) {
        final m = (e is Map<String, dynamic>) ? e : const <String, dynamic>{};
        return Infusion(
          name: (m['name'] ?? '').toString(),
          volume: toInt(m['volume']),
          route: nonEmpty(m['route']),
          time: nonEmpty(m['time']),
        );
      }).toList();
    }

    List<Medication> parseMeds(dynamic arr) {
      if (arr is! List) return const [];
      return arr.map((e) {
        final m = (e is Map<String, dynamic>) ? e : const <String, dynamic>{};
        return Medication(
          name: (m['name'] ?? '').toString(),
          dosage: nonEmpty(m['dosage']),
          route: nonEmpty(m['route']),
          time: nonEmpty(m['time']),
        );
      }).toList();
    }

    // flatten treatmentAirway
    final aw = (j['treatmentAirway'] as Map?) ?? const {};

    // flatten tourniquets
    final tq = (j['treatmentCirculatoryTourniquet'] as Map?) ?? const {};
    final tqType = [
      (tq['extremityType'] ?? '').toString(),
      (tq['junctionalType'] ?? '').toString(),
      (tq['truncalType'] ?? '').toString(),
    ].where((e) => e.trim().isNotEmpty).join('/');

    // breathing & dressings
    final br = (j['treatmentBreathing'] as Map?) ?? const {};
    final dr = (j['treatmentCirculatoryDressing'] as Map?) ?? const {};
    final oth = (j['treatmentOther'] as Map?) ?? const {};

    // date/time -> local DateTime
    DateTime? dt() {
      final d = (j['date'] ?? '').toString(); // "2024-10-10"
      final t = (j['time'] ?? '').toString(); // "14:30"
      if (d.isEmpty || t.isEmpty) return null;
      return DateTime.tryParse('$d $t'); // tolerant
    }

    return TcccRecord(
      patientId: (j['patientId'] ?? '').toString(),
      rosterNumber: (j['battleRosterNumber'] ?? '').toString(),
      evac: evacFromAny(j['evacuationLevelRequest'] ?? j['evac'] ?? ''),
      patientSsan: (j['socialSecurityAccountNumber'] ?? '').toString(),
      gender: (j['gender'] ?? '').toString(),
      lastName: (j['lastName'] ?? '').toString(),
      firstName: (j['firstName'] ?? '').toString(),
      service: (j['service'] ?? '').toString(),
      unit: (j['unit'] ?? '').toString(),
      allergies: (j['allergies'] ?? '').toString(),
      dateTimeLocal: dt(),
      moi: parseMoi(j['mechanismOfInjury'] as Map?),

      // Vitals with signsSymptoms override
      pulse: _nzInt(ss['pulse']) ?? toInt(j['pulse']),
      bp: _bpFromSs() ?? nonEmpty(j['bp']),
      resp:
          _nzInt(ss['respiratoryRate']) ?? toInt(j['resp'] ?? j['respiratory']),
      spo2:
          _nzInt(ss['pulseOxO2Saturation']) ?? parseSpo2(j['spo2'] ?? j['o2']),
      avpu: _avpuFromLevel() ?? nonEmpty(j['avpu']),
      pain: toInt(ss['painScale']) ?? toInt(j['pain']),

      // Tourniquets
      tqExtremity: (tq['extremity'] == true),
      tqJunctional: (tq['junctional'] == true),
      tqTruncal: (tq['truncal'] == true),
      tqType: nonEmpty(tqType),

      tqRightArm: rightArm,
      tqLeftArm: leftArm,
      tqRightLeg: rightLeg,
      tqLeftLeg: leftLeg,
      injuryAnnotationList: annList,

      // Airway
      airwayIntact: aw['intact'] != false,
      npa: aw['nasopharyngealAirway'] == true,
      cric: aw['cricothyroidotomy'] == true,
      ett: aw['endotrachealTube'] == true,
      sga: aw['supraglotticAirway'] == true,

      // Breathing
      oxygenAdministered: br['oxygenAdministered'] == true,
      needleDecompression: br['needleDecompression'] == true,
      chestTube: br['chestTube'] == true,
      chestSeal: br['chestSeal'] == true,

      // Dressings
      dressingHemostatic: dr['hemostatic'] == true,
      dressingPressure: dr['pressure'] == true,

      // Other treatments
      combatPill: oth['combatPill'] == true,
      hypothermiaBlanket: oth['hypothermiaBlanket'] == true,
      eyeShieldRight: oth['eyeShieldRight'] == true,
      eyeShieldLeft: oth['eyeShieldLeft'] == true,
      splint: oth['splint'] == true,
      otherType: nonEmpty(oth['type']),

      // arrays
      fluids: parseInfusions(j['treatmentFluids']),
      bloodProducts: parseInfusions(j['treatmentBloodProducts']),

      // meds
      medsAnalgesic: parseMeds(j['treatmentMedicationsAnalgesic']),
      medsAntibiotic: parseMeds(j['treatmentMedicationsAntibiotic']),
      medsOther: parseMeds(j['treatmentMedicationsOther']),

      notes: (j['treatmentNotes'] ?? j['notes'] ?? '').toString(),
      responderLast: (j['responder']?['lastName'] ?? '').toString(),
      responderFirst: (j['responder']?['firstName'] ?? '').toString(),
      responderSsan:
          (j['responder']?['socialSecurityAccountNumber'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
        patientId,
        rosterNumber,
        evac,
        lastName,
        firstName,
        service,
        unit,
        allergies,
        dateTimeLocal,
        moi,
        pulse,
        bp,
        resp,
        spo2,
        avpu,
        pain,
        tqExtremity,
        tqJunctional,
        tqTruncal,
        tqType,
        airwayIntact,
        npa,
        cric,
        ett,
        sga,
        oxygenAdministered,
        needleDecompression,
        chestTube,
        chestSeal,
        dressingHemostatic,
        dressingPressure,
        fluids,
        bloodProducts,
        medsAnalgesic,
        medsAntibiotic,
        medsOther,
        notes,
        responderLast,
        responderFirst,
        responderSsan,
        tqRightArm,
        tqLeftArm,
        tqRightLeg,
        tqLeftLeg,
        injuryAnnotationList,
        combatPill,
        hypothermiaBlanket,
        eyeShieldRight,
        eyeShieldLeft,
        splint,
        otherType,
        patientSsan,
        gender,
      ];
}

class TqSite extends Equatable {
  final String? type; // e.g. "strap"
  final String? time; // e.g. "14:45"
  const TqSite({this.type, this.time});
  bool get hasData =>
      (type != null && type!.trim().isNotEmpty) ||
      (time != null && time!.trim().isNotEmpty);

  @override
  List<Object?> get props => [type, time];
}
