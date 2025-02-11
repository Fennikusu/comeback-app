// lib/viewmodels/home_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/user_bet.dart';
import '../core/api/api_client.dart';
import 'auth_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final AuthViewModel _authViewModel;

  List<UserBet> _recentBets = [];
  bool _isLoadingBets = false;
  bool _isDailyChestAvailable = false;
  double _lastSessionEarnings = 0;
  String? _error;

  // Getters manquants
  List<UserBet> get recentBets => _recentBets;
  bool get isLoadingBets => _isLoadingBets;
  bool get isDailyChestAvailable => _isDailyChestAvailable;
  double get lastSessionEarnings => _lastSessionEarnings;
  String? get error => _error;

  HomeViewModel(this._apiClient, this._authViewModel) {
    _init();
  }

  // Méthode init manquante
  Future<void> _init() async {
    await Future.wait([
      _loadRecentBets(),
      _checkDailyChest(),
      _getLastSessionEarnings(),
    ]);
  }

  Future<void> _loadRecentBets() async {
    _isLoadingBets = true;
    notifyListeners();

    try {
      final userId = _authViewModel.currentUser?.id;
      final response = await _apiClient.get(
        '/profile/$userId/bets',
      );

      if (response.success && response.data != null) {
        _recentBets = (response.data as List)
            .map((bet) => UserBet.fromJson(bet))
            .toList();
        _error = null;
      } else {
        _error = response.error;
        _recentBets = [];
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des paris récents';
      _recentBets = [];
    } finally {
      _isLoadingBets = false;
      notifyListeners();
    }
  }

  Future<void> _checkDailyChest() async {
    try {
      final userId = _authViewModel.currentUser?.id;
      final response = await _apiClient.get(
        '/profile/$userId/daily-chest',
      );

      if (response.success) {
        _isDailyChestAvailable = response.data?['available'] ?? false;
      }
    } catch (e) {
      _isDailyChestAvailable = false;
    }
    notifyListeners();
  }

  Future<void> _getLastSessionEarnings() async {
    try {
      final userId = _authViewModel.currentUser?.id;
      final response = await _apiClient.get(
        '/profile/$userId/last-session-earnings',
      );

      if (response.success) {
        _lastSessionEarnings = double.parse(
            response.data?['earnings'].toString() ?? '0'
        );
      }
    } catch (e) {
      _lastSessionEarnings = 0;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> openDailyChest() async {
    try {
      final userId = _authViewModel.currentUser?.id;
      final response = await _apiClient.post(
        '/profile/$userId/daily-chest',
      );

      if (response.success) {
        _isDailyChestAvailable = false;
        await _getLastSessionEarnings(); // Mettre à jour le solde
        notifyListeners();
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _error = 'Erreur lors de l\'ouverture du coffre';
      notifyListeners();
      return null;
    }
  }

  // Méthode refresh manquante
  Future<void> refresh() async {
    _error = null;
    await _init();
  }
}