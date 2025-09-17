import '../data/models.dart';
import '../i18n/strings.dart';

/// Servicio para manejar el modo simplificado de la aplicación
class SimplifiedModeService {
  
  /// Verificar si el modo simplificado está activo
  static bool get isActive => AppState.simplifiedMode;
  
  /// Habilitar/deshabilitar modo simplificado
  static void setEnabled(bool enabled) {
    AppState.simplifiedMode = enabled;
    AppState.notifyAccessibilityChange();
    print('🔧 Modo Simplificado: ${enabled ? 'Habilitado' : 'Deshabilitado'}');
  }
  
  /// Obtener información del modo simplificado
  static String getInfo() {
    return AppStrings.t('access.simplified_mode.info');
  }
  
  /// Obtener configuración de UI para modo simplificado
  static SimplifiedUIConfig getUIConfig() {
    return SimplifiedUIConfig(
      buttonSize: isActive ? 120.0 : 80.0,
      fontSize: isActive ? 24.0 : 18.0,
      spacing: isActive ? 24.0 : 16.0,
      showAdvancedOptions: !isActive,
      maxOptionsPerScreen: isActive ? 3 : 6,
    );
  }
  
  /// Obtener texto simplificado para una pantalla
  static String getSimplifiedText(String screenKey) {
    if (!isActive) return AppStrings.t(screenKey);
    
    final simplifiedTexts = {
      'zone.title': 'SELECCIONAR ZONA',
      'zone.next': 'CONTINUAR',
      'plate.title': 'MATRÍCULA',
      'plate.next': 'CONTINUAR',
      'time.title': 'TIEMPO',
      'time.pay': 'PAGAR',
      'pay.title': 'PAGO',
      'pay.pay_now': 'PAGAR',
      'ticket.title.new': 'TICKET LISTO',
      'ticket.ok': 'FINALIZAR',
    };
    
    return simplifiedTexts[screenKey] ?? AppStrings.t(screenKey);
  }
  
  /// Obtener instrucciones simplificadas
  static String getSimplifiedInstructions(String screenKey) {
    if (!isActive) return '';
    
    final instructions = {
      'zone': 'Toque la zona que desea usar',
      'plate': 'Escriba su matrícula',
      'time': 'Seleccione cuánto tiempo',
      'payment': 'Elija cómo pagar',
      'ticket': 'Tome su ticket',
    };
    
    return instructions[screenKey] ?? '';
  }
  
  /// Verificar si mostrar una opción en modo simplificado
  static bool shouldShowOption(String optionKey) {
    if (!isActive) return true;
    
    // En modo simplificado, ocultar opciones avanzadas
    final hiddenOptions = [
      'extend',
      'quick_select',
      'advanced_settings',
      'help',
      'language',
    ];
    
    return !hiddenOptions.any((hidden) => optionKey.contains(hidden));
  }
  
  /// Obtener botones prioritarios para modo simplificado
  static List<String> getPriorityButtons(String screenKey) {
    if (!isActive) return [];
    
    final priorityButtons = {
      'zone': ['next'],
      'plate': ['next'],
      'time': ['pay'],
      'payment': ['pay_now'],
      'ticket': ['ok'],
    };
    
    return priorityButtons[screenKey] ?? [];
  }
}

/// Configuración de UI para modo simplificado
class SimplifiedUIConfig {
  final double buttonSize;
  final double fontSize;
  final double spacing;
  final bool showAdvancedOptions;
  final int maxOptionsPerScreen;
  
  const SimplifiedUIConfig({
    required this.buttonSize,
    required this.fontSize,
    required this.spacing,
    required this.showAdvancedOptions,
    required this.maxOptionsPerScreen,
  });
}
