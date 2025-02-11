// lib/viewmodels/shop_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../models/user.dart';
import '../repository/user_repository.dart';
import 'auth_viewmodel.dart';

class ShopViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthViewModel _authViewModel;

  bool _isLoading = false;
  String _error = '';
  Map<String, List<ShopItem>> _availableItems = {
    'profile_pictures': [],
    'banners': [],
    'titles': [],
  };
  List<ShopItem> _newlyUnlockedItems = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, List<ShopItem>> get availableItems => _availableItems;
  List<ShopItem> get newlyUnlockedItems => _newlyUnlockedItems;
  User? get currentUser => _authViewModel.currentUser;
  int get currentCoins => currentUser?.coins ?? 0;

  ShopViewModel(this._userRepository, this._authViewModel);

  Future<void> loadAvailableItems() async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        throw Exception('User not logged in');
      }

      _setLoading(true);
      final userId = int.parse(_authViewModel.currentUser!.id);
      final items = await _userRepository.getAvailableItems(userId);

      _newlyUnlockedItems = [];
      _availableItems = {
        'profile_pictures': _processItems(items['profile_pictures'] ?? []),
        'banners': _processItems(items['banners'] ?? []),
        'titles': _processItems(items['titles'] ?? []),
      };

      if (_newlyUnlockedItems.isNotEmpty) {
        await _unlockNewItems(userId);
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  List<ShopItem> _processItems(List<dynamic> items) {
    return items.map<ShopItem>((item) {
      if (item is! ShopItem) {
        item = ShopItem.fromJson(item as Map<String, dynamic>);
      }
      final wasLocked = !item.isUnlocked;
      final shouldBeUnlocked = currentCoins >= item.price;

      if (wasLocked && shouldBeUnlocked) {
        _newlyUnlockedItems.add(item);
      }

      return item.copyWith(isUnlocked: shouldBeUnlocked);
    }).toList();
  }

  Future<void> _unlockNewItems(int userId) async {
    for (var item in _newlyUnlockedItems) {
      await _userRepository.unlockItem(userId, item.id);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}