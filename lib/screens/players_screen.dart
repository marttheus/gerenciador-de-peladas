import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/player.dart';
import '../widgets/add_player_form.dart';
import '../widgets/player_list_item.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  bool _showAddForm = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final players = appState.players;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_showAddForm)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AddPlayerForm(
                      onClose: () {
                        setState(() {
                          _showAddForm = false;
                        });
                      },
                    ),
                  ),
                ),
              ),

            Expanded(
              child:
                  players.isEmpty
                      ? _buildEmptyState()
                      : _buildPlayersList(players),
            ),
          ],
        ),
      ),

      floatingActionButton:
          !_showAddForm
              ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showAddForm = true;
                  });
                },
                child: const Icon(Icons.add, color: Colors.white),
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 4,
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhum jogador cadastrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no botão + para adicionar jogadores',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList(List<Player> playersList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jogadores (${playersList.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Chip(
                label: Text(
                  'Média: ${_calculateAverageWeight(playersList).toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: playersList.length,
              itemBuilder: (context, index) {
                return PlayerListItem(player: playersList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAverageWeight(List<Player> playersList) {
    if (playersList.isEmpty) return 0;

    final sum = playersList.fold<int>(
      0,
      (previousValue, player) => previousValue + player.weight,
    );

    return sum / playersList.length;
  }
}
