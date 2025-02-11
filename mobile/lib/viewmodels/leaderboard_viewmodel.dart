// lib/viewmodels/leaderboard_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repository/user_repository.dart';
import 'auth_viewmodel.dart';
import 'dart:developer' as dev;

enum LeaderboardType {
  global,
  friends,
  audacious
}

class LeaderboardViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthViewModel _authViewModel;

  List<User> _users = [];
  List<User> _friends = [];
  User? _topWinner;
  User? _topLoser;
  bool _isLoading = false;
  String _error = '';
  LeaderboardType _currentType = LeaderboardType.global;

  LeaderboardViewModel(this._userRepository, this._authViewModel);

  // Getters
  List<User> get users => _users;
  List<User> get friends => _friends;
  User? get topWinner => _topWinner;
  User? get topLoser => _topLoser;
  bool get isLoading => _isLoading;
  String get error => _error;
  LeaderboardType get currentType => _currentType;

  void switchType(LeaderboardType type) {
    _currentType = type;
    notifyListeners();
  }

  Future<void> loadLeaderboard() async {
    try {
      _setLoading(true);
      switch (_currentType) {
        case LeaderboardType.global:
          _users = await _userRepository.getGlobalLeaderboard();
          break;
        case LeaderboardType.friends:
          if (_authViewModel.currentUser != null) {
            _friends = await _userRepository.getFriendsLeaderboard(
                int.parse(_authViewModel.currentUser!.id)
            );
          }
          break;
        case LeaderboardType.audacious:
          final data = await _userRepository.getAudaciousLeaderboard();
          dev.log('Audacious data received: $data');

          // Set both to null by default
          _topWinner = null;
          _topLoser = null;

          // Only try to parse if not false
          if (data['winner'] != false && data['winner'] != null) {
            if (data['winner'] is Map<String, dynamic>) {
              _topWinner = User.fromJson(data['winner'] as Map<String, dynamic>);
            }
          }

          if (data['loser'] != false && data['loser'] != null) {
            if (data['loser'] is Map<String, dynamic>) {
              _topLoser = User.fromJson(data['loser'] as Map<String, dynamic>);
            }
          }

          dev.log('Parsed winners - Winner: ${_topWinner?.pseudo}, Loser: ${_topLoser?.pseudo}');
          break;
      }
      _error = '';
    } catch (e, stackTrace) {
      dev.log('Error in loadLeaderboard: $e');
      dev.log('Stack trace: $stackTrace');
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}