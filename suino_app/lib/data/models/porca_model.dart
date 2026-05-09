// lib/data/models/porca_model.dart
// Modelo principal de dados da porca/matriz

import 'package:flutter/foundation.dart';

class Porca {
  final int? id;
  final String nome;
  final String? fotoPath;

  // Datas principais
  final DateTime dataCobertura;
  final DateTime dataMedicacao;
  final DateTime dataParto;
  final DateTime dataAparta;

  // Flags indicando se foram editadas manualmente
  final bool medicacaoEditadaManual;
  final bool partoEditadoManual;
  final bool apartaEditadaManual;

  // Informações adicionais
  final int? quantidadeLeitoes;
  final String? observacoes;

  final DateTime createdAt;

  Porca({
    this.id,
    required this.nome,
    this.fotoPath,
    required this.dataCobertura,
    required this.dataMedicacao,
    required this.dataParto,
    required this.dataAparta,
    this.medicacaoEditadaManual = false,
    this.partoEditadoManual = false,
    this.apartaEditadaManual = false,
    this.quantidadeLeitoes,
    this.observacoes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ─── Regras de negócio: cálculo automático das datas ────────────────────────
  static DateTime calcularMedicacao(DateTime cobertura) =>
      cobertura.add(const Duration(days: 90));

  static DateTime calcularParto(DateTime cobertura) =>
      cobertura.add(const Duration(days: 113));

  static DateTime calcularAparta(DateTime parto) =>
      parto.add(const Duration(days: 35));

  // Factory: cria porca com datas calculadas automaticamente
  factory Porca.fromCobertura({
    int? id,
    required String nome,
    required DateTime dataCobertura,
    String? fotoPath,
    String? observacoes,
    int? quantidadeLeitoes,
    DateTime? createdAt,
  }) {
    final parto = calcularParto(dataCobertura);
    return Porca(
      id: id,
      nome: nome,
      fotoPath: fotoPath,
      dataCobertura: dataCobertura,
      dataMedicacao: calcularMedicacao(dataCobertura),
      dataParto: parto,
      dataAparta: calcularAparta(parto),
      observacoes: observacoes,
      quantidadeLeitoes: quantidadeLeitoes,
      createdAt: createdAt,
    );
  }

  // Restaura uma data específica para o valor automático
  Porca restaurarMedicacao() => copyWith(
        dataMedicacao: calcularMedicacao(dataCobertura),
        medicacaoEditadaManual: false,
      );

  Porca restaurarParto() {
    final novoParto = calcularParto(dataCobertura);
    return copyWith(
      dataParto: novoParto,
      partoEditadoManual: false,
      // Se aparta não foi editada, recalcula também
      dataAparta: apartaEditadaManual ? dataAparta : calcularAparta(novoParto),
    );
  }

  Porca restaurarAparta() => copyWith(
        dataAparta: calcularAparta(dataParto),
        apartaEditadaManual: false,
      );

  // ─── Serialização para SQLite ───────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'foto_path': fotoPath,
      'data_cobertura': dataCobertura.toIso8601String(),
      'data_medicacao': dataMedicacao.toIso8601String(),
      'data_parto': dataParto.toIso8601String(),
      'data_aparta': dataAparta.toIso8601String(),
      'medicacao_editada_manual': medicacaoEditadaManual ? 1 : 0,
      'parto_editado_manual': partoEditadoManual ? 1 : 0,
      'aparta_editada_manual': apartaEditadaManual ? 1 : 0,
      'quantidade_leitoes': quantidadeLeitoes,
      'observacoes': observacoes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Porca.fromMap(Map<String, dynamic> map) {
    return Porca(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      fotoPath: map['foto_path'] as String?,
      dataCobertura: DateTime.parse(map['data_cobertura'] as String),
      dataMedicacao: DateTime.parse(map['data_medicacao'] as String),
      dataParto: DateTime.parse(map['data_parto'] as String),
      dataAparta: DateTime.parse(map['data_aparta'] as String),
      medicacaoEditadaManual: (map['medicacao_editada_manual'] as int) == 1,
      partoEditadoManual: (map['parto_editado_manual'] as int) == 1,
      apartaEditadaManual: (map['aparta_editada_manual'] as int) == 1,
      quantidadeLeitoes: map['quantidade_leitoes'] as int?,
      observacoes: map['observacoes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // ─── copyWith para imutabilidade ────────────────────────────────────────────
  Porca copyWith({
    int? id,
    String? nome,
    String? fotoPath,
    DateTime? dataCobertura,
    DateTime? dataMedicacao,
    DateTime? dataParto,
    DateTime? dataAparta,
    bool? medicacaoEditadaManual,
    bool? partoEditadoManual,
    bool? apartaEditadaManual,
    int? quantidadeLeitoes,
    String? observacoes,
    DateTime? createdAt,
  }) {
    return Porca(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      fotoPath: fotoPath ?? this.fotoPath,
      dataCobertura: dataCobertura ?? this.dataCobertura,
      dataMedicacao: dataMedicacao ?? this.dataMedicacao,
      dataParto: dataParto ?? this.dataParto,
      dataAparta: dataAparta ?? this.dataAparta,
      medicacaoEditadaManual:
          medicacaoEditadaManual ?? this.medicacaoEditadaManual,
      partoEditadoManual: partoEditadoManual ?? this.partoEditadoManual,
      apartaEditadaManual: apartaEditadaManual ?? this.apartaEditadaManual,
      quantidadeLeitoes: quantidadeLeitoes ?? this.quantidadeLeitoes,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Porca && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
