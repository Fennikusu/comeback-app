class SubBet {
  final String id;
  final String betId;
  final String description;
  final String option1;
  final String option2;
  final String status;

  SubBet({
    required this.id,
    required this.betId,
    required this.description,
    required this.option1,
    required this.option2,
    required this.status,
  });

  factory SubBet.fromJson(Map<String, dynamic> json) {
    return SubBet(
      id: json['id'],
      betId: json['bet_id'],
      description: json['description'],
      option1: json['option1'],
      option2: json['option2'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bet_id': betId,
    'description': description,
    'option1': option1,
    'option2': option2,
    'status': status,
  };

  // Copie l'objet avec possibilité de modifier certains champs
  SubBet copyWith({
    String? id,
    String? betId,
    String? description,
    String? option1,
    String? option2,
    String? status,
  }) {
    return SubBet(
      id: id ?? this.id,
      betId: betId ?? this.betId,
      description: description ?? this.description,
      option1: option1 ?? this.option1,
      option2: option2 ?? this.option2,
      status: status ?? this.status,
    );
  }
}