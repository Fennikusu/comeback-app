// lib/views/bet/widgets/bet_card.dart
import 'package:flutter/material.dart';
import '../../../models/bet.dart';
import '../../../models/user_bet.dart';

class BetCard extends StatelessWidget {
  final Bet bet;
  final UserBet? userBet;
  final Function()? onTap;

  const BetCard({
    Key? key,
    required this.bet,
    this.userBet,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isFinished = bet.status == 'finished';
    final bool isClosed = bet.status == 'closed';
    final bool hasUserBet = userBet != null;
    final bool isWin = userBet?.result == 'win';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: isFinished && hasUserBet
          ? (isWin ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
          : null,
      child: InkWell(
        onTap: (isClosed || isFinished) ? null : onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bet.league,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(bet.matchDate),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(context),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTeamColumn(
                          context,
                          bet.team1,
                          bet.oddsTeam1,
                          userBet?.selectedTeam == bet.team1,
                          userBet?.selectedTeam == 'team1',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Text(
                          'VS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildTeamColumn(
                          context,
                          bet.team2,
                          bet.oddsTeam2,
                          userBet?.selectedTeam == bet.team2,
                          userBet?.selectedTeam == 'team2',
                        ),
                      ),
                    ],
                  ),
                  if (hasUserBet) ...[
                    const SizedBox(height: 16.0),
                    _buildBetInfoSection(context),
                  ],
                ],
              ),
            ),
            if (isClosed && !hasUserBet)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String text;

    switch (bet.status) {
      case 'open':
        color = Colors.green;
        text = 'EN COURS';
        break;
      case 'closed':
        color = Colors.orange;
        text = 'FERMÉ';
        break;
      case 'finished':
        color = Colors.blue;
        text = 'TERMINÉ';
        break;
      default:
        color = Colors.grey;
        text = bet.status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildTeamColumn(BuildContext context, String team, double odds, bool isSelected, bool isUserTeam) {
    final bool isFinished = bet.status == 'finished';
    final bool isClosed = bet.status == 'closed';
    final bool isDisabled = isFinished || isClosed;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: isUserTeam ? BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ) : null,
      child: Column(
        children: [
          Text(
            team,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isUserTeam
                  ? Theme.of(context).primaryColor
                  : isDisabled
                  ? Colors.grey
                  : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            'x${odds.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDisabled ? Colors.grey : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final matchDate = DateTime(date.year, date.month, date.day);

    if (matchDate == DateTime(now.year, now.month, now.day)) {
      return "Aujourd'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (matchDate == tomorrow) {
      return "Demain ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
  }

  Widget _buildBetInfoSection(BuildContext context) {
    if (userBet == null) return const SizedBox.shrink();

    final bool isFinished = bet.status == 'finished';
    final int earnings = isFinished
        ? userBet!.result == 'win'
        ? (userBet!.amount * userBet!.odds - userBet!.amount).round()
        : -userBet!.amount
        : 0;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mise placée: ${userBet!.amount} coins',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (isFinished) ...[
            const SizedBox(height: 4),
            Text(
              'Résultat: ${earnings >= 0 ? '+' : ''}$earnings coins',
              style: TextStyle(
                color: earnings >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}