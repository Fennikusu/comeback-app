// lib/models/user.dart
import 'dart:developer' as dev;


class UserAsset {
  final String filePath;

  UserAsset({required this.filePath});

  factory UserAsset.fromJson(Map<String, dynamic> json) {
    return UserAsset(
      filePath: json['file_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'file_path': filePath,
  };
}

class User {
  final String id;
  final String pseudo;
  final String email;
  final String profilePicture;
  final String? banner;
  final String? title;
  final int coins;
  final int? totalEarnings;
  final DateTime? createdAt;
  final int? totalWin;
  final int? totalLoss;
  final DateTime? lastChestClaim;
  final UserAsset? profilePictureAsset;
  final UserAsset? bannerAsset;

  User({
    required this.id,
    required this.pseudo,
    required this.email,
    required this.profilePicture,
    this.banner,
    this.title,
    required this.coins,
    this.totalEarnings,
    this.createdAt,
    this.totalWin,
    this.totalLoss,
    this.lastChestClaim,
    this.profilePictureAsset,
    this.bannerAsset,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    dev.log('Parsing user JSON: $json'); // Ajoutez ce log pour le débogage
    return User(
      id: json['id'].toString(),
      pseudo: json['pseudo'].toString(),
      email: json['email']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '1',
      banner: json['banner']?.toString(),
      title: json['title']?.toString(),
      coins: json['coins'] is int ? json['coins'] : int.parse(json['coins'].toString()),
      lastChestClaim: json['last_chest_claim'] != null
          ? DateTime.parse(json['last_chest_claim'])
          : null,
      totalEarnings: json['total_earnings'] != null
          ? (json['total_earnings'] is int
          ? json['total_earnings']
          : int.parse(json['total_earnings'].toString()))
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      totalWin: json['total_win'] != null
          ? (json['total_win'] is int
          ? json['total_win']
          : json['total_win'] is String
          ? int.parse(json['total_win'])
          : json['total_win'] is bool
          ? 0
          : int.parse(json['total_win'].toString()))
          : null,
      totalLoss: json['total_loss'] != null
          ? (json['total_loss'] is int
          ? json['total_loss']
          : json['total_loss'] is String
          ? int.parse(json['total_loss'])
          : json['total_loss'] is bool
          ? 0
          : int.parse(json['total_loss'].toString()))
          : null,
      // Modification ici pour le mapping des assets
      profilePictureAsset: json['profile_picture_asset'] != null
          ? UserAsset(filePath: json['profile_picture_asset']['file_path'])
          : null,
      bannerAsset: json['banner_asset'] != null
          ? UserAsset(filePath: json['banner_asset']['file_path'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pseudo': pseudo,
    'email': email,
    'profile_picture': profilePicture,
    'last_chest_claim': lastChestClaim?.toIso8601String(),
    if (banner != null) 'banner': banner,
    if (title != null) 'title': title,
    'coins': coins,
    if (totalEarnings != null) 'total_earnings': totalEarnings,
    if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    if (profilePictureAsset != null) 'profile_picture_asset': {'file_path': profilePictureAsset!.filePath},
    if (bannerAsset != null) 'banner_asset': {'file_path': bannerAsset!.filePath},
  };
}