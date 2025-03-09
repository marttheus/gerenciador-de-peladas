import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../models/match.dart';
import '../models/player.dart';
import '../models/app_state.dart';
import '../screens/match_screen.dart';
import 'payment_manager.dart';

class MatchDetails extends StatefulWidget {
  final Match match;

  final Function(String matchId)? onDelete;

  const MatchDetails({super.key, required this.match, this.onDelete});

  @override
  State<MatchDetails> createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final appState = Provider.of<MyAppState>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.zero,
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
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Data: ${dateFormat.format(widget.match.dateTime)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.visible,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Chip(
                      label: Text(
                        widget.match.status.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: widget.match.status.color,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.timer),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Duração: ${widget.match.durationMinutes} minutos (Término: ${dateFormat.format(widget.match.endDateTime)})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.attach_money),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Custo: R\$ ${widget.match.cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Valor por jogador: R\$ ${widget.match.costPerPlayer.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.shuffle),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Método de sorteio: ${widget.match.sortMethod.displayName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.group),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Jogadores por time: ${widget.match.maxPlayersPerTeam}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Times'), Tab(text: 'Pagamentos')],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTeamsTab(),

              SingleChildScrollView(
                child: PaymentManager(
                  match: widget.match,
                  showCompleteButton: false,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              if (widget.match.status == MatchStatus.played)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _showCompleteMatchDialog(context),
                      icon: const Icon(Icons.sports_score, color: Colors.white),
                      label: const Text('Concluir Partida'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmationDialog(context),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Excluir Partida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir Partida'),
            content: const Text(
              'Tem certeza que deseja excluir esta partida? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final matchId = widget.match.id;

                  Navigator.of(context).pop();

                  if (widget.onDelete != null) {
                    widget.onDelete!(matchId);
                  } else {
                    final appState = Provider.of<MyAppState>(
                      context,
                      listen: false,
                    );
                    appState.removeMatch(matchId);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Partida excluída com sucesso'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  Widget _buildTeamsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.match.teams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  if (widget.match.status != MatchStatus.completed)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _showResortTeamsDialog(context),
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Refazer Sorteio'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _shareAllTeams(context),
                        icon: const Icon(Icons.share),
                        label: const Text('Compartilhar Times'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (widget.match.teams.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nenhum time foi criado ainda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...widget.match.teams.map(
              (team) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildTeamCard(context, team),
              ),
            ),

          if (widget.match.unassignedPlayers.isNotEmpty)
            _buildUnassignedPlayers(context),
        ],
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team) {
    final List<Color> teamColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    final teamIndex = int.tryParse(team.id.split('_').last) ?? 0;
    final color = teamColors[teamIndex % teamColors.length];

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  team.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Compartilhar time',
                  onPressed: () => _shareTeam(context, team),
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...team.players.map(
              (player) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: color.withOpacity(0.2),
                      child: Text(
                        player.name.isNotEmpty
                            ? player.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        player.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        player.weight.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (team.players.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Nenhum jogador neste time'),
              ),
          ],
        ),
      ),
    );
  }

  void _shareTeam(BuildContext context, Team team) {
    final appState = Provider.of<MyAppState>(context, listen: false);

    final updatedMatch = appState.matches.firstWhere(
      (m) => m.id == widget.match.id,
      orElse: () => widget.match,
    );

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final buffer = StringBuffer();

    buffer.writeln('🏆 *PARTIDA DE FUTEBOL* 🏆');
    buffer.writeln('📅 *Data:* ${dateFormat.format(updatedMatch.dateTime)}');
    buffer.writeln(
      '💰 *Valor total:* R\$ ${updatedMatch.cost.toStringAsFixed(2)}',
    );
    buffer.writeln(
      '👤 *Valor por jogador:* R\$ ${updatedMatch.costPerPlayer.toStringAsFixed(2)}',
    );

    if (updatedMatch.pixKey != null && updatedMatch.pixKey!.isNotEmpty) {
      buffer.writeln('💳 *PIX:* ${updatedMatch.pixKey}');
    }

    buffer.writeln('\n👥 *${team.name}* 👥');

    for (int i = 0; i < team.players.length; i++) {
      final player = team.players[i];
      buffer.writeln('${i + 1}. ${player.name} (${player.weight})');
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Compartilhar Time'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Copie o texto abaixo para compartilhar no WhatsApp:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(buffer.toString()),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: buffer.toString()));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Texto copiado para a área de transferência',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  void _shareAllTeams(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: false);

    final updatedMatch = appState.matches.firstWhere(
      (m) => m.id == widget.match.id,
      orElse: () => widget.match,
    );

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final buffer = StringBuffer();

    buffer.writeln('🏆 *PARTIDA DE FUTEBOL* 🏆');
    buffer.writeln('📅 *Data:* ${dateFormat.format(updatedMatch.dateTime)}');
    buffer.writeln(
      '💰 *Valor total:* R\$ ${updatedMatch.cost.toStringAsFixed(2)}',
    );
    buffer.writeln(
      '👤 *Valor por jogador:* R\$ ${updatedMatch.costPerPlayer.toStringAsFixed(2)}',
    );

    if (updatedMatch.pixKey != null && updatedMatch.pixKey!.isNotEmpty) {
      buffer.writeln('💳 *PIX:* ${updatedMatch.pixKey}');
    }

    buffer.writeln('\n⚽ *TIMES* ⚽');

    for (int i = 0; i < updatedMatch.teams.length; i++) {
      final team = updatedMatch.teams[i];

      buffer.writeln('\n👥 *${team.name}* 👥');

      for (int j = 0; j < team.players.length; j++) {
        final player = team.players[j];
        buffer.writeln('${j + 1}. ${player.name} (${player.weight})');
      }
    }

    if (updatedMatch.unassignedPlayers.isNotEmpty) {
      buffer.writeln('\n🔄 *Jogadores Disponíveis* 🔄');

      for (int i = 0; i < updatedMatch.unassignedPlayers.length; i++) {
        final player = updatedMatch.unassignedPlayers[i];
        buffer.writeln('${i + 1}. ${player.name} (${player.weight})');
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Compartilhar Times'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Copie o texto abaixo para compartilhar no WhatsApp:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(buffer.toString()),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: buffer.toString()));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Texto copiado para a área de transferência',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildUnassignedPlayers(BuildContext context) {
    final unassignedPlayers = widget.match.unassignedPlayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jogadores Disponíveis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children:
                  unassignedPlayers
                      .map(
                        (player) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                child: Text(
                                  player.name.isNotEmpty
                                      ? player.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  player.weight.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showCompleteMatchDialog(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Concluir Partida'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tem certeza que deseja concluir esta partida?'),
                  const SizedBox(height: 16),

                  if (!widget.match.allPlayersPaid)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Atenção: Pagamentos Pendentes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Existem ${widget.match.selectedPlayers.length - widget.match.paidPlayerIds.length} jogadores que ainda não pagaram.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.updateMatchStatus(
                    widget.match.id,
                    MatchStatus.completed,
                  );
                  Navigator.of(context).pop();

                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Concluir'),
              ),
            ],
          ),
    );
  }

  void _showResortTeamsDialog(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Refazer Sorteio'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tem certeza que deseja refazer o sorteio dos times?',
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Atenção',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ao refazer o sorteio, todos os times atuais serão substituídos por novos times. '
                          'Esta ação não pode ser desfeita.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.resortTeams(widget.match.id);

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Times sorteados novamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Refazer Sorteio'),
              ),
            ],
          ),
    );
  }
}
