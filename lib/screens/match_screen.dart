import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../models/match.dart';
import '../widgets/create_match_form.dart';
import '../widgets/match_details.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  bool _showCreateForm = false;

  Match? _selectedMatch;

  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final matches = appState.matches;
    final hasPlayers = appState.players.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_showCreateForm)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CreateMatchForm(
                        onClose: () {
                          setState(() {
                            _showCreateForm = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

            if (_selectedMatch != null && !_showCreateForm)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              setState(() {
                                _selectedMatch = null;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Detalhes da Partida',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: MatchDetails(
                          match: _selectedMatch!,
                          onDelete: (String matchId) {
                            appState.removeMatch(matchId);

                            setState(() {
                              _selectedMatch = null;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Partida excluída com sucesso'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_selectedMatch == null && !_showCreateForm)
              Expanded(
                child:
                    matches.isEmpty
                        ? _buildEmptyState(hasPlayers)
                        : _buildMatchesList(matches),
              ),
          ],
        ),
      ),

      floatingActionButton:
          _selectedMatch == null && !_showCreateForm
              ? FloatingActionButton(
                onPressed: () {
                  if (hasPlayers) {
                    setState(() {
                      _showCreateForm = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cadastre jogadores antes de criar uma partida',
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Provider.of<MyAppState>(
                      context,
                      listen: false,
                    ).setSelectedIndex(1);
                  }
                },
                child: const Icon(Icons.add, color: Colors.white),
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 4,
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState(bool hasPlayers) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Nenhuma partida cadastrada',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (hasPlayers)
                Text(
                  'Clique no botão + para criar uma partida',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                )
              else
                Column(
                  children: [
                    Text(
                      'Cadastre jogadores antes de criar uma partida',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<MyAppState>(
                          context,
                          listen: false,
                        ).setSelectedIndex(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.person_add),
                          SizedBox(width: 8),
                          Text('Adicionar Jogadores'),
                        ],
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

  Widget _buildMatchesList(List<Match> matches) {
    final sortedMatches = List<Match>.from(matches)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Partidas (${matches.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: sortedMatches.length,
              itemBuilder: (context, index) {
                final match = sortedMatches[index];
                return _buildMatchCard(match);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMatch = match;
          });
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
                            _dateFormat.format(match.dateTime),
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
                        Text(
                          'R\$ ${match.cost.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${match.selectedPlayers.length} jogadores',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pagamentos: ${match.paidPlayerIds.length}/${match.selectedPlayers.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
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
                  ),
                  const SizedBox(width: 16),

                  Text(
                    'Times: ${match.teams.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
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
