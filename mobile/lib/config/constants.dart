class AppConstants {
  // API URLs
  static const String baseApiUrl = 'http://192.168.1.12/api/public';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String userProfileEndpoint = '/profile';
  static const String betsEndpoint = '/bets';
  static const String friendsEndpoint = '/friends';
  static const String shopEndpoint = '/shop';
  static const String leaderboardEndpoint = '/leaderboard';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds


  static String imageUrl(String path) => '$baseApiUrl/$path';
  static String profileImage(String name) => '$baseApiUrl/uploads/profile_pictures/$name';
  static String bannerImage(String name) => '$baseApiUrl/uploads/banners/$name';
}