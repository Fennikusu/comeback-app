// lib/repository/bet_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/bet.dart';

class BetRepository {
  final String? authToken;

  BetRepository(this.authToken);

  Future<List<Bet>> getAllBets() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.bets)),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Bet.fromJson(json)).toList();
      }
      throw Exception('Failed to load bets');
    } catch (e) {
      print('Error fetching bets: $e');
      rethrow;
    }
  }

  Future<Bet> getBetById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.bets)}/$id'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Bet.fromJson(json.decode(response.body));
      }
      throw Exception('Bet not found');
    } catch (e) {
      print('Error fetching bet details: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> finishBet(int betId,
      {required int winningTeam}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/bets/finish'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'bet_id': betId,
          'winning_team': winningTeam,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to finish bet: ${response.body}');
    } catch (e) {
      print('Error finishing bet: $e');
      rethrow;
    }
  }

  Future<Bet> createBet(Bet bet) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.bets)),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(bet.toJson()),
      );

      if (response.statusCode == 200) {
        return bet;
      }
      throw Exception('Failed to create bet');
    } catch (e) {
      print('Error creating bet: $e');
      rethrow;
    }
  }

  Future<Bet> updateBet(Bet bet) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.updateBet)),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(bet.toJson()),
      );

      if (response.statusCode == 200) {
        return bet;
      }
      throw Exception('Failed to update bet');
    } catch (e) {
      print('Error updating bet: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBetStats(int betId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bets/$betId/stats'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get bet stats: ${response.body}');
    } catch (e) {
      print('Error getting bet stats: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBetStatus(
      int betId, String newStatus) async {
    try {
      print('Updating bet status...');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/bets/update-status'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'bet_id': betId,
          'status': newStatus,
        }),
      );

      print('Update status response code: ${response.statusCode}');
      print('Update status response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to update bet status: ${response.body}');
    } catch (e) {
      print('Error updating bet status: $e');
      rethrow;
    }
  }
}
