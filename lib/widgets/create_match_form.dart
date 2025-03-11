import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../services/team_balancer_service.dart';

class CreateMatchForm extends StatefulWidget {
  final VoidCallback onClose;

  const CreateMatchForm({super.key, required this.onClose});

  @override
  State<CreateMatchForm> createState() => _CreateMatchFormState();
}

class _CreateMatchFormState extends State<CreateMatchForm> {
  final _costController = TextEditingController();

  final _pixController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();

  TeamSortMethod _sortMethod = TeamSortMethod.balanced;

  int _maxPlayersPerTeam = 5;

  int _durationMinutes = 90;

  final List<Player> _selectedPlayers = [];

  final Map<String, List<String>> _preselectedTeams = {};

  List<Team> _generatedTeams = [];

  bool _teamsGenerated = false;

  bool _manualTeamSelection = false;

  final _formKey = GlobalKey<FormState>();

  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  bool get _isFormValid {
    return _costController.text.isNotEmpty &&
        double.tryParse(_costController.text) != null &&
        double.tryParse(_costController.text)! > 0 &&
        _selectedPlayers.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _costController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _costController.dispose();
    _pixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final allPlayers = appState.players;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (_manualTeamSelection) {
      return _buildManualTeamSelectionScreen(context, appState);
    }

    if (_teamsGenerated && _sortMethod != TeamSortMethod.captains) {
      return _buildTeamsPreviewScreen(context, appState);
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cabeçalho
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Criar Nova Partida',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: widget.onClose,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
            
                    if (allPlayers.isEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Nenhum jogador disponível',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Você precisa adicionar jogadores antes de criar uma partida.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                widget.onClose();
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  Provider.of<MyAppState>(
                                    context,
                                    listen: false,
                                  ).setSelectedIndex(1);
                                });
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Ir para Cadastro de Jogadores'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
            
                    // Data e Hora
                    InkWell(
                      onTap: _selectDateTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data e Hora',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _dateFormat.format(_selectedDateTime),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
            
                    // Custo da Partida
                    TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: 'Custo da Partida (R\$)',
                        hintText: 'Ex: 150.00',
                        prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe o custo da partida';
                        }
            
                        final cost = double.tryParse(value);
                        if (cost == null || cost <= 0) {
                          return 'O custo deve ser um valor positivo';
                        }
            
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
            
                    // Duração da Partida
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: primaryColor),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duração da Partida',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          DropdownButton<int>(
                            value: _durationMinutes,
                            underline: const SizedBox(),
                            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                            onChanged: (value) {
                              setState(() {
                                _durationMinutes = value!;
                              });
                            },
                            items: [60, 90, 120, 150, 180].map((duration) {
                              return DropdownMenuItem<int>(
                                value: duration,
                                child: Text(
                                  '$duration minutos',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
            
                    // Chave PIX
                    TextFormField(
                      controller: _pixController,
                      decoration: InputDecoration(
                        labelText: 'Chave PIX do Recebedor (opcional)',
                        hintText: 'CPF, e-mail, telefone ou chave aleatória',
                        prefixIcon: Icon(Icons.pix, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
            
                    // Método de Sorteio
                    Text(
                      'Método de Sorteio',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<TeamSortMethod>(
                            value: _sortMethod,
                            decoration: InputDecoration(
                              labelText: 'Selecione o método',
                              prefixIcon: Icon(Icons.shuffle, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: TeamSortMethod.values.map((method) {
                              return DropdownMenuItem<TeamSortMethod>(
                                value: method,
                                child: Text(method.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortMethod = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _sortMethod.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
            
                    // Jogadores por Time
                    Text(
                      'Jogadores por Time: $_maxPlayersPerTeam',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: primaryColor.withOpacity(0.2),
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.2),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                      ),
                      child: Slider(
                        value: _maxPlayersPerTeam.toDouble(),
                        min: 3,
                        max: 11,
                        divisions: 8,
                        onChanged: (value) {
                          setState(() {
                            _maxPlayersPerTeam = value.round();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
            
                    // Seleção de Jogadores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selecionar Jogadores',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_selectedPlayers.length} selecionados',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
            
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: allPlayers.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum jogador cadastrado',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          : ListView.builder(
                              itemCount: allPlayers.length,
                              itemBuilder: (context, index) {
                                final player = allPlayers[index];
                                final isSelected = _selectedPlayers.contains(player);
                                final weightColor = _getWeightColor(player.weight);
            
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected 
                                        ? primaryColor 
                                        : Colors.grey.shade200,
                                    child: Text(
                                      player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey.shade700,
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: weightColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: weightColor.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '${player.weight}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: weightColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    activeColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedPlayers.add(player);
                                        } else {
                                          _selectedPlayers.remove(player);
                                        }
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (_selectedPlayers.contains(player)) {
                                        _selectedPlayers.remove(player);
                                      } else {
                                        _selectedPlayers.add(player);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
            
                    ElevatedButton.icon(
                      onPressed: (_selectedPlayers.length >= 2 && _sortMethod != TeamSortMethod.captains) ? () {
                        _showTeamSelectionDialog(context);
                      } : null,
                      icon: const Icon(Icons.group_add),
                      label: const Text('Selecionar jogadores para o mesmo time'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isFormValid ? _createMatch : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  _teamsGenerated
                      ? 'Finalizar Criação da Partida'
                      : 'Continuar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
              ),
              timePickerTheme: TimePickerThemeData(
                hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            child: Localizations.override(
              context: context,
              locale: const Locale('pt', 'BR'),
              child: child!,
            ),
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _createMatch() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPlayers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos um jogador para a partida'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_sortMethod == TeamSortMethod.captains && !_teamsGenerated) {
        setState(() {
          _manualTeamSelection = true;
        });
        return;
      }

      if (!_teamsGenerated) {
        _generateTeams();
        return;
      }

      _finalizeMatchCreation();
    }
  }

  void _finalizeMatchCreation() {
    final appState = context.read<MyAppState>();

    appState.addMatch(
      _selectedDateTime,
      double.parse(_costController.text),
      _sortMethod,
      _maxPlayersPerTeam,
      _selectedPlayers,
      _pixController.text.isNotEmpty ? _pixController.text : null,
      durationMinutes: _durationMinutes,
      preselectedTeams: _preselectedTeams,
      generatedTeams: _generatedTeams,
    );

    widget.onClose();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partida criada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _generateTeams() {
    final players = List<Player>.from(_selectedPlayers);

    players.shuffle();

    final List<Team> teams = [];

    final int totalPlayers = players.length;
    final int maxPlayersPerTeam = _maxPlayersPerTeam;

    final int numFullTeams = totalPlayers ~/ maxPlayersPerTeam;
    final int remainingPlayersCount = totalPlayers % maxPlayersPerTeam;

    final int totalTeams =
        remainingPlayersCount > 0 ? numFullTeams + 1 : numFullTeams;

    List<Player> preparedPlayers;

    final preselectedPlayers = <String>{};

    final usedTeamNames = <String>{};

    if (_preselectedTeams.isNotEmpty) {
      int teamIndex = 0;
      _preselectedTeams.forEach((teamId, playerIds) {
        final existingTeamIndex = teams.indexWhere((team) => team.id == teamId);

        if (existingTeamIndex == -1) {
          String teamName;
          int nameIndex = teamIndex;
          do {
            teamName = 'Time ${String.fromCharCode(65 + nameIndex)}';
            nameIndex++;
          } while (usedTeamNames.contains(teamName));

          usedTeamNames.add(teamName);

          final teamPlayers = <Player>[];

          for (final playerId in playerIds) {
            final player = players.firstWhere(
              (p) => p.id == playerId,
              orElse: () => Player(name: 'Desconhecido', weight: 0),
            );

            if (player.id.isNotEmpty) {
              teamPlayers.add(player);
              preselectedPlayers.add(player.id);
            }
          }

          teams.add(Team(id: teamId, name: teamName, players: teamPlayers));

          teamIndex++;
        } else {
          final team = teams[existingTeamIndex];
          usedTeamNames.add(team.name);

          final teamPlayers = List<Player>.from(team.players);

          for (final playerId in playerIds) {
            final player = players.firstWhere(
              (p) => p.id == playerId,
              orElse: () => Player(name: 'Desconhecido', weight: 0),
            );

            if (player.id.isNotEmpty && !teamPlayers.contains(player)) {
              teamPlayers.add(player);
              preselectedPlayers.add(player.id);
            }
          }

          teams[existingTeamIndex] = team.copyWith(players: teamPlayers);
        }
      });
    }

    final remainingPlayers =
        players.where((p) => !preselectedPlayers.contains(p.id)).toList();

    switch (_sortMethod) {
      case TeamSortMethod.random:
        preparedPlayers = remainingPlayers;
        break;

      case TeamSortMethod.balanced:
        final balancedTeams = TeamBalancerService.createBalancedTeams(
          players: players,
          numTeams: totalTeams,
          maxPlayersPerTeam: _maxPlayersPerTeam,
          preselectedTeams: _preselectedTeams,
        );

        final uniqueBalancedTeams = <Team>[];
        for (final team in balancedTeams) {
          String teamName = team.name;
          int nameIndex = 0;

          while (usedTeamNames.contains(teamName)) {
            nameIndex++;
            teamName = 'Time ${String.fromCharCode(65 + nameIndex)}';
          }

          usedTeamNames.add(teamName);
          uniqueBalancedTeams.add(team.copyWith(name: teamName));
        }

        setState(() {
          _generatedTeams = uniqueBalancedTeams;
          _teamsGenerated = true;
        });
        return;

      case TeamSortMethod.captains:
        return;
    }

    int playerIndex = 0;

    for (int i = 0; i < totalTeams; i++) {
      final teamId = 'team_${DateTime.now().millisecondsSinceEpoch}_$i';
      final existingTeamIndex = teams.indexWhere((team) => team.id == teamId);

      if (existingTeamIndex == -1) {
        String teamName;
        int nameIndex = i;
        do {
          teamName = 'Time ${String.fromCharCode(65 + nameIndex)}';
          nameIndex++;
        } while (usedTeamNames.contains(teamName));

        usedTeamNames.add(teamName);

        final teamPlayers = <Player>[];

        int playersInThisTeam;
        if (i < numFullTeams) {
          playersInThisTeam = maxPlayersPerTeam;
        } else {
          playersInThisTeam = remainingPlayersCount;
        }

        for (
          int j = 0;
          j < playersInThisTeam && playerIndex < preparedPlayers.length;
          j++
        ) {
          teamPlayers.add(preparedPlayers[playerIndex++]);
        }

        teams.add(Team(id: teamId, name: teamName, players: teamPlayers));
      } else {
        final team = teams[existingTeamIndex];
        usedTeamNames.add(team.name);

        final teamPlayers = List<Player>.from(team.players);

        int playersInThisTeam;
        if (i < numFullTeams) {
          playersInThisTeam = maxPlayersPerTeam;
        } else {
          playersInThisTeam = remainingPlayersCount;
        }

        while (teamPlayers.length < playersInThisTeam &&
            playerIndex < preparedPlayers.length) {
          teamPlayers.add(preparedPlayers[playerIndex++]);
        }

        teams[existingTeamIndex] = team.copyWith(players: teamPlayers);
      }
    }

    setState(() {
      _generatedTeams = teams;
      _teamsGenerated = true;
    });
  }

  Widget _buildTeamsPreviewScreen(BuildContext context, MyAppState appState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Times Gerados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _teamsGenerated = false;
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _generatedTeams.length,
              itemBuilder: (context, index) {
                final team = _generatedTeams[index];

                final totalSkill = team.players.fold<int>(
                  0,
                  (sum, player) => sum + player.weight,
                );

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                team.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Chip(
                              label: Text(
                                'Habilidade: $totalSkill',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        const Divider(),
                        ...team.players.map((player) {
                          return ListTile(
                            title: Text(player.name),
                            subtitle: Text('Habilidade: ${player.weight}'),
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            dense: true,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _generateTeams();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refazer Sorteio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _finalizeMatchCreation();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar Times'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualTeamSelectionScreen(
    BuildContext context,
    MyAppState appState,
  ) {
    final int totalPlayers = _selectedPlayers.length;
    final int maxPlayersPerTeam = _maxPlayersPerTeam;

    final int numFullTeams = totalPlayers ~/ maxPlayersPerTeam;
    final int remainingPlayersCount = totalPlayers % maxPlayersPerTeam;

    final int totalTeams =
        remainingPlayersCount > 0 ? numFullTeams + 1 : numFullTeams;

    if (_generatedTeams.isEmpty) {
      final usedTeamNames = <String>{};

      for (int i = 0; i < totalTeams; i++) {
        final teamId = 'team_${DateTime.now().millisecondsSinceEpoch}_$i';

        String teamName;
        int nameIndex = i;
        do {
          teamName = 'Time ${String.fromCharCode(65 + nameIndex)}';
          nameIndex++;
        } while (usedTeamNames.contains(teamName));

        usedTeamNames.add(teamName);

        _generatedTeams.add(Team(id: teamId, name: teamName, players: []));
      }
    }

    final unassignedPlayers =
        _selectedPlayers.where((player) {
          return !_generatedTeams.any((team) => team.players.contains(player));
        }).toList();

    final availableTeams =
        _generatedTeams
            .where((team) => team.players.length < _maxPlayersPerTeam)
            .toList();

    final totalUnassignedSkill = unassignedPlayers.fold<int>(
      0,
      (sum, player) => sum + player.weight,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Times Manualmente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _manualTeamSelection = false;
              _generatedTeams = [];
            });
          },
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jogadores Disponíveis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (unassignedPlayers.isNotEmpty)
                        Chip(
                          label: Text(
                            'Habilidade Total: $totalUnassignedSkill',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: Colors.grey,
                        ),
                    ],
                  ),
                  const Divider(),
                  Container(
                    height: 150,
                    child:
                        unassignedPlayers.isEmpty
                            ? const Center(
                              child: Text('Todos os jogadores foram alocados'),
                            )
                            : ListView.builder(
                              itemCount: unassignedPlayers.length,
                              itemBuilder: (context, index) {
                                final player = unassignedPlayers[index];
                                return ListTile(
                                  title: Text(player.name),
                                  subtitle: Text(
                                    'Habilidade: ${player.weight}',
                                  ),
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  trailing:
                                      availableTeams.isEmpty
                                          ? const Text(
                                            'Sem times disponíveis',
                                            style: TextStyle(color: Colors.red),
                                          )
                                          : DropdownButton<String>(
                                            hint: const Text('Selecionar Time'),
                                            onChanged: (teamId) {
                                              if (teamId != null) {
                                                setState(() {
                                                  final teamIndex =
                                                      _generatedTeams
                                                          .indexWhere(
                                                            (team) =>
                                                                team.id ==
                                                                teamId,
                                                          );
                                                  if (teamIndex != -1) {
                                                    final team =
                                                        _generatedTeams[teamIndex];

                                                    if (team.players.length <
                                                        _maxPlayersPerTeam) {
                                                      final updatedPlayers =
                                                          List<Player>.from(
                                                            team.players,
                                                          )..add(player);
                                                      _generatedTeams[teamIndex] =
                                                          team.copyWith(
                                                            players:
                                                                updatedPlayers,
                                                          );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'O time ${team.name} já atingiu o limite de jogadores',
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                });
                                              }
                                            },
                                            items:
                                                availableTeams.map((team) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: team.id,
                                                    child: Text(
                                                      '${team.name} (${team.players.length}/${_maxPlayersPerTeam})',
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                  dense: true,
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),

          if (availableTeams.length < _generatedTeams.length &&
              availableTeams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alguns times já atingiram o limite de ${_maxPlayersPerTeam} jogadores e não aparecem mais nas opções.',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: _generatedTeams.length,
              itemBuilder: (context, index) {
                final team = _generatedTeams[index];
                final bool isTeamFull =
                    team.players.length >= _maxPlayersPerTeam;

                final totalSkill = team.players.fold<int>(
                  0,
                  (sum, player) => sum + player.weight,
                );

                return Card(
                  margin: const EdgeInsets.all(8),
                  color: isTeamFull ? Colors.grey.shade100 : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${team.name} (${team.players.length}/${_maxPlayersPerTeam})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isTeamFull ? Colors.green : null,
                                ),
                              ),
                            ),

                            Chip(
                              label: Text(
                                'Habilidade: $totalSkill',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            if (isTeamFull)
                              const Chip(
                                label: Text(
                                  'Completo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              ),
                          ],
                        ),
                        const Divider(),
                        ...team.players.map((player) {
                          return ListTile(
                            title: Text(player.name),
                            subtitle: Text('Habilidade: ${player.weight}'),
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  final updatedPlayers = List<Player>.from(
                                    team.players,
                                  )..remove(player);
                                  _generatedTeams[index] = team.copyWith(
                                    players: updatedPlayers,
                                  );
                                });
                              },
                            ),
                            dense: true,
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo de Habilidades dos Times:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              _generatedTeams.map((team) {
                                final totalSkill = team.players.fold<int>(
                                  0,
                                  (sum, player) => sum + player.weight,
                                );
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    '${team.name}: $totalSkill pontos (${team.players.length} jogadores)',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed:
                  unassignedPlayers.isEmpty
                      ? () {
                        setState(() {
                          _teamsGenerated = true;
                          _manualTeamSelection = false;
                        });
                        _finalizeMatchCreation();
                      }
                      : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar Times'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTeamSelectionDialog(BuildContext context) {
    final selectedPlayers = <String>[];
    final selectedGroups = <List<String>>[];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Selecionar Jogadores para o Mesmo Time'),
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
                        'Selecione os jogadores e clique em "Adicionar Grupo" para criar um grupo. '
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
                          if (selectedPlayers.isNotEmpty)
                            Chip(
                              label: Text(
                                '${selectedPlayers.length} selecionados',
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
                          itemCount: _selectedPlayers.length,
                          itemBuilder: (context, index) {
                            final player = _selectedPlayers[index];
                            final isSelected = selectedPlayers.contains(
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
                                            selectedPlayers.add(player.id);
                                          } else {
                                            selectedPlayers.remove(player.id);
                                          }
                                        });
                                      },
                              enabled: !isInAnyGroup,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (selectedPlayers.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedGroups.add(
                                List<String>.from(selectedPlayers),
                              );
                              selectedPlayers.clear();
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
                                          final player = _selectedPlayers
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
                              'O limite máximo de jogadores por time é $_maxPlayersPerTeam. '
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed:
                        (selectedPlayers.isEmpty && selectedGroups.isEmpty)
                            ? null
                            : () {
                              if (selectedPlayers.isNotEmpty) {
                                selectedGroups.add(
                                  List<String>.from(selectedPlayers),
                                );
                              }

                              for (final group in selectedGroups) {
                                final newTeamId =
                                    'team_${DateTime.now().millisecondsSinceEpoch}_${group.hashCode}';
                                _preselectedTeams[newTeamId] = group;
                              }

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    selectedGroups.length == 1
                                        ? 'Um grupo de jogadores selecionado para o mesmo time'
                                        : '${selectedGroups.length} grupos de jogadores selecionados',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirmar'),
                  ),
                ],
              );
            },
          ),
    );
  }
}
