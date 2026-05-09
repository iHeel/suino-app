// lib/core/theme/app_theme.dart
// Tema global do aplicativo - otimizado para facilidade de uso

import 'package:flutter/material.dart';

class AppTheme {
  // ─── Paleta de cores ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2E7D32);      // Verde campo
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);

  static const Color amarelo = Color(0xFFF9A825);      // Atenção
  static const Color vermelho = Color(0xFFC62828);     // Urgente/atrasado
  static const Color verde = Color(0xFF2E7D32);        // Normal

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);
  static const Color divider = Color(0xFFE0E0E0);

  // ─── Tema principal ─────────────────────────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        surface: surface,
      ),

      scaffoldBackgroundColor: background,

      // Fontes grandes para facilitar leitura
      textTheme: const TextTheme(
        // Títulos principais
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        // Corpo do texto
        bodyLarge: TextStyle(
          fontSize: 17,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: textPrimary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          color: textSecondary,
        ),
        // Labels e botões
        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),

      // AppBar limpa
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Botões grandes e fáceis de tocar
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56), // Altura mínima grande
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
        ),
      ),

      // Botão outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Campos de texto grandes e legíveis
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18, // Área de toque maior
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(fontSize: 15, color: textSecondary),
        hintStyle: const TextStyle(fontSize: 15, color: textSecondary),
      ),

      // Cards com sombra suave
      cardTheme: CardTheme(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // FAB grande e visível
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ─── Helpers de cor por status ──────────────────────────────────────────────
  /// Retorna a cor do status baseado na diferença em dias
  static Color corStatus(DateTime data) {
    final hoje = DateTime.now();
    final diff = data.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;

    if (diff < 0) return vermelho;        // Atrasado
    if (diff <= 3) return amarelo;        // Próximo (até 3 dias)
    return verde;                          // Normal
  }

  static Color corStatusFundo(DateTime data) {
    return corStatus(data).withOpacity(0.1);
  }

  /// Label legível do status
  static String labelStatus(DateTime data) {
    final hoje = DateTime.now();
    final diff = data.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;

    if (diff < 0) return '${diff.abs()}d atrasado';
    if (diff == 0) return 'Hoje!';
    if (diff == 1) return 'Amanhã';
    if (diff <= 7) return 'Em ${diff}d';
    return '';
  }
}
