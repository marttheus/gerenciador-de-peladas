import 'dart:math';
import '../models/player.dart';
import '../models/match.dart';

class TeamBalancerService {
  static List<Team> createBalancedTeams({
    required List<Player> players,
    required int numTeams,
    Map<String, List<String>>? preselectedTeams,
  }) {
    final allPlayers = List<Player>.from(players);

    final List<Team> teams = [];

    final preselectedPlayerIds = <String>{};

    final usedTeamNames = <String>{};

    if (preselectedTeams != null && preselectedTeams.isNotEmpty) {
      int teamIndex = 0;
      preselectedTeams.forEach((teamId, playerIds) {
        String teamName;
        int nameIndex = teamIndex;
        do {
          teamName = 'Time ${String.fromCharCode(65 + nameIndex)}';
          nameIndex++;
        } while (usedTeamNames.contains(teamName));

        usedTeamNames.add(teamName);

        final teamPlayers = <Player>[];

        for (final playerId in playerIds) {
          final playerIndex = allPlayers.indexWhere((p) => p.id == playerId);
          if (playerIndex != -1) {
            teamPlayers.add(allPlayers[playerIndex]);
            preselectedPlayerIds.add(playerId);
          }
        }

        if (teamPlayers.isNotEmpty) {
          teams.add(Team(id: teamId, name: teamName, players: teamPlayers));
          teamIndex++;
        }
      });
    }

    final remainingPlayers =
        allPlayers.where((p) => !preselectedPlayerIds.contains(p.id)).toList();

    final int totalRemainingPlayers = remainingPlayers.length;
    final int playersPerTeam =
        (totalRemainingPlayers + teams.length) ~/ numTeams;
    final int extraPlayers = (totalRemainingPlayers + teams.length) % numTeams;

    const int maxAttempts = 1000;
    List<Team>? bestTeams;
    double bestVariance = double.infinity;

    while (teams.length < numTeams) {
      final teamId =
          'team_${DateTime.now().millisecondsSinceEpoch}_${teams.length}';

      String teamName;
      int nameIndex = teams.length;
      do {
        teamName = 'Time ${String.fromCharCode(65 + nameIndex)}';
        nameIndex++;
      } while (usedTeamNames.contains(teamName));

      usedTeamNames.add(teamName);

      teams.add(Team(id: teamId, name: teamName, players: []));
    }

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final List<Team> attemptTeams =
          teams
              .map(
                (team) => Team(
                  id: team.id,
                  name: team.name,
                  players: List<Player>.from(team.players),
                ),
              )
              .toList();

      final shuffledPlayers = List<Player>.from(remainingPlayers);
      shuffledPlayers.shuffle(Random());

      final List<int> teamWeights =
          attemptTeams
              .map(
                (team) =>
                    team.players.fold(0, (sum, player) => sum + player.weight),
              )
              .toList();

      int currentTeam = 0;
      for (final player in shuffledPlayers) {
        int minWeightTeamIndex = 0;
        for (int i = 1; i < attemptTeams.length; i++) {
          if (teamWeights[i] < teamWeights[minWeightTeamIndex]) {
            minWeightTeamIndex = i;
          }
        }

        final team = attemptTeams[minWeightTeamIndex];
        final updatedPlayers = List<Player>.from(team.players)..add(player);
        attemptTeams[minWeightTeamIndex] = team.copyWith(
          players: updatedPlayers,
        );
        teamWeights[minWeightTeamIndex] += player.weight;
      }

      final double meanWeight =
          teamWeights.fold(0, (sum, weight) => sum + weight) /
          teamWeights.length;
      final double variance =
          teamWeights.fold(
            0.0,
            (sum, weight) => sum + pow(weight - meanWeight, 2),
          ) /
          teamWeights.length;

      if (variance < bestVariance) {
        bestVariance = variance;
        bestTeams = attemptTeams;

        if (variance < 2) {
          break;
        }
      }
    }

    return bestTeams ?? teams;
  }
}
