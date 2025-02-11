// Dans recent_bets_list.dart

import 'package:flutter/material.dart';
import '../../../models/user_bet.dart';
import 'package:intl/intl.dart'; // Pour formater les dates

class RecentBetsList extends StatelessWidget {
  final List<UserBet> bets;
  final bool isLoading;

  const RecentBetsList({
    Key? key,
    required this.bets,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filtrer les paris des dernières 24h
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final recentBets = bets.where((bet) =>
    bet.createdAt.isAfter(last24Hours) &&
        bet.result != 'pending'
    ).toList();

    // Calculer les statistiques
    int totalWins = 0;
    int totalLosses = 0;
    int totalEarnings = 0;

    for (var bet in recentBets) {
      if (bet.result == 'win') {
        totalWins++;
        totalEarnings += ((bet.amount * bet.odds) - bet.amount).round();
      } else if (bet.result == 'lose') {
        totalLosses++;
        totalEarnings -= bet.amount;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Récapitulatif des paris',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Dernières 24h',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (recentBets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Aucun pari dans les dernières 24h'),
              ),
            )
          else
            Column(
              children: [
                // Statistiques
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        'Gagnés',
                        totalWins.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        'Perdus',
                        totalLosses.toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                      _buildStatCard(
                        context,
                        'Total',
                        '${totalEarnings >= 0 ? '+' : ''}$totalEarnings',
                        Icons.account_balance_wallet,
                        totalEarnings >= 0 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Liste des paris récents
                ...recentBets.map((bet) => _buildBetItem(context, bet)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetItem(BuildContext context, UserBet bet) {
    final isWin = bet.result == 'win';
    final earnings = isWin ? ((bet.amount * bet.odds) - bet.amount).round() : -bet.amount;
    final timeFormat = DateFormat('HH:mm');

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isWin ? Colors.green : Colors.red).withOpacity(0.1),
          child: Icon(
            isWin ? Icons.check_circle : Icons.cancel,
            color: isWin ? Colors.green : Colors.red,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${bet.team1} vs ${bet.team2}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              timeFormat.format(bet.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                bet.selectedTeam,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${bet.amount} coins'),
          ],
        ),
        trailing: Text(
          '${earnings >= 0 ? '+' : ''}$earnings',
          style: TextStyle(
            color: isWin ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}