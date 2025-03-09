import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';

class AddPlayerForm extends StatefulWidget {
  final VoidCallback onClose;

  const AddPlayerForm({super.key, required this.onClose});

  @override
  State<AddPlayerForm> createState() => _AddPlayerFormState();
}

class _AddPlayerFormState extends State<AddPlayerForm> {
  final _nameController = TextEditingController();

  int _weight = 5;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adicionar Jogador',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 16),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do Jogador',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, informe o nome do jogador';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Habilidade: $_weight',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getWeightColor(_weight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getWeightLabel(_weight),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('1'),
                  Expanded(
                    child: Slider(
                      value: _weight.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _weight.toString(),
                      activeColor: _getWeightColor(_weight),
                      onChanged: (value) {
                        setState(() {
                          _weight = value.round();
                        });
                      },
                    ),
                  ),
                  const Text('10'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _savePlayer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.save),
                SizedBox(width: 8),
                Text('Salvar Jogador'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _savePlayer() {
    if (_formKey.currentState!.validate()) {
      final appState = context.read<MyAppState>();

      appState.addPlayer(_nameController.text.trim(), _weight);

      widget.onClose();
    }
  }

  Color _getWeightColor(int weight) {
    if (weight <= 3) {
      return Colors.red;
    } else if (weight <= 7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getWeightLabel(int weight) {
    if (weight <= 3) {
      return 'Bagre';
    } else if (weight <= 7) {
      return 'Domina um bola';
    } else {
      return 'Craque';
    }
  }
}
