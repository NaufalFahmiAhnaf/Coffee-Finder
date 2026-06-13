import 'package:mobile_coffee/core/constants.dart';
import 'package:mobile_coffee/core/location_utils.dart';

class CoffeeShop {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int price;
  final Map<String, bool> facilities;
  final double distance;
  final String? imageUrl;

  CoffeeShop({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.price,
    required this.facilities,
    required this.distance,
    this.imageUrl,
  });

  factory CoffeeShop.fromJson(
    Map<String, dynamic> json, {
    double userLat = defaultUserLat,
    double userLng = defaultUserLng,
  }) {
    final lat = sanitizeLatitude(json['latitude']);
    final lng = sanitizeLongitude(json['longitude']);
    final safeUserLat = sanitizeLatitude(userLat);
    final safeUserLng = sanitizeLongitude(userLng);

    return CoffeeShop(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Kafe Tanpa Nama',
      address: json['address']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
      rating: parseFiniteDouble(json['rating'], fallback: 0.0),
      price: parseFiniteDouble(json['price'], fallback: 0.0).toInt(),
      facilities: Map<String, bool>.from(json['facilities'] ?? {}),
      distance: calculateDistance(safeUserLat, safeUserLng, lat, lng),
      imageUrl: json['image_url']?.toString(),
    );
  }
}
