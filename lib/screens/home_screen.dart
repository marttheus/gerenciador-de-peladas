import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../models/match.dart';
import '../models/player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final players = appState.players;
    final matches = appState.matches;

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final upcomingMatches =
        matches.where((match) => match.status != MatchStatus.completed).toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final recentMatches =
        matches.where((match) => match.status == MatchStatus.completed).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (players.isNotEmpty || matches.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              Icons.people,
                              players.length.toString(),
                              'Jogadores',
                              Colors.blue,
                              () {
                                appState.setSelectedIndex(1);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              Icons.sports_soccer,
                              matches.length.toString(),
                              'Partidas',
                              Colors.green,
                              () {
                                appState.setSelectedIndex(2);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                if (matches.isEmpty)
                  _buildEmptyHomeState(context, players.isNotEmpty, appState)
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (upcomingMatches.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Próxima Partida',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildNextMatchCard(
                              context,
                              upcomingMatches.first,
                              dateFormat,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      _buildPaymentSummary(context, matches),

                      const SizedBox(height: 24),

                      if (recentMatches.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Partidas Recentes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...recentMatches
                                .take(3)
                                .map(
                                  (match) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: _buildRecentMatchCard(
                                      context,
                                      match,
                                      dateFormat,
                                    ),
                                  ),
                                ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      if (players.isNotEmpty)
                        _buildTopPlayersCard(context, players, matches),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHomeState(
    BuildContext context,
    bool hasPlayers,
    MyAppState appState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sports_soccer,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Bem-vindo ao Gerenciador de Pelada!',
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        if (hasPlayers)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text(
                  'Você já tem jogadores cadastrados! Agora você pode criar sua primeira partida.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    appState.setSelectedIndex(2);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Criar minha primeira partida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade800,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Primeiro passo:',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Você precisa adicionar jogadores antes de criar uma partida.',
                  style: TextStyle(color: Colors.orange.shade900, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    appState.setSelectedIndex(1);
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Adicionar Jogadores'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Como usar o Gerenciador de Pelada:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTipItem(
                  context,
                  '1. Cadastre os jogadores',
                  'Adicione todos os jogadores que participam das suas partidas.',
                  Icons.person_add,
                ),
                const SizedBox(height: 6),
                _buildTipItem(
                  context,
                  '2. Crie uma partida',
                  'Defina data, custo e selecione os jogadores participantes.',
                  Icons.sports_soccer,
                ),
                const SizedBox(height: 6),
                _buildTipItem(
                  context,
                  '3. Gerencie os times',
                  'Sorteie os times automaticamente ou organize manualmente.',
                  Icons.group,
                ),
                const SizedBox(height: 6),
                _buildTipItem(
                  context,
                  '4. Controle os pagamentos',
                  'Acompanhe quem já pagou e quanto falta receber.',
                  Icons.payments,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String value,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title, style: TextStyle(color: color.withOpacity(0.8))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextMatchCard(
    BuildContext context,
    Match match,
    DateFormat dateFormat,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Provider.of<MyAppState>(context, listen: false).setSelectedIndex(2);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            dateFormat.format(match.dateTime),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      match.status.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: match.status.color,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'R\$ ${match.cost.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${match.selectedPlayers.length} jogadores',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pagamentos: ${match.paidPlayerIds.length}/${match.selectedPlayers.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: match.paymentPercentage,
                    backgroundColor: Colors.grey.shade300,
                    color: _getProgressColor(match.paymentPercentage),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMatchCard(
    BuildContext context,
    Match match,
    DateFormat dateFormat,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Provider.of<MyAppState>(context, listen: false).setSelectedIndex(2);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.sports_soccer,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(match.dateTime),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${match.selectedPlayers.length} jogadores • ${match.teams.length} times',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${match.cost.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    match.allPlayersPaid ? 'Pago' : 'Pendente',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          match.allPlayersPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, List<Match> matches) {
    int totalPendingPayments = 0;
    double totalPendingAmount = 0;

    for (final match in matches) {
      final pendingPlayers =
          match.selectedPlayers.length - match.paidPlayerIds.length;
      totalPendingPayments += pendingPlayers;

      if (pendingPlayers > 0) {
        totalPendingAmount += pendingPlayers * match.costPerPlayer;
      }
    }

    if (totalPendingPayments == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Pagamentos Pendentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Você tem $totalPendingPayments pagamentos pendentes.',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            const SizedBox(height: 4),
            Text(
              'Valor total pendente: R\$ ${totalPendingAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Provider.of<MyAppState>(
                  context,
                  listen: false,
                ).setSelectedIndex(2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ver Detalhes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPlayersCard(
    BuildContext context,
    List<Player> players,
    List<Match> matches,
  ) {
    final playerParticipation = <String, int>{};

    for (final player in players) {
      playerParticipation[player.id] = 0;
    }

    for (final match in matches) {
      for (final player in match.selectedPlayers) {
        playerParticipation[player.id] =
            (playerParticipation[player.id] ?? 0) + 1;
      }
    }

    final sortedPlayers = List<Player>.from(players)..sort(
      (a, b) => (playerParticipation[b.id] ?? 0).compareTo(
        playerParticipation[a.id] ?? 0,
      ),
    );

    final topPlayers = sortedPlayers.take(5).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jogadores Mais Ativos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...topPlayers.map((player) {
              final participation = playerParticipation[player.id] ?? 0;
              final participationPercentage =
                  matches.isEmpty ? 0.0 : participation / matches.length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      child: Text(
                        player.name.isNotEmpty
                            ? player.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: participationPercentage,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$participation partidas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (topPlayers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhum jogador participou de partidas ainda',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 1.0) {
      return Colors.green;
    } else if (percentage >= 0.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
