import 'dart:developer' as developer;
import '../../models/user.dart';
import '../api/api_client.dart';
import 'storage_service.dart';
import '../../config/constants.dart';

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthService(this._apiClient, this._storageService);

  Future<ApiResponse<User>> login(String email, String password) async {
    final response = await _apiClient.post(
      AppConstants.loginEndpoint,
      body: {
        'email': email.trim(),
        'password': password.trim(),
      },
    );

    if (response.success && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;
      final token = responseData['token'] as String;
      final userData = responseData['user'] as Map<String, dynamic>;

      developer.log('Login successful, saving token: ${token.substring(0, 10)}...');
      await _storageService.setAuthToken(token);
      _apiClient.setAuthToken(token);

      return ApiResponse(
        success: true,
        data: User.fromJson(userData),
      );

    }

    developer.log('Login failed: ${response.error}');
    return ApiResponse(
      success: false,
      error: response.error ?? 'Erreur lors de la connexion',
    );
  }

  Future<ApiResponse<User>> register(String pseudo, String email, String password) async {
    developer.log('Attempting to register user with email: $email and pseudo: $pseudo');

    final response = await _apiClient.post(
      AppConstants.registerEndpoint,
      body: {
        'pseudo': pseudo.trim(),
        'email': email.trim(),
        'password': password.trim(),
      },
    );

    if (response.success && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;
      final token = responseData['token'] as String;
      final userData = responseData['user'] as Map<String, dynamic>;

      developer.log('Registration successful, saving token: ${token.substring(0, 10)}...');
      await _storageService.setAuthToken(token);
      _apiClient.setAuthToken(token);

      return ApiResponse(
        success: true,
        data: User.fromJson(userData),
      );
    }

    developer.log('Registration failed: ${response.error}');
    return ApiResponse(
      success: false,
      error: response.error ?? 'Erreur lors de l\'inscription',
    );
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.getAuthToken();
    developer.log('Checking auth status, token exists: ${token != null}');
    return token != null;
  }

  Future<bool> verifyToken() async {
    try {
      final response = await getCurrentUser();
      return response.success;
    } catch (e) {
      developer.log('Token verification failed: $e');
      return false;
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    developer.log('Getting current user data');
    try {
      final response = await _apiClient.get(
        AppConstants.userProfileEndpoint,
      );

      // Log de la réponse brute
      developer.log('Raw API response: ${response.data}');

      if (!response.success) {
        developer.log('Failed to get user data: ${response.error}');
        await logout();
        return ApiResponse(success: false, error: response.error);
      }

      if (response.data != null) {
        try {
          final user = User.fromJson(response.data as Map<String, dynamic>);
          developer.log('User parsed successfully with all fields: ${user.toJson()}');
          return ApiResponse(success: true, data: user);
        } catch (e, stackTrace) {
          developer.log('Error parsing user data: $e');
          developer.log('Stack trace: $stackTrace');
          return ApiResponse(success: false, error: 'Error parsing user data');
        }
      }

      return ApiResponse(success: false, error: 'No data received');
    } catch (e, stackTrace) {
      developer.log('Error in getCurrentUser: $e');
      developer.log('Stack trace: $stackTrace');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    developer.log('Logging out user');
    await _storageService.removeAuthToken();
    await _storageService.removeUserId();
    _apiClient.removeAuthToken();
  }
}