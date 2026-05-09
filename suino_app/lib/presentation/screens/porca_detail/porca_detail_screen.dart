// lib/presentation/screens/porca_detail/porca_detail_screen.dart
// Tela de detalhes: mostra todas as datas com edição individual e restauração

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/porca_model.dart';
import '../../providers/porca_provider.dart';
import '../../widgets/data_field_widget.dart';
import '../porca_form/porca_form_screen.dart';

class PorcaDetailScreen extends StatelessWidget {
  final int porcaId;

  const PorcaDetailScreen({super.key, required this.porcaId});

  @override
  Widget build(BuildContext context) {
    return Consumer<PorcaProvider>(
      builder: (context, provider, _) {
        final porca = provider.buscarPorId(porcaId);

        if (porca == null) {
          return const Scaffold(
            body: Center(child: Text('Porca não encontrada')),
          );
        }

        return Scaffold(
          // ─── AppBar ──────────────────────────────────────────────────────
          appBar: AppBar(
            title: Text(porca.nome),
            actions: [
              // Botão editar
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                iconSize: 24,
                tooltip: 'Editar',
                onPressed: () => _abrirEdicao(context, porca),
              ),
              // Botão excluir
              IconButton(
                icon: const Icon(Icons.delete_outline),
                iconSize: 24,
                tooltip: 'Excluir',
                color: Colors.white,
                onPressed: () => _confirmarExclusao(context, porca, provider),
              ),
            ],
          ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Foto da porca ──────────────────────────────────────────
                _buildFoto(porca),

                const SizedBox(height: 4),

                // ─── Informações básicas ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cobertura
                      _buildInfoCobertura(context, porca),

                      const SizedBox(height: 20),

                      // Título da seção de datas
                      const Row(
                        children: [
                          Icon(Icons.event, color: AppTheme.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Datas do ciclo reprodutivo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ─── Medicação ─────────────────────────────────────────
                      DataFieldWidget(
                        icone: '💉',
                        titulo: 'Medicação',
                        subtitulo: '+90 dias da cobertura',
                        data: porca.dataMedicacao,
                        editadaManual: porca.medicacaoEditadaManual,
                        onEditar: () => _editarData(
                          context,
                          provider,
                          porca,
                          tipo: 'medicacao',
                        ),
                        onRestaurar: porca.medicacaoEditadaManual
                            ? () => provider.restaurarMedicacao(porca)
                            : null,
                      ),

                      const SizedBox(height: 12),

                      // ─── Parto ─────────────────────────────────────────────
                      DataFieldWidget(
                        icone: '🐷',
                        titulo: 'Parto previsto',
                        subtitulo: '+113 dias da cobertura',
                        data: porca.dataParto,
                        editadaManual: porca.partoEditadoManual,
                        onEditar: () => _editarData(
                          context,
                          provider,
                          porca,
                          tipo: 'parto',
                        ),
                        onRestaurar: porca.partoEditadoManual
                            ? () => provider.restaurarParto(porca)
                            : null,
                      ),

                      const SizedBox(height: 12),

                      // ─── Aparta ────────────────────────────────────────────
                      DataFieldWidget(
                        icone: '📦',
                        titulo: 'Apartação / Desmame',
                        subtitulo: '+35 dias do parto',
                        data: porca.dataAparta,
                        editadaManual: porca.apartaEditadaManual,
                        onEditar: () => _editarData(
                          context,
                          provider,
                          porca,
                          tipo: 'aparta',
                        ),
                        onRestaurar: porca.apartaEditadaManual
                            ? () => provider.restaurarAparta(porca)
                            : null,
                      ),

                      const SizedBox(height: 20),

                      // ─── Leitões ────────────────────────────────────────────
                      _buildLeitoes(context, porca, provider),

                      // ─── Observações ────────────────────────────────────────
                      if (porca.observacoes != null &&
                          porca.observacoes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildObservacoes(context, porca),
                      ],

                      const SizedBox(height: 32),

                      // ─── Botão excluir no fim da tela ─────────────────────
                      OutlinedButton.icon(
                        onPressed: () =>
                            _confirmarExclusao(context, porca, provider),
                        icon: const Icon(Icons.delete_outline,
                            color: AppTheme.vermelho),
                        label: const Text(
                          'Excluir esta porca',
                          style: TextStyle(color: AppTheme.vermelho),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.vermelho),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Foto grande no topo ───────────────────────────────────────────────────
  Widget _buildFoto(Porca porca) {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppTheme.primary.withOpacity(0.08),
      child: porca.fotoPath != null
          ? Image.file(
              File(porca.fotoPath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            )
          : const Center(
              child: Text('🐷', style: TextStyle(fontSize: 80)),
            ),
    );
  }

  // ─── Info de cobertura ─────────────────────────────────────────────────────
  Widget _buildInfoCobertura(BuildContext context, Porca porca) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data da cobertura',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                AppDateUtils.formatarCompleto(porca.dataCobertura),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Quantidade de leitões ─────────────────────────────────────────────────
  Widget _buildLeitoes(
      BuildContext context, Porca porca, PorcaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider, width: 1.5),
      ),
      child: Row(
        children: [
          const Text('🐽', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quantidade de leitões',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  porca.quantidadeLeitoes?.toString() ?? 'Não informado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: porca.quantidadeLeitoes != null
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Botão para editar quantidade
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => _editarLeitoes(context, porca, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildObservacoes(BuildContext context, Porca porca) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note_outlined, size: 18, color: Colors.amber),
              SizedBox(width: 6),
              Text(
                'Observações',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            porca.observacoes!,
            style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  // ─── Editar data individual ────────────────────────────────────────────────
  Future<void> _editarData(
    BuildContext context,
    PorcaProvider provider,
    Porca porca, {
    required String tipo, // 'medicacao', 'parto', 'aparta'
  }) async {
    DateTime dataAtual;
    String titulo;

    switch (tipo) {
      case 'medicacao':
        dataAtual = porca.dataMedicacao;
        titulo = 'Editar data da medicação';
        break;
      case 'parto':
        dataAtual = porca.dataParto;
        titulo = 'Editar data do parto';
        break;
      default:
        dataAtual = porca.dataAparta;
        titulo = 'Editar data da apartação';
    }

    final nova = await showDatePicker(
      context: context,
      initialDate: dataAtual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: titulo,
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );

    if (nova == null) return;

    Porca porcaAtualizada;
    switch (tipo) {
      case 'medicacao':
        porcaAtualizada = porca.copyWith(
          dataMedicacao: nova,
          medicacaoEditadaManual: true,
        );
        break;
      case 'parto':
        porcaAtualizada = porca.copyWith(
          dataParto: nova,
          partoEditadoManual: true,
        );
        break;
      default:
        porcaAtualizada = porca.copyWith(
          dataAparta: nova,
          apartaEditadaManual: true,
        );
    }

    await provider.atualizar(porcaAtualizada);
  }

  // ─── Editar leitões ────────────────────────────────────────────────────────
  Future<void> _editarLeitoes(
    BuildContext context,
    Porca porca,
    PorcaProvider provider,
  ) async {
    final ctrl = TextEditingController(
      text: porca.quantidadeLeitoes?.toString() ?? '',
    );

    final resultado = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quantidade de leitões'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: '0',
            suffixText: 'leitões',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              Navigator.pop(ctx, v);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (resultado != null) {
      await provider.atualizar(porca.copyWith(quantidadeLeitoes: resultado));
    }
  }

  // ─── Confirmar exclusão ────────────────────────────────────────────────────
  Future<void> _confirmarExclusao(
    BuildContext context,
    Porca porca,
    PorcaProvider provider,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir porca?'),
        content: Text(
          'Tem certeza que deseja excluir "${porca.nome}"?\n\nEssa ação não pode ser desfeita.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.vermelho),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await provider.excluir(porca.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${porca.nome} excluída'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _abrirEdicao(BuildContext context, Porca porca) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PorcaFormScreen(porca: porca),
      ),
    );
  }
}
