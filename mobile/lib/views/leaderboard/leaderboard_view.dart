// lib/views/leaderboard/leaderboard_view.dart
import 'package:comeback/views/leaderboard/widgets/firends_leaderboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/leaderboard_viewmodel.dart';
import 'widgets/leaderboard_type_selector.dart';
import 'widgets/global_leaderboard.dart';
import 'widgets/firends_leaderboard.dart';
import 'widgets/audacious_leaderboard.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  _LeaderboardViewState createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<LeaderboardViewModel>().loadLeaderboard()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // En-tête avec le titre
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Classement',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sélecteur de type
                      LeaderboardTypeSelector(
                        currentType: viewModel.currentType,
                        onTypeChanged: (type) {
                          viewModel.switchType(type);
                          viewModel.loadLeaderboard();
                        },
                      ),
                    ],
                  ),
                ),

                // Message d'erreur
                if (viewModel.error.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Contenu principal
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContent(viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(LeaderboardViewModel viewModel) {
    switch (viewModel.currentType) {
      case LeaderboardType.global:
        return GlobalLeaderboard(users: viewModel.users);
      case LeaderboardType.friends:
        return FriendsLeaderboard(friends: viewModel.friends);
      case LeaderboardType.audacious:
        return AudaciousLeaderboard(
          topWinner: viewModel.topWinner,
          topLoser: viewModel.topLoser,
        );
    }
  }
}