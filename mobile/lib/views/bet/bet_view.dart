// lib/views/bet/bet_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bet.dart';
import '../../viewmodels/bet_viewmodel.dart';
import 'widgets/game_selector.dart';
import 'widgets/bet_card.dart';
import '../../config/routes.dart';

class BetView extends StatefulWidget {
  const BetView({Key? key}) : super(key: key);

  @override
  State<BetView> createState() => _BetViewState();
}

class _BetViewState extends State<BetView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => context.read<BetViewModel>().loadAvailableBets());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPlacedBets() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BetViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          floatingActionButton: _buildFloatingActionButton(viewModel),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GameSelector(),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'En cours'),
                  Tab(text: 'Fermés'),
                  Tab(text: 'Terminés'),
                ],
              ),
              if (viewModel.error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    viewModel.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(viewModel, 'open'),
                    _buildTabContent(viewModel, 'closed'),
                    _buildTabContent(viewModel, 'finished'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _buildFloatingActionButton(BetViewModel viewModel) {
    final status = _getStatusFromIndex(_tabController.index);
    final betsWithUserBets = viewModel.availableBets
        .where((bet) => bet.status == status)
        .where((bet) => viewModel.findUserBetForBet(bet.id) != null)
        .toList();

    if (betsWithUserBets.isEmpty) return null;

    return FloatingActionButton.extended(
      onPressed: _scrollToPlacedBets,
      backgroundColor: Theme.of(context).primaryColor,
      icon: const Icon(Icons.arrow_downward),
      label: Text('Mes paris (${betsWithUserBets.length})'),
    );
  }

  String _getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return 'open';
      case 1:
        return 'closed';
      case 2:
        return 'finished';
      default:
        return 'open';
    }
  }

  Widget _buildTabContent(BetViewModel viewModel, String status) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Pour les paris terminés, on ne montre que ceux où l'utilisateur a parié
    if (status == 'finished') {
      final userBets = viewModel.userBets;
      final finishedBets = viewModel.availableBets
          .where((bet) => bet.status == 'finished')
          .where((bet) => viewModel.findUserBetForBet(bet.id) != null)
          .toList();

      if (finishedBets.isEmpty) {
        return const Center(
          child: Text('Aucun pari terminé'),
        );
      }

      return SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vos paris terminés',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${finishedBets.length} ${finishedBets.length > 1 ? 'paris' : 'pari'}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: finishedBets.length,
                itemBuilder: (context, index) {
                  final bet = finishedBets[index];
                  final userBet = viewModel.findUserBetForBet(bet.id);
                  return BetCard(
                    bet: bet,
                    userBet: userBet,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.betDetail,
                        arguments: bet.id,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    // Pour les autres statuts
    final allBets = viewModel.availableBets.where((bet) => bet.status == status).toList();
    final availableBets = allBets.where((bet) => viewModel.findUserBetForBet(bet.id) == null).toList();
    final placedBets = allBets.where((bet) => viewModel.findUserBetForBet(bet.id) != null).toList();

    if (allBets.isEmpty) {
      return Center(
        child: Text('Aucun pari ${status == 'open' ? 'en cours' : 'fermé'}'),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (availableBets.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableBets.length,
                itemBuilder: (context, index) {
                  return BetCard(
                    bet: availableBets[index],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.betDetail,
                        arguments: availableBets[index].id,
                      );
                    },
                  );
                },
              ),
            ],
            if (placedBets.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vos paris placés',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total misé: ${_calculateTotalBets(placedBets, viewModel)} coins',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: placedBets.length,
                itemBuilder: (context, index) {
                  final bet = placedBets[index];
                  final userBet = viewModel.findUserBetForBet(bet.id);
                  return BetCard(
                    bet: bet,
                    userBet: userBet,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.betDetail,
                        arguments: bet.id,
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _calculateTotalBets(List<Bet> bets, BetViewModel viewModel) {
    return bets.fold<int>(0, (sum, bet) {
      final userBet = viewModel.findUserBetForBet(bet.id);
      return sum + (userBet?.amount ?? 0);
    });
  }
}