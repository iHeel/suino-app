// lib/presentation/widgets/porca_card.dart
// Cartão grande e legível exibido na tela inicial

import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/porca_model.dart';

class PorcaCard extends StatelessWidget {
  final Porca porca;
  final VoidCallback onTap;

  const PorcaCard({
    super.key,
    required this.porca,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Cabeçalho: foto + nome ──────────────────────────────────
              Row(
                children: [
                  _buildFoto(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          porca.nome,
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cobertura: ${AppDateUtils.formatar(porca.dataCobertura)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Seta indicando que é clicável
                  const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // ─── Datas com indicadores de cor ────────────────────────────
              _buildLinhaData(
                context,
                icone: '💉',
                label: 'Medicação',
                data: porca.dataMedicacao,
                editada: porca.medicacaoEditadaManual,
              ),
              const SizedBox(height: 10),
              _buildLinhaData(
                context,
                icone: '🐷',
                label: 'Parto',
                data: porca.dataParto,
                editada: porca.partoEditadoManual,
              ),
              const SizedBox(height: 10),
              _buildLinhaData(
                context,
                icone: '📦',
                label: 'Apartação',
                data: porca.dataAparta,
                editada: porca.apartaEditadaManual,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoto() {
    // Círculo com foto ou ícone padrão
    return CircleAvatar(
      radius: 30,
      backgroundColor: AppTheme.primary.withOpacity(0.1),
      backgroundImage:
          porca.fotoPath != null ? FileImage(File(porca.fotoPath!)) : null,
      child: porca.fotoPath == null
          ? const Text('🐷', style: TextStyle(fontSize: 28))
          : null,
    );
  }

  Widget _buildLinhaData(
    BuildContext context, {
    required String icone,
    required String label,
    required DateTime data,
    required bool editada,
  }) {
    final cor = AppTheme.corStatus(data);
    final labelStatus = AppTheme.labelStatus(data);

    return Row(
      children: [
        Text(icone, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        // Data formatada
        Text(
          AppDateUtils.formatar(data),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (labelStatus.isNotEmpty) ...[
          const SizedBox(width: 8),
          // Badge de status colorido
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labelStatus,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cor,
              ),
            ),
          ),
        ],
        // Ícone se foi editado manualmente
        if (editada) ...[
          const SizedBox(width: 4),
          const Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
        ],
      ],
    );
  }
}
