import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_coffee/core/fallback_data.dart';

// Top-level background notification handler
@pragma('vm:entry-point')
void backgroundNotificationHandler(NotificationResponse response) async {
  final actionId = response.actionId;

  if (actionId == 'action_shuffle') {
    debugPrint('CoffeeBuddy: Shuffle clicked in background');
    
    // List of backend base URLs to try
    final baseUrls = ['http://10.0.2.2:8000', 'http://192.168.1.3:8000', 'http://127.0.0.1:8000'];
    List<dynamic> shops = [];
    
    // Try to fetch coffee shops from the backend
    for (final url in baseUrls) {
      try {
        final uri = Uri.parse('$url/api/coffee-shops');
        final res = await http.get(uri).timeout(const Duration(seconds: 2));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          shops = data['data'] ?? [];
          break;
        }
      } catch (e) {
        debugPrint('CoffeeBuddy: Failed to fetch from $url in background: $e');
      }
    }

    // Fallback to offline local data if backend is unreachable
    if (shops.isEmpty) {
      debugPrint('CoffeeBuddy: API unreachable in background. Using offline fallback.');
      shops = fallbackCoffeeShops;
    }

    if (shops.isNotEmpty) {
      // Pick a random coffee shop
      final random = Random();
      final shop = shops[random.nextInt(shops.length)];
      
      final String name = shop['name'] ?? 'Kedai Kopi';
      final String address = shop['address'] ?? 'Surabaya';
      final double lat = double.tryParse(shop['latitude']?.toString() ?? '0') ?? 0;
      final double lng = double.tryParse(shop['longitude']?.toString() ?? '0') ?? 0;
      final double rating = double.tryParse(shop['rating']?.toString() ?? '4.5') ?? 4.5;
      final int price = int.tryParse(shop['price']?.toString() ?? '25000') ?? 25000;

      // Save shuffle info in SharedPreferences to prevent GPS stream overwrite
      try {
        WidgetsFlutterBinding.ensureInitialized();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('coffee_buddy_shuffled_at', DateTime.now().millisecondsSinceEpoch);
        await prefs.setString('coffee_buddy_shuffled_name', name);
        await prefs.setString('coffee_buddy_shuffled_address', address);
        await prefs.setDouble('coffee_buddy_shuffled_lat', lat);
        await prefs.setDouble('coffee_buddy_shuffled_lng', lng);
        await prefs.setDouble('coffee_buddy_shuffled_rating', rating);
        await prefs.setInt('coffee_buddy_shuffled_price', price);
        debugPrint('CoffeeBuddy: Saved shuffle state to SharedPreferences: $name');
      } catch (e) {
        debugPrint('CoffeeBuddy: Error saving shuffle state: $e');
      }
      
      // Select a fun context-based description based on the current time
      final hour = DateTime.now().hour;
      String vibeDescription = '';
      if (hour >= 5 && hour < 11) {
        vibeDescription = '☕ Semangat Pagi! Cocok untuk memulai hari Anda.';
      } else if (hour >= 11 && hour < 17) {
        vibeDescription = '💻 Rekomendasi WFH/Nugas sore ini dengan rating $rating.';
      } else {
        vibeDescription = '🌌 Sempurna untuk nongkrong santai malam ini.';
      }

      final String bodyText = '$vibeDescription\n📍 $address\n💵 Est. Harga: Rp $price';
      
      // Update the persistent notification card with new payload
      final payloadData = {
        'name': name,
        'latitude': lat,
        'longitude': lng,
      };

      await NotificationService.showPersistentNotification(
        id: 999,
        title: '☕ CoffeeBuddy: $name',
        body: bodyText,
        payload: json.encode(payloadData),
      );
    }
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationClick,
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
    );

    // Request permissions for Android 13+
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // Foreground click handler (opens maps if ROUTE or notification itself is clicked)
  static void _onNotificationClick(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = json.decode(payload);
      final double lat = double.tryParse(data['latitude']?.toString() ?? '') ?? 0;
      final double lng = double.tryParse(data['longitude']?.toString() ?? '') ?? 0;

      if (lat != 0 && lng != 0) {
        final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('CoffeeBuddy: Error handling notification click: $e');
    }
  }

  // Show a standard high-priority alert banner (Proximity alert)
  static Future<void> showAlertNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'coffeetrack_alerts',
      'CoffeeTrack Proximity Alerts',
      channelDescription: 'Notifications for nearby coffee shops',
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: null,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Show/Update the persistent CoffeeBuddy Lockscreen widget card
  static Future<void> showPersistentNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'coffeetrack_buddy',
      'CoffeeBuddy Live Card',
      channelDescription: 'Persistent interactive notification card for lockscreen',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true, // Cannot be dismissed by swiping
      autoCancel: false,
      styleInformation: BigTextStyleInformation(''),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'action_route',
          '🗺️ Buka Rute',
          showsUserInterface: true, // Opens the app and triggers foreground listener
        ),
        AndroidNotificationAction(
          'action_shuffle',
          '🔄 Acak Cafe',
          showsUserInterface: false, // Runs silently in background isolate
        ),
      ],
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Cancel a notification
  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
