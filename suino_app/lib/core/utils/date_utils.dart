// lib/core/utils/date_utils.dart
// Utilitários para formatação de datas em Português do Brasil

import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _formato = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _formatoCompleto =
      DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');
  static final DateFormat _formatoDiaSemana =
      DateFormat("EEEE, dd/MM", 'pt_BR');

  /// Formata data como dd/MM/yyyy
  static String formatar(DateTime data) => _formato.format(data);

  /// Formata data como "12 de março de 2025"
  static String formatarCompleto(DateTime data) =>
      _formatoCompleto.format(data);

  /// Formata como "segunda-feira, 12/03"
  static String formatarComDiaSemana(DateTime data) =>
      _formatoDiaSemana.format(data);

  /// Quantos dias faltam / passaram
  static int diasParaHoje(DateTime data) {
    final hoje = DateTime.now();
    final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
    final dataNormalizada = DateTime(data.year, data.month, data.day);
    return dataNormalizada.difference(hojeNormalizado).inDays;
  }

  /// Texto amigável de quando é o evento
  static String textoRelativo(DateTime data) {
    final diff = diasParaHoje(data);
    if (diff < 0) return '${diff.abs()} dia${diff.abs() > 1 ? 's' : ''} atrás';
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    if (diff < 7) return 'Em $diff dias';
    if (diff < 30) return 'Em ${(diff / 7).floor()} semana${(diff / 7).floor() > 1 ? 's' : ''}';
    return formatar(data);
  }

  /// Parse de string dd/MM/yyyy para DateTime
  static DateTime? parse(String texto) {
    try {
      return _formato.parse(texto);
    } catch (_) {
      return null;
    }
  }
}
