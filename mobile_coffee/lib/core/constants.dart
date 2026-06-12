import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double defaultUserLat = -7.250445;
const double defaultUserLng = 112.768845;

String getBaseUrl() {
  return kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';
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
