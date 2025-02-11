// lib/models/user.dart

class User {
  final int id;
  final String pseudo;
  final String email;
  final int coins;
  final int totalEarnings;
  final int profilePicture;
  final int banner;
  final int title;
  final DateTime createdAt;
  final DateTime? lastChestClaim;

  User({
    required this.id,
    required this.pseudo,
    required this.email,
    required this.coins,
    required this.totalEarnings,
    required this.profilePicture,
    required this.banner,
    required this.title,
    required this.createdAt,
    this.lastChestClaim,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      pseudo: json['pseudo'],
      email: json['email'],
      coins: json['coins'],
      totalEarnings: json['total_earnings'],
      profilePicture: json['profile_picture'],
      banner: json['banner'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      lastChestClaim: json['last_chest_claim'] != null
          ? DateTime.parse(json['last_chest_claim'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pseudo': pseudo,
        'email': email,
        'coins': coins,
        'total_earnings': totalEarnings,
        'profile_picture': profilePicture,
        'banner': banner,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'last_chest_claim': lastChestClaim?.toIso8601String(),
      };
}
