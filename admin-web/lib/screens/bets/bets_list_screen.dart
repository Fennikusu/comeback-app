// lib/screens/bets/bets_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/bets_service.dart';
import '../../models/bet.dart';
import 'bet_finish_dialog.dart';

class BetsListScreen extends StatefulWidget {
  const BetsListScreen({super.key});

  @override
  _BetsListScreenState createState() => _BetsListScreenState();
}

class _BetsListScreenState extends State<BetsListScreen>
    with SingleTickerProviderStateMixin {
  late BetsService _betsService;
  List<Bet> _bets = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _betsService = BetsService(
      Provider.of<AuthService>(context, listen: false).token,
    );
    _tabController = TabController(length: 3, vsync: this);
    _loadBets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bets = await _betsService.getBets();
      if (mounted) {
        setState(() {
          _bets = bets;
          _isLoading = false;
        });
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

  List<Bet> _getFilteredBets(String status) {
    return _bets.where((bet) => bet.status == status).toList();
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
                'Gestion des paris',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBetDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau pari'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'En cours'),
              Tab(text: 'Fermé'),
              Tab(text: 'Terminé'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BetsTable(
                    bets: _getFilteredBets('open'),
                    onStatusUpdate: _updateBetStatus,
                    onEditBet: _showBetDialog,
                  ),
                  _BetsTable(
                    bets: _getFilteredBets('closed'),
                    onStatusUpdate: _updateBetStatus,
                    onEditBet: _showBetDialog,
                  ),
                  _BetsTable(
                    bets: _getFilteredBets('finished'),
                    onStatusUpdate: _updateBetStatus,
                    onEditBet: _showBetDialog,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updateBetStatus(int? betId, String newStatus) async {
    if (betId == null) return;

    try {
      if (newStatus == 'finished') {
        // Afficher le dialog de finalisation
        final result = await showDialog(
          context: context,
          builder: (context) => BetFinishDialog(
            bet: _bets.firstWhere((b) => b.id == betId),
            betRepository: _betsService.repository,
          ),
        );

        if (result != null) {
          _loadBets();
        }
      } else {
        // Mise à jour normale du statut
        await _betsService.updateBetStatus(betId, newStatus);
        _loadBets();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showBetDialog({Bet? bet}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _BetFormDialog(
        bet: bet,
        betsService: _betsService,
      ),
    );

    if (result == true) {
      _loadBets();
    }
  }
}

class _BetsTable extends StatelessWidget {
  final List<Bet> bets;
  final Function(int?, String) onStatusUpdate;
  final Function({Bet? bet}) onEditBet;

  const _BetsTable({
    required this.bets,
    required this.onStatusUpdate,
    required this.onEditBet,
  });

  @override
  Widget build(BuildContext context) {
    if (bets.isEmpty) {
      return const Center(child: Text('Aucun pari dans cette catégorie'));
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Jeu')),
            DataColumn(label: Text('Ligue')),
            DataColumn(label: Text('Équipe 1')),
            DataColumn(label: Text('Équipe 2')),
            DataColumn(label: Text('Cote 1')),
            DataColumn(label: Text('Cote 2')),
            DataColumn(label: Text('Statut')),
            DataColumn(label: Text('Actions')),
          ],
          rows: bets.map<DataRow>((bet) {
            return DataRow(
              cells: [
                DataCell(Text(bet.id.toString())),
                DataCell(Text(bet.game)),
                DataCell(Text(bet.league)),
                DataCell(Text(bet.team1)),
                DataCell(Text(bet.team2)),
                DataCell(Text(bet.oddsTeam1.toString())),
                DataCell(Text(bet.oddsTeam2.toString())),
                DataCell(_StatusCell(
                  status: bet.status,
                  onChanged: (newStatus) => onStatusUpdate(bet.id, newStatus),
                )),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditBet(bet: bet),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;
  final Function(String) onChanged;

  const _StatusCell({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color color;
    String displayStatus;
    switch (status) {
      case 'open':
        color = Colors.green;
        displayStatus = 'En cours';
        break;
      case 'closed':
        color = Colors.orange;
        displayStatus = 'Fermé';
        break;
      case 'finished':
        color = Colors.red;
        displayStatus = 'Terminé';
        break;
      default:
        color = Colors.grey;
        displayStatus = status;
    }

    return PopupMenuButton<String>(
      initialValue: status,
      onSelected: (newStatus) async {
        try {
          await onChanged(newStatus);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Statut mis à jour avec succès')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      itemBuilder: (context) => [
        if (status != 'open')
          const PopupMenuItem(
            value: 'open',
            child: Text('Mettre en cours'),
          ),
        if (status != 'closed')
          const PopupMenuItem(
            value: 'closed',
            child: Text('Fermer'),
          ),
        if (status != 'finished')
          const PopupMenuItem(
            value: 'finished',
            child: Text('Terminer'),
          ),
      ],
      child: Chip(
        label: Text(
          displayStatus,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
      ),
    );
  }
}

class _BetFormDialog extends StatefulWidget {
  final Bet? bet;
  final BetsService betsService;

  const _BetFormDialog({
    this.bet,
    required this.betsService,
  });

  @override
  _BetFormDialogState createState() => _BetFormDialogState();
}

class _BetFormDialogState extends State<_BetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _gameController = TextEditingController();
  final _leagueController = TextEditingController();
  final _team1Controller = TextEditingController();
  final _team2Controller = TextEditingController();
  final _odds1Controller = TextEditingController();
  final _odds2Controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bet != null) {
      _gameController.text = widget.bet!.game;
      _leagueController.text = widget.bet!.league;
      _team1Controller.text = widget.bet!.team1;
      _team2Controller.text = widget.bet!.team2;
      _odds1Controller.text = widget.bet!.oddsTeam1.toString();
      _odds2Controller.text = widget.bet!.oddsTeam2.toString();
    }
  }

  @override
  void dispose() {
    _gameController.dispose();
    _leagueController.dispose();
    _team1Controller.dispose();
    _team2Controller.dispose();
    _odds1Controller.dispose();
    _odds2Controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.bet == null) {
        await widget.betsService.createBet(
          game: _gameController.text,
          league: _leagueController.text,
          team1: _team1Controller.text,
          team2: _team2Controller.text,
          oddsTeam1: double.parse(_odds1Controller.text),
          oddsTeam2: double.parse(_odds2Controller.text),
        );
      } else if (widget.bet?.id != null) {
        await widget.betsService.updateBet(
          id: widget.bet!.id!,
          data: {
            'game': _gameController.text,
            'league': _leagueController.text,
            'team1': _team1Controller.text,
            'team2': _team2Controller.text,
            'odds_team1': double.parse(_odds1Controller.text),
            'odds_team2': double.parse(_odds2Controller.text),
          },
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.bet == null ? 'Nouveau pari' : 'Modifier le pari',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _gameController,
                decoration: const InputDecoration(
                  labelText: 'Jeu',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _leagueController,
                decoration: const InputDecoration(
                  labelText: 'Ligue',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _team1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Équipe 1',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _team2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Équipe 2',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _odds1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Cote équipe 1',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Ce champ est requis';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Entrez un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _odds2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Cote équipe 2',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Ce champ est requis';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Entrez un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
