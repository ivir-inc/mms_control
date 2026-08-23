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

// Stable, contrast-aware, non-colliding color allocator for Flutter (Dart 3.7+)
// MIT License

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ===== Hash =====
int _hash32(String s) {
  int h = 0x811c9dc5;
  for (int i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    h = (h * 0x01000193) & 0xFFFFFFFF; // FNV-1a 32-bit
  }
  return h & 0xFFFFFFFF;
}

// ===== Color spaces (OKLCH/OKLAB) =====
double _deg2rad(double d) => d * math.pi / 180.0;

class _OKLCH {
  final double L, C, h;
  const _OKLCH(this.L, this.C, this.h);
}

class _OKLAB {
  final double L, a, b;
  const _OKLAB(this.L, this.a, this.b);
}

_OKLAB _oklchToOklab(_OKLCH lch) {
  final hr = _deg2rad(lch.h);
  return _OKLAB(lch.L, math.cos(hr) * lch.C, math.sin(hr) * lch.C);
}

List<double> _oklabToLinearSRGB(_OKLAB lab) {
  final l_ = lab.L + 0.3963377774 * lab.a + 0.2158037573 * lab.b;
  final m_ = lab.L - 0.1055613458 * lab.a - 0.0638541728 * lab.b;
  final s_ = lab.L - 0.0894841775 * lab.a - 1.2914855480 * lab.b;
  final l = l_ * l_ * l_;
  final m = m_ * m_ * m_;
  final s = s_ * s_ * s_;
  final r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
  final g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
  final b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;
  return [r, g, b]; // linear sRGB
}

bool _inGamut(List<double> lin) => lin.every((c) => c >= 0.0 && c <= 1.0);

// Relative luminance from linear sRGB (WCAG)
double _relLuminanceLin(List<double> lin) =>
    0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2];

// sRGB encoding -> 0..255
int _encode8(double x) {
  final y = x.clamp(0.0, 1.0);
  final e = y <= 0.0031308 ? 12.92 * y : 1.055 * math.pow(y, 1 / 2.4) - 0.055;
  return (e * 255.0).round().clamp(0, 255);
}

class _SRGBOut {
  final List<double> lin; // linear sRGB 0..1
  final Color color; // encoded sRGB 0..255
  final bool inGamut;
  final double luminance; // relative luminance of color
  _SRGBOut(this.lin, this.color, this.inGamut, this.luminance);
}

_SRGBOut _oklchToSRGBClamped(_OKLCH lch) {
  double low = 0, high = lch.C, mid = lch.C;
  bool ok = false;
  List<double> best = [0, 0, 0];
  for (int i = 0; i < 18; i++) {
    // binary search chroma to fit gamut
    mid = (low + high) / 2.0;
    final lab = _oklchToOklab(_OKLCH(lch.L, mid, lch.h));
    final lin = _oklabToLinearSRGB(lab);
    if (_inGamut(lin)) {
      ok = true;
      best = lin;
      low = mid;
    } else {
      high = mid;
    }
  }
  final lin =
      ok ? best : _oklabToLinearSRGB(_oklchToOklab(_OKLCH(lch.L, 0, lch.h)));
  final lum = _relLuminanceLin(lin);
  return _SRGBOut(
      lin,
      Color.fromARGB(255, _encode8(lin[0]), _encode8(lin[1]), _encode8(lin[2])),
      ok,
      lum);
}

// Contrast ratio (color vs pure white background)
double _contrastVsWhite(double lum) => (1.0 + 0.05) / (lum + 0.05);

// Perceptual distance in OKLab (≈ ΔE)
double _deltaEok(_OKLAB a, _OKLAB b) {
  final dL = a.L - b.L, da = a.a - b.a, db = a.b - b.b;
  return math.sqrt(dL * dL + da * da + db * db);
}

// Golden-angle candidates with small L/C wiggles (to escape near-collisions)
Iterable<_OKLCH> _candidates(_OKLCH base) sync* {
  const phi = 137.50776405003785; // golden angle
  const Lw = [0.0, -0.08, 0.08, -0.12, 0.12];
  const Cw = [0.0, 0.02, -0.02, 0.04, -0.04];
  int k = 0;
  while (true) {
    final hue = (base.h + k * phi) % 360;
    final L =
        (base.L + Lw[k % Lw.length]).clamp(0.35, 0.70); // keep away from white
    final C = (base.C + Cw[k % Cw.length]).clamp(0.04, 0.22);
    yield _OKLCH(L.toDouble(), C.toDouble(), hue.toDouble());
    k++;
  }
}

class StableColorAllocator {
  final double minDeltaE; // global distinctness
  final double minDeltaENeighbor; // extra spacing vs immediate neighbor
  final double minContrastOnWhite; // WCAG contrast vs pure white

  final Map<String, _OKLCH> _assign = {}; // id -> OKLCH
  final Map<String, _OKLAB> _assignLAB = {}; // id -> OKLab

  StableColorAllocator({
    this.minDeltaE = 0.08,
    this.minDeltaENeighbor = 0.12,
    this.minContrastOnWhite = 3.5, // good for colored text/badges on white
  });

  // Make a stable base candidate from the ID
  _OKLCH _base(String id) {
    final h1 = _hash32(id);
    final h2 = _hash32('$id::v');
    final h = (h1 % 360).toDouble();
    final L = 0.52 + ((h2 & 3) - 1) * 0.03; // 0.49..0.55 (darker for white UI)
    final C = 0.15 + ((h2 >> 2) % 30) / 1000.0; // 0.15..0.18
    return _OKLCH(L, C, h);
  }

  // Darken (decrease L) until contrast vs white is met, preserving C/h as much as possible
  _OKLCH _meetContrastOnWhite(_OKLCH lch) {
    final initial = _oklchToSRGBClamped(lch);
    if (_contrastVsWhite(initial.luminance) >= minContrastOnWhite) return lch;

    double lo = 0.20, hi = lch.L; // search lower L to get darker color
    _OKLCH best = lch;
    for (int i = 0; i < 12; i++) {
      final mid = (lo + hi) / 2.0;
      final test = _OKLCH(mid, lch.C, lch.h);
      final srgb = _oklchToSRGBClamped(test);
      final cr = _contrastVsWhite(srgb.luminance);
      if (cr >= minContrastOnWhite) {
        best = test;
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return best;
  }

  // PUBLIC: get a stable, contrast-safe, distinct color for a source ID
  Color getColor(String id,
      {String? neighborId, List<String> visibleIds = const []}) {
    final existing = _assign[id];
    if (existing != null) {
      final srgb = _oklchToSRGBClamped(existing);
      return srgb.color;
    }

    final base = _base(id);
    final neighborLab = neighborId != null ? _assignLAB[neighborId] : null;
    final assignedLabs = _assignLAB.values.toList(growable: false);
    final visibleLabs = visibleIds
        .map((v) => _assignLAB[v])
        .whereType<_OKLAB>()
        .toList(growable: false);

    _OKLCH? chosen;

    // stages: (tries, globalΔE, neighborΔE)
    final stages = [
      (64, minDeltaE, minDeltaENeighbor),
      (128, minDeltaE * 0.95, minDeltaENeighbor * 0.95),
      (256, minDeltaE * 0.90, minDeltaENeighbor * 0.90),
    ];

    outer:
    for (final st in stages) {
      int k = 0;
      final maxTries = st.$1;
      final gD = st.$2;
      final nD = st.$3;
      for (final cand0 in _candidates(base)) {
        final cand = _meetContrastOnWhite(cand0); // ensure contrast vs white
        final lab = _oklchToOklab(cand);

        bool ok = true;
        for (final v in assignedLabs) {
          if (_deltaEok(lab, v) < gD) {
            ok = false;
            break;
          }
        }
        if (!ok) {
          if (++k >= maxTries)
            break;
          else
            continue;
        }

        if (neighborLab != null && _deltaEok(lab, neighborLab) < nD) {
          if (++k >= maxTries)
            break;
          else
            continue;
        }

        for (final v in visibleLabs) {
          if (_deltaEok(lab, v) < gD * 1.05) {
            ok = false;
            break;
          }
        }
        if (!ok) {
          if (++k >= maxTries)
            break;
          else
            continue;
        }

        chosen = cand;
        break outer;
      }
    }

    chosen ??= _meetContrastOnWhite(_OKLCH(base.L, 0.06,
        base.h)); // desaturated fallback (still distinct vs white)

    final lab = _oklchToOklab(chosen!);
    _assign[id] = chosen!;
    _assignLAB[id] = lab;

    final srgb = _oklchToSRGBClamped(chosen!);
    return srgb.color;
  }

  // Serialization for persistence
  Map<String, dynamic> toJson() => {
        for (final e in _assign.entries)
          e.key: {'L': e.value.L, 'C': e.value.C, 'h': e.value.h}
      };
  void loadFromJson(Map<String, dynamic> json) {
    _assign.clear();
    _assignLAB.clear();
    json.forEach((key, v) {
      final lch = _OKLCH((v['L'] as num).toDouble(), (v['C'] as num).toDouble(),
          (v['h'] as num).toDouble());
      _assign[key] = lch;
      _assignLAB[key] = _oklchToOklab(lch);
    });
  }
}

// Optional helper: choose black or white text over a given background color to hit ~AA contrast
TextStyle foregroundOn(Color bg, {TextStyle? base, double minCR = 4.5}) {
  double srgbToLin(int c) {
    final x = c / 255.0;
    return x <= 0.04045
        ? x / 12.92
        : math.pow((x + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = srgbToLin(bg.red), g = srgbToLin(bg.green), b = srgbToLin(bg.blue);
  final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  final crWhite = (lum + 0.05) / (1.0 + 0.05);
  final crBlack = (1.0 + 0.05) / (lum + 0.05);
  final chosen = (crBlack >= crWhite) ? Colors.black : Colors.white;
  return (base ?? const TextStyle()).copyWith(color: chosen);
}
