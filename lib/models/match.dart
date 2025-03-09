import 'player.dart';
import 'package:flutter/material.dart';

enum TeamSortMethod { random, balanced, captains }

enum MatchStatus { scheduled, inProgress, played, completed }

class Team {
  final String id;

  final String name;

  final List<Player> players;

  Team({required this.id, required this.name, required this.players});

  Team copyWith({String? id, String? name, List<Player>? players}) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
    );
  }
}

extension TeamSortMethodExtension on TeamSortMethod {
  String get displayName {
    switch (this) {
      case TeamSortMethod.random:
        return 'Aleatório';
      case TeamSortMethod.balanced:
        return 'Balanceado por habilidade';
      case TeamSortMethod.captains:
        return 'Capitães escolhem';
    }
  }
}

extension MatchStatusExtension on MatchStatus {
  String get displayName {
    switch (this) {
      case MatchStatus.scheduled:
        return 'Agendada';
      case MatchStatus.inProgress:
        return 'Em andamento';
      case MatchStatus.played:
        return 'Jogada';
      case MatchStatus.completed:
        return 'Concluída';
    }
  }

  Color get color {
    switch (this) {
      case MatchStatus.scheduled:
        return Colors.orange;
      case MatchStatus.inProgress:
        return Colors.blue;
      case MatchStatus.played:
        return Colors.purple;
      case MatchStatus.completed:
        return Colors.green;
    }
  }
}

class Match {
  final String id;

  final DateTime dateTime;

  final int durationMinutes;

  final double cost;

  final TeamSortMethod sortMethod;

  final int maxPlayersPerTeam;

  final List<Player> selectedPlayers;

  final List<Team> teams;

  final MatchStatus status;

  final String? pixKey;

  final List<String> paidPlayerIds;

  final Map<String, List<String>> preselectedTeams;

  Match({
    required this.id,
    required this.dateTime,
    required this.cost,
    required this.sortMethod,
    required this.maxPlayersPerTeam,
    required this.selectedPlayers,
    this.durationMinutes = 90,
    this.pixKey,
    List<Team>? teams,
    MatchStatus? status,
    List<String>? paidPlayerIds,
    Map<String, List<String>>? preselectedTeams,
  }) : teams = teams ?? [],
       status = status ?? MatchStatus.scheduled,
       paidPlayerIds = paidPlayerIds ?? [],
       preselectedTeams = preselectedTeams ?? {};

  DateTime get endDateTime => dateTime.add(Duration(minutes: durationMinutes));

  bool isInProgressNow() {
    final now = DateTime.now();
    return now.isAfter(dateTime) && now.isBefore(endDateTime);
  }

  bool isPlayedNow() {
    final now = DateTime.now();
    return now.isAfter(endDateTime);
  }

  double get costPerPlayer {
    if (selectedPlayers.isEmpty) return 0;
    return cost / selectedPlayers.length;
  }

  bool get allPlayersPaid {
    return paidPlayerIds.length == selectedPlayers.length;
  }

  bool isPlayerPaid(String playerId) {
    return paidPlayerIds.contains(playerId);
  }

  double get paymentPercentage {
    if (selectedPlayers.isEmpty) return 0;
    return paidPlayerIds.length / selectedPlayers.length;
  }

  List<Player> get unassignedPlayers {
    final assignedPlayerIds = <String>{};
    for (final team in teams) {
      assignedPlayerIds.addAll(team.players.map((p) => p.id));
    }

    return selectedPlayers
        .where((p) => !assignedPlayerIds.contains(p.id))
        .toList();
  }

  Match copyWith({
    String? id,
    DateTime? dateTime,
    int? durationMinutes,
    double? cost,
    TeamSortMethod? sortMethod,
    int? maxPlayersPerTeam,
    List<Player>? selectedPlayers,
    List<Team>? teams,
    MatchStatus? status,
    String? pixKey,
    List<String>? paidPlayerIds,
    Map<String, List<String>>? preselectedTeams,
  }) {
    return Match(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      cost: cost ?? this.cost,
      sortMethod: sortMethod ?? this.sortMethod,
      maxPlayersPerTeam: maxPlayersPerTeam ?? this.maxPlayersPerTeam,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      teams: teams ?? this.teams,
      status: status ?? this.status,
      pixKey: pixKey ?? this.pixKey,
      paidPlayerIds: paidPlayerIds ?? this.paidPlayerIds,
      preselectedTeams: preselectedTeams ?? this.preselectedTeams,
    );
  }
}
