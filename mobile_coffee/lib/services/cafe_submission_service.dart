import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_coffee/core/constants.dart';

class CafeSubmissionService {
  /// Submit a new cafe request to the mobile API endpoint.
  /// Returns a [SubmissionResult] with success/error details.
  Future<SubmissionResult> submitCafe({
    required String name,
    required String address,
    required String description,
    required int price,
    required double rating,
    required double latitude,
    required double longitude,
    required Map<String, bool> facilities,
    String? imageUrl,
    String? submittedBy,
  }) async {
    final body = json.encode({
      'name': name,
      'address': address,
      'description': description,
      'price': price,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'facilities': facilities,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      if (submittedBy != null && submittedBy.isNotEmpty)
        'submitted_by': submittedBy,
    });

    for (final baseUrl in getBaseUrls()) {
      try {
        final uri = Uri.parse('$baseUrl/api/mobile/coffee-shop-submissions');

        final response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: body,
            )
            .timeout(const Duration(seconds: 10));

        final decoded = json.decode(response.body) as Map<String, dynamic>;

        if (response.statusCode == 201) {
          return SubmissionResult.success(
            message:
                decoded['message'] as String? ?? 'Cafe submitted successfully.',
            id: decoded['data']?['id']?.toString(),
          );
        } else {
          final serverMessage =
              decoded['message'] as String? ??
              'Submission failed. Please try again.';
          return SubmissionResult.failure(message: serverMessage);
        }
      } catch (e) {
        debugPrint('CafeSubmissionService error from $baseUrl: $e');
      }
    }

    return SubmissionResult.failure(
      message: 'Unable to connect to server. Please check your connection.',
    );
  }
}

class SubmissionResult {
  final bool success;
  final String message;
  final String? id;

  const SubmissionResult._({
    required this.success,
    required this.message,
    this.id,
  });

  factory SubmissionResult.success({required String message, String? id}) =>
      SubmissionResult._(success: true, message: message, id: id);

  factory SubmissionResult.failure({required String message}) =>
      SubmissionResult._(success: false, message: message);
}
