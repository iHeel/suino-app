// lib/main.dart
// Ponto de entrada do aplicativo Suíno App

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/porca_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa serviço de notificações
  await NotificationService.instance.init();

  // Orientação apenas retrato (vertical) - melhor para mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Cor da barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SuinoApp());
}

class SuinoApp extends StatelessWidget {
  const SuinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider principal das porcas
        ChangeNotifierProvider(create: (_) => PorcaProvider()),
      ],
      child: MaterialApp(
        title: 'Controle de Porcas',
        debugShowCheckedModeBanner: false,

        // Tema global (fontes grandes, cores, botões)
        theme: AppTheme.theme,

        // Localização em Português do Brasil
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],

        home: const HomeScreen(),
      ),
    );
  }
}
