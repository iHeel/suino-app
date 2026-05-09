// lib/presentation/screens/porca_form/porca_form_screen.dart
// Tela de cadastro/edição: simples, com poucos campos e botões grandes

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/porca_model.dart';
import '../../providers/porca_provider.dart';

class PorcaFormScreen extends StatefulWidget {
  final Porca? porca; // null = novo cadastro, não-null = edição

  const PorcaFormScreen({super.key, this.porca});

  @override
  State<PorcaFormScreen> createState() => _PorcaFormScreenState();
}

class _PorcaFormScreenState extends State<PorcaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime? _dataCobertura;
  String? _fotoPath;
  bool _salvando = false;

  bool get _editando => widget.porca != null;

  @override
  void initState() {
    super.initState();
    if (_editando) {
      final p = widget.porca!;
      _nomeCtrl.text = p.nome;
      _obsCtrl.text = p.observacoes ?? '';
      _dataCobertura = p.dataCobertura;
      _fotoPath = p.fotoPath;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Porca' : 'Nova Porca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Foto ──────────────────────────────────────────────────────
              Center(child: _buildSeletorFoto()),

              const SizedBox(height: 28),

              // ─── Nome / identificação ─────────────────────────────────────
              _label('Nome ou número da porca *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomeCtrl,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Ex: 014 ou Maria',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Por favor, informe o nome ou número';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ─── Data da cobertura ────────────────────────────────────────
              _label('Data da cobertura *'),
              const SizedBox(height: 8),
              _buildBotaoData(),

              // Preview das datas calculadas
              if (_dataCobertura != null) ...[
                const SizedBox(height: 20),
                _buildPreviewDatas(),
              ],

              const SizedBox(height: 24),

              // ─── Observações ──────────────────────────────────────────────
              _label('Observações (opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _obsCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Anotações sobre esta porca...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 36),

              // ─── Botão salvar ─────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, size: 22),
                label: Text(_editando ? 'Salvar alterações' : 'Cadastrar porca'),
              ),

              const SizedBox(height: 12),

              // Botão cancelar
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Seletor de foto ───────────────────────────────────────────────────────
  Widget _buildSeletorFoto() {
    return GestureDetector(
      onTap: _selecionarFoto,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            backgroundImage:
                _fotoPath != null ? FileImage(File(_fotoPath!)) : null,
            child: _fotoPath == null
                ? const Text('🐷', style: TextStyle(fontSize: 50))
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarFoto() async {
    final picker = ImagePicker();

    // Mostra opções: câmera ou galeria
    final opcao = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escolher foto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Tirar foto', style: TextStyle(fontSize: 17)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Da galeria', style: TextStyle(fontSize: 17)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (_fotoPath != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.vermelho,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  title: const Text('Remover foto',
                      style: TextStyle(fontSize: 17, color: AppTheme.vermelho)),
                  onTap: () {
                    setState(() => _fotoPath = null);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );

    if (opcao == null) return;

    final img = await picker.pickImage(
      source: opcao,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (img != null) {
      setState(() => _fotoPath = img.path);
    }
  }

  // ─── Botão seletor de data ─────────────────────────────────────────────────
  Widget _buildBotaoData() {
    return InkWell(
      onTap: _selecionarData,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _dataCobertura == null
                ? AppTheme.divider
                : AppTheme.primary,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _dataCobertura == null
                  ? AppTheme.textSecondary
                  : AppTheme.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dataCobertura == null
                    ? 'Toque para escolher a data'
                    : AppDateUtils.formatar(_dataCobertura!),
                style: TextStyle(
                  fontSize: 17,
                  color: _dataCobertura == null
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                  fontWeight: _dataCobertura != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (_dataCobertura != null)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataCobertura ?? hoje,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      helpText: 'Data da cobertura',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );

    if (selecionada != null) {
      setState(() => _dataCobertura = selecionada);
    }
  }

  // ─── Preview das datas calculadas ─────────────────────────────────────────
  Widget _buildPreviewDatas() {
    final parto = Porca.calcularParto(_dataCobertura!);
    final medicacao = Porca.calcularMedicacao(_dataCobertura!);
    final aparta = Porca.calcularAparta(parto);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_fix_high, size: 16, color: AppTheme.primary),
              SizedBox(width: 6),
              Text(
                'Datas calculadas automaticamente',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _linhaPreview('💉 Medicação', medicacao),
          const SizedBox(height: 6),
          _linhaPreview('🐷 Parto', parto),
          const SizedBox(height: 6),
          _linhaPreview('📦 Apartação', aparta),
        ],
      ),
    );
  }

  Widget _linhaPreview(String label, DateTime data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        Text(
          AppDateUtils.formatar(data),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  // ─── Salvar ────────────────────────────────────────────────────────────────
  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataCobertura == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe a data da cobertura'),
          backgroundColor: AppTheme.vermelho,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    final provider = context.read<PorcaProvider>();

    bool sucesso;

    if (_editando) {
      // Edição: mantém datas manuais, atualiza cobertura e recalcula automáticas
      final p = widget.porca!;
      final novoParto = p.partoEditadoManual
          ? p.dataParto
          : Porca.calcularParto(_dataCobertura!);

      final porcaAtualizada = p.copyWith(
        nome: _nomeCtrl.text.trim(),
        fotoPath: _fotoPath,
        dataCobertura: _dataCobertura,
        dataMedicacao: p.medicacaoEditadaManual
            ? p.dataMedicacao
            : Porca.calcularMedicacao(_dataCobertura!),
        dataParto: novoParto,
        dataAparta: p.apartaEditadaManual
            ? p.dataAparta
            : Porca.calcularAparta(novoParto),
        observacoes: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      );
      sucesso = await provider.atualizar(porcaAtualizada);
    } else {
      // Novo cadastro
      final nova = Porca.fromCobertura(
        nome: _nomeCtrl.text.trim(),
        dataCobertura: _dataCobertura!,
        fotoPath: _fotoPath,
        observacoes:
            _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      );
      final resultado = await provider.adicionar(nova);
      sucesso = resultado != null;
    }

    setState(() => _salvando = false);

    if (!mounted) return;

    if (sucesso) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editando ? 'Porca atualizada!' : 'Porca cadastrada!'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar. Tente novamente.'),
          backgroundColor: AppTheme.vermelho,
        ),
      );
    }
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }
}
