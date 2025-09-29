import 'package:flutter/material.dart';
import 'dart:async';
import 'app_router.dart';
import 'theme/app_theme.dart';
import 'data/models.dart';
import 'data/mock_data.dart';
import 'services/centralized_websocket_service.dart';
import 'services/local_storage_service.dart';
import 'services/dual_storage_service.dart';
import 'services/voice_guide_service.dart';
import 'services/adaptive_ai_service.dart';
import 'services/simplified_mode_service.dart';
import 'services/geographic_id_service.dart';
import 'i18n/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar configuración básica
  await AppState.loadConfig();
  
  // Inicializar servicio de guía por voz (opcional)
  try {
    await VoiceGuideService.initialize();
  } catch (e) {
    print('⚠️ No se pudo inicializar TTS - la app funcionará sin guía por voz');
  }
  
  // Inicializar empresa por defecto
  AppState.initializeDefaultCompany();
  
  // Inicializar servicios de accesibilidad avanzada
  AdaptiveAIService.initialize();
  SimplifiedModeService.setEnabled(AppState.simplifiedMode);
  
  // Verificar idioma cargado
  print('Idioma actual: ${AppState.currentLanguage}');
  
  // Asegurar que el idioma esté en español por defecto
  if (AppState.currentLanguage.isEmpty) {
    AppState.currentLanguage = 'es-ES';
    await LocalStorageService.saveConfig();
  }
  
  // Debug: Verificar idioma cargado
  print('Idioma cargado: ${AppState.currentLanguage}');
  print('Traducción de zone.title: ${AppStrings.t('zone.title')}');
  
  // GENERAR ID GEOGRÁFICO PARA EL KIOSKO
  AppState.kioscoId = 'MAD_Centro_K${DateTime.now().millisecondsSinceEpoch % 100}';
  print('🏢 ID Geográfico asignado: ${AppState.kioscoId}');
  
  // CONECTAR AL BACKEND PRIMERO - NO USAR DATOS LOCALES
  CentralizedWebSocketService.connect(AppState.kioscoId!);
  
  // Solicitar datos completos del backend
  CentralizedWebSocketService.requestFullData();
  
  // NO USAR DATOS LOCALES - TODO DEBE VENIR DEL BACKEND
  // La app esperará a recibir datos del backend antes de funcionar
  
  // Enviar diagnósticos técnicos simulados
  CentralizedWebSocketService.sendTechDiagnostics({
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