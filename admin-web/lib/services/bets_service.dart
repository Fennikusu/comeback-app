// lib/services/bets_service.dart
import '../repository/bet_repository.dart';
import '../models/bet.dart';

class BetsService {
  final BetRepository repository;

  BetsService(String? authToken) : repository = BetRepository(authToken);

  Future<List<Bet>> getBets() => repository.getAllBets();

  Future<Map<String, dynamic>> updateBetStatus(int betId, String newStatus) =>
      repository.updateBetStatus(betId, newStatus);

  Future<Bet> createBet({
    required String game,
    required String league,
    required String team1,
    required String team2,
    required double oddsTeam1,
    required double oddsTeam2,
  }) {
    final bet = Bet(
      game: game,
      league: league,
      team1: team1,
      team2: team2,
      oddsTeam1: oddsTeam1,
      oddsTeam2: oddsTeam2,
      status: 'open',
    );
    return repository.createBet(bet);
  }

  Future<Bet> updateBet(
      {required int id, required Map<String, dynamic> data}) async {
    final existingBets = await repository.getAllBets();
    final existingBet = existingBets.firstWhere((bet) => bet.id == id);

    final updatedBet = Bet(
      id: id,
      game: data['game'] ?? existingBet.game,
      league: data['league'] ?? existingBet.league,
      team1: data['team1'] ?? existingBet.team1,
      team2: data['team2'] ?? existingBet.team2,
      oddsTeam1: data['odds_team1'] != null
          ? double.parse(data['odds_team1'].toString())
          : existingBet.oddsTeam1,
      oddsTeam2: data['odds_team2'] != null
          ? double.parse(data['odds_team2'].toString())
          : existingBet.oddsTeam2,
      status: data['status'] ?? existingBet.status,
    );

    return repository.updateBet(updatedBet);
  }

  Future<Map<String, dynamic>> getBetStats(int betId) =>
      repository.getBetStats(betId);

  Future<Map<String, dynamic>> finishBet(int betId, int winningTeam) =>
      repository.finishBet(betId, winningTeam: winningTeam);
}
