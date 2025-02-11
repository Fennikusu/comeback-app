// lib/models/bet.dart
import 'sub_bet.dart';

class Bet {
  final String id;
  final String game;
  final String league;
  final String team1;
  final String team2;
  final double oddsTeam1;
  final double oddsTeam2;
  final String status;
  final List<SubBet>? subBets;
  final DateTime matchDate;

  Bet({
    required this.id,
    required this.game,
    required this.league,
    required this.team1,
    required this.team2,
    required this.oddsTeam1,
    required this.oddsTeam2,
    required this.status,
    this.subBets,
    DateTime? matchDate,
  }) : this.matchDate = matchDate ?? DateTime.now();

  factory Bet.fromJson(Map<String, dynamic> json) {
    return Bet(
      id: json['id'].toString(),
      game: json['game'].toString(),
      league: json['league'].toString(),
      team1: json['team1'].toString(),
      team2: json['team2'].toString(),
      oddsTeam1: double.parse(json['odds_team1'].toString()),
      oddsTeam2: double.parse(json['odds_team2'].toString()),
      status: json['status'].toString(),
      matchDate: json['match_date'] != null
          ? DateTime.parse(json['match_date'].toString())
          : DateTime.now(),
      subBets: json['sub_bets'] != null
          ? List<SubBet>.from(json['sub_bets'].map((x) => SubBet.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game': game,
      'league': league,
      'team1': team1,
      'team2': team2,
      'odds_team1': oddsTeam1.toString(),
      'odds_team2': oddsTeam2.toString(),
      'status': status,
      'match_date': matchDate.toIso8601String(),
      'sub_bets': subBets?.map((x) => x.toJson()).toList(),
    };
  }

  // Utile pour mettre à jour certains champs sans modifier les autres
  Bet copyWith({
    String? id,
    String? game,
    String? league,
    String? team1,
    String? team2,
    double? oddsTeam1,
    double? oddsTeam2,
    String? status,
    List<SubBet>? subBets,
    DateTime? matchDate,
  }) {
    return Bet(
      id: id ?? this.id,
      game: game ?? this.game,
      league: league ?? this.league,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      oddsTeam1: oddsTeam1 ?? this.oddsTeam1,
      oddsTeam2: oddsTeam2 ?? this.oddsTeam2,
      status: status ?? this.status,
      subBets: subBets ?? this.subBets,
      matchDate: matchDate ?? this.matchDate,
    );
  }

  // Helper pour obtenir les cotes d'une équipe spécifique
  double getOddsForTeam(String team) {
    if (team == team1) return oddsTeam1;
    if (team == team2) return oddsTeam2;
    throw Exception('Team not found in bet');
  }
}