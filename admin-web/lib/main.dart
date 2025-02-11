import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/matches_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'config/theme_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ProxyProvider<AuthService, MatchesService>(
          update: (context, auth, previous) => MatchesService(auth.token),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comeback Admin',
      theme: ThemeConfig.lightTheme,
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          return FutureBuilder<bool>(
            future: authService.isAuthenticated(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return snapshot.data == true
                  ? const DashboardScreen()
                  : const LoginScreen();
            },
          );
        },
      ),
    );
  }
}
