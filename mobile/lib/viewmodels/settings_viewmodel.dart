// lib/viewmodels/settings_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import 'auth_viewmodel.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;

  bool _isDarkMode = false;
  bool _areNotificationsEnabled = true;
  String _error = '';
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  String get error => _error;
  bool get isLoading => _isLoading;
  User? get currentUser => _authViewModel.currentUser;

  SettingsViewModel(this._authViewModel);

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authViewModel.logout();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> copyUserId() async {
    if (currentUser != null) {
      await Clipboard.setData(ClipboardData(text: currentUser!.id));
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _areNotificationsEnabled = !_areNotificationsEnabled;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}