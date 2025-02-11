// lib/screens/bets/bet_finish_dialog.dart
import 'package:flutter/material.dart';
import '../../models/bet.dart';
import '../../repository/bet_repository.dart';

class BetFinishDialog extends StatefulWidget {
  final Bet bet;
  final BetRepository betRepository;

  const BetFinishDialog({
    super.key,
    required this.bet,
    required this.betRepository,
  });

  @override
  State<BetFinishDialog> createState() => _BetFinishDialogState();
}

class _BetFinishDialogState extends State<BetFinishDialog> {
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await widget.betRepository.getBetStats(widget.bet.id!);
      if (mounted) {
        setState(() => _stats = stats);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  Future<void> _finishBet(int winningTeam) async {
    setState(() => _isLoading = true);

    try {
      final result = await widget.betRepository.finishBet(
        widget.bet.id!,
        winningTeam: winningTeam,
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finaliser le pari: ${widget.bet.team1} vs ${widget.bet.team2}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_stats != null) ...[
              Text('Nombre de paris: ${_stats!['total_bets']}'),
              Text('Montant total parié: ${_stats!['total_amount']} pièces'),
              Text('Paris sur ${widget.bet.team1}: ${_stats!['team1_bets']}'),
              Text('Paris sur ${widget.bet.team2}: ${_stats!['team2_bets']}'),
              const SizedBox(height: 24),
            ],
            const Text(
              'Sélectionnez l\'équipe gagnante :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _finishBet(1),
                    child: Text(widget.bet.team1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _finishBet(2),
                    child: Text(widget.bet.team2),
                  ),
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
