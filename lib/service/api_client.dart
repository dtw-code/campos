import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  /// Base URL configured for Android emulator local host communication as per guidelines.md
  /// Default: http://10.0.2.2:5000 (Node.js backend)
  final String baseUrl;
  final Duration timeout;

  ApiClient({
    this.baseUrl = 'http://10.0.2.2:5000',
    this.timeout = const Duration(seconds: 4),
  });

  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .get(uri, headers: defaultHeaders)
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to fetch $endpoint',
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] GET $endpoint failed: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .post(uri, headers: defaultHeaders, body: jsonEncode(data))
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to post to $endpoint',
        );
      }
    } catch (e) {
      debugPrint('[ApiClient] POST $endpoint failed: $e');
      rethrow;
    }
  }
}
