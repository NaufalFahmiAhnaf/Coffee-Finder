import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_coffee/core/constants.dart';
import 'package:mobile_coffee/core/location_utils.dart';
import 'package:mobile_coffee/models/coffee_shop.dart';

import 'package:mobile_coffee/core/fallback_data.dart';

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
          lastError = null;
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

    // If all API calls failed, load local fallback data to ensure the app is fully functional
    debugPrint('CoffeeShopService: API connection failed. Loading local fallback data.');
    
    var fallbackShops = fallbackCoffeeShops.map((item) {
      return CoffeeShop.fromJson(
        item,
        userLat: safeUserLat,
        userLng: safeUserLng,
      );
    }).toList();

    // Apply client-side search filtering
    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      fallbackShops = fallbackShops.where((shop) {
        return shop.name.toLowerCase().contains(lowercaseQuery) ||
               shop.address.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    // Apply price filtering
    if (maxPrice != null && maxPrice > 0) {
      fallbackShops = fallbackShops.where((shop) => shop.price <= maxPrice).toList();
    }

    // Apply facility filtering
    if (selectedFacilities.isNotEmpty) {
      fallbackShops = fallbackShops.where((shop) {
        return selectedFacilities.every((facility) => shop.facilities[facility] == true);
      }).toList();
    }

    // Apply sorting
    if (sortBy == 'nearest') {
      fallbackShops.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (sortBy == 'rating') {
      fallbackShops.sort((a, b) => b.rating.compareTo(a.rating));
    }

    lastError = 'Gagal terhubung ke server. Menampilkan data offline.';
    return fallbackShops;
  }
}
