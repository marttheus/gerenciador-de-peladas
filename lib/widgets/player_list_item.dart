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
    final primaryColor = theme.colorScheme.primary;
    final weightColor = _getWeightColor(player.weight);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar do jogador
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.7),
                      primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Informações do jogador
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: weightColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: weightColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${player.weight}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: weightColor,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getWeightLabel(player.weight),
                                style: TextStyle(
                                  color: weightColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botões de ação
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showEditSkillDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.edit_outlined,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _confirmDelete(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade400,
                          size: 22,
                        ),
                      ),
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

  IconData _getWeightIcon(int weight) {
    if (weight >= 8) {
      return Icons.emoji_events; // Troféu para "Craque"
    } else if (weight >= 4) {
      return Icons.sports_soccer; // Bola de futebol para "Sabe dominar uma bola"
    } else {
      return Icons.waves; // Ondas representando um bagre (peixe na água)
    }
  }

  void _showEditSkillDialog(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    int newWeight = player.weight;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Editar Habilidade de ${player.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Alterar o nível de habilidade deste jogador não afetará partidas já cadastradas.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getWeightColor(newWeight).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getWeightColor(newWeight).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bagre',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getWeightColor(newWeight),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              newWeight.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(
                            'Craque',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: _getWeightColor(newWeight),
                          inactiveTrackColor: _getWeightColor(newWeight).withOpacity(0.2),
                          thumbColor: _getWeightColor(newWeight),
                          overlayColor: _getWeightColor(newWeight).withOpacity(0.2),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                        ),
                        child: Slider(
                          value: newWeight.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              newWeight = value.round();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getWeightLabel(newWeight),
                        style: TextStyle(
                          color: _getWeightColor(newWeight),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newWeight != player.weight) {
                    final updatedPlayer = player.copyWith(weight: newWeight);
                    context.read<MyAppState>().updatePlayer(updatedPlayer);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Habilidade de ${player.name} atualizada para $newWeight (${_getWeightLabel(newWeight)})'),
                        backgroundColor: primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Jogador'),
        content: Text(
          'Deseja realmente excluir o jogador ${player.name}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MyAppState>().removePlayer(player.id);
              Navigator.of(context).pop();
              
              // Mostrar snackbar de confirmação
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${player.name} foi removido'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Color _getWeightColor(int weight) {
    if (weight >= 8) {
      return const Color(0xFF2E7D32); // Verde escuro
    } else if (weight >= 5) {
      return const Color(0xFFEF6C00); // Laranja
    } else {
      return const Color(0xFFC62828); // Vermelho
    }
  }
  
  String _getWeightLabel(int weight) {
    if (weight <= 3) {
      return 'Bagre';
    } else if (weight <= 7) {
      return 'Sabe dominar uma bola';
    } else {
      return 'Craque';
    }
  }
}
