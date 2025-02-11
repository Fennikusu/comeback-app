// lib/views/leaderboard/widgets/leaderboard_type_selector.dart
import 'package:flutter/material.dart';
import '../../../viewmodels/leaderboard_viewmodel.dart';

class LeaderboardTypeSelector extends StatelessWidget {
  final LeaderboardType currentType;
  final Function(LeaderboardType) onTypeChanged;

  const LeaderboardTypeSelector({
    Key? key,
    required this.currentType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: LeaderboardType.values.map((type) {
          final isSelected = type == currentType;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(type),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _getTypeName(type),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTypeName(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.global:
        return 'Global';
      case LeaderboardType.friends:
        return 'Amis';
      case LeaderboardType.audacious:
        return 'Audacieux';
    }
  }
}