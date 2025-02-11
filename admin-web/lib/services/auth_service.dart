// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/admin_config.dart';
import '../config/api_config.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  String? _token;
  Map<String, dynamic>? _userData;

  AuthService(this._prefs) {
    _token = _prefs.getString('token');
    final userDataStr = _prefs.getString('userData');
    if (userDataStr != null) {
      _userData = json.decode(userDataStr);
    }
  }

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  Future<bool> isAuthenticated() async {
    return _token != null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (!AdminConfig.isAuthorizedAdmin(email)) {
      return {'success': false, 'message': 'Accès non autorisé'};
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.login)),
        body: json.encode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _userData = data['user'];

        await _prefs.setString('token', _token!);
        await _prefs.setString('userData', json.encode(_userData));

        notifyListeners();
        return {'success': true};
      }

      return {'success': false, 'message': 'Identifiants incorrects'};
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.logout)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
      );
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _token = null;
      _userData = null;
      await _prefs.remove('token');
      await _prefs.remove('userData');
      notifyListeners();
    }
  }
}
