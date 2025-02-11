class UserBet {
  final int id;
  final int userId;
  final int betId;
  final int? subBetId;  // Nullable car peut être null dans la DB
  final String game;
  final String league;
  final String team1;
  final String team2;
  final int amount;
  final double odds;
  final String selectedTeam;  // Pour savoir sur quelle équipe le pari a été placé
  final String result;  // 'win', 'lose', 'pending'
  final DateTime createdAt;

  UserBet({
    required this.id,
    required this.userId,
    required this.betId,
    this.subBetId,
    required this.game,
    required this.league,
    required this.team1,
    required this.team2,
    required this.amount,
    required this.odds,
    required this.selectedTeam,
    required this.result,
    required this.createdAt,
  });

  factory UserBet.fromJson(Map<String, dynamic> json) {
    try {
      return UserBet(
        id: int.parse(json['id']?.toString() ?? '0'),
        userId: int.parse(json['user_id']?.toString() ?? '0'),
        betId: int.parse(json['bet_id']?.toString() ?? '0'),
        subBetId: json['sub_bet_id'] != null ? int.parse(json['sub_bet_id'].toString()) : null,
        game: json['game']?.toString() ?? '',
        league: json['league']?.toString() ?? '',
        team1: json['team1']?.toString() ?? '',
        team2: json['team2']?.toString() ?? '',
        amount: int.parse(json['amount']?.toString() ?? '0'),
        odds: json['odds_team1'] != null ? double.parse(json['odds_team1'].toString()) : 0.0,
        selectedTeam: json['selected_team']?.toString() ?? '',
        result: json['result']?.toString() ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      print('Erreur dans UserBet.fromJson: $json');
      print('Exception: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id.toString(),
    'user_id': userId.toString(),
    'bet_id': betId.toString(),
    'sub_bet_id': subBetId?.toString(),
    'game': game,
    'league': league,
    'team1': team1,
    'team2': team2,
    'amount': amount.toString(),
    'selected_team': selectedTeam,
    'result': result,
    'created_at': createdAt.toIso8601String(),
  };
}