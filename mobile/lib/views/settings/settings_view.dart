// lib/views/settings/settings_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Paramètres'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            children: [
              // Section Compte
              const _SectionHeader(title: 'Compte'),
              if (viewModel.currentUser != null) ...[
                // ID Utilisateur
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('ID Utilisateur'),
                  subtitle: Text(viewModel.currentUser!.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await viewModel.copyUserId();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ID copié dans le presse-papiers'),
                        ),
                      );
                    },
                  ),
                ),
                // Pseudo
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Pseudo'),
                  subtitle: Text(viewModel.currentUser!.pseudo),
                ),
              ],

              // Section Apparence
              const _SectionHeader(title: 'Apparence'),
              SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: const Text('Activer le thème sombre'),
                value: viewModel.isDarkMode,
                onChanged: (value) => viewModel.toggleDarkMode(),
                secondary: const Icon(Icons.dark_mode),
              ),

              // Section Notifications
              const _SectionHeader(title: 'Notifications'),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Recevoir des notifications'),
                value: viewModel.areNotificationsEnabled,
                onChanged: (value) => viewModel.toggleNotifications(),
                secondary: const Icon(Icons.notifications),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('Types de notifications'),
                subtitle: const Text('Gérer les types de notifications'),
                onTap: () {
                  // Navigation vers la page de gestion des notifications
                },
              ),

              // Section À propos
              const _SectionHeader(title: 'À propos'),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.policy),
                title: const Text('Politique de confidentialité'),
                onTap: () {
                  // Navigation vers la politique de confidentialité
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Conditions d\'utilisation'),
                onTap: () {
                  // Navigation vers les conditions d'utilisation
                },
              ),

              // Section Déconnexion
              const _SectionHeader(title: 'Session'),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text(
                          'Voulez-vous vraiment vous déconnecter ?'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await viewModel.logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context,
                                  '/login'
                              );
                            }
                          },
                          child: const Text(
                            'Déconnexion',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}