import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_coffee/core/constants.dart';
import 'package:mobile_coffee/models/coffee_shop.dart';

class CoffeeShopService {

  Future<List<CoffeeShop>> fetchCoffeeShops({
    required double userLat,
    required double userLng,
    String query = '',
    int? maxPrice,
    List<String> selectedFacilities = const [],
    String sortBy = 'rating',
  }) async {
    try {
      final queryParams = <String, String>{
        'lat': userLat.toString(),
        'lng': userLng.toString(),
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

      final uri = Uri.parse('${getBaseUrl()}/api/coffee-shops?${paramsList.join('&')}');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        var shops = list.map((item) => CoffeeShop.fromJson(item, userLat: userLat, userLng: userLng)).toList();

        if (sortBy == 'nearest') {
          shops.sort((a, b) => a.distance.compareTo(b.distance));
        }

        return shops;
      }
    } catch (e) {
      debugPrint('API error: $e. Backend data is unavailable.');
    }

    return [];
  }
}
