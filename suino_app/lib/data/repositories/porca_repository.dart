// lib/data/repositories/porca_repository.dart
// Repositório responsável por todas as operações de banco de dados da porca

import '../database/database_helper.dart';
import '../models/porca_model.dart';

class PorcaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Busca todas as porcas, ordenadas por data de cobertura
  Future<List<Porca>> getAll() async {
    final db = await _dbHelper.db;
    final maps = await db.query(
      'porcas',
      orderBy: 'data_cobertura DESC',
    );
    return maps.map((m) => Porca.fromMap(m)).toList();
  }

  // Busca porca por ID
  Future<Porca?> getById(int id) async {
    final db = await _dbHelper.db;
    final maps = await db.query('porcas', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Porca.fromMap(maps.first);
  }

  // Pesquisa por nome (busca simples)
  Future<List<Porca>> search(String query) async {
    final db = await _dbHelper.db;
    final maps = await db.query(
      'porcas',
      where: 'nome LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nome ASC',
    );
    return maps.map((m) => Porca.fromMap(m)).toList();
  }

  // Insere nova porca
  Future<Porca> insert(Porca porca) async {
    final db = await _dbHelper.db;
    final id = await db.insert('porcas', porca.toMap());
    return porca.copyWith(id: id);
  }

  // Atualiza porca existente
  Future<void> update(Porca porca) async {
    final db = await _dbHelper.db;
    await db.update(
      'porcas',
      porca.toMap(),
      where: 'id = ?',
      whereArgs: [porca.id],
    );
  }

  // Remove porca por ID
  Future<void> delete(int id) async {
    final db = await _dbHelper.db;
    await db.delete('porcas', where: 'id = ?', whereArgs: [id]);
  }

  // Busca porcas com eventos nos próximos N dias (para resumo do topo)
  Future<List<Porca>> getWithEventosProximos(int dias) async {
    final db = await _dbHelper.db;
    final limite = DateTime.now().add(Duration(days: dias)).toIso8601String();
    final hoje = DateTime.now().toIso8601String();

    final maps = await db.rawQuery('''
      SELECT * FROM porcas
      WHERE data_medicacao BETWEEN ? AND ?
         OR data_parto BETWEEN ? AND ?
         OR data_aparta BETWEEN ? AND ?
      ORDER BY data_parto ASC
    ''', [hoje, limite, hoje, limite, hoje, limite]);

    return maps.map((m) => Porca.fromMap(m)).toList();
  }
}
