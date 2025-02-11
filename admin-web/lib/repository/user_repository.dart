// lib/repository/user_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

class UserRepository {
  final String? authToken;

  UserRepository(this.authToken);

  Future<List<User>> getAllUsers() async {
    final response = await http.get(
      Uri.parse(ApiConfig.getUrl('/leaderboard/global')),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Failed to load users');
  }

  Future<User> getUserById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.getUrl('/profile')}/$id'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    }
    throw Exception('User not found');
  }

  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.getUrl('/profile')}/$id/update'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update user');
  }
}
