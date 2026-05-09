// lib/presentation/widgets/data_field_widget.dart
// Campo de data reutilizável com botão editar e restaurar automático

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';

class DataFieldWidget extends StatelessWidget {
  final String icone;
  final String titulo;
  final String subtitulo; // Ex: "+90 dias da cobertura"
  final DateTime data;
  final bool editadaManual;
  final VoidCallback onEditar;
  final VoidCallback? onRestaurar;

  const DataFieldWidget({
    super.key,
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.data,
    required this.editadaManual,
    required this.onEditar,
    this.onRestaurar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = AppTheme.corStatus(data);
    final textoRelativo = AppDateUtils.textoRelativo(data);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: editadaManual
              ? AppTheme.amarelo.withOpacity(0.5)
              : AppTheme.divider,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Cabeçalho ───────────────────────────────────────────────
            Row(
              children: [
                Text(icone, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (editadaManual) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.amarelo.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'editado',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.amarelo,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ─── Data e status ────────────────────────────────────────────
            Row(
              children: [
                // Data grande e legível
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppDateUtils.formatar(data),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (textoRelativo.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            textoRelativo,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ─── Botões de ação ───────────────────────────────────────
                Column(
                  children: [
                    // Botão editar
                    _botaoAcao(
                      icone: Icons.edit_outlined,
                      label: 'Editar',
                      cor: AppTheme.primary,
                      onTap: onEditar,
                    ),
                    if (editadaManual && onRestaurar != null) ...[
                      const SizedBox(height: 6),
                      _botaoAcao(
                        icone: Icons.refresh,
                        label: 'Automático',
                        cor: AppTheme.amarelo,
                        onTap: onRestaurar!,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoAcao({
    required IconData icone,
    required String label,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 16, color: cor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
