// lib/presentation/widgets/resumo_widget.dart
// Resumo rápido no topo mostrando eventos próximos

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/porca_provider.dart';
import '../../core/theme/app_theme.dart';

class ResumoWidget extends StatelessWidget {
  const ResumoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PorcaProvider>(
      builder: (context, provider, _) {
        final partos = provider.partosProximos;
        final medicacoes = provider.medicacoesProximas;
        final apartas = provider.apartasSemana;

        // Se não há eventos próximos, não exibe o resumo
        if (partos == 0 && medicacoes == 0 && apartas == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Próximos eventos',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (partos > 0)
                    _chip('🐷', '$partos parto${partos > 1 ? 's' : ''}', 'essa semana'),
                  if (medicacoes > 0)
                    _chip('💉', '$medicacoes medicaç${medicacoes > 1 ? 'ões' : 'ão'}', 'em 3 dias'),
                  if (apartas > 0)
                    _chip('📦', '$apartas apartaç${apartas > 1 ? 'ões' : 'ão'}', 'essa semana'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String emoji, String texto, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                texto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
