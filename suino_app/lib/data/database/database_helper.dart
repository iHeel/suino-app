// lib/data/database/database_helper.dart
// Gerencia conexão e schema do banco de dados SQLite local

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'suino_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE porcas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        foto_path TEXT,
        data_cobertura TEXT NOT NULL,
        data_medicacao TEXT NOT NULL,
        data_parto TEXT NOT NULL,
        data_aparta TEXT NOT NULL,
        medicacao_editada_manual INTEGER NOT NULL DEFAULT 0,
        parto_editado_manual INTEGER NOT NULL DEFAULT 0,
        aparta_editada_manual INTEGER NOT NULL DEFAULT 0,
        quantidade_leitoes INTEGER,
        observacoes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
}
