// lib/services/matches_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MatchesService {
  final String? authToken;

  MatchesService(this.authToken);

  Future<List<Map<String, dynamic>>> getPendingMatches() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/matches/pending'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((match) => match as Map<String, dynamic>).toList();
      }
      throw Exception('Failed to load pending matches');
    } catch (e) {
      print('Error loading pending matches: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateMatch(int matchId) async {
    try {
      print('Validating match $matchId'); // Debug log
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/matches/validate'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'match_id': matchId, 'accept': true}),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to validate match: ${response.body}');
    } catch (e) {
      print('Error in validateMatch: $e'); // Debug log
      rethrow;
    }
  }

  Future<void> rejectMatch(int matchId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/matches/reject'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'match_id': matchId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reject match');
      }
    } catch (e) {
      print('Error rejecting match: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getImportSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/matches/import-settings'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load import settings');
    } catch (e) {
      print('Error loading import settings: $e');
      rethrow;
    }
  }

  Future<void> updateImportSettings(Map<String, dynamic> settings) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/matches/import-settings'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(settings),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update import settings');
      }
    } catch (e) {
      print('Error updating import settings: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableLeagues() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/matches/available-leagues'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['leagues']);
      }
      throw Exception('Failed to load leagues');
    } catch (e) {
      print('Error loading leagues: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> importMatches(
      Set<String> selectedLeagues) async {
    try {
      print(
          'Selected leagues to import: $selectedLeagues'); // Log des ligues sélectionnées

      final requestBody = {'leagues': selectedLeagues.toList()};
      print('Request body: ${json.encode(requestBody)}'); // Log du body

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/matches/import'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}'); // Log du status
      print('Response body: ${response.body}'); // Log de la réponse

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to import matches: ${response.body}');
    } catch (e) {
      print('Error importing matches: $e');
      rethrow;
    }
  }
}
