// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../bets/bets_list_screen.dart';
import '../users/users_screen.dart';
import '../shop/shop_items_screen.dart';
import '../matches/matches_import_screen.dart';
import '../matches/matches_validation_screen.dart';
import '../../widgets/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardContent(),
    const BetsListScreen(),
    const UsersScreen(),
    const ShopItemsScreen(),
    const MatchesImportScreen(),
    const MatchesValidationScreen(),
  ];

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Tableau de bord';
      case 1:
        return 'Gestion des paris';
      case 2:
        return 'Gestion des utilisateurs';
      case 3:
        return 'Gestion de la boutique';
      case 4:
        return 'Import des matchs';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getScreenTitle(_selectedIndex),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'logout') {
                            Provider.of<AuthService>(context, listen: false)
                                .logout();
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Text('Déconnexion'),
                          ),
                        ],
                        child: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tableau de bord',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              children: [
                _StatCard(
                  title: 'Paris actifs',
                  value: '0',
                  icon: Icons.sports_esports,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Utilisateurs',
                  value: '0',
                  icon: Icons.people,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Items boutique',
                  value: '0',
                  icon: Icons.shopping_bag,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
