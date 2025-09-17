import 'dart:async';
import '../data/models.dart';
import '../i18n/strings.dart';

/// Servicio de IA Adaptativa que aprende del comportamiento del usuario
class AdaptiveAIService {
  static Timer? _learningTimer;
  static bool _isLearning = false;
  
  /// Inicializar el servicio de IA
  static void initialize() {
    if (AppState.adaptiveAI) {
      _startLearning();
    }
  }
  
  /// Iniciar el proceso de aprendizaje
  static void _startLearning() {
    if (_isLearning) return;
    
    _isLearning = true;
    _learningTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _analyzeBehavior();
    });
    
    print('🧠 IA Adaptativa: Iniciando proceso de aprendizaje');
  }
  
  /// Detener el proceso de aprendizaje
  static void stopLearning() {
    _learningTimer?.cancel();
    _isLearning = false;
    print('🧠 IA Adaptativa: Proceso de aprendizaje detenido');
  }
  
  /// Analizar comportamiento y aplicar preferencias
  static void _analyzeBehavior() {
    if (!AppState.adaptiveAI) return;
    
    // Aplicar preferencias aprendidas
    AppState.applyLearnedPreferences();
    
    // Mostrar estadísticas de aprendizaje
    _showLearningStats();
  }
  
  /// Mostrar estadísticas de aprendizaje
  static void _showLearningStats() {
    if (AppState.userBehavior.isEmpty) return;
    
    print('🧠 IA Adaptativa - Estadísticas:');
    print('   Comportamientos registrados: ${AppState.userBehavior.length}');
    print('   Características más usadas: ${AppState.mostUsedFeatures.join(', ')}');
    print('   Preferencias aprendidas: ${AppState.userPreferences.keys.join(', ')}');
  }
  
  /// Registrar una acción del usuario
  static void recordAction(String action) {
    if (!AppState.adaptiveAI) return;
    
    AppState.learnUserBehavior(action);
    
    // Aplicar preferencias inmediatamente si es necesario
    AppState.applyLearnedPreferences();
  }
  
  /// Obtener sugerencias basadas en comportamiento
  static List<String> getSuggestions() {
    if (!AppState.adaptiveAI) return [];
    
    List<String> suggestions = [];
    
    // Sugerir características basadas en uso
    if (AppState.userBehavior['voice_guide_used'] != null && 
        AppState.userBehavior['voice_guide_used']! > 2) {
      suggestions.add('Habilitar guía por voz automáticamente');
    }
    
    if (AppState.userBehavior['large_buttons_used'] != null && 
        AppState.userBehavior['large_buttons_used']! > 1) {
      suggestions.add('Aumentar tamaño de fuente automáticamente');
    }
    
    if (AppState.userBehavior['simplified_mode_used'] != null && 
        AppState.userBehavior['simplified_mode_used']! > 1) {
      suggestions.add('Habilitar modo simplificado automáticamente');
    }
    
    return suggestions;
  }
  
  /// Obtener zona preferida del usuario
  static String? getPreferredZone() {
    if (!AppState.adaptiveAI) return null;
    
    return AppState.userPreferences['preferred_zone'];
  }
  
  /// Obtener método de pago preferido
  static String? getPreferredPaymentMethod() {
    if (!AppState.adaptiveAI) return null;
    
    return AppState.userPreferences['preferred_payment'];
  }
  
  /// Reiniciar datos de aprendizaje
  static void resetLearning() {
    AppState.resetAdaptiveAI();
    print('🧠 IA Adaptativa: Datos de aprendizaje reiniciados');
  }
  
  /// Habilitar/deshabilitar IA adaptativa
  static void setEnabled(bool enabled) {
    AppState.adaptiveAI = enabled;
    
    if (enabled) {
      _startLearning();
    } else {
      stopLearning();
    }
    
    AppState.notifyAccessibilityChange();
    print('🧠 IA Adaptativa: ${enabled ? 'Habilitada' : 'Deshabilitada'}');
  }
  
  /// Obtener información de la IA para mostrar al usuario
  static String getAIInfo() {
    return AppStrings.t('access.adaptive_ai.info');
  }
  
  /// Obtener información del modo simplificado
  static String getSimplifiedModeInfo() {
    return AppStrings.t('access.simplified_mode.info');
  }
}
