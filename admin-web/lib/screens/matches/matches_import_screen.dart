// lib/screens/matches/matches_import_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/matches_service.dart';

class MatchesImportScreen extends StatefulWidget {
  const MatchesImportScreen({super.key});

  @override
  _MatchesImportScreenState createState() => _MatchesImportScreenState();
}

class _MatchesImportScreenState extends State<MatchesImportScreen> {
  bool _isLoading = false;
  bool _isImporting = false;
  List<Map<String, dynamic>> _leagues = [];
  Set<String> _selectedLeagues = {};
  Set<String> _autoValidateLeagues = {};
  Set<String> _selectedRegions = {};
  List<String> _allRegions = [];
  String? _lastImport;
  bool _showTBDMatches = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadLeagues();
  }

  Future<void> _loadSettings() async {
    try {
      final matchesService = context.read<MatchesService>();
      final settings = await matchesService.getImportSettings();

      setState(() {
        _selectedLeagues = Set.from(settings['selected_leagues'] ?? []);
        _autoValidateLeagues =
            Set.from(settings['auto_validate_leagues'] ?? []);
        _selectedRegions = Set.from(settings['region_filters'] ?? []);
        _lastImport = settings['last_import'];
      });
    } catch (e) {
      _showError('Erreur lors du chargement des paramètres: $e');
    }
  }

  Future<void> _loadLeagues() async {
    setState(() => _isLoading = true);

    try {
      final matchesService = context.read<MatchesService>();
      final leagues = await matchesService.getAvailableLeagues();

      setState(() {
        _leagues = leagues;
        _allRegions = leagues.map((l) => l['region'] as String).toSet().toList()
          ..sort();
        _isLoading = false;
      });
    } catch (e) {
      _showError('Erreur lors du chargement des ligues: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final matchesService = context.read<MatchesService>();
      await matchesService.updateImportSettings({
        'selected_leagues': _selectedLeagues.toList(),
        'auto_validate_leagues': _autoValidateLeagues.toList(),
        'region_filters': _selectedRegions.toList(),
        'show_tbd': _showTBDMatches,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres enregistrés'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Erreur lors de la sauvegarde: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importMatches() async {
    if (_selectedLeagues.isEmpty) {
      _showError('Veuillez sélectionner au moins une ligue');
      return;
    }

    print(
        'Selected leagues before import: $_selectedLeagues'); // Log des ligues sélectionnées
    setState(() => _isImporting = true);

    try {
      final matchesService = context.read<MatchesService>();
      final result = await matchesService.importMatches(_selectedLeagues);

      setState(() => _lastImport = DateTime.now().toIso8601String());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Import terminé : ${result['imported_matches']} matchs importés'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Erreur lors de l\'import: $e');
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getFilteredLeagues() {
    return _leagues.where((league) {
      return _selectedRegions.isEmpty ||
          _selectedRegions.contains(league['region']);
    }).toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  Widget _buildRegionFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const Text(
              'Régions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allRegions.map((region) {
                return FilterChip(
                  label: Text(region),
                  selected: _selectedRegions.contains(region),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedRegions.add(region);
                      } else {
                        _selectedRegions.remove(region);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaguesList() {
    final filteredLeagues = _getFilteredLeagues();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_esports),
                const SizedBox(width: 8),
                const Text(
                  'Ligues disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    final allSlugs =
                        filteredLeagues.map((l) => l['slug'] as String).toSet();
                    setState(() {
                      if (_selectedLeagues.length == allSlugs.length) {
                        _selectedLeagues.clear();
                        _autoValidateLeagues.clear();
                      } else {
                        _selectedLeagues = allSlugs;
                      }
                    });
                  },
                  icon: Icon(
                    _selectedLeagues.length == filteredLeagues.length
                        ? Icons.deselect
                        : Icons.select_all,
                  ),
                  label: Text(
                    _selectedLeagues.length == filteredLeagues.length
                        ? 'Tout désélectionner'
                        : 'Tout sélectionner',
                  ),
                ),
              ],
            ),
            const Divider(),
            if (_lastImport != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Dernier import : ${DateTime.parse(_lastImport!).toLocal()}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredLeagues.length,
                itemBuilder: (context, index) {
                  final league = filteredLeagues[index];
                  final slug = league['slug'] as String;
                  final isSelected = _selectedLeagues.contains(slug);

                  return Card(
                    elevation: 0,
                    color: Colors.grey[50],
                    child: ListTile(
                      title: Text(league['name'] as String),
                      subtitle: Text(league['region'] as String),
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              _selectedLeagues.add(slug);
                            } else {
                              _selectedLeagues.remove(slug);
                              _autoValidateLeagues.remove(slug);
                            }
                          });
                        },
                      ),
                      trailing: isSelected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Auto-validation'),
                                Switch(
                                  value: _autoValidateLeagues.contains(slug),
                                  onChanged: (autoValidate) {
                                    setState(() {
                                      if (autoValidate) {
                                        _autoValidateLeagues.add(slug);
                                      } else {
                                        _autoValidateLeagues.remove(slug);
                                      }
                                    });
                                  },
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
              Text(
                'Configuration de l\'import',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _showTBDMatches,
                        onChanged: (value) {
                          setState(() => _showTBDMatches = value ?? false);
                        },
                      ),
                      const Text('Inclure les matchs TBD'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading || _isImporting ? null : _importMatches,
                    icon: _isImporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download),
                    label: const Text('Importer les matchs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: _buildRegionFilters(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildLeaguesList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadLeagues,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser les ligues'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveSettings,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Enregistrer les paramètres'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
