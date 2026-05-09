// lib/presentation/screens/home/home_screen.dart
// Tela principal: lista de porcas + resumo + busca + botão adicionar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/porca_provider.dart';
import '../../widgets/porca_card.dart';
import '../../widgets/resumo_widget.dart';
import '../porca_form/porca_form_screen.dart';
import '../porca_detail/porca_detail_screen.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _buscaCtrl = TextEditingController();
  bool _buscaAberta = false;

  @override
  void initState() {
    super.initState();
    // Carrega as porcas ao abrir o app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PorcaProvider>().carregar();
    });
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: _buscaAberta
            ? TextField(
                controller: _buscaCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 17),
                decoration: const InputDecoration(
                  hintText: 'Buscar porca...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                onChanged: (v) => context.read<PorcaProvider>().buscar(v),
              )
            : const Text('🐷 Controle de Porcas'),
        actions: [
          // Botão de busca
          IconButton(
            icon: Icon(_buscaAberta ? Icons.close : Icons.search),
            iconSize: 26,
            onPressed: () {
              setState(() {
                _buscaAberta = !_buscaAberta;
                if (!_buscaAberta) {
                  _buscaCtrl.clear();
                  context.read<PorcaProvider>().limparBusca();
                }
              });
            },
          ),
        ],
      ),

      // ─── Corpo ─────────────────────────────────────────────────────────────
      body: Consumer<PorcaProvider>(
        builder: (context, provider, _) {
          if (provider.carregando) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final porcas = provider.porcas;

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => provider.carregar(),
            child: CustomScrollView(
              slivers: [
                // Resumo de eventos próximos
                const SliverToBoxAdapter(child: ResumoWidget()),

                // Lista vazia
                if (porcas.isEmpty)
                  SliverFillRemaining(
                    child: _buildListaVazia(context),
                  )
                else ...[
                  // Contador de porcas
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Text(
                        '${porcas.length} porca${porcas.length != 1 ? 's' : ''} cadastrada${porcas.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Lista de cartões
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => PorcaCard(
                        porca: porcas[i],
                        onTap: () => _abrirDetalhe(context, porcas[i].id!),
                      ),
                      childCount: porcas.length,
                    ),
                  ),

                  // Espaço no final para o FAB não cobrir
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ],
            ),
          );
        },
      ),

      // ─── Botão flutuante grande ─────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add, size: 26),
        label: const Text(
          'Nova Porca',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildListaVazia(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐷', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma porca cadastrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Toque no botão abaixo para\ncadastrar a primeira porca',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () => _abrirFormulario(context),
                icon: const Icon(Icons.add, size: 22),
                label: const Text('Cadastrar porca'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirFormulario(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PorcaFormScreen()),
    );
  }

  void _abrirDetalhe(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PorcaDetailScreen(porcaId: id)),
    );
  }
}
