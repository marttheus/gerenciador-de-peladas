import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../models/app_state.dart';

class PlayerListItem extends StatelessWidget {
  final Player player;

  const PlayerListItem({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final weightColor = _getWeightColor(player.weight);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          child: Text(
            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            const Text('Habilidade: '),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: weightColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                player.weight.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: weightColor,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: () => _confirmDelete(context),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir Jogador'),
            content: Text('Deseja realmente excluir o jogador ${player.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  context.read<MyAppState>().removePlayer(player.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Excluir'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  Color _getWeightColor(int weight) {
    if (weight >= 8) {
      return Colors.green;
    } else if (weight >= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
