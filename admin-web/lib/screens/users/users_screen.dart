// lib/screens/users/users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/users_service.dart';
import '../../models/user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late UsersService _usersService;
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usersService = UsersService(
      Provider.of<AuthService>(context, listen: false).token,
    );
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _usersService.getUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showUserDetails(User user) async {
    try {
      final details = await _usersService.getUserDetails(user.id);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _UserDetailsDialog(user: details),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des utilisateurs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUsers,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)))
          else
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Pseudo')),
                      DataColumn(label: Text('Pièces')),
                      DataColumn(label: Text('Gains totaux')),
                      DataColumn(label: Text('Date inscription')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _users.map<DataRow>((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user.id.toString())),
                          DataCell(Text(user.pseudo)),
                          DataCell(Text(user.coins.toString())),
                          DataCell(Text(user.totalEarnings.toString())),
                          DataCell(Text(user.createdAt
                              .toLocal()
                              .toString()
                              .split('.')[0])),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () => _showUserDetails(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // TODO: Implement edit functionality
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final User user;

  const _UserDetailsDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Détails de ${user.pseudo}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailItem(label: 'Email', value: user.email),
            _DetailItem(label: 'Pièces', value: user.coins.toString()),
            _DetailItem(
                label: 'Gains totaux', value: user.totalEarnings.toString()),
            _DetailItem(
                label: 'Photo de profil', value: 'ID: ${user.profilePicture}'),
            _DetailItem(label: 'Bannière', value: 'ID: ${user.banner}'),
            _DetailItem(label: 'Titre', value: 'ID: ${user.title}'),
            _DetailItem(
                label: 'Date d\'inscription',
                value: user.createdAt.toLocal().toString().split('.')[0]),
            _DetailItem(
              label: 'Dernière récupération coffre',
              value: user.lastChestClaim?.toLocal().toString().split('.')[0] ??
                  'Jamais',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
