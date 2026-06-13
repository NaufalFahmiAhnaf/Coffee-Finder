import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_coffee/core/constants.dart';
import 'package:mobile_coffee/services/cafe_submission_service.dart';

/// Screen allowing mobile users to submit a new cafe for admin review.
/// Uses POST /api/mobile/coffee-shop-submissions.
/// The admin approves or rejects submissions via the web dashboard.
class AddCafeScreen extends StatefulWidget {
  final String username;

  const AddCafeScreen({super.key, required this.username});

  @override
  State<AddCafeScreen> createState() => _AddCafeScreenState();
}

class _AddCafeScreenState extends State<AddCafeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CafeSubmissionService();

  // Form controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '25000');
  final _ratingController = TextEditingController(text: '4.5');
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Facilities state (mirrors backend schema)
  final Map<String, bool> _facilities = {
    'wifi': false,
    'outdoor': false,
    'ac': false,
    'sockets': false,
    'smoking_room': false,
  };

  bool _isSubmitting = false;
  bool _isLocating = false;
  bool _isGeocoding = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ─── Location helpers ───────────────────────────────────────────────────

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location service is disabled. Please enable it.', isError: true);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showSnack('Location permission denied.', isError: true);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });
      _showSnack('Location filled automatically ✓');
    } catch (e) {
      _showSnack('Failed to get location: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  /// Geocode the address field using Nominatim (OpenStreetMap, no API key needed).
  Future<void> _geocodeAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showSnack('Please enter an address first.', isError: true);
      return;
    }

    setState(() => _isGeocoding = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': address,
        'format': 'json',
        'limit': '1',
      });

      final response = await http.get(uri, headers: {'User-Agent': 'CoffeeTrack-MobileApp/1.0'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat'].toString());
          final lon = double.parse(results[0]['lon'].toString());
          if (!mounted) return;
          setState(() {
            _latController.text = lat.toStringAsFixed(6);
            _lngController.text = lon.toStringAsFixed(6);
          });
          _showSnack('Coordinates found ✓');
        } else {
          _showSnack('Address not found. Try a more specific address.', isError: true);
        }
      } else {
        _showSnack('Geocoding service unavailable. Fill coordinates manually.', isError: true);
      }
    } catch (e) {
      _showSnack('Geocoding failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  // ─── Submit ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final result = await _service.submitCafe(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.tryParse(_priceController.text.trim()) ?? 0,
      rating: double.tryParse(_ratingController.text.trim()) ?? 4.5,
      latitude: double.tryParse(_latController.text.trim()) ?? 0,
      longitude: double.tryParse(_lngController.text.trim()) ?? 0,
      facilities: _facilities,
      imageUrl: _imageUrlController.text.trim(),
      submittedBy: widget.username,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      _showSuccessDialog(result.message);
    } else {
      _showSnack(result.message, isError: true);
    }
  }

  // ─── Feedback helpers ────────────────────────────────────────────────────

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
              child: Icon(Icons.check_circle_rounded, color: Colors.green[600], size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'Request Submitted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'The admin will review your submission on the web dashboard.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // go back to dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── UI Builders ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[700], letterSpacing: 0.4),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix, String? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixText: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildCoordinatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Coordinates'),
        // Quick-fill buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLocating ? null : _useCurrentLocation,
                icon: _isLocating
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.my_location, size: 16, color: Colors.orange[800]),
                label: Text(
                  _isLocating ? 'Locating...' : 'Use My Location',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isGeocoding ? null : _geocodeAddress,
                icon: _isGeocoding
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.search, size: 16, color: Colors.blue[700]),
                label: Text(
                  _isGeocoding ? 'Searching...' : 'Search from Address',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: _inputDecoration('Latitude'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lngController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: _inputDecoration('Longitude'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Facilities'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _facilities.keys.map((key) {
            final isSelected = _facilities[key]!;
            return FilterChip(
              avatar: Icon(
                facilityIcons[key] ?? Icons.check,
                size: 15,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              label: Text(
                facilityLabels[key] ?? key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.orange[800],
              backgroundColor: Colors.grey[50],
              checkmarkColor: Colors.white,
              showCheckmark: false,
              side: BorderSide(color: isSelected ? Colors.orange[800]! : Colors.grey[200]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) => setState(() => _facilities[key] = val),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Submit a New Cafe',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Info banner ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your submission will be reviewed by the admin before it appears in the app.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[900], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Basic info ────────────────────────────────────────────────
            _buildSectionLabel('Cafe Name *'),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('e.g. Morning Bean'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Cafe name is required' : null,
            ),
            const SizedBox(height: 16),

            _buildSectionLabel('Address *'),
            TextFormField(
              controller: _addressController,
              decoration: _inputDecoration('Jl. Example No. 1, Surabaya'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),

            _buildSectionLabel('Description'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration('What makes this cafe special?'),
            ),
            const SizedBox(height: 16),

            // ── Price & rating ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Avg Price (Rp) *'),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('25000', prefix: 'Rp '),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (int.tryParse(v.trim()) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Rating (0–5) *'),
                      TextFormField(
                        controller: _ratingController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration('4.5'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = double.tryParse(v.trim());
                          if (n == null) return 'Invalid';
                          if (n < 0 || n > 5) return '0–5 only';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Image URL ─────────────────────────────────────────────────
            _buildSectionLabel('Image URL (optional)'),
            TextFormField(
              controller: _imageUrlController,
              keyboardType: TextInputType.url,
              decoration: _inputDecoration('https://example.com/cafe.jpg'),
            ),
            const SizedBox(height: 24),

            // ── Coordinates ───────────────────────────────────────────────
            _buildCoordinatesSection(),
            const SizedBox(height: 24),

            // ── Facilities ────────────────────────────────────────────────
            _buildFacilitiesSection(),
            const SizedBox(height: 32),

            // ── Submit button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.orange[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Send Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
