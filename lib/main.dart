import 'package:flutter/material.dart';
import 'dart:async';
import 'app_router.dart';
import 'theme/app_theme.dart';
import 'data/models.dart';
import 'data/mock_data.dart';
import 'services/websocket_service.dart';
import 'services/local_storage_service.dart';
import 'services/voice_guide_service.dart';
import 'services/adaptive_ai_service.dart';
import 'services/simplified_mode_service.dart';
import 'i18n/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar configuración local
  await LocalStorageService.loadConfig();
  await LocalStorageService.loadSessions();
  
  // Inicializar servicio de guía por voz (opcional)
  try {
    await VoiceGuideService.initialize();
  } catch (e) {
    print('⚠️ No se pudo inicializar TTS - la app funcionará sin guía por voz');
  }
  
  // Inicializar servicios de accesibilidad avanzada
  AdaptiveAIService.initialize();
  SimplifiedModeService.setEnabled(AppState.simplifiedMode);
  
  // Verificar idioma cargado
  print('Idioma actual: ${AppState.currentLanguage}');
  
  // Si no hay datos cargados, inicializar datos mock
  if (AppState.companies.isEmpty) {
    MockData.initializeMockData();
  }
  
  // Inicializar operadores desde MockData si no hay datos
  if (AppState.operators.isEmpty) {
    for (var operator in MockData.operators) {
      AppState.operators[operator.id] = operator;
    }
    print('Operadores inicializados desde MockData:');
    for (var op in AppState.operators.values) {
      print('  ${op.username} / ${op.password}');
    }
  }
  
  // Asegurar que el idioma esté en español por defecto
  if (AppState.currentLanguage.isEmpty) {
    AppState.currentLanguage = 'es-ES';
    await LocalStorageService.saveConfig();
  }
  
  // Debug: Verificar idioma cargado
  print('Idioma cargado: ${AppState.currentLanguage}');
  print('Traducción de zone.title: ${AppStrings.t('zone.title')}');
  
  // Probar cálculos de precios
  MockData.testPriceCalculations();
  
  // Conectar al WebSocket
  AppState.kioscoId = 'kiosco-${DateTime.now().millisecondsSinceEpoch}';
  WebSocketService.connectKiosco(AppState.kioscoId!);
  
  // Enviar estado inicial del kiosco
  WebSocketService.sendKioscoStatus({'status': 'online'});
  
  // Enviar diagnósticos técnicos simulados
  WebSocketService.sendTechDiagnostics({
      'network': true,
      'printer': true,
      'display': true,
      'touch': true,
      'coins': true,
      'cards': true,
    });
  
  runApp(const MEYPARKApp());
}

class MEYPARKApp extends StatefulWidget {
  const MEYPARKApp({super.key});

  @override
  State<MEYPARKApp> createState() => _MEYPARKAppState();
}

class _MEYPARKAppState extends State<MEYPARKApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    AppState.dispose();
    super.dispose();
  }

  Stream<void> _createMergedStream() {
    final controller = StreamController<void>.broadcast();
    
    AppState.accessibilityStream.listen((_) => controller.add(null));
    AppState.configStream.listen((_) => controller.add(null));
    AppState.websocketStream.listen((_) => controller.add(null));
    
    return controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: _createMergedStream(),
      builder: (context, snapshot) {
        return MaterialApp.router(
          title: AppState.currentCompany?.name ?? 'MEYPARK',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppState.darkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return child!;
          },
        );
      },
    );
  }
}