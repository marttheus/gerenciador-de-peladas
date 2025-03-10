import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Compartilha o texto usando o menu nativo de compartilhamento
  /// Se falhar, copia para a área de transferência
  static Future<void> shareText(BuildContext context, String text) async {
    try {
      // Tenta usar o share_plus para compartilhar
      await Share.share(
        text,
        subject: 'Detalhes da Partida',
      );
    } catch (e) {
      debugPrint('Erro ao compartilhar: $e');
      
      // Fallback: copia para a área de transferência
      await Clipboard.setData(ClipboardData(text: text));
      
      // Notifica o usuário
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível compartilhar. O texto foi copiado para a área de transferência.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
} 