// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../viewmodels/friends_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/shop_viewmodel.dart';
import '../views/friends/friends_view.dart';
import '../views/profile/profile_view.dart';
import '../views/settings/settings_view.dart';
import '../views/shop/shop_view.dart';
import '../views/splash/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/home/home_view.dart';
import '../views/bet/bet_view.dart';
import '../views/bet/bet_detail_view.dart';
import '../repository/bet_repository.dart';
import '../viewmodels/bet_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';  // Ajout de l'import
import '../core/api/api_client.dart';
import '../views/leaderboard/leaderboard_view.dart';
import '../viewmodels/leaderboard_viewmodel.dart';
import '../repository/user_repository.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String bet = '/bet';
  static const String betDetail = '/bet-detail';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String shop = '/shop';
  static const String settings = '/settings';
  static const String friends = '/friends';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashView(),
      login: (context) => const LoginView(),
      home: (context) => const MainNavigationView(),
      bet: (context) {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        return ChangeNotifierProvider(
          create: (_) => BetViewModel(
            BetRepository(apiClient),
            authViewModel,
          ),
          child: const BetView(),
        );
      },
      betDetail: (context) {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        return ChangeNotifierProvider(
          create: (_) => BetViewModel(
            BetRepository(apiClient),
            authViewModel,
          ),
          child: BetDetailView(
            betId: ModalRoute.of(context)!.settings.arguments as String,
          ),
        );
      },
      leaderboard: (context) {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        return ChangeNotifierProvider(
          create: (_) => LeaderboardViewModel(
            UserRepository(apiClient),
            authViewModel,
          ),
          child: const LeaderboardView(),
        );
      },
      profile: (context) {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        return ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            UserRepository(apiClient),
            authViewModel,
          ),
          child: const ProfileView(),
        );
      },
      shop: (context) {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        return ChangeNotifierProvider(
          create: (_) => ShopViewModel(
            UserRepository(apiClient),
            authViewModel,
          ),
          child: const ShopView(),
        );
      },
      settings: (context) {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        return ChangeNotifierProvider(
          create: (_) => SettingsViewModel(authViewModel),
          child: const SettingsView(),
        );
      },
      friends: (context) {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        return ChangeNotifierProvider(
          create: (_) => FriendsViewModel(
            UserRepository(apiClient),
            authViewModel,
          ),
          child: const FriendsView(),
        );
      },
    };
  }

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Route non trouvée: ${settings.name}'),
        ),
      ),
    );
  }
}