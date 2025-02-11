import 'package:flutter/material.dart';

import '../../config/routes.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Comeback',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Boutique'),
            onTap: () {
              Navigator.pop(context); // Ferme le drawer
              Navigator.pushNamed(context, AppRoutes.shop);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Amis'),
            onTap: () {
              Navigator.pop(context); // Ferme le drawer
              Navigator.pushNamed(context, AppRoutes.friends);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context); // Ferme le drawer
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
    );
  }
}