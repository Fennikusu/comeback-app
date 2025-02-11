// lib/config/api_config.dart

class ApiConfig {
  static const String baseUrl =
      'http://192.168.1.12/api/public'; // URL mise à jour

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';

  // Bets endpoints
  static const String bets = '/bets';
  static const String updateBet = '/bets/update';
  static const String placeBet = '/bets/place';

  // Users endpoints
  static const String profile = '/profile';
  static const String users = '/users';
  static const String userItems = '/items';
  static const String userBets = '/bets';
  static const String userFriends = '/friends';
  static const String dailyChest = '/daily-chest';

  // Shop endpoints
  static const String shopItems = '/shop/items';
  static const String buyItem = '/shop/buy';

  static String getUrl(String endpoint) => baseUrl + endpoint;
}
