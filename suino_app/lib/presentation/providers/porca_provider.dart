// lib/presentation/providers/porca_provider.dart
// Gerenciamento de estado com Provider - mantém lista de porcas em memória

import 'package:flutter/foundation.dart';
import '../../data/models/porca_model.dart';
import '../../data/repositories/porca_repository.dart';
import '../../services/notification_service.dart';

class PorcaProvider with ChangeNotifier {
  final PorcaRepository _repo = PorcaRepository();
  final NotificationService _notifService = NotificationService.instance;

  List<Porca> _porcas = [];
  bool _carregando = false;
  String? _erro;
  String _busca = '';

  // ─── Getters ────────────────────────────────────────────────────────────────
  List<Porca> get porcas {
    if (_busca.isEmpty) return _porcas;
    final q = _busca.toLowerCase();
    return _porcas.where((p) => p.nome.toLowerCase().contains(q)).toList();
  }

  bool get carregando => _carregando;
  String? get erro => _erro;
  String get busca => _busca;

  // ─── Resumo para o topo da tela ─────────────────────────────────────────────
  int get partosProximos {
    final limite = DateTime.now().add(const Duration(days: 7));
    final hoje = DateTime.now();
    return _porcas.where((p) {
      final diff = p.dataParto.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
      return diff >= 0 && p.dataParto.isBefore(limite);
    }).length;
  }

  int get medicacoesProximas {
    final limite = DateTime.now().add(const Duration(days: 3));
    final hoje = DateTime.now();
    return _porcas.where((p) {
      final diff = p.dataMedicacao.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
      return diff >= 0 && p.dataMedicacao.isBefore(limite);
    }).length;
  }

  int get apartasSemana {
    final limite = DateTime.now().add(const Duration(days: 7));
    final hoje = DateTime.now();
    return _porcas.where((p) {
      final diff = p.dataAparta.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
      return diff >= 0 && p.dataAparta.isBefore(limite);
    }).length;
  }

  // ─── Carregamento inicial ────────────────────────────────────────────────────
  Future<void> carregar() async {
    _setCarregando(true);
    try {
      _porcas = await _repo.getAll();
      _erro = null;
    } catch (e) {
      _erro = 'Erro ao carregar: $e';
    } finally {
      _setCarregando(false);
    }
  }

  // ─── Busca ───────────────────────────────────────────────────────────────────
  void buscar(String query) {
    _busca = query;
    notifyListeners();
  }

  void limparBusca() {
    _busca = '';
    notifyListeners();
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────────
  Future<Porca?> adicionar(Porca porca) async {
    try {
      final nova = await _repo.insert(porca);
      _porcas.insert(0, nova);
      notifyListeners();
      // Agenda notificações
      await _notifService.agendarParaPorca(nova);
      return nova;
    } catch (e) {
      _erro = 'Erro ao salvar: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> atualizar(Porca porca) async {
    try {
      await _repo.update(porca);
      final idx = _porcas.indexWhere((p) => p.id == porca.id);
      if (idx != -1) {
        _porcas[idx] = porca;
        notifyListeners();
      }
      // Reagenda notificações com novas datas
      await _notifService.agendarParaPorca(porca);
      return true;
    } catch (e) {
      _erro = 'Erro ao atualizar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluir(int id) async {
    try {
      await _repo.delete(id);
      await _notifService.cancelarParaPorca(id);
      _porcas.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _erro = 'Erro ao excluir: $e';
      notifyListeners();
      return false;
    }
  }

  // ─── Restaurar datas automáticas ────────────────────────────────────────────
  Future<void> restaurarMedicacao(Porca porca) async {
    await atualizar(porca.restaurarMedicacao());
  }

  Future<void> restaurarParto(Porca porca) async {
    await atualizar(porca.restaurarParto());
  }

  Future<void> restaurarAparta(Porca porca) async {
    await atualizar(porca.restaurarAparta());
  }

  // ─── Helpers internos ───────────────────────────────────────────────────────
  void _setCarregando(bool v) {
    _carregando = v;
    notifyListeners();
  }

  Porca? buscarPorId(int id) {
    try {
      return _porcas.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
