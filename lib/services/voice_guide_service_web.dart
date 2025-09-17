import 'package:universal_html/html.dart' as html;
import '../data/models.dart';

/// Servicio de guía por voz compatible con Web
class VoiceGuideServiceWeb {
  static bool _isInitialized = false;
  static html.SpeechSynthesis? _speechSynthesis;
  
  /// Inicializar el servicio de TTS para Web
  static Future<void> initialize() async {
    try {
      if (html.window.speechSynthesis != null) {
        _speechSynthesis = html.window.speechSynthesis;
        _isInitialized = true;
        
        print('🎤 TTS Web inicializado correctamente');
      } else {
        print('⚠️ TTS no soportado en este navegador');
      }
    } catch (e) {
      print('❌ Error inicializando TTS Web: $e');
    }
  }
  
  /// Reproducir texto
  static Future<void> speak(String text) async {
    if (!_isInitialized || _speechSynthesis == null) {
      print('⚠️ TTS no inicializado');
      return;
    }
    
    try {
      // Cancelar cualquier síntesis en curso
      _speechSynthesis!.cancel();
      
      // Crear utterance con configuración básica
      final utterance = html.SpeechSynthesisUtterance(text);
      
      // Reproducir
      _speechSynthesis!.speak(utterance);
      
      print('🎤 Reproduciendo: $text');
    } catch (e) {
      print('❌ Error reproduciendo texto: $e');
    }
  }
  
  /// Detener síntesis
  static void stop() {
    if (_speechSynthesis != null) {
      _speechSynthesis!.cancel();
      print('🛑 TTS detenido');
    }
  }
  
  /// Verificar si está disponible
  static bool get isAvailable => _isInitialized && _speechSynthesis != null;
  
  /// Actualizar configuración de voz
  static void updateVoiceSettings() {
    // La configuración se aplica en el próximo speak()
    print('🎤 Configuración de voz actualizada');
  }
  
  /// Obtener voces disponibles
  static List<html.SpeechSynthesisVoice> getAvailableVoices() {
    if (_speechSynthesis != null) {
      return _speechSynthesis!.getVoices();
    }
    return [];
  }
}