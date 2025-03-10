import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareText(BuildContext context, String text) async {
    try {
      await Share.share(text, subject: 'Detalhes da Partida');
    } catch (e) {
      debugPrint('Erro ao compartilhar: $e');

      await Clipboard.setData(ClipboardData(text: text));

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
