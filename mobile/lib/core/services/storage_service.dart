import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _preferences = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Auth Token
  Future<bool> setAuthToken(String token) async {
    return await _preferences!.setString(AppConstants.authTokenKey, token);
  }

  String? getAuthToken() {
    return _preferences!.getString(AppConstants.authTokenKey);
  }

  Future<bool> removeAuthToken() async {
    return await _preferences!.remove(AppConstants.authTokenKey);
  }

  // User ID
  Future<bool> setUserId(String userId) async {
    return await _preferences!.setString(AppConstants.userIdKey, userId);
  }

  String? getUserId() {
    return _preferences!.getString(AppConstants.userIdKey);
  }

  Future<bool> removeUserId() async {
    return await _preferences!.remove(AppConstants.userIdKey);
  }

  // Clear all data
  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }
}