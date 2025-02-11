// lib/screens/matches/matches_validation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/matches_service.dart';

class MatchesValidationScreen extends StatefulWidget {
  const MatchesValidationScreen({super.key});

  @override
  _MatchesValidationScreenState createState() =>
      _MatchesValidationScreenState();
}

class _MatchesValidationScreenState extends State<MatchesValidationScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingMatches = [];
  Set<int> _selectedMatches = {};
  late MatchesService _matchesService;

  @override
  void initState() {
    super.initState();
    _matchesService = context.read<MatchesService>();
    _loadPendingMatches();
  }

  Future<void> _loadPendingMatches() async {
    setState(() => _isLoading = true);

    try {
      final matches = await _matchesService.getPendingMatches();

      setState(() {
        _pendingMatches = matches;
        _selectedMatches.clear();
      });
    } catch (e) {
      _showError('Erreur lors du chargement des matchs : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validateSelected() async {
    if (_selectedMatches.isEmpty) {
      _showError('Veuillez sélectionner au moins un match');
      return;
    }

    try {
      for (final matchId in _selectedMatches) {
        await _matchesService.validateMatch(matchId);
      }

      _showSuccess('${_selectedMatches.length} matchs validés');
      _loadPendingMatches();
    } catch (e) {
      _showError('Erreur lors de la validation : $e');
    }
  }

  Future<void> _rejectSelected() async {
    if (_selectedMatches.isEmpty) {
      _showError('Veuillez sélectionner au moins un match');
      return;
    }

    try {
      for (final matchId in _selectedMatches) {
        await _matchesService.rejectMatch(matchId);
      }

      _showSuccess('${_selectedMatches.length} matchs rejetés');
      _loadPendingMatches();
    } catch (e) {
      _showError('Erreur lors du rejet : $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleAllMatches(bool? value) {
    if (value == null) return;

    setState(() {
      if (value) {
        _selectedMatches = _pendingMatches.map((m) => m['id'] as int).toSet();
      } else {
        _selectedMatches.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Validation des matchs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedMatches.isNotEmpty)
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _validateSelected,
                      icon: const Icon(Icons.check),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      label: Text('Valider (${_selectedMatches.length})'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _rejectSelected,
                      icon: const Icon(Icons.close),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      label: Text('Rejeter (${_selectedMatches.length})'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_pendingMatches.isEmpty)
            const Center(
              child: Text(
                'Aucun match en attente de validation',
                style: TextStyle(fontSize: 16),
              ),
            )
          else
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.grey[100],
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selectedMatches.length ==
                                _pendingMatches.length,
                            tristate: _selectedMatches.isNotEmpty &&
                                _selectedMatches.length !=
                                    _pendingMatches.length,
                            onChanged: _toggleAllMatches,
                          ),
                          const Text(
                            'Tous les matchs',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _loadPendingMatches,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Actualiser'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _pendingMatches.length,
                        itemBuilder: (context, index) {
                          final match = _pendingMatches[index];
                          final id = match['id'] as int;

                          return ListTile(
                            leading: Checkbox(
                              value: _selectedMatches.contains(id),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked ?? false) {
                                    _selectedMatches.add(id);
                                  } else {
                                    _selectedMatches.remove(id);
                                  }
                                });
                              },
                            ),
                            title: Text(
                                '${match['league']} - ${match['team1']} vs ${match['team2']}'),
                            subtitle: Text(
                                'Cotes: ${match['odds_team1']} - ${match['odds_team2']}\n'
                                'Date: ${match['scheduled_at']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle),
                                  color: Colors.green,
                                  onPressed: () async {
                                    await _matchesService.validateMatch(id);
                                    _loadPendingMatches();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel),
                                  color: Colors.red,
                                  onPressed: () async {
                                    await _matchesService.rejectMatch(id);
                                    _loadPendingMatches();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
