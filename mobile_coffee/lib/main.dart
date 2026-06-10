<<<<<<< HEAD
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // contains kIsWeb
=======
import 'package:flutter/material.dart';
>>>>>>> ba18f1633387b0253b5da2913e8c23077f18dfb8

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoffeeTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange[800]!,
          secondary: Colors.amber[600]!,
          surface: Colors.grey[50]!,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
=======
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
>>>>>>> ba18f1633387b0253b5da2913e8c23077f18dfb8
    );
  }
}

<<<<<<< HEAD
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('coffee_user');
      _loading = false;
=======
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
>>>>>>> ba18f1633387b0253b5da2913e8c23077f18dfb8
    });
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_username != null && _username!.isNotEmpty) {
      return DashboardScreen(username: _username!);
    }
    return const LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('coffee_user', _nameController.text.trim());
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(username: _nameController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[900]!,
              Colors.amber[700]!,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_cafe,
                          size: 64,
                          color: Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'CoffeeTrack',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Temukan pengalaman kopi terbaik di sekitarmu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Kamu',
                          hintText: 'Masukkan nama kamu...',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Cari Kopi Terdekat',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

  factory CoffeeShop.fromJson(Map<String, dynamic> json, {double userLat = -7.250445, double userLng = 112.768845}) {
    final lat = json['latitude'] != null ? (json['latitude'] as num).toDouble() : -7.250445;
    final lng = json['longitude'] != null ? (json['longitude'] as num).toDouble() : 112.768845;
    
    final dist = calculateDistance(userLat, userLng, lat, lng);

    return CoffeeShop(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Kafe Tanpa Nama',
      address: json['address']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      price: json['price'] != null ? (json['price'] as num).toInt() : 0,
      facilities: Map<String, bool>.from(json['facilities'] ?? {}),
      distance: dist,
      imageUrl: json['image_url']?.toString(),
    );
  }
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
      math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

double _toRadians(double degree) {
  return degree * math.pi / 180;
}

class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<CoffeeShop> _coffeeShops = [];
  bool _isLoading = true;
  bool _showMap = true;
  String _query = "";
  int? _maxPrice;
  final List<String> _selectedFacilities = [];
  String _sortBy = "rating";
  
  final double _userLat = -7.250445; 
  final double _userLng = 112.768845;

  final _searchController = TextEditingController();
  final _priceController = TextEditingController();
  final MapController _mapController = MapController();

  final Map<String, IconData> _facilityIcons = {
    'wifi': Icons.wifi,
    'outdoor': Icons.wb_sunny,
    'ac': Icons.ac_unit,
    'sockets': Icons.power,
    'smoking_room': Icons.smoking_rooms,
  };

  final Map<String, String> _facilityLabels = {
    'wifi': 'Wifi',
    'outdoor': 'Outdoor',
    'ac': 'AC',
    'sockets': 'Colokan',
    'smoking_room': 'Smoking',
  };

  // Environment-based API URL detection
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  // Local Mock Data Falling Back automatically if Laravel server is offline/unreachable
  final List<Map<String, dynamic>> _mockCoffeeShopsData = [
    {
      'id': 'm1',
      'name': 'Tunjungan Coffee Bar',
      'address': 'Jl. Tunjungan No. 12',
      'latitude': -7.2575,
      'longitude': 112.7421,
      'rating': 4.8,
      'price': 35000,
      'facilities': {'wifi': true, 'outdoor': true, 'ac': true, 'sockets': true, 'smoking_room': false}
    },
    {
      'id': 'm2',
      'name': 'Gubeng Station Brew',
      'address': 'Jl. Gubeng Masjid No. 5',
      'latitude': -7.2654,
      'longitude': 112.7532,
      'rating': 4.5,
      'price': 25000,
      'facilities': {'wifi': true, 'outdoor': false, 'ac': true, 'sockets': true, 'smoking_room': true}
    },
    {
      'id': 'm3',
      'name': 'Darmahusada Hub',
      'address': 'Jl. Darmahusada No. 45',
      'latitude': -7.2688,
      'longitude': 112.7788,
      'rating': 4.7,
      'price': 30000,
      'facilities': {'wifi': true, 'outdoor': true, 'ac': true, 'sockets': true, 'smoking_room': false}
    },
    {
      'id': 'm4',
      'name': 'Basuki Rahmat Roasters',
      'address': 'Jl. Basuki Rahmat No. 10',
      'latitude': -7.2633,
      'longitude': 112.7399,
      'rating': 4.9,
      'price': 45000,
      'facilities': {'wifi': true, 'outdoor': true, 'ac': true, 'sockets': true, 'smoking_room': false}
    },
    {
      'id': 'm5',
      'name': 'Mulyorejo Chill Spot',
      'address': 'Jl. Mulyorejo No. 88',
      'latitude': -7.2611,
      'longitude': 112.7911,
      'rating': 4.3,
      'price': 20000,
      'facilities': {'wifi': true, 'outdoor': true, 'ac': false, 'sockets': false, 'smoking_room': true}
    },
    {
      'id': 'm6',
      'name': 'Pakuwon Vibe',
      'address': 'Pakuwon Mall L3',
      'latitude': -7.2888,
      'longitude': 112.6788,
      'rating': 4.6,
      'price': 55000,
      'facilities': {'wifi': true, 'outdoor': false, 'ac': true, 'sockets': true, 'smoking_room': false}
    },
    {
      'id': 'm7',
      'name': 'Mayjen Sungkono Beans',
      'address': 'Jl. Mayjen Sungkono No. 20',
      'latitude': -7.2911,
      'longitude': 112.7111,
      'rating': 4.4,
      'price': 32000,
      'facilities': {'wifi': false, 'outdoor': true, 'ac': true, 'sockets': true, 'smoking_room': true}
    },
    {
      'id': 'm8',
      'name': 'Ngagel Espresso',
      'address': 'Jl. Ngagel Jaya No. 15',
      'latitude': -7.2955,
      'longitude': 112.7488,
      'rating': 4.2,
      'price': 18000,
      'facilities': {'wifi': true, 'outdoor': true, 'ac': false, 'sockets': true, 'smoking_room': true}
    },
    {
      'id': 'm9',
      'name': 'Manyar Kertoarjo Social',
      'address': 'Jl. Manyar Kertoarjo No. 3',
      'latitude': -7.2833,
      'longitude': 112.7699,
      'rating': 4.7,
      'price': 40000,
      'facilities': {'wifi': true, 'outdoor': true, 'ac': true, 'sockets': true, 'smoking_room': false}
    },
    {
      'id': 'm10',
      'name': 'Ahmad Yani Coffee',
      'address': 'Jl. Ahmad Yani No. 150',
      'latitude': -7.3211,
      'longitude': 112.7322,
      'rating': 4.5,
      'price': 28000,
      'facilities': {'wifi': true, 'outdoor': false, 'ac': true, 'sockets': true, 'smoking_room': false}
    },
    {
      'id': 'm11',
      'name': 'Citraland Lake Cafe',
      'address': 'G-Walk Citraland',
      'latitude': -7.2811,
      'longitude': 112.6522,
      'rating': 4.8,
      'price': 50000,
      'facilities': {'wifi': true, 'outdoor': true, 'ac': true, 'sockets': false, 'smoking_room': false}
    },
    {
      'id': 'm12',
      'name': 'Wonokromo Morning',
      'address': 'Jl. Wonokromo No. 1',
      'latitude': -7.3011,
      'longitude': 112.7355,
      'rating': 4.1,
      'price': 15000,
      'facilities': {'wifi': false, 'outdoor': true, 'ac': false, 'sockets': false, 'smoking_room': true}
    },
    {
      'id': 'm13',
      'name': 'Fore Coffee - Ruko Bukit Palma',
      'address': 'Ruko Palma Galeria RB 05-20',
      'latitude': -7.261716331131363,
      'longitude': 112.6346913804825,
      'rating': 4.7,
      'price': 25000,
      'facilities': {'wifi': true, 'outdoor': false, 'ac': true, 'sockets': true, 'smoking_room': false}
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchCoffeeShops();
  }

  Future<void> _fetchCoffeeShops() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final queryParams = {
        'lat': _userLat.toString(),
        'lng': _userLng.toString(),
        if (_query.isNotEmpty) 'q': _query,
        if (_maxPrice != null && _maxPrice! > 0) 'max_price': _maxPrice.toString(),
        if (_sortBy != 'nearest') 'sort_by': _sortBy,
      };

      String urlStr = "$_baseUrl/api/coffee-shops?";
      final paramsList = <String>[];
      
      queryParams.forEach((key, value) {
        paramsList.add("$key=${Uri.encodeQueryComponent(value)}");
      });

      for (var facility in _selectedFacilities) {
        paramsList.add("facilities[]=${Uri.encodeQueryComponent(facility)}");
      }

      urlStr += paramsList.join('&');
      final uri = Uri.parse(urlStr);

      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        
        var shops = list.map((item) => CoffeeShop.fromJson(item, userLat: _userLat, userLng: _userLng)).toList();

        if (_sortBy == 'nearest') {
          shops.sort((a, b) => a.distance.compareTo(b.distance));
        }

        setState(() {
          _coffeeShops = shops;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint("API error: $e. Fallback to mock data offline.");
    }

    // Fallback: Local mock filtering
    _loadMockDataOffline();
  }

  void _loadMockDataOffline() {
    var list = List<Map<String, dynamic>>.from(_mockCoffeeShopsData);

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((item) =>
        item['name'].toString().toLowerCase().contains(q) ||
        item['address'].toString().toLowerCase().contains(q)
      ).toList();
    }

    if (_maxPrice != null && _maxPrice! > 0) {
      list = list.where((item) => (item['price'] as num).toInt() <= _maxPrice!).toList();
    }

    if (_selectedFacilities.isNotEmpty) {
      list = list.where((item) {
        final facs = Map<String, bool>.from(item['facilities'] ?? {});
        for (var facility in _selectedFacilities) {
          if (facs[facility] != true) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    var shops = list.map((item) => CoffeeShop.fromJson(item, userLat: _userLat, userLng: _userLng)).toList();

    if (_sortBy == 'nearest') {
      shops.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_sortBy == 'rating') {
      shops.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'price_asc') {
      shops.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      shops.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() {
      _coffeeShops = shops;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('coffee_user');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _toggleFacility(String facility) {
    setState(() {
      if (_selectedFacilities.contains(facility)) {
        _selectedFacilities.remove(facility);
      } else {
        _selectedFacilities.add(facility);
      }
    });
    _fetchCoffeeShops();
  }

  Future<void> _openGoogleMaps(String name, String address) async {
    final query = Uri.encodeComponent("$name $address");
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  void _showCafeDetailsSheet(CoffeeShop shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    shop.imageUrl ?? 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.orange[50],
                      child: Icon(Icons.coffee, size: 64, color: Colors.orange[800]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          shop.rating.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                shop.address,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Harga Rata-rata:',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp ${shop.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jarak dari Anda:',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${shop.distance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Fasilitas Tersedia:',
                style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: shop.facilities.entries.map((entry) {
                  final isAvailable = entry.value;
                  if (!isAvailable) return const SizedBox.shrink();
                  final key = entry.key;
                  return Chip(
                    avatar: Icon(_facilityIcons[key] ?? Icons.check, size: 16, color: Colors.orange[800]),
                    label: Text(_facilityLabels[key] ?? key),
                    backgroundColor: Colors.orange[50],
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openGoogleMaps(shop.name, shop.address);
                  },
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text('Buka di Google Maps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[800]!, Colors.amber[600]!],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${widget.username}! 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Yuk temukan tempat ngopi terbaik hari ini!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection({required bool isWide}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: isWide 
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildPriceField(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildSortDropdown(),
                ),
                const SizedBox(width: 12),
                _buildMapToggleButton(),
              ],
            )
          : Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildPriceField(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: _buildSortDropdown(),
                    ),
                    const SizedBox(width: 8),
                    _buildMapToggleButton(),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari nama kafe atau alamat...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _query = "";
                  });
                  _fetchCoffeeShops();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (val) {
        setState(() {
          _query = val.trim();
        });
      },
      onSubmitted: (val) {
        _fetchCoffeeShops();
      },
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Harga Max (e.g. 30000)',
        prefixIcon: const Icon(Icons.payments, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (val) {
        setState(() {
          _maxPrice = int.tryParse(val.trim());
        });
      },
      onSubmitted: (val) {
        _fetchCoffeeShops();
      },
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _sortBy = newValue;
              });
              _fetchCoffeeShops();
            }
          },
          items: const [
            DropdownMenuItem(value: 'rating', child: Text('⭐ Rating')),
            DropdownMenuItem(value: 'nearest', child: Text('📍 Terdekat')),
            DropdownMenuItem(value: 'price_asc', child: Text('💵 Termurah')),
            DropdownMenuItem(value: 'price_desc', child: Text('💎 Termahal')),
          ],
        ),
      ),
    );
  }

  Widget _buildMapToggleButton() {
    return Container(
      decoration: BoxDecoration(
        color: _showMap ? Colors.grey[900] : Colors.orange[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          _showMap ? Icons.grid_view : Icons.map,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            _showMap = !_showMap;
          });
        },
        tooltip: _showMap ? 'Sembunyikan Peta' : 'Tampilkan Peta',
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: _facilityIcons.keys.map((facility) {
          final isSelected = _selectedFacilities.contains(facility);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
            child: FilterChip(
              avatar: Icon(
                _facilityIcons[facility],
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              label: Text(
                _facilityLabels[facility] ?? facility,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.orange[800],
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey[200]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => _toggleFacility(facility),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardLayout(double width) {
    int crossAxisCount = 1;
    double childAspectRatio = 0.82;

    if (width > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.85;
    } else if (width > 900) {
      crossAxisCount = 3;
      childAspectRatio = 0.82;
    } else if (width > 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
            child: Text(
              'Rekomendasi Kafe',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.grey[800],
              ),
            ),
          ),
          crossAxisCount == 1 
              ? Column(
                  children: _coffeeShops.map((shop) => _buildCafeCard(shop, isGrid: false)).toList(),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: _coffeeShops.length,
                  itemBuilder: (context, index) {
                    final shop = _coffeeShops[index];
                    return _buildCafeCard(shop, isGrid: true);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCafeCard(CoffeeShop shop, {required bool isGrid}) {
    return Container(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showCafeDetailsSheet(shop),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Image.network(
                        shop.imageUrl ?? 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.orange[50],
                          child: Icon(Icons.coffee, size: 64, color: Colors.orange[800]),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shop.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            border: Border.all(color: Colors.orange[100]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Rp ${(shop.price / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.navigation_outlined, size: 12, color: Colors.orange[800]),
                              const SizedBox(width: 2),
                              Text(
                                '${shop.distance.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: shop.facilities.entries
                          .where((entry) => entry.value && _facilityIcons.containsKey(entry.key))
                          .take(4)
                          .map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border.all(color: Colors.grey[100]!),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _facilityIcons[entry.key],
                              size: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: () => _openGoogleMaps(shop.name, shop.address),
                        icon: Icon(Icons.map_outlined, color: Colors.orange[800], size: 16),
                        label: const Text('Google Maps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange[800]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(_userLat, _userLng),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.coffetrack.app',
        ),
        MarkerLayer(
          markers: [
            // User Location Marker
            Marker(
              point: LatLng(_userLat, _userLng),
              width: 45,
              height: 45,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ),
            // Coffee Shops Markers - Blue pin styled like Leaflet
            ..._coffeeShops.map((shop) {
              return Marker(
                point: LatLng(shop.latitude, shop.longitude),
                width: 45,
                height: 45,
                child: GestureDetector(
                  onTap: () => _showCafeDetailsSheet(shop),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue[700],
                        size: 38,
                      ),
                      Positioned(
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_cafe,
                            color: Colors.blue[700],
                            size: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileDashboard(BoxConstraints constraints) {
    return ListView(
      children: [
        _buildWelcomeCard(),
        _buildFiltersSection(isWide: false),
        _buildFacilitiesSection(),
        const SizedBox(height: 8),
        if (_showMap)
          Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildMapView(),
            ),
          ),
        _buildCardLayout(constraints.maxWidth),
      ],
    );
  }

  Widget _buildWideDashboard(BoxConstraints constraints) {
    return ListView(
      children: [
        _buildWelcomeCard(),
        _buildFiltersSection(isWide: true),
        _buildFacilitiesSection(),
        const SizedBox(height: 8),
        if (_showMap)
          Container(
            height: 400,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildMapView(),
            ),
          ),
        _buildCardLayout(constraints.maxWidth),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_cafe, color: Colors.orange[800], size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'CoffeeTrack',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchCoffeeShops,
                  child: isWide 
                      ? _buildWideDashboard(constraints)
                      : _buildMobileDashboard(constraints),
                );
        },
=======
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
>>>>>>> ba18f1633387b0253b5da2913e8c23077f18dfb8
      ),
    );
  }
}
