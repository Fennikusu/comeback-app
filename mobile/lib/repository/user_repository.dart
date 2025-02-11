// lib/repository/user_repository.dart
import '../core/api/api_client.dart';
import '../models/shop_item.dart';
import '../models/user.dart';
import '../config/constants.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<List<User>> getGlobalLeaderboard() async {
    final response = await _apiClient.get<List<dynamic>>(
      '${AppConstants.leaderboardEndpoint}/global',
    );

    if (response.success && response.data != null) {
      return (response.data as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.error ?? 'Failed to load global leaderboard');
    }
  }

  Future<List<User>> getFriendsLeaderboard(int userId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${AppConstants.leaderboardEndpoint}/friends/$userId',
    );

    if (response.success && response.data != null) {
      return (response.data as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.error ?? 'Failed to load friends leaderboard');
    }
  }

  Future<Map<String, dynamic>> getAudaciousLeaderboard() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.leaderboardEndpoint}/audacious',
    );

    if (response.success && response.data != null) {
      // On retourne directement la réponse qui contient winner et loser
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Failed to load audacious leaderboard');
    }
  }

  // Récupère les items débloqués de l'utilisateur
  Future<List<ShopItem>> getUnlockedItems(int userId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '${AppConstants.userProfileEndpoint}/$userId/items',
    );

    if (response.success && response.data != null) {
      return (response.data as List)
          .map((json) => ShopItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.error ?? 'Failed to load unlocked items');
    }
  }

  // Met à jour le profil de l'utilisateur
  Future<void> updateUserProfile(int userId, Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${AppConstants.userProfileEndpoint}/$userId/update',
      body: data,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to update profile');
    }
  }

  // Récupère les détails du profil utilisateur
  Future<User> getUserProfile(int userId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.userProfileEndpoint}/$userId',
    );

    if (response.success && response.data != null) {
      return User.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load user profile');
    }
  }

  // Récupère les items disponibles pour l'utilisateur (débloqués et non débloqués)
  Future<Map<String, List<ShopItem>>> getAvailableItems(int userId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.userProfileEndpoint}/$userId/available-items',
    );

    if (response.success && response.data != null) {
      return {
        'profile_pictures': (response.data!['profile_pictures'] as List)
            .map((json) => ShopItem.fromJson(json as Map<String, dynamic>))
            .toList(),
        'banners': (response.data!['banners'] as List)
            .map((json) => ShopItem.fromJson(json as Map<String, dynamic>))
            .toList(),
        'titles': (response.data!['titles'] as List)
            .map((json) => ShopItem.fromJson(json as Map<String, dynamic>))
            .toList(),
      };
    } else {
      throw Exception(response.error ?? 'Failed to load available items');
    }
  }

  Future<List<User>> getFriendsList(int userId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/users/$userId/friends',
    );

    if (response.success && response.data != null) {
      return (response.data as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.error ?? 'Failed to load friends');
    }
  }

  Future<void> addFriend(int userId, int friendId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/$userId/friends',
      body: {'friend_id': friendId},
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to add friend');
    }
  }

  Future<void> removeFriend(int userId, int friendId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/users/$userId/friends/$friendId',
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to remove friend');
    }
  }

  Future<void> unlockItem(int userId, String itemId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/$userId/unlocks',
      body: {
        'items': [itemId],
      },
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to unlock item');
    }
  }
}