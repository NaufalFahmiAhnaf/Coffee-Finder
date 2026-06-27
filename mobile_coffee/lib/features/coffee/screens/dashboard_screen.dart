import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mobile_coffee/core/constants.dart';
import 'package:mobile_coffee/core/location_utils.dart';
import 'package:mobile_coffee/features/auth/screens/login_screen.dart';
import 'package:mobile_coffee/features/coffee/screens/add_cafe_screen.dart';
import 'package:mobile_coffee/models/coffee_shop.dart';
import 'package:mobile_coffee/services/coffee_shop_service.dart';
import 'package:mobile_coffee/services/notification_service.dart';
import 'package:mobile_coffee/services/coffee_buddy_service.dart';
import 'package:mobile_coffee/shared/widgets/coffee_app_logo.dart';

class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CoffeeShopService _coffeeShopService = CoffeeShopService();

  List<CoffeeShop> _coffeeShops = [];
  bool _isLoading = true;
  String? _loadError;
  bool _showMap = true;
  String _query = '';
  int? _maxPrice;
  final List<String> _selectedFacilities = [];
  String _sortBy = 'rating';

  double _userLat = defaultUserLat;
  double _userLng = defaultUserLng;

  final _searchController = TextEditingController();
  final _priceController = TextEditingController();
  final MapController _mapController = MapController();

  Timer? _debounceTimer;
  String? _offlineMessage;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    // Initialize and start CoffeeBuddy notification radar
    try {
      await NotificationService.initialize();
      await CoffeeBuddyService().startTracking();
    } catch (e) {
      debugPrint('CoffeeBuddy: Error starting service: $e');
    }

    await _loadUserLocation();
    if (mounted) {
      await _fetchCoffeeShops();
    }
  }

  Future<void> _loadUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      
      if (position == null) {
        debugPrint('Location: No last known location. Requesting current position...');
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        ).timeout(const Duration(seconds: 15));
      } else {
        debugPrint('Location: Using last known location.');
      }
      
      final lat = sanitizeLatitude(position.latitude);
      final lng = sanitizeLongitude(position.longitude);

      if (!mounted) return;

      setState(() {
        _userLat = lat;
        _userLng = lng;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        try {
          _mapController.move(LatLng(lat, lng), 15);
        } catch (error) {
          debugPrint('Map controller is not ready: $error');
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error getting user location: $e');
    }
  }

  Future<void> _fetchCoffeeShops() async {
    setState(() => _isLoading = true);

    final shops = await _coffeeShopService.fetchCoffeeShops(
      userLat: _userLat,
      userLng: _userLng,
      query: _query,
      maxPrice: _maxPrice,
      selectedFacilities: _selectedFacilities,
      sortBy: _sortBy,
    );

    if (mounted) {
      setState(() {
        _coffeeShops = shops;
        _loadError = shops.isEmpty ? _coffeeShopService.lastError : null;
        _offlineMessage = shops.isNotEmpty ? _coffeeShopService.lastError : null;
        _isLoading = false;
      });
    }
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

  void _debouncedFetch({Duration delay = const Duration(milliseconds: 600)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      if (mounted) _fetchCoffeeShops();
    });
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    debugPrint('Opening Google Maps: $googleMapsUrl');

    try {
      final bool opened = await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    } catch (error) {
      debugPrint('Error opening Google Maps: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka Google Maps: $error')),
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
                    shop.imageUrl ??
                        'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.orange[50],
                      child: Icon(
                        Icons.coffee,
                        size: 64,
                        color: Colors.orange[800],
                      ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
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
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
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
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: shop.facilities.entries.map((entry) {
                  final isAvailable = entry.value;
                  if (!isAvailable) return const SizedBox.shrink();
                  return Chip(
                    avatar: Icon(
                      facilityIcons[entry.key] ?? Icons.check,
                      size: 16,
                      color: Colors.orange[800],
                    ),
                    label: Text(facilityLabels[entry.key] ?? entry.key),
                    backgroundColor: Colors.orange[50],
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    _openGoogleMaps(shop.latitude, shop.longitude);
                  },
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text(
                    'Buka di Google Maps',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 8),
          _buildFilterButton(),
          const SizedBox(width: 8),
          _buildMapToggleButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    int activeFilterCount = 0;
    if (_maxPrice != null && _maxPrice! > 0) activeFilterCount++;
    if (_sortBy != 'rating') activeFilterCount++;
    activeFilterCount += _selectedFacilities.length;

    final hasActiveFilters = activeFilterCount > 0;

    return Badge(
      isLabelVisible: hasActiveFilters,
      label: Text(activeFilterCount.toString()),
      backgroundColor: Colors.orange[800],
      child: Container(
        decoration: BoxDecoration(
          color: hasActiveFilters ? Colors.orange[50] : Colors.white,
          border: Border.all(
            color: hasActiveFilters ? Colors.orange[800]! : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            Icons.tune,
            color: hasActiveFilters ? Colors.orange[800] : Colors.grey[700],
          ),
          onPressed: _showFilterBottomSheet,
          tooltip: 'Filter Kafe',
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    List<String> tempSelectedFacilities = List.from(_selectedFacilities);
    int? tempMaxPrice = _maxPrice;
    String tempSortBy = _sortBy;

    final tempPriceController = TextEditingController(
      text: tempMaxPrice != null && tempMaxPrice > 0 ? tempMaxPrice.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Kafe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempSelectedFacilities.clear();
                            tempMaxPrice = null;
                            tempSortBy = 'rating';
                            tempPriceController.clear();
                          });
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Urutkan Berdasarkan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip('rating', '⭐ Rating', tempSortBy, (val) {
                        setSheetState(() => tempSortBy = val);
                      }),
                      _buildSortChip('nearest', '📍 Terdekat', tempSortBy, (val) {
                        setSheetState(() => tempSortBy = val);
                      }),
                      _buildSortChip('price_asc', '💵 Termurah', tempSortBy, (val) {
                        setSheetState(() => tempSortBy = val);
                      }),
                      _buildSortChip('price_desc', '💎 Termahal', tempSortBy, (val) {
                        setSheetState(() => tempSortBy = val);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Fasilitas Kafe',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: facilityIcons.keys.map((facility) {
                      final isSelected = tempSelectedFacilities.contains(facility);
                      return FilterChip(
                        avatar: Icon(
                          facilityIcons[facility],
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        label: Text(
                          facilityLabels[facility] ?? facility,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (_) {
                          setSheetState(() {
                            if (isSelected) {
                              tempSelectedFacilities.remove(facility);
                            } else {
                              tempSelectedFacilities.add(facility);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Harga Maksimal (Rupiah)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tempPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 30000',
                      prefixIcon: const Icon(Icons.payments, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) {
                      tempMaxPrice = int.tryParse(val.trim());
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFacilities.clear();
                          _selectedFacilities.addAll(tempSelectedFacilities);
                          _maxPrice = tempMaxPrice;
                          _sortBy = tempSortBy;
                          _priceController.text = tempPriceController.text;
                        });
                        Navigator.pop(context);
                        _fetchCoffeeShops();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(String value, String label, String currentSort, Function(String) onSelected) {
    final isSelected = currentSort == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.orange[800],
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey[200]!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (_) => onSelected(value),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari kafe... (cth: "Kofind", "Tanah Kopi")',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _debounceTimer?.cancel();
                  _searchController.clear();
                  setState(() => _query = '');
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
        setState(() => _query = val.trim());
        _debouncedFetch();
      },
      onSubmitted: (val) => _fetchCoffeeShops(),
    );
  }

  Widget _buildMapToggleButton() {
    return Container(
      decoration: BoxDecoration(
        color: _showMap ? Colors.grey[900] : Colors.orange[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(_showMap ? Icons.grid_view : Icons.map, color: Colors.white),
        onPressed: () => setState(() => _showMap = !_showMap),
        tooltip: _showMap ? 'Sembunyikan Peta' : 'Tampilkan Peta',
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
          if (_coffeeShops.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                _loadError ??
                    'Belum ada kafe yang sesuai dengan pencarian atau filter saat ini.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (crossAxisCount == 1)
            Column(
              children: _coffeeShops
                  .map((shop) => _buildCafeCard(shop, isGrid: false))
                  .toList(),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: _coffeeShops.length,
              itemBuilder: (context, index) =>
                  _buildCafeCard(_coffeeShops[index], isGrid: true),
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Image.network(
                        shop.imageUrl ??
                            'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.orange[50],
                          child: Icon(
                            Icons.coffee,
                            size: 64,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.navigation_outlined,
                                size: 12,
                                color: Colors.orange[800],
                              ),
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
                          .where(
                            (entry) =>
                                entry.value &&
                                facilityIcons.containsKey(entry.key),
                          )
                          .take(4)
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  border: Border.all(color: Colors.grey[100]!),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  facilityIcons[entry.key],
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _openGoogleMaps(shop.latitude, shop.longitude),
                        icon: Icon(
                          Icons.map_outlined,
                          color: Colors.orange[800],
                          size: 16,
                        ),
                        label: const Text(
                          'Google Maps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange[800]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
    final markers = _coffeeShops
        .where((shop) => isValidCoordinate(shop.latitude, shop.longitude))
        .map(
          (shop) => Marker(
            point: LatLng(shop.latitude, shop.longitude),
            width: 45,
            height: 45,
            child: GestureDetector(
              onTap: () => _showCafeDetailsSheet(shop),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.blue[700], size: 38),
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
          ),
        )
        .toList();

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
                  child: Icon(Icons.my_location, color: Colors.blue, size: 20),
                ),
              ),
            ),
            ...markers,
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    if (_offlineMessage == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange[800], size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _offlineMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[900],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _offlineMessage = null),
            child: Icon(Icons.close, size: 16, color: Colors.orange[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDashboard(BoxConstraints constraints) {
    return ListView(
      children: [
        _buildWelcomeCard(),
        _buildOfflineBanner(),
        _buildFiltersSection(),
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
        _buildOfflineBanner(),
        _buildFiltersSection(),
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
            const CoffeeAppLogo(size: 20),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCafeScreen(username: widget.username),
            ),
          );
          // Refresh list in case the admin approved something while user was away
          if (mounted) _fetchCoffeeShops();
        },
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text(
          'Add Cafe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
      ),
    );
  }
}
