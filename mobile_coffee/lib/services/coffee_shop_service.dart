import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_coffee/core/constants.dart';
import 'package:mobile_coffee/core/location_utils.dart';
import 'package:mobile_coffee/models/coffee_shop.dart';

class CoffeeShopService {
  String? lastError;

  Future<List<CoffeeShop>> fetchCoffeeShops({
    required double userLat,
    required double userLng,
    String query = '',
    int? maxPrice,
    List<String> selectedFacilities = const [],
    String sortBy = 'rating',
  }) async {
    lastError = null;
    final safeUserLat = sanitizeLatitude(userLat);
    final safeUserLng = sanitizeLongitude(userLng);
    final queryParams = <String, String>{
      'lat': safeUserLat.toString(),
      'lng': safeUserLng.toString(),
      if (query.isNotEmpty) 'q': query,
      if (maxPrice != null && maxPrice > 0) 'max_price': maxPrice.toString(),
      if (sortBy != 'nearest') 'sort_by': sortBy,
    };

    final paramsList = <String>[];
    queryParams.forEach((key, value) {
      paramsList.add('$key=${Uri.encodeQueryComponent(value)}');
    });

    for (final facility in selectedFacilities) {
      paramsList.add('facilities[]=${Uri.encodeQueryComponent(facility)}');
    }

    final queryString = paramsList.join('&');

    for (final baseUrl in getBaseUrls()) {
      try {
        final uri = Uri.parse('$baseUrl/api/coffee-shops?$queryString');
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> list = data['data'] ?? [];
          var shops = list
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => CoffeeShop.fromJson(
                  item,
                  userLat: safeUserLat,
                  userLng: safeUserLng,
                ),
              )
              .toList();

          if (sortBy == 'nearest') {
            shops.sort((a, b) => a.distance.compareTo(b.distance));
          }

          return shops;
        }
        lastError = 'Server returned ${response.statusCode} from $baseUrl';
        debugPrint('API error: ${response.statusCode} from ${uri.toString()}');
      } catch (e) {
        lastError = 'Cannot connect to $baseUrl';
        debugPrint('API error from $baseUrl: $e');
      }
    }

    lastError = 'Cannot load cafes. Tried: ${getBaseUrls().join(', ')}';
    debugPrint('Backend data is unavailable. $lastError');
    return [];
  }
}
