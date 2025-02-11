// lib/models/bet.dart

class Bet {
  final int? id;
  final String game;
  final String league;
  final String team1;
  final String team2;
  final double oddsTeam1;
  final double oddsTeam2;
  final String status;

  Bet({
    this.id,
    required this.game,
    required this.league,
    required this.team1,
    required this.team2,
    required this.oddsTeam1,
    required this.oddsTeam2,
    required this.status,
  });

  factory Bet.fromJson(Map<String, dynamic> json) {
    print('Creating Bet from JSON: $json');
    try {
      return Bet(
        id: json['id'] is String ? int.parse(json['id']) : json['id'] as int?,
        game: json['game'] as String,
        league: json['league'] as String,
        team1: json['team1'] as String,
        team2: json['team2'] as String,
        oddsTeam1: (json['odds_team1'] as num).toDouble(),
        oddsTeam2: (json['odds_team2'] as num).toDouble(),
        status: json['status'] as String? ?? 'open',
      );
    } catch (e) {
      print('Error creating Bet from JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'game': game,
        'league': league,
        'team1': team1,
        'team2': team2,
        'odds_team1': oddsTeam1,
        'odds_team2': oddsTeam2,
        'status': status,
      };

  Bet copyWith({
    int? id,
    String? game,
    String? league,
    String? team1,
    String? team2,
    double? oddsTeam1,
    double? oddsTeam2,
    String? status,
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
    );
  }
}
