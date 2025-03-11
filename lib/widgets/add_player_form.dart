import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';

class AddPlayerForm extends StatefulWidget {
  final VoidCallback onClose;

  const AddPlayerForm({super.key, required this.onClose});

  @override
  State<AddPlayerForm> createState() => _AddPlayerFormState();
}

class _AddPlayerFormState extends State<AddPlayerForm> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  int _weight = 5;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animações
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                      'Adicionar Jogador',
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
                        onPressed: () {
                          // Animar saída
                          _animationController.reverse().then((_) {
                            widget.onClose();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Campo de nome
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Jogador',
                    hintText: 'Digite o nome completo',
                    prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o nome do jogador';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Seletor de habilidade
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nível de Habilidade',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getWeightColor(_weight).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getWeightColor(_weight).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getWeightColor(_weight),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _weight.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: _getWeightColor(_weight),
                              inactiveTrackColor: _getWeightColor(_weight).withOpacity(0.2),
                              thumbColor: _getWeightColor(_weight),
                              overlayColor: _getWeightColor(_weight).withOpacity(0.2),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                            ),
                            child: Slider(
                              value: _weight.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              onChanged: (value) {
                                setState(() {
                                  _weight = value.round();
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getWeightDescription(_weight),
                            style: TextStyle(
                              color: _getWeightColor(_weight),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Botão de adicionar
                ElevatedButton.icon(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('ADICIONAR JOGADOR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addPlayer() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      
      context.read<MyAppState>().addPlayer(name, _weight);
      
      // Animar saída
      _animationController.reverse().then((_) {
        widget.onClose();
        
        // Mostrar snackbar de confirmação
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name foi adicionado com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
      });
    }
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
  
  String _getWeightDescription(int weight) {
    if (weight <= 3) {
      return 'Bagre';
    } else if (weight <= 7) {
      return 'Sabe dominar uma bola';
    } else {
      return 'Craque';
    }
  }
}
