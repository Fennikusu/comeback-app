// lib/services/dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DashboardService {
  final String? authToken;

  DashboardService(this.authToken);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final activeBetsResponse = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.bets)}'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      final shopItemsResponse = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.shopItems)}?user_id=1'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (activeBetsResponse.statusCode == 200 &&
          shopItemsResponse.statusCode == 200) {
        final bets = json.decode(activeBetsResponse.body);
        final items = json.decode(shopItemsResponse.body);

        return {
          'activeBets': bets.length,
          'shopItems': items.length,
        };
      }

      throw Exception('Failed to load dashboard stats');
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'activeBets': 0,
        'shopItems': 0,
      };
    }
  }
}
