// lib/widgets/sidebar.dart
import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.dashboard,
        title: 'Tableau de bord',
        index: 0,
      ),
      _MenuItem(
        icon: Icons.sports_esports,
        title: 'Paris',
        index: 1,
      ),
      _MenuItem(
        icon: Icons.people,
        title: 'Utilisateurs',
        index: 2,
      ),
      _MenuItem(
        icon: Icons.shopping_bag,
        title: 'Boutique',
        index: 3,
      ),
      _MenuItem(
        icon: Icons.download,
        title: 'Import des matchs',
        index: 4,
      ),
      _MenuItem(
        icon: Icons.rule,
        title: 'Validation des matchs',
        index: 5,
      ),
    ];

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              'MENU',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menuItems
                  .map((item) => _SideBarItem(
                        icon: item.icon,
                        title: item.title,
                        isSelected: selectedIndex == item.index,
                        onTap: () => onItemSelected(item.index),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final int index;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.index,
  });
}

class _SideBarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideBarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
