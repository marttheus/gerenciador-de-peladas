import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/match.dart';
import '../models/player.dart';

class PaymentManager extends StatefulWidget {
  final Match match;
  final bool showCompleteButton;

  const PaymentManager({
    Key? key,
    required this.match,
    this.showCompleteButton = true,
  }) : super(key: key);

  @override
  State<PaymentManager> createState() => _PaymentManagerState();
}

class _PaymentManagerState extends State<PaymentManager> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

    final updatedMatch = appState.matches.firstWhere(
      (m) => m.id == widget.match.id,
      orElse: () => widget.match,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentHeader(updatedMatch),

        _buildPlayerPaymentList(updatedMatch),

        if (updatedMatch.status == MatchStatus.completed)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Esta partida foi concluída',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (updatedMatch.status != MatchStatus.completed)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _markAllAsPaid(updatedMatch),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Marcar Todos como Pagos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                if (widget.showCompleteButton &&
                    updatedMatch.status == MatchStatus.played)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _showCompleteMatchDialog(context, updatedMatch),
                      icon: const Icon(Icons.sports_score, color: Colors.white),
                      label: const Text('Concluir Partida'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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

  Widget _buildPaymentHeader(Match match) {
    final totalPlayers = match.selectedPlayers.length;
    final paidPlayers = match.paidPlayerIds.length;
    final paymentPercentage =
        totalPlayers > 0 ? paidPlayers / totalPlayers : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pagamentos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso: ${(paymentPercentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$paidPlayers de $totalPlayers pagos',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: paymentPercentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(paymentPercentage),
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (match.pixKey != null && match.pixKey!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pix, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Chave PIX',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.pixKey!,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          () => _copyPixKeyToClipboard(context, match.pixKey!),
                      icon: const Icon(Icons.copy, color: Colors.blue),
                      tooltip: 'Copiar chave PIX',
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlayerPaymentList(Match match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status de Pagamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: match.selectedPlayers.length,
          itemBuilder: (context, index) {
            final player = match.selectedPlayers[index];
            final isPaid = match.isPlayerPaid(player.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPaid ? Colors.green : Colors.grey.shade300,
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: isPaid ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isPaid ? 'Pago' : 'Pendente',
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing:
                    match.status != MatchStatus.completed
                        ? Switch(
                          value: isPaid,
                          onChanged:
                              (value) => _togglePlayerPaymentStatus(
                                match.id,
                                player.id,
                                value,
                              ),
                          activeColor: Colors.green,
                        )
                        : null,
              ),
            );
          },
        ),
      ],
    );
  }

  void _showCompleteMatchDialog(BuildContext context, Match match) {
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

                  if (!match.allPlayersPaid)
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
                            'Existem ${match.selectedPlayers.length - match.paidPlayerIds.length} jogadores que ainda não pagaram.',
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
                  appState.updateMatchStatus(match.id, MatchStatus.completed);
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

  void _markAllAsPaid(Match match) {
    final appState = Provider.of<MyAppState>(context, listen: false);

    for (final player in match.selectedPlayers) {
      if (!match.isPlayerPaid(player.id)) {
        appState.markPlayerAsPaid(match.id, player.id);
      }
    }

    setState(() {});
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

  void _copyPixKeyToClipboard(BuildContext context, String pixKey) {
    Clipboard.setData(ClipboardData(text: pixKey));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chave PIX copiada para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _togglePlayerPaymentStatus(String matchId, String playerId, bool value) {
    final appState = Provider.of<MyAppState>(context, listen: false);
    if (value) {
      appState.markPlayerAsPaid(matchId, playerId);
    } else {
      appState.markPlayerAsUnpaid(matchId, playerId);
    }

    setState(() {});
  }
}
