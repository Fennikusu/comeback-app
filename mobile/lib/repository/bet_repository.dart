// lib/repository/bet_repository.dart
import '../core/api/api_client.dart';
import '../config/constants.dart';
import '../models/bet.dart';
import '../models/user_bet.dart';

class BetRepository {
  final ApiClient _apiClient;

  BetRepository(this._apiClient);

  Future<List<Bet>> getAvailableBets(String game) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        AppConstants.betsEndpoint,
        queryParameters: {'game': game},
      );

      if (response.success && response.data != null) {
        // La réponse est directement la liste, pas besoin de chercher dans un objet
        final List<dynamic> betsJson = response.data as List<dynamic>;
        return betsJson
            .map((json) => Bet.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.error ?? 'Failed to load bets');
      }
    } catch (e) {
      throw Exception('Error getting available bets: $e');
    }
  }

  Future<Bet> getBetDetails(String betId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.betsEndpoint}/$betId',
    );

    if (response.success && response.data != null) {
      return Bet.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load bet details');
    }
  }

  Future<List<UserBet>> getUserBets(int userId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/users/$userId${AppConstants.betsEndpoint}',
    );

    if (response.success && response.data != null) {
      return (response.data as List)
          .map((json) => UserBet.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.error ?? 'Failed to load user bets');
    }
  }

  Future<UserBet> placeBet({
    required int userId,
    required String betId,
    required String selectedTeam,
    required int amount,
    String? subBetId,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${AppConstants.betsEndpoint}/place',
        body: {
          'user_id': userId,
          'bet_id': betId,
          'sub_bet_id': subBetId,
          'selected_team': selectedTeam,
          'amount': amount,
        },
      );

      if (response.success && response.data != null) {
        // Ajouter les informations manquantes nécessaires pour créer un UserBet complet
        final data = Map<String, dynamic>.from(response.data!);
        // Ajouter les champs du pari original si nécessaire
        return UserBet.fromJson(data);
      } else {
        throw Exception(response.error ?? 'Failed to place bet');
      }
    } catch (e) {
      print('Erreur dans placeBet repository: $e');
      rethrow;
    }
  }

  Future<bool> checkUserBalance(int userId, int amount) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/users/$userId/balance',
    );

    if (response.success && response.data != null) {
      final userBalance = int.parse(response.data!['coins'].toString());
      return userBalance >= amount;
    } else {
      throw Exception(response.error ?? 'Failed to check user balance');
    }
  }

  Future<List<UserBet>> getRecentBets(int userId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/users/$userId${AppConstants.betsEndpoint}/recent',
    );

    if (response.success && response.data != null) {
      return (response.data as List)
          .map((json) => UserBet.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.error ?? 'Failed to load recent bets');
    }
  }

  Future<bool> cancelBet(String betId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '${AppConstants.betsEndpoint}/$betId/cancel',
    );

    return response.success;
  }
}