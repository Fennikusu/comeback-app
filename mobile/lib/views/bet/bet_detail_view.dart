// lib/views/bet/bet_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bet.dart';
import '../../viewmodels/bet_viewmodel.dart';
import '../../core/services/auth_service.dart';

class BetDetailView extends StatefulWidget {
  final String betId;

  const BetDetailView({
    Key? key,
    required this.betId,
  }) : super(key: key);

  @override
  State<BetDetailView> createState() => _BetDetailViewState();
}

class _BetDetailViewState extends State<BetDetailView> {
  final _amountController = TextEditingController();
  String? _selectedTeam;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final viewModel = context.read<BetViewModel>();
      await viewModel.selectBet(widget.betId);
      await viewModel.loadBetUserBets(widget.betId);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BetViewModel>(
      builder: (context, viewModel, child) {
        final bet = viewModel.selectedBet;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Détails du match'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : bet == null
              ? const Center(child: Text('Erreur lors du chargement du pari'))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMatchCard(bet),
                const SizedBox(height: 24),
                _buildBettingSection(bet),
                if (viewModel.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      viewModel.error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _buildUserBetsSection(viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(Bet bet) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              bet.league,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        bet.team1,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'x${bet.oddsTeam1.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        bet.team2,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'x${bet.oddsTeam2.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBetsSection(BetViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vos paris placés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.userBets.isEmpty)
              const Center(
                child: Text('Aucun pari placé sur ce match'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.userBets.length,
                itemBuilder: (context, index) {
                  final bet = viewModel.userBets[index];
                  return Card(
                    child: ListTile(
                      title: Text(bet.selectedTeam),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Montant: ${bet.amount} coins'),
                          Text('Date: ${_formatDate(bet.createdAt)}'),
                          Text('Statut: ${_formatStatus(bet.result)}'),
                        ],
                      ),
                      trailing: _getBetStatusIcon(bet.result),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'win':
        return 'Gagné';
      case 'lose':
        return 'Perdu';
      default:
        return status;
    }
  }

  Widget _getBetStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'win':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'lose':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
    }
  }

  Widget _buildBettingSection(Bet bet) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Placez votre pari',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Sélection d'équipe
            Row(
              children: [
                Expanded(
                  child: _buildTeamButton(
                    team: bet.team1,
                    odds: bet.oddsTeam1,
                    isSelected: _selectedTeam == bet.team1,
                    onTap: () => setState(() => _selectedTeam = bet.team1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTeamButton(
                    team: bet.team2,
                    odds: bet.oddsTeam2,
                    isSelected: _selectedTeam == bet.team2,
                    onTap: () => setState(() => _selectedTeam = bet.team2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Champ de montant
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant du pari',
                hintText: 'Entrez votre mise',
                prefixIcon: const Icon(Icons.monetization_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton de validation
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTeam != null && _amountController.text.isNotEmpty
                    ? () => _placeBet(bet)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirmer le pari',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamButton({
    required String team,
    required double odds,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              team,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'x${odds.toStringAsFixed(2)}',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _placeBet(Bet bet) async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      if (mounted) {  // Vérifier si le widget est toujours monté
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer un montant valide')),
        );
      }
      return;
    }

    final viewModel = context.read<BetViewModel>();
    final success = await viewModel.placeBet(
      betId: bet.id,
      selectedTeam: _selectedTeam!,
      amount: amount,
    );

    if (success && mounted) {  // Vérifier si le widget est toujours monté
      // Stocker une référence au BuildContext actuel
      final currentContext = context;
      // Recharger les paris avant la navigation
      await viewModel.loadUserBets();

      if (mounted) {  // Vérifier à nouveau si le widget est monté
        Navigator.pop(currentContext);
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Pari placé avec succès')),
        );
      }
    }
  }
}