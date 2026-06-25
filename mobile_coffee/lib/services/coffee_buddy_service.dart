import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_coffee/core/location_utils.dart';
import 'package:mobile_coffee/models/coffee_shop.dart';
import 'package:mobile_coffee/services/coffee_shop_service.dart';
import 'package:mobile_coffee/services/notification_service.dart';

class CoffeeBuddyService {
  static final CoffeeBuddyService _instance = CoffeeBuddyService._internal();
  factory CoffeeBuddyService() => _instance;
  CoffeeBuddyService._internal();

  final CoffeeShopService _shopService = CoffeeShopService();
  StreamSubscription<Position>? _positionSubscription;
  
  // Keep track of last notified timestamp for each coffee shop to prevent spamming (cooldown: 10 minutes)
  final Map<String, DateTime> _notifiedShops = {};
  
  // Persistent notification ID
  static const int _persistentCardId = 999;
  
  // Cooldown duration (10 minutes)
  static const Duration _cooldown = Duration(minutes: 10);
  
  // Proximity range (300 meters, which is 0.3 km)
  static const double _proximityLimitKm = 0.3;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // Start the background tracking and lockscreen widgets
  Future<void> startTracking() async {
    if (_isTracking) return;

    // 1. Request location permission if not granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('CoffeeBuddy: Location permission denied. Cannot start tracking.');
        return;
      }
    }

    // 2. Setup Foreground Service Notification Settings for Android
    // This allows the geolocator stream to run persistently in the background.
    late final LocationSettings locationSettings;
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 30, // Trigger updates every 30 meters of movement
        intervalDuration: const Duration(seconds: 15),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: '☕ CoffeeBuddy Radar Aktif',
          notificationText: 'CoffeeTrack sedang melacak kedai kopi terdekat...',
          notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 30,
      );
    }

    // 3. Initialize dynamic persistent lockscreen card immediately with a welcoming message
    await _showInitialWidgetCard();

    // 4. Start listening to the location stream
    _isTracking = true;
    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _onLocationUpdated(position);
    }, onError: (error) {
      debugPrint('CoffeeBuddy: Location stream error: $error');
    });

    debugPrint('CoffeeBuddy: Proximity background tracking started.');
  }

  // Stop background tracking
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    
    // Remove the persistent card from status bar
    await NotificationService.cancel(_persistentCardId);
    debugPrint('CoffeeBuddy: Proximity background tracking stopped.');
  }

  // Initialize lockscreen card with a default welcome message
  Future<void> _showInitialWidgetCard() async {
    const String title = '☕ CoffeeBuddy Live Card';
    const String body = 'Mencari kopi terbaik di sekitar Anda...\nSilakan berjalan-jalan atau tekan tombol Acak di bawah ini!';
    
    // Default payload pointing to center of Surabaya
    final defaultPayload = json.encode({
      'name': 'Pusat Surabaya',
      'latitude': -7.250445,
      'longitude': 112.768845,
    });

    await NotificationService.showPersistentNotification(
      id: _persistentCardId,
      title: title,
      body: body,
      payload: defaultPayload,
    );
  }

  // Handle incoming GPS coordinates
  void _onLocationUpdated(Position position) async {
    final double lat = position.latitude;
    final double lng = position.longitude;
    debugPrint('CoffeeBuddy: Location updated: lat=$lat, lng=$lng');

    // 1. Fetch coffee shops from the database using current coordinates
    final List<CoffeeShop> shops = await _shopService.fetchCoffeeShops(
      userLat: lat,
      userLng: lng,
    );

    if (shops.isEmpty) return;

    // 2. Check for Proximity Alert (within 300 meters)
    for (final shop in shops) {
      final double distanceKm = shop.distance;
      
      if (distanceKm <= _proximityLimitKm) {
        final double distanceMeters = (distanceKm * 1000).roundToDouble();
        final String shopId = shop.id;

        // Check if we already notified this shop recently
        final lastNotified = _notifiedShops[shopId];
        final now = DateTime.now();

        if (lastNotified == null || now.difference(lastNotified) > _cooldown) {
          // Trigger high-priority sound/vibration alert on the lockscreen!
          final payload = json.encode({
            'name': shop.name,
            'latitude': shop.latitude,
            'longitude': shop.longitude,
          });

          await NotificationService.showAlertNotification(
            id: shopId.hashCode,
            title: '☕ Ada Cafe Terdekat!',
            body: '${shop.name} berjarak hanya ${distanceMeters.toInt()} meter dari Anda. Yuk singgah!',
            payload: payload,
          );

          // Update notified timestamp
          _notifiedShops[shopId] = now;
          debugPrint('CoffeeBuddy: Proximity alert sent for ${shop.name} (${distanceMeters.toInt()}m)');
        }
      }
    }

    // 3. Smart Contextual Selection for Persistent Lockscreen Widget Card
    final hour = DateTime.now().hour;
    late final CoffeeShop selectedShop;
    bool isShuffled = false;

    // Check if the user manually shuffled recently (active for 3 minutes)
    try {
      final prefs = await SharedPreferences.getInstance();
      final shuffledAt = prefs.getInt('coffee_buddy_shuffled_at') ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      if (nowMs - shuffledAt < 180000) {
        final String? name = prefs.getString('coffee_buddy_shuffled_name');
        if (name != null) {
          final String address = prefs.getString('coffee_buddy_shuffled_address') ?? '';
          final double sLat = prefs.getDouble('coffee_buddy_shuffled_lat') ?? 0;
          final double sLng = prefs.getDouble('coffee_buddy_shuffled_lng') ?? 0;
          final double rating = prefs.getDouble('coffee_buddy_shuffled_rating') ?? 4.5;
          final int price = prefs.getInt('coffee_buddy_shuffled_price') ?? 25000;

          // Calculate current distance to the shuffled cafe dynamically
          final double distance = calculateDistance(lat, lng, sLat, sLng);

          selectedShop = CoffeeShop(
            id: 'shuffled',
            name: name,
            address: address,
            latitude: sLat,
            longitude: sLng,
            rating: rating,
            price: price,
            facilities: {},
            distance: distance,
          );
          isShuffled = true;
          debugPrint('CoffeeBuddy: Preserving active shuffled cafe: $name');
        }
      }
    } catch (e) {
      debugPrint('CoffeeBuddy: Error loading shuffle state: $e');
    }

    if (!isShuffled) {
      if (hour >= 5 && hour < 11) {
        // Pagi: Grab the absolute closest cafe
        selectedShop = shops.first;
      } else if (hour >= 11 && hour < 17) {
        // Siang/Sore: Find closest with fast Wi-Fi and power sockets for WFH/study
        selectedShop = shops.firstWhere(
          (s) => s.facilities['wifi'] == true && s.facilities['sockets'] == true,
          orElse: () => shops.first,
        );
      } else {
        // Malam: Find closest with outdoor seating for chilling out
        selectedShop = shops.firstWhere(
          (s) => s.facilities['outdoor'] == true,
          orElse: () => shops.first,
        );
      }
    }

    // 4. Update the persistent lockscreen widget card with the smart (or shuffled) recommendation
    final double distanceM = (selectedShop.distance * 1000).roundToDouble();
    final double rating = selectedShop.rating;
    final int price = selectedShop.price;
    final String name = selectedShop.name;
      
    String vibeText = '';
    if (isShuffled) {
      vibeText = '🔄 Pilihan Acak Anda:';
    } else if (hour >= 5 && hour < 11) {
      vibeText = '☕ Semangat Pagi! Butuh asupan kafein? Mampir ke';
    } else if (hour >= 11 && hour < 17) {
      vibeText = '💻 Waktunya Produktif! Tempat nugas & WFH terbaik saat ini:';
    } else {
      vibeText = '🌌 Malam yang hangat! Cocok untuk nongkrong outdoor di';
    }

    final String cardTitle = '☕ CoffeeBuddy: $name';
    final String cardBody = '$vibeText $name (${distanceM.toInt()}m)\n📍 ${selectedShop.address}\n⭐ Rating: $rating | 💵 Est: Rp $price';

    final payload = json.encode({
      'name': name,
      'latitude': selectedShop.latitude,
      'longitude': selectedShop.longitude,
    });

    await NotificationService.showPersistentNotification(
      id: _persistentCardId,
      title: cardTitle,
      body: cardBody,
      payload: payload,
    );
    
    debugPrint('CoffeeBuddy: Persistent lockscreen card updated with $name (${distanceM.toInt()}m)');
  }
}
