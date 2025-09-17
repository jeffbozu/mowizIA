import 'package:flutter_tts/flutter_tts.dart';
import '../data/models.dart';

class VoiceGuideService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isEnabled = false;
  static bool _isInitialized = false;

  /// Inicializar el servicio de texto a voz
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Verificar si TTS está disponible en esta plataforma
      final languages = await _flutterTts.getLanguages;
      if (languages == null || languages.isEmpty) {
        print('⚠️ TTS no disponible en esta plataforma - guía por voz deshabilitada');
        _isInitialized = true;
        return;
      }
      
      // Configurar idioma por defecto
      await _flutterTts.setLanguage(AppState.currentLanguage == 'es' ? 'es-ES' : 'en-US');
      
      // Configurar velocidad de habla (usar configuración del usuario)
      await _flutterTts.setSpeechRate(AppState.voiceSpeed);
      
      // Configurar tono (usar configuración del usuario)
      await _flutterTts.setPitch(AppState.voicePitch);
      
      // Configurar volumen (usar configuración del usuario)
      await _flutterTts.setVolume(AppState.voiceVolume);
      
      // Configurar motor de voz para sonido más natural (solo en plataformas compatibles)
      try {
        await _flutterTts.setEngine("com.apple.ttsbundle.siri_male_es-ES_compact");
      } catch (e) {
        print('⚠️ Motor de voz premium no disponible, usando configuración básica');
      }
      
      _isInitialized = true;
      print('🎤 Servicio de guía por voz inicializado');
    } catch (e) {
      print('❌ Error inicializando TTS: $e');
      print('⚠️ TTS deshabilitado - la app funcionará sin guía por voz');
      _isInitialized = true;
    }
  }

  /// Habilitar/deshabilitar guía por voz
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
    print('🎤 Guía por voz ${enabled ? 'habilitada' : 'deshabilitada'}');
  }

  /// Verificar si está habilitada
  static bool get isEnabled => _isEnabled;

  /// Hablar texto con voz natural
  static Future<void> speak(String text) async {
    if (!_isEnabled || !_isInitialized) return;

    try {
      // Detener cualquier habla anterior
      await _flutterTts.stop();
      
      // Hablar el texto
      await _flutterTts.speak(text);
      print('🎤 Hablando: $text');
    } catch (e) {
      print('❌ Error hablando: $e');
    }
  }

  /// Detener la guía por voz
  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('❌ Error deteniendo TTS: $e');
    }
  }

  /// Cambiar idioma de la voz
  static Future<void> setLanguage(String language) async {
    try {
      String voiceLanguage = language == 'es' ? 'es-ES' : 'en-US';
      await _flutterTts.setLanguage(voiceLanguage);
      
      // Intentar usar una voz más natural
      if (language == 'es') {
        await _flutterTts.setEngine("com.apple.ttsbundle.siri_male_es-ES_compact");
      } else {
        await _flutterTts.setEngine("com.apple.ttsbundle.siri_male_en-US_compact");
      }
      
      print('🎤 Idioma de voz cambiado a: $voiceLanguage');
    } catch (e) {
      print('❌ Error cambiando idioma de voz: $e');
      // Fallback básico
      await _flutterTts.setLanguage(language == 'es' ? 'es-ES' : 'en-US');
    }
  }

  /// Actualizar configuración de voz
  static Future<void> updateVoiceSettings() async {
    if (!_isInitialized) return;
    
    try {
      await _flutterTts.setSpeechRate(AppState.voiceSpeed);
      await _flutterTts.setPitch(AppState.voicePitch);
      await _flutterTts.setVolume(AppState.voiceVolume);
      print('🎤 Configuración de voz actualizada');
    } catch (e) {
      print('❌ Error actualizando configuración de voz: $e');
    }
  }

  /// Configurar voz para sonido más natural
  static Future<void> configureNaturalVoice() async {
    try {
      // Configuración para voz más natural
      await _flutterTts.setSpeechRate(AppState.voiceSpeed);  // Usar configuración del usuario
      await _flutterTts.setPitch(AppState.voicePitch);       // Usar configuración del usuario
      await _flutterTts.setVolume(AppState.voiceVolume);     // Usar configuración del usuario
      
      // Intentar usar voces premium si están disponibles
      String language = AppState.currentLanguage == 'es' ? 'es-ES' : 'en-US';
      
      if (language == 'es-ES') {
        await _flutterTts.setEngine("com.apple.ttsbundle.siri_male_es-ES_compact");
      } else {
        await _flutterTts.setEngine("com.apple.ttsbundle.siri_male_en-US_compact");
      }
      
      print('🎤 Voz configurada para sonido natural');
    } catch (e) {
      print('❌ Error configurando voz natural: $e');
    }
  }
}
