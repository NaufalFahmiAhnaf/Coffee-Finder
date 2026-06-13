import 'dart:math' as math;

import 'package:mobile_coffee/core/constants.dart';

bool isValidCoordinate(double latitude, double longitude) {
  return latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}

double parseFiniteDouble(
  Object? value, {
  required double fallback,
  double? min,
  double? max,
}) {
  final parsed = switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value.trim()),
    _ => null,
  };

  if (parsed == null || !parsed.isFinite) return fallback;
  if (min != null && parsed < min) return fallback;
  if (max != null && parsed > max) return fallback;

  return parsed;
}

double sanitizeLatitude(Object? value, {double fallback = defaultUserLat}) {
  return parseFiniteDouble(value, fallback: fallback, min: -90, max: 90);
}

double sanitizeLongitude(Object? value, {double fallback = defaultUserLng}) {
  return parseFiniteDouble(value, fallback: fallback, min: -180, max: 180);
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  if (!isValidCoordinate(lat1, lon1) || !isValidCoordinate(lat2, lon2)) {
    return 0;
  }

  const r = 6371;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

double _toRadians(double degree) {
  return degree * math.pi / 180;
}
