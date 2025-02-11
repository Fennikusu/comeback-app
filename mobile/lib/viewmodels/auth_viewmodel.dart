import 'package:flutter/foundation.dart';
import '../core/services/auth_service.dart';
import '../models/user.dart';
import 'dart:developer' as dev;


class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthViewModel(this._authService) {
    _checkCurrentUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;


  Future<void> _checkCurrentUser() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await getCurrentUser();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.success) {
        _currentUser = response.data;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Une erreur est survenue';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String pseudo, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(pseudo, email, password);

      if (response.success) {
        _currentUser = response.data;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Une erreur est survenue';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> getCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getCurrentUser();
      if (response.success) {
        _currentUser = response.data;
        dev.log('Current user data: ${response.data?.toJson()}'); // Ajoutez ce log
        _error = null;
      } else {
        _error = response.error;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkAutoLogin() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) return false;

    final isTokenValid = await _authService.verifyToken();
    if (!isTokenValid) {
      await _authService.logout();
      return false;
    }

    final userResponse = await _authService.getCurrentUser();
    if (userResponse.success) {
      _currentUser = userResponse.data;
      notifyListeners();
      return true;
    }

    return false;
  }
}
