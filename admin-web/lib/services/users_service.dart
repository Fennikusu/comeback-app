// lib/services/users_service.dart
import '../repository/user_repository.dart';
import '../models/user.dart';

class UsersService {
  final UserRepository _repository;

  UsersService(String? authToken) : _repository = UserRepository(authToken);

  Future<List<User>> getUsers() => _repository.getAllUsers();

  Future<User> getUserDetails(int userId) => _repository.getUserById(userId);

  Future<User> updateUser(int userId, Map<String, dynamic> data) =>
      _repository.updateUser(userId, data);
}
