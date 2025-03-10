import 'dart:math';
import '../models/player.dart';
import '../models/match.dart';

class TeamBalancerService {
  static List<Team> createBalancedTeams({
    required List<Player> players,
    required int numTeams,
    required int maxPlayersPerTeam,
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

        final limitedPlayerIds =
            playerIds.length > maxPlayersPerTeam
                ? playerIds.sublist(0, maxPlayersPerTeam)
                : playerIds;

        final teamPlayers = <Player>[];

        for (final playerId in limitedPlayerIds) {
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
    final int totalTeamsNeeded =
        (totalRemainingPlayers +
            preselectedPlayerIds.length +
            maxPlayersPerTeam -
            1) ~/
        maxPlayersPerTeam;

    final int adjustedNumTeams =
        totalTeamsNeeded > numTeams ? totalTeamsNeeded : numTeams;

    final int playersPerTeam = totalRemainingPlayers ~/ adjustedNumTeams;
    final int extraPlayers = totalRemainingPlayers % adjustedNumTeams;

    while (teams.length < adjustedNumTeams) {
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

    remainingPlayers.sort((a, b) => b.weight.compareTo(a.weight));

    const int maxAttempts = 1000;
    List<Team>? bestTeams;
    double bestVariance = double.infinity;

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

      final List<int> targetPlayersPerTeam = List<int>.filled(
        attemptTeams.length,
        playersPerTeam,
      );

      for (int i = 0; i < extraPlayers; i++) {
        targetPlayersPerTeam[i]++;
      }

      for (final player in shuffledPlayers) {
        int targetTeamIndex = -1;
        double minAdjustedWeight = double.infinity;

        for (int i = 0; i < attemptTeams.length; i++) {
          if (attemptTeams[i].players.length >= maxPlayersPerTeam) {
            continue;
          }

          if (attemptTeams[i].players.length >= targetPlayersPerTeam[i]) {
            continue;
          }

          final int currentPlayers = attemptTeams[i].players.length;
          final int targetPlayers = targetPlayersPerTeam[i];
          final int missingPlayers = maxPlayersPerTeam - currentPlayers;

          double adjustedWeight;

          if (currentPlayers == 0) {
            adjustedWeight = 0;
          } else {
            final double avgWeight = teamWeights[i] / currentPlayers;

            adjustedWeight = teamWeights[i] + (avgWeight * missingPlayers);
          }

          if (targetTeamIndex == -1 || adjustedWeight < minAdjustedWeight) {
            targetTeamIndex = i;
            minAdjustedWeight = adjustedWeight;
          }
        }

        if (targetTeamIndex == -1) {
          for (int i = 0; i < attemptTeams.length; i++) {
            if (attemptTeams[i].players.length >= maxPlayersPerTeam) {
              continue;
            }

            final int currentPlayers = attemptTeams[i].players.length;
            final int missingPlayers = maxPlayersPerTeam - currentPlayers;

            double adjustedWeight;
            if (currentPlayers == 0) {
              adjustedWeight = 0;
            } else {
              final double avgWeight = teamWeights[i] / currentPlayers;
              adjustedWeight = teamWeights[i] + (avgWeight * missingPlayers);
            }

            if (targetTeamIndex == -1 || adjustedWeight < minAdjustedWeight) {
              targetTeamIndex = i;
              minAdjustedWeight = adjustedWeight;
            }
          }
        }

        if (targetTeamIndex == -1) {
          break;
        }

        final team = attemptTeams[targetTeamIndex];
        final updatedPlayers = List<Player>.from(team.players)..add(player);
        attemptTeams[targetTeamIndex] = team.copyWith(players: updatedPlayers);
        teamWeights[targetTeamIndex] += player.weight;
      }

      final List<double> adjustedWeights = [];

      for (int i = 0; i < attemptTeams.length; i++) {
        final int currentPlayers = attemptTeams[i].players.length;
        final int currentWeight = teamWeights[i];

        if (currentPlayers == 0) {
          adjustedWeights.add(0);
          continue;
        }

        final double avgWeight = currentWeight / currentPlayers;

        final double adjustedWeight = avgWeight * maxPlayersPerTeam;

        adjustedWeights.add(adjustedWeight);
      }

      final double meanAdjustedWeight =
          adjustedWeights.fold(0.0, (sum, weight) => sum + weight) /
          adjustedWeights.length;
      final double variance =
          adjustedWeights.fold(
            0.0,
            (sum, weight) => sum + pow(weight - meanAdjustedWeight, 2),
          ) /
          adjustedWeights.length;

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
