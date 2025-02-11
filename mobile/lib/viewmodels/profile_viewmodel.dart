// lib/viewmodels/profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/shop_item.dart';
import '../repository/user_repository.dart';
import 'auth_viewmodel.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthViewModel _authViewModel;

  bool _isLoading = false;
  String _error = '';
  List<ShopItem> _unlockedProfilePictures = [];
  List<ShopItem> _unlockedBanners = [];
  List<ShopItem> _unlockedTitles = [];

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  List<ShopItem> get unlockedProfilePictures => _unlockedProfilePictures;
  List<ShopItem> get unlockedBanners => _unlockedBanners;
  List<ShopItem> get unlockedTitles => _unlockedTitles;
  User? get currentUser => _authViewModel.currentUser;

  ProfileViewModel(this._userRepository, this._authViewModel);

  Future<void> loadUnlockedItems() async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        _error = 'Utilisateur non connecté';
        return;
      }

      _setLoading(true);
      final userId = int.parse(_authViewModel.currentUser!.id);
      final unlockedItems = await _userRepository.getUnlockedItems(userId);

      // Séparer les items par type
      _unlockedProfilePictures = unlockedItems
          .where((item) => item.type == 'profile_picture')
          .toList();

      _unlockedBanners = unlockedItems
          .where((item) => item.type == 'banner')
          .toList();

      _unlockedTitles = unlockedItems
          .where((item) => item.type == 'title')
          .toList();

      _error = '';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfilePicture(String pictureId) async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        _error = 'Utilisateur non connecté';
        return false;
      }

      _setLoading(true);
      final userId = int.parse(_authViewModel.currentUser!.id);
      await _userRepository.updateUserProfile(userId, {
        'profile_picture': pictureId,
      });

      // Recharger les informations de l'utilisateur
      await _authViewModel.getCurrentUser();
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBanner(String bannerId) async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        _error = 'Utilisateur non connecté';
        return false;
      }

      _setLoading(true);
      final userId = int.parse(_authViewModel.currentUser!.id);
      await _userRepository.updateUserProfile(userId, {
        'banner': bannerId,
      });

      await _authViewModel.getCurrentUser();
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTitle(String titleId) async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        _error = 'Utilisateur non connecté';
        return false;
      }

      _setLoading(true);
      final userId = int.parse(_authViewModel.currentUser!.id);
      await _userRepository.updateUserProfile(userId, {
        'title': titleId,
      });

      await _authViewModel.getCurrentUser();
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}