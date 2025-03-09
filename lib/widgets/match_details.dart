import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  late Match _currentMatch;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentMatch = widget.match;
  }

  @override
  void didUpdateWidget(MatchDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.id != widget.match.id) {
      _currentMatch = widget.match;
    }
  }

  void _reloadMatchData() {
    final appState = Provider.of<MyAppState>(context, listen: false);
    final updatedMatch = appState.matches.firstWhere(
      (m) => m.id == widget.match.id,
      orElse: () => widget.match,
    );

    setState(() {
      _currentMatch = updatedMatch;
    });
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

    final match = _currentMatch;

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
                              'Data: ${dateFormat.format(match.dateTime)}',
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
                        match.status.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: match.status.color,
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
                        'Duração: ${match.durationMinutes} minutos (Término: ${dateFormat.format(match.endDateTime)})',
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
                        'Custo: R\$ ${match.cost.toStringAsFixed(2)}',
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
                        'Valor por jogador: R\$ ${match.costPerPlayer.toStringAsFixed(2)}',
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
                        'Método de sorteio: ${match.sortMethod.displayName}',
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
                        'Jogadores por time: ${match.maxPlayersPerTeam}',
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
                child: PaymentManager(match: match, showCompleteButton: false),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              if (match.status == MatchStatus.played)
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
                  final matchId = _currentMatch.id;

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
    final match = _currentMatch;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (match.teams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  if (match.status != MatchStatus.completed)
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
                        label: const Text('Compartilhar Detalhes'),
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

          if (match.teams.isEmpty)
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
            ...match.teams.map(
              (team) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildTeamCard(context, team),
              ),
            ),

          if (match.unassignedPlayers.isNotEmpty)
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

    final totalSkill = team.players.fold<int>(
      0,
      (sum, player) => sum + player.weight,
    );

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
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        team.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Habilidade Total: $totalSkill',
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

  void _shareAllTeams(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: false);

    final updatedMatch = appState.matches.firstWhere(
      (m) => m.id == _currentMatch.id,
      orElse: () => _currentMatch,
    );

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final buffer = StringBuffer();

    buffer.writeln('Data: ${dateFormat.format(updatedMatch.dateTime)}');
    buffer.writeln(
      'Total de Jogadores: ${updatedMatch.selectedPlayers.length}',
    );
    buffer.writeln('Número de Times: ${updatedMatch.teams.length}');
    buffer.writeln('Valor: R\$ ${updatedMatch.cost.toStringAsFixed(0)}');
    buffer.writeln(
      'Valor unitário: R\$${updatedMatch.costPerPlayer.toStringAsFixed(0)}',
    );

    if (updatedMatch.pixKey != null && updatedMatch.pixKey!.isNotEmpty) {
      buffer.writeln('Pix: ${updatedMatch.pixKey}');
    }

    buffer.writeln('----------------------------------------');
    buffer.writeln();

    for (int i = 0; i < updatedMatch.teams.length; i++) {
      final team = updatedMatch.teams[i];

      buffer.writeln('Time ${i + 1}');
      buffer.writeln('Jogadores: ${team.players.length}');

      for (final player in team.players) {
        buffer.writeln('- ${player.name}');
      }

      if (i < updatedMatch.teams.length - 1) {
        buffer.writeln();
      }
    }

    if (updatedMatch.unassignedPlayers.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Jogadores Disponíveis');
      buffer.writeln('Jogadores: ${updatedMatch.unassignedPlayers.length}');

      for (final player in updatedMatch.unassignedPlayers) {
        buffer.writeln('- ${player.name}');
      }
    }

    final messageText = buffer.toString();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Compartilhar Detalhes da Partida'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Copie o texto abaixo para compartilhar:',
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
                  child: SelectableText(messageText),
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
                  Clipboard.setData(ClipboardData(text: messageText));

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
              ElevatedButton.icon(
                onPressed: () {
                  _shareToWhatsApp(messageText);
                  Navigator.of(context).pop();
                },
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                label: const Text('WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  void _shareToWhatsApp(String text) async {
    try {
      final encodedText = Uri.encodeComponent(text);

      final whatsappUrl = "whatsapp://send?text=$encodedText";

      if (await canLaunchUrlString(whatsappUrl)) {
        await launchUrlString(whatsappUrl);
      } else {
        final webWhatsappUrl = "https://wa.me/?text=$encodedText";
        if (await canLaunchUrlString(webWhatsappUrl)) {
          await launchUrlString(webWhatsappUrl);
        } else {
          throw 'Não foi possível abrir o WhatsApp';
        }
      }
    } catch (e) {
      debugPrint('Erro ao compartilhar no WhatsApp: $e');
    }
  }

  Widget _buildUnassignedPlayers(BuildContext context) {
    final unassignedPlayers = _currentMatch.unassignedPlayers;

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

                  if (!_currentMatch.allPlayersPaid)
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
                            'Existem ${_currentMatch.selectedPlayers.length - _currentMatch.paidPlayerIds.length} jogadores que ainda não pagaram.',
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
                    _currentMatch.id,
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
                  const Text('Como você deseja refazer o sorteio dos times?'),
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
              ElevatedButton.icon(
                onPressed: () async {
                  await appState.resortTeams(_currentMatch.id);
                  Navigator.of(context).pop();

                  _reloadMatchData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Times sorteados novamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refazer com Mesmas Configurações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showFullResortDialog(context);
                },
                icon: const Icon(Icons.settings_backup_restore),
                label: const Text('Refazer do Zero'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  void _showFullResortDialog(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: false);
    final match = _currentMatch;

    final selectedPlayers = List<Player>.from(match.selectedPlayers);
    final preselectedTeams = <String, List<String>>{};
    var sortMethod = match.sortMethod;
    var maxPlayersPerTeam = match.maxPlayersPerTeam;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Refazer Sorteio do Zero'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configure as opções para o novo sorteio:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Método de Sorteio:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<TeamSortMethod>(
                        value: sortMethod,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            TeamSortMethod.values.map((method) {
                              return DropdownMenuItem<TeamSortMethod>(
                                value: method,
                                child: Text(method.displayName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              sortMethod = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Jogadores por Time:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: maxPlayersPerTeam.toDouble(),
                              min: 3,
                              max: 11,
                              divisions: 8,
                              label: maxPlayersPerTeam.toString(),
                              onChanged: (value) {
                                setState(() {
                                  maxPlayersPerTeam = value.round();
                                });
                              },
                            ),
                          ),
                          Text(
                            maxPlayersPerTeam.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (sortMethod != TeamSortMethod.captains)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showTeamSelectionDialogForResort(
                              context,
                              selectedPlayers,
                              preselectedTeams,
                              sortMethod,
                              maxPlayersPerTeam,
                            );
                          },
                          icon: const Icon(Icons.group_add),
                          label: const Text('Selecionar Grupos de Jogadores'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
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
                    onPressed: () async {
                      await appState.updateMatchSettings(
                        match.id,
                        sortMethod: sortMethod,
                        maxPlayersPerTeam: maxPlayersPerTeam,
                        preselectedTeams: preselectedTeams,
                      );

                      Navigator.of(context).pop();

                      _reloadMatchData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Times sorteados com novas configurações',
                          ),
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
              );
            },
          ),
    );
  }

  void _showTeamSelectionDialogForResort(
    BuildContext context,
    List<Player> selectedPlayers,
    Map<String, List<String>> preselectedTeams,
    TeamSortMethod sortMethod,
    int maxPlayersPerTeam,
  ) {
    final selectedPlayerIds = <String>[];
    final selectedGroups = <List<String>>[];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Selecionar Grupos de Jogadores'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecione os jogadores que devem ficar juntos no mesmo time:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selecione os jogadores e clique em "Adicionar como Grupo" para criar um grupo. '
                        'Você pode criar vários grupos que ficarão em times diferentes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jogadores disponíveis:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (selectedPlayerIds.isNotEmpty)
                            Chip(
                              label: Text(
                                '${selectedPlayerIds.length} selecionados',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        height: 300,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: selectedPlayers.length,
                          itemBuilder: (context, index) {
                            final player = selectedPlayers[index];
                            final isSelected = selectedPlayerIds.contains(
                              player.id,
                            );

                            final isInAnyGroup = selectedGroups.any(
                              (group) => group.contains(player.id),
                            );

                            return CheckboxListTile(
                              title: Text(player.name),
                              subtitle: Text(
                                isInAnyGroup
                                    ? 'Habilidade: ${player.weight} (já em um grupo)'
                                    : 'Habilidade: ${player.weight}',
                              ),
                              value: isSelected,
                              onChanged:
                                  isInAnyGroup
                                      ? null
                                      : (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedPlayerIds.add(player.id);
                                          } else {
                                            selectedPlayerIds.remove(player.id);
                                          }
                                        });
                                      },
                              enabled: !isInAnyGroup,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (selectedPlayerIds.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedGroups.add(
                                List<String>.from(selectedPlayerIds),
                              );
                              selectedPlayerIds.clear();
                            });
                          },
                          icon: const Icon(Icons.group_add),
                          label: const Text('Adicionar como Grupo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),

                      const SizedBox(height: 16),

                      if (selectedGroups.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Grupos já selecionados:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Grupos definidos:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(
                                          Icons.clear_all,
                                          size: 14,
                                        ),
                                        label: const Text(
                                          'Limpar todos',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedGroups.clear();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...selectedGroups.asMap().entries.map((
                                    entry,
                                  ) {
                                    final groupIndex = entry.key;
                                    final group = entry.value;
                                    final playerNames = group
                                        .map((playerId) {
                                          final player = selectedPlayers
                                              .firstWhere(
                                                (p) => p.id == playerId,
                                                orElse:
                                                    () => Player(
                                                      name: 'Desconhecido',
                                                      weight: 0,
                                                    ),
                                              );
                                          return player.name;
                                        })
                                        .join(', ');

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Grupo ${groupIndex + 1}: $playerNames',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              setState(() {
                                                selectedGroups.removeAt(
                                                  groupIndex,
                                                );
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info, color: Colors.blue),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Informação',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'O limite máximo de jogadores por time é $maxPlayersPerTeam. '
                              'Se você selecionar mais jogadores do que o limite, alguns jogadores podem ser '
                              'colocados em times diferentes.\n\n'
                              'Você pode adicionar múltiplos grupos de jogadores que devem ficar juntos.',
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showFullResortDialog(context);
                    },
                    child: const Text('Voltar'),
                  ),
                  ElevatedButton(
                    onPressed:
                        (selectedPlayerIds.isEmpty && selectedGroups.isEmpty)
                            ? null
                            : () {
                              if (selectedPlayerIds.isNotEmpty) {
                                selectedGroups.add(
                                  List<String>.from(selectedPlayerIds),
                                );
                              }

                              for (final group in selectedGroups) {
                                final newTeamId =
                                    'team_${DateTime.now().millisecondsSinceEpoch}_${group.hashCode}';
                                preselectedTeams[newTeamId] = group;
                              }

                              Navigator.of(context).pop();

                              _showFullResortDialog(context);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirmar Grupos'),
                  ),
                ],
              );
            },
          ),
    );
  }
}
