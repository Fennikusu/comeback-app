// lib/viewmodels/bet_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/bet.dart';
import '../models/user_bet.dart';
import '../repository/bet_repository.dart';
import '../viewmodels/auth_viewmodel.dart';

class BetViewModel extends ChangeNotifier {
  final BetRepository _betRepository;
  final AuthViewModel _authViewModel;

  List<Bet> _availableBets = [];
  List<UserBet> _userBets = [];
  Bet? _selectedBet;
  bool _isLoading = false;
  String _error = '';
  String _selectedGame = 'League of Legends';

  List<Bet> get availableBets => _availableBets;
  List<UserBet> get userBets => _userBets;
  Bet? get selectedBet => _selectedBet;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get selectedGame => _selectedGame;

  BetViewModel(this._betRepository, this._authViewModel);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> changeGame(String game) async {
    _selectedGame = game;
    notifyListeners();
    await loadAvailableBets();
  }

  Future<void> loadAvailableBets() async {
    try {
      _setLoading(true);
      _availableBets = await _betRepository.getAvailableBets(_selectedGame);
      _error = '';
    } catch (e) {
      _error = e.toString();
      _availableBets = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserBets() async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        _error = 'Utilisateur non connecté';
        return;
      }

      _setLoading(true);
      final userId = _authViewModel.currentUser!.id;
      if (userId == null || userId.isEmpty) {
        _error = 'ID utilisateur invalide';
        return;
      }

      try {
        _userBets = await _betRepository.getUserBets(int.parse(userId));
        _error = '';
      } catch (parseError) {
        print('Erreur de conversion ID: $parseError');
        _userBets = [];
        _error = 'Erreur lors du chargement des paris';
      }
    } catch (e) {
      print('Erreur dans loadUserBets: $e');
      _error = e.toString();
      _userBets = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectBet(String betId) async {
    try {
      _setLoading(true);
      final bet = await _betRepository.getBetDetails(betId);
      _selectedBet = bet;
      _error = '';
    } catch (e) {
      _error = e.toString();
      _selectedBet = null;
    } finally {
      _setLoading(false);
    }
  }

  UserBet? findUserBetForBet(String betId) {
    try {
      return _userBets.firstWhere(
            (userBet) => userBet.betId.toString() == betId,
      );
    } catch (e) {
      return null;  // Retourne null si aucun pari n'est trouvé
    }
  }

  // Dans BetViewModel, ajoutez ou modifiez ces méthodes
  Future<void> loadBetUserBets(String betId) async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        _error = 'Utilisateur non connecté';
        return;
      }

      _setLoading(true);

      // Charger d'abord tous les paris de l'utilisateur
      await loadUserBets();

      // Filtrer pour ne garder que les paris sur ce match spécifique
      _userBets = _userBets.where((bet) => bet.betId.toString() == betId).toList();
      _error = '';
    } catch (e) {
      _error = e.toString();
      _userBets = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> placeBet({
    required String betId,
    required String selectedTeam,
    required int amount,
    String? subBetId,
  }) async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        _error = 'Utilisateur non connecté';
        return false;
      }

      _setLoading(true);

      final userId = _authViewModel.currentUser!.id;
      if (userId == null || userId.isEmpty) {
        _error = 'ID utilisateur invalide';
        return false;
      }

      int parsedUserId;
      try {
        parsedUserId = int.parse(userId);
      } catch (e) {
        print('Erreur de conversion ID: $e');
        _error = 'ID utilisateur invalide';
        return false;
      }

      // Vérification du solde
      final hasEnoughBalance = await _betRepository.checkUserBalance(parsedUserId, amount);
      if (!hasEnoughBalance) {
        _error = 'Solde insuffisant pour placer ce pari';
        return false;
      }

      // Place le pari
      await _betRepository.placeBet(
        userId: parsedUserId,
        betId: betId,
        selectedTeam: selectedTeam,
        amount: amount,
        subBetId: subBetId,
      );

      // Ne pas recharger les paris immédiatement pour éviter l'erreur
      _error = '';
      return true;
    } catch (e) {
      print('Erreur dans placeBet: $e');
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelBet(String betId) async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        _error = 'Utilisateur non connecté';
        return false;
      }

      _setLoading(true);
      final success = await _betRepository.cancelBet(betId);
      if (success) {
        await loadUserBets();
        _error = '';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<UserBet>> getRecentBets() async {
    try {
      if (!_authViewModel.isLoggedIn || _authViewModel.currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final userId = int.parse(_authViewModel.currentUser!.id);
      return await _betRepository.getRecentBets(userId);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }


  // Dans BetViewModel
  List<Bet> get availableUnplacedBets {
    // Récupérer les IDs des paris déjà placés par l'utilisateur
    final placedBetIds = userBets.map((ub) => ub.betId.toString()).toList();
    // Retourner les paris qui ne sont pas dans cette liste
    return _availableBets.where((bet) => !placedBetIds.contains(bet.id)).toList();
  }

  List<Bet> get placedBets {
    // Récupérer les IDs des paris déjà placés
    final placedBetIds = userBets.map((ub) => ub.betId.toString()).toList();
    // Retourner les paris qui sont dans cette liste
    return _availableBets.where((bet) => placedBetIds.contains(bet.id)).toList();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}