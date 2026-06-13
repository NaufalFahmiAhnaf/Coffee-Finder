import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double defaultUserLat = -7.250445;
const double defaultUserLng = 112.768845;

String getBaseUrl() {
  return getBaseUrls().first;
}

List<String> getBaseUrls() {
  const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (configuredBaseUrl.isNotEmpty) {
    return [_cleanBaseUrl(configuredBaseUrl)];
  }

  if (kIsWeb) {
    return const ['http://127.0.0.1:8000'];
  }

  return const ['http://127.0.0.1:8000', 'http://10.0.2.2:8000'];
}

String _cleanBaseUrl(String value) {
  return value.replaceFirst(RegExp(r'/$'), '');
}

const Map<String, IconData> facilityIcons = {
  'wifi': Icons.wifi,
  'outdoor': Icons.wb_sunny,
  'ac': Icons.ac_unit,
  'sockets': Icons.power,
  'smoking_room': Icons.smoking_rooms,
};

const Map<String, String> facilityLabels = {
  'wifi': 'Wifi',
  'outdoor': 'Outdoor',
  'ac': 'AC',
  'sockets': 'Colokan',
  'smoking_room': 'Smoking',
};
