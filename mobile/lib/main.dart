import 'package:comeback/repository/user_repository.dart';
import 'package:comeback/viewmodels/friends_viewmodel.dart';
import 'package:comeback/viewmodels/leaderboard_viewmodel.dart';
import 'package:comeback/viewmodels/profile_viewmodel.dart';
import 'package:comeback/viewmodels/settings_viewmodel.dart';
import 'package:comeback/viewmodels/shop_viewmodel.dart';
import 'package:comeback/views/bet/bet_view.dart';
import 'package:comeback/views/friends/friends_view.dart';
import 'package:comeback/views/home/home_view.dart';
import 'package:comeback/views/profile/profile_view.dart';
import 'package:comeback/views/settings/settings_view.dart';
import 'package:comeback/views/shop/shop_view.dart';
import 'package:comeback/widgets/common/bottom_nav_bar.dart';
import 'package:comeback/widgets/common/side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'core/api/api_client.dart';
import 'core/services/storage_service.dart';
import 'core/services/auth_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'repository/bet_repository.dart';
import 'viewmodels/bet_viewmodel.dart';
import 'views/leaderboard/leaderboard_view.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final storageService = await StorageService.getInstance();
  final authService = AuthService(apiClient, storageService);

  // Récupération du token stocké si existant
  final token = storageService.getAuthToken();
  if (token != null) {
    apiClient.setAuthToken(token);
  }

  runApp(MyApp(
    apiClient: apiClient,
    authService: authService,
  ));
}


class MainNavigationView extends StatefulWidget {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  _MainNavigationViewState createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeView(),
      ChangeNotifierProvider(
        create: (context) {
          final apiClient = Provider.of<ApiClient>(context, listen: false);
          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
          return BetViewModel(BetRepository(apiClient), authViewModel);
        },
        child: const BetView(),
      ),
      ChangeNotifierProvider(
        create: (context) {
          final apiClient = Provider.of<ApiClient>(context, listen: false);
          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
          return LeaderboardViewModel(
            UserRepository(apiClient),
            authViewModel,
          );
        },
        child: const LeaderboardView(),
      ),
      ChangeNotifierProvider(
        create: (context) {
          final apiClient = Provider.of<ApiClient>(context, listen: false);
          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
          return ProfileViewModel(
            UserRepository(apiClient),
            authViewModel,
          );
        },
        child: const ProfileView(),
      ),
      ChangeNotifierProvider(
        create: (context) {
          final apiClient = Provider.of<ApiClient>(context, listen: false);
          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
          return FriendsViewModel(
            UserRepository(apiClient),
            authViewModel,
          );
        },
        child: const FriendsView(),
      ),
      ChangeNotifierProvider(
        create: (context) {
          final apiClient = Provider.of<ApiClient>(context, listen: false);
          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
          return ShopViewModel(
            UserRepository(apiClient),
            authViewModel,
          );
        },
        child: const ShopView(),
      ),
      ChangeNotifierProvider(
        create: (context) {
          final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
          return SettingsViewModel(authViewModel);
        },
        child: const SettingsView(),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comeback'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: const SideDrawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  final AuthService authService;
  final ApiClient apiClient;

  const MyApp({
    Key? key,
    required this.authService,
    required this.apiClient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authService),
        ),
      ],
      child: MaterialApp(
        title: 'Comeback',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(),
        onUnknownRoute: AppRoutes.unknownRoute,
      ),
    );
  }
}

