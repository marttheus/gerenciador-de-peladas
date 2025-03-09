import 'package:flutter/material.dart';
import 'dart:math';
import 'player.dart';
import 'match.dart';
import '../services/database_helper.dart';

class MyAppState extends ChangeNotifier {
  int _selectedIndex = 0;

  final List<Player> _players = [];

  final List<Match> _matches = [];

  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoaded = false;

  MyAppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoaded) return;

    try {
      final players = await _dbHelper.getPlayers();
      _players.clear();
      _players.addAll(players);

      final matches = await _dbHelper.getMatches();
      _matches.clear();
      _matches.addAll(matches);

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    }
  }

  int get selectedIndex => _selectedIndex;

  List<Player> get players => List.unmodifiable(_players);

  List<Match> get matches => List.unmodifiable(_matches);

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> addPlayer(String name, int weight) async {
    final id =
        'player_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

    final player = Player(id: id, name: name, weight: weight);

    _players.add(player);

    await _dbHelper.insertPlayer(player);

    notifyListeners();
  }

  Future<void> removePlayer(String id) async {
    _players.removeWhere((player) => player.id == id);

    await _dbHelper.deletePlayer(id);

    notifyListeners();
  }

  Future<void> updatePlayer(Player updatedPlayer) async {
    final index = _players.indexWhere(
      (player) => player.id == updatedPlayer.id,
    );

    if (index != -1) {
      _players[index] = updatedPlayer;

      await _dbHelper.updatePlayer(updatedPlayer);

      notifyListeners();
    }
  }

  Future<void> addMatch(
    DateTime dateTime,
    double cost,
    TeamSortMethod sortMethod,
    int maxPlayersPerTeam,
    List<Player> selectedPlayers,
    String? pixKey, {
    int durationMinutes = 90,
    Map<String, List<String>>? preselectedTeams,
    List<Team>? generatedTeams,
  }) async {
    final id =
        'match_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

    final match = Match(
      id: id,
      dateTime: dateTime,
      cost: cost,
      sortMethod: sortMethod,
      maxPlayersPerTeam: maxPlayersPerTeam,
      selectedPlayers: List.from(selectedPlayers),
      pixKey: pixKey,
      durationMinutes: durationMinutes,
      preselectedTeams: preselectedTeams ?? {},
      teams: generatedTeams ?? [],
    );

    if (generatedTeams == null) {
      _sortTeams(match);
    }

    _matches.add(match);

    await _dbHelper.insertMatch(match);

    notifyListeners();
  }

  Future<void> removeMatch(String id) async {
    _matches.removeWhere((match) => match.id == id);

    await _dbHelper.deleteMatch(id);

    notifyListeners();
  }

  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    final index = _matches.indexWhere((match) => match.id == matchId);

    if (index != -1) {
      final updatedMatch = _matches[index].copyWith(status: status);
      _matches[index] = updatedMatch;

      await _dbHelper.updateMatch(updatedMatch);

      notifyListeners();
    }
  }

  Future<void> updateMatchesStatus() async {
    bool hasChanges = false;

    for (int i = 0; i < _matches.length; i++) {
      final match = _matches[i];
      Match? updatedMatch;

      if (match.status == MatchStatus.scheduled && match.isInProgressNow()) {
        updatedMatch = match.copyWith(status: MatchStatus.inProgress);
        hasChanges = true;
      } else if (match.status == MatchStatus.inProgress &&
          match.isPlayedNow()) {
        updatedMatch = match.copyWith(status: MatchStatus.played);
        hasChanges = true;
      }

      if (updatedMatch != null) {
        _matches[i] = updatedMatch;

        await _dbHelper.updateMatch(updatedMatch);
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<void> markPlayerAsPaid(String matchId, String playerId) async {
    final index = _matches.indexWhere((match) => match.id == matchId);

    if (index != -1) {
      final match = _matches[index];

      if (!match.paidPlayerIds.contains(playerId)) {
        final updatedPaidPlayerIds = List<String>.from(match.paidPlayerIds)
          ..add(playerId);
        final updatedMatch = match.copyWith(
          paidPlayerIds: updatedPaidPlayerIds,
        );

        _matches[index] = updatedMatch;

        await _dbHelper.updateMatch(updatedMatch);

        notifyListeners();
      }
    }
  }

  Future<void> markPlayerAsUnpaid(String matchId, String playerId) async {
    final index = _matches.indexWhere((match) => match.id == matchId);

    if (index != -1) {
      final match = _matches[index];

      if (match.paidPlayerIds.contains(playerId)) {
        final updatedPaidPlayerIds = List<String>.from(match.paidPlayerIds)
          ..remove(playerId);
        final updatedMatch = match.copyWith(
          paidPlayerIds: updatedPaidPlayerIds,
        );

        _matches[index] = updatedMatch;

        await _dbHelper.updateMatch(updatedMatch);

        notifyListeners();
      }
    }
  }

  void _sortTeams(Match match) {
    final players = List<Player>.from(match.selectedPlayers);

    players.shuffle();

    final List<Team> teams = [];

    final int totalPlayers = players.length;
    final int maxPlayersPerTeam = match.maxPlayersPerTeam;

    final int numFullTeams = totalPlayers ~/ maxPlayersPerTeam;
    final int remainingPlayersCount = totalPlayers % maxPlayersPerTeam;

    final int totalTeams =
        remainingPlayersCount > 0 ? numFullTeams + 1 : numFullTeams;

    List<Player> preparedPlayers;

    final preselectedPlayers = <String>{};

    if (match.preselectedTeams.isNotEmpty) {
      int teamIndex = 0;
      match.preselectedTeams.forEach((teamId, playerIds) {
        final existingTeamIndex = teams.indexWhere((team) => team.id == teamId);

        if (existingTeamIndex == -1) {
          final teamName = 'Time ${String.fromCharCode(65 + teamIndex)}';
          final teamPlayers = <Player>[];

          for (final playerId in playerIds) {
            final player = players.firstWhere(
              (p) => p.id == playerId,
              orElse: () => Player(id: '', name: '', weight: 0),
            );

            if (player.id.isNotEmpty) {
              teamPlayers.add(player);
              preselectedPlayers.add(player.id);
            }
          }

          teams.add(Team(id: teamId, name: teamName, players: teamPlayers));

          teamIndex++;
        } else {
          final team = teams[existingTeamIndex];
          final teamPlayers = List<Player>.from(team.players);

          for (final playerId in playerIds) {
            final player = players.firstWhere(
              (p) => p.id == playerId,
              orElse: () => Player(id: '', name: '', weight: 0),
            );

            if (player.id.isNotEmpty && !teamPlayers.contains(player)) {
              teamPlayers.add(player);
              preselectedPlayers.add(player.id);
            }
          }

          teams[existingTeamIndex] = team.copyWith(players: teamPlayers);
        }
      });
    }

    final remainingPlayers =
        players.where((p) => !preselectedPlayers.contains(p.id)).toList();

    switch (match.sortMethod) {
      case TeamSortMethod.random:
        preparedPlayers = remainingPlayers;
        break;

      case TeamSortMethod.balanced:
        remainingPlayers.sort((a, b) => b.weight.compareTo(a.weight));
        preparedPlayers = [];

        for (int i = 0; i < totalTeams; i++) {
          for (int j = i; j < remainingPlayers.length; j += totalTeams) {
            if (j < remainingPlayers.length) {
              preparedPlayers.add(remainingPlayers[j]);
            }
          }
        }
        break;

      case TeamSortMethod.captains:
        preparedPlayers = [];

        for (int i = 0; i < totalTeams && i < remainingPlayers.length; i++) {
          final teamId = 'team_${match.id}_$i';
          final existingTeamIndex = teams.indexWhere(
            (team) => team.id == teamId,
          );

          if (existingTeamIndex == -1) {
            final teamName = 'Time ${String.fromCharCode(65 + i)}';

            teams.add(
              Team(id: teamId, name: teamName, players: [remainingPlayers[i]]),
            );
          } else {
            final team = teams[existingTeamIndex];
            final teamPlayers = List<Player>.from(team.players);

            if (!teamPlayers.contains(remainingPlayers[i])) {
              teamPlayers.add(remainingPlayers[i]);
            }

            teams[existingTeamIndex] = team.copyWith(players: teamPlayers);
          }

          preparedPlayers.add(remainingPlayers[i]);
        }

        final index = _matches.indexWhere((m) => m.id == match.id);
        if (index != -1) {
          final updatedMatch = match.copyWith(teams: teams);
          _matches[index] = updatedMatch;

          _dbHelper.updateMatch(updatedMatch);
        }

        return;
    }

    if (match.sortMethod != TeamSortMethod.captains) {
      int playerIndex = 0;

      for (int i = 0; i < totalTeams; i++) {
        final teamId = 'team_${match.id}_$i';
        final existingTeamIndex = teams.indexWhere((team) => team.id == teamId);

        if (existingTeamIndex == -1) {
          final teamName = 'Time ${String.fromCharCode(65 + i)}';
          final teamPlayers = <Player>[];

          int playersInThisTeam;
          if (i < numFullTeams) {
            playersInThisTeam = maxPlayersPerTeam;
          } else {
            playersInThisTeam = remainingPlayersCount;
          }

          for (
            int j = 0;
            j < playersInThisTeam && playerIndex < preparedPlayers.length;
            j++
          ) {
            teamPlayers.add(preparedPlayers[playerIndex++]);
          }

          teams.add(Team(id: teamId, name: teamName, players: teamPlayers));
        } else {
          final team = teams[existingTeamIndex];
          final teamPlayers = List<Player>.from(team.players);

          int playersInThisTeam;
          if (i < numFullTeams) {
            playersInThisTeam = maxPlayersPerTeam;
          } else {
            playersInThisTeam = remainingPlayersCount;
          }

          while (teamPlayers.length < playersInThisTeam &&
              playerIndex < preparedPlayers.length) {
            teamPlayers.add(preparedPlayers[playerIndex++]);
          }

          teams[existingTeamIndex] = team.copyWith(players: teamPlayers);
        }
      }
    }

    final index = _matches.indexWhere((m) => m.id == match.id);
    if (index != -1) {
      final updatedMatch = match.copyWith(teams: teams);
      _matches[index] = updatedMatch;

      _dbHelper.updateMatch(updatedMatch);
    }
  }

  Future<void> addPreselectedPlayers(
    String matchId,
    String teamId,
    List<String> playerIds,
  ) async {
    final index = _matches.indexWhere((match) => match.id == matchId);

    if (index != -1) {
      final match = _matches[index];

      final preselectedTeams = Map<String, List<String>>.from(
        match.preselectedTeams,
      );

      if (preselectedTeams.containsKey(teamId)) {
        final existingPlayerIds = List<String>.from(preselectedTeams[teamId]!);
        for (final playerId in playerIds) {
          if (!existingPlayerIds.contains(playerId)) {
            existingPlayerIds.add(playerId);
          }
        }
        preselectedTeams[teamId] = existingPlayerIds;
      } else {
        preselectedTeams[teamId] = List<String>.from(playerIds);
      }

      final updatedMatch = match.copyWith(preselectedTeams: preselectedTeams);
      _matches[index] = updatedMatch;

      await _dbHelper.updateMatch(updatedMatch);

      _sortTeams(_matches[index]);

      notifyListeners();
    }
  }

  Future<void> removePreselectedPlayers(
    String matchId,
    String teamId,
    List<String> playerIds,
  ) async {
    final index = _matches.indexWhere((match) => match.id == matchId);

    if (index != -1) {
      final match = _matches[index];

      final preselectedTeams = Map<String, List<String>>.from(
        match.preselectedTeams,
      );

      if (preselectedTeams.containsKey(teamId)) {
        final existingPlayerIds = List<String>.from(preselectedTeams[teamId]!);
        existingPlayerIds.removeWhere((id) => playerIds.contains(id));

        if (existingPlayerIds.isEmpty) {
          preselectedTeams.remove(teamId);
        } else {
          preselectedTeams[teamId] = existingPlayerIds;
        }
      }

      final updatedMatch = match.copyWith(preselectedTeams: preselectedTeams);
      _matches[index] = updatedMatch;

      await _dbHelper.updateMatch(updatedMatch);

      _sortTeams(_matches[index]);

      notifyListeners();
    }
  }

  Future<void> clearPreselectedPlayers(String matchId) async {
    final index = _matches.indexWhere((match) => match.id == matchId);

    if (index != -1) {
      final match = _matches[index];

      final updatedMatch = match.copyWith(preselectedTeams: {});
      _matches[index] = updatedMatch;

      await _dbHelper.updateMatch(updatedMatch);

      _sortTeams(_matches[index]);

      notifyListeners();
    }
  }

  Future<void> resortTeams(String matchId) async {
    final index = _matches.indexWhere((match) => match.id == matchId);

    if (index != -1) {
      _sortTeams(_matches[index]);

      await _dbHelper.updateMatch(_matches[index]);

      notifyListeners();
    }
  }
}
