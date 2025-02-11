// lib/viewmodels/friends_viewmodel.dart
import 'package:flutter/cupertino.dart';

import '../models/user.dart';
import '../repository/user_repository.dart';
import 'auth_viewmodel.dart';

class FriendsViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthViewModel _authViewModel;

  List<User> _friends = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  List<User> get friends => _friends;
  bool get isLoading => _isLoading;
  String get error => _error;

  FriendsViewModel(this._userRepository, this._authViewModel);

  Future<void> loadFriends() async {
    try {
      _setLoading(true);
      final userId = int.parse(_authViewModel.currentUser!.id);
      _friends = await _userRepository.getFriendsList(userId);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addFriend(String friendId) async {
    try {
      if (!_authViewModel.isLoggedIn) return false;

      _setLoading(true);
      final userId = int.parse(_authViewModel.currentUser!.id);
      await _userRepository.addFriend(userId, int.parse(friendId));
      await loadFriends();  // Recharger la liste
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeFriend(String friendId) async {
    try {
      if (!_authViewModel.isLoggedIn) return false;

      _setLoading(true);
      final userId = int.parse(_authViewModel.currentUser!.id);
      await _userRepository.removeFriend(userId, int.parse(friendId));
      await loadFriends();  // Recharger la liste
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}