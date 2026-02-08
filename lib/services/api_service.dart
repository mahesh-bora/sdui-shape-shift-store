import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product_model.dart';
import '../ui_config.dart';

class ApiService {
  // IMPORTANT: Change this based on your setup
  // For iOS Simulator: 'http://localhost:8080'
  // For Android Emulator: 'http://10.0.2.2:8080'
  // For Physical Device: 'http://YOUR_COMPUTER_IP:8080'
  static const String baseUrl = 'http://localhost:8080';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch UI configuration for a specific screen
  Future<UiConfig> fetchUiConfig({
    required String screen,
    Map<String, dynamic>? params,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/ui-config').replace(
        queryParameters: {
          'screen': screen,
          if (params != null) ...params.map((k, v) => MapEntry(k, v.toString())),
        },
      );

      print('📡 Fetching UI config: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - check if Go server is running');
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('✅ UI config loaded successfully');
        return UiConfig.fromJson(json);
      } else {
        throw Exception('Failed to load UI config: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching UI config: $e');
      rethrow;
    }
  }

  /// Fetch product details
  Future<Product> fetchProduct(String productId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/products/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      print('Error fetching product: $e');
      rethrow;
    }
  }

  /// Send analytics event to server
  Future<void> trackEvent({
    required String eventType,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/api/analytics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event_type': eventType,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print('Error tracking event: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}