// lib/services/notification_service.dart
// Serviço de notificações locais - funciona 100% offline

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import '../data/models/porca_model.dart';
import '../core/utils/date_utils.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  factory NotificationService() => instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  // ─── Inicialização ──────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_inicializado) return;

    tzData.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _inicializado = true;
  }

  // Configuração do canal Android
  AndroidNotificationDetails get _androidDetails =>
      const AndroidNotificationDetails(
        'suino_canal',
        'Suíno App',
        channelDescription: 'Alertas de manejo reprodutivo',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

  NotificationDetails get _details =>
      NotificationDetails(android: _androidDetails);

  // ─── Agendamento de notificações para uma porca ─────────────────────────────
  Future<void> agendarParaPorca(Porca porca) async {
    if (!_inicializado) await init();
    if (porca.id == null) return;

    // Cancela notificações antigas desta porca
    await cancelarParaPorca(porca.id!);

    final agora = DateTime.now();

    // IDs únicos baseados no ID da porca (evita colisão)
    // Medicação
    await _agendarSe(
      id: porca.id! * 10 + 1,
      data: porca.dataMedicacao,
      titulo: '💉 Medicação - ${porca.nome}',
      corpo: 'Hora de medicar a porca ${porca.nome}! (${AppDateUtils.formatar(porca.dataMedicacao)})',
      agora: agora,
    );

    // Aviso 1 dia antes da medicação
    await _agendarSe(
      id: porca.id! * 10 + 2,
      data: porca.dataMedicacao.subtract(const Duration(days: 1)),
      titulo: '💉 Medicação amanhã - ${porca.nome}',
      corpo: 'A porca ${porca.nome} precisa de medicação amanhã.',
      agora: agora,
    );

    // Parto
    await _agendarSe(
      id: porca.id! * 10 + 3,
      data: porca.dataParto,
      titulo: '🐷 Parto previsto - ${porca.nome}',
      corpo: 'Parto previsto hoje para a porca ${porca.nome}!',
      agora: agora,
    );

    // Aviso 2 dias antes do parto
    await _agendarSe(
      id: porca.id! * 10 + 4,
      data: porca.dataParto.subtract(const Duration(days: 2)),
      titulo: '🐷 Parto em 2 dias - ${porca.nome}',
      corpo: 'Prepare-se! A porca ${porca.nome} pari em 2 dias.',
      agora: agora,
    );

    // Aparta/desmame
    await _agendarSe(
      id: porca.id! * 10 + 5,
      data: porca.dataAparta,
      titulo: '📦 Apartação - ${porca.nome}',
      corpo: 'Hora da apartação dos leitões da porca ${porca.nome}!',
      agora: agora,
    );

    // Aviso 1 dia antes da aparta
    await _agendarSe(
      id: porca.id! * 10 + 6,
      data: porca.dataAparta.subtract(const Duration(days: 1)),
      titulo: '📦 Apartação amanhã - ${porca.nome}',
      corpo: 'A porca ${porca.nome} será desmamada amanhã.',
      agora: agora,
    );
  }

  Future<void> _agendarSe({
    required int id,
    required DateTime data,
    required String titulo,
    required String corpo,
    required DateTime agora,
  }) async {
    // Notifica às 7h da manhã do dia do evento
    final dataNotificacao = DateTime(
      data.year,
      data.month,
      data.day,
      7, // 7h da manhã
    );

    if (dataNotificacao.isBefore(agora)) return; // Já passou

    await _plugin.zonedSchedule(
      id,
      titulo,
      corpo,
      tz.TZDateTime.from(dataNotificacao, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancela todas as notificações de uma porca
  Future<void> cancelarParaPorca(int porcaId) async {
    for (int i = 1; i <= 6; i++) {
      await _plugin.cancel(porcaId * 10 + i);
    }
  }

  // Cancela todas as notificações
  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }
}
