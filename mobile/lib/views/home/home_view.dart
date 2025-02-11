// lib/views/home/home_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'widgets/balance_card.dart';
import 'widgets/daily_chest.dart';
import 'widgets/recent_bets_list.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final apiClient = context.read<ApiClient>();
    final user = authVM.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(apiClient, authVM),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Consumer<HomeViewModel>(
          builder: (context, homeVM, child) {
            return RefreshIndicator(
              onRefresh: () => homeVM.refresh(),
              child: CustomScrollView(
                slivers: [
                  // Balance Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: BalanceCard(
                        user: user,
                        lastSessionEarnings: homeVM.lastSessionEarnings,
                      ),
                    ),
                  ),

                  // Daily Chest
                  SliverToBoxAdapter(
                    child: DailyChest(
                      isAvailable: homeVM.isDailyChestAvailable,
                      lastClaimTime: user.lastChestClaim,
                      onOpen: () async {
                        final reward = await homeVM.openDailyChest();
                        if (reward != null && context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.celebration,
                                    size: 50,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Félicitations !',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${reward['reward']['coins']} 💰',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  if (reward['reward']['items']?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.card_giftcard, color: Colors.purple),
                                          const SizedBox(width: 8),
                                          Text(
                                            reward['reward']['items'].first['name'],
                                            style: const TextStyle(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Super !'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // Recent Bets List
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: RecentBetsList(
                        bets: homeVM.recentBets,
                        isLoading: homeVM.isLoadingBets,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}