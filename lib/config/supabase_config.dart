/// Configuración de Supabase para MEYPARK
/// 
/// Este archivo contiene todas las constantes y configuraciones
/// necesarias para conectar con Supabase.
/// 
/// IMPORTANTE: NUNCA hardcodear datos aquí - todo debe venir de Supabase
/// Este archivo solo contiene la configuración de conexión.

class SupabaseConfig {
  // ========================================
  // CONFIGURACIÓN DE CONEXIÓN
  // ========================================
  
  /// URL del proyecto Supabase
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  
  /// API Key pública (anon key)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b2FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';
  
  /// Service Role Key (solo para operaciones administrativas)
  static const String supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b2FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImiYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.CV7qGEl0GvReQJW8aWZ7U_0SWufBBIW4QLHgsm9foY';
  
  // ========================================
  // CONFIGURACIÓN DE CACHÉ
  // ========================================
  
  /// Tiempo de vida del caché local en segundos
  static const int cacheLifetimeSeconds = 300; // 5 minutos
  
  /// Tamaño máximo del caché en MB
  static const int maxCacheSizeMB = 50;
  
  /// Tiempo de reconexión automática en segundos
  static const int reconnectIntervalSeconds = 5;
  
  /// Número máximo de intentos de reconexión
  static const int maxReconnectAttempts = 10;
  
  // ========================================
  // CONFIGURACIÓN DE REALTIME
  // ========================================
  
  /// Canales de Realtime a los que suscribirse
  static const List<String> realtimeChannels = [
    'companies',
    'operators', 
    'zones',
    'payment_config',
    'accessibility_config',
    'kiosks',
    'active_sessions',
    'ui_texts',
    'ui_elements_config',
  ];
  
  /// Intervalo de heartbeat para mantener conexión activa
  static const int heartbeatIntervalSeconds = 30;
  
  // ========================================
  // CONFIGURACIÓN DE TABLAS
  // ========================================
  
  /// Nombres de las tablas principales
  static const String tableCompanies = 'companies';
  static const String tableOperators = 'operators';
  static const String tableZones = 'zones';
  static const String tablePaymentConfig = 'payment_config';
  static const String tableAccessibilityConfig = 'accessibility_config';
  static const String tableKiosks = 'kiosks';
  static const String tableActiveSessions = 'active_sessions';
  static const String tableInvoiceConfig = 'invoice_config';
  static const String tableUiTexts = 'ui_texts';
  static const String tableUiTranslationsCache = 'ui_translations_cache';
  static const String tableUiElementsConfig = 'ui_elements_config';
  
  // ========================================
  // CONFIGURACIÓN DE VISTAS
  // ========================================
  
  /// Nombres de las vistas optimizadas
  static const String viewCompanyComplete = 'v_company_complete';
  static const String viewZonesWithCompany = 'v_zones_with_company';
  static const String viewActiveSessionsDetails = 'v_active_sessions_details';
  
  // ========================================
  // CONFIGURACIÓN DE IDIOMAS
  // ========================================
  
  /// Idiomas soportados
  static const List<String> supportedLanguages = [
    'es-ES',
    'en-US',
    'fr-FR',
    'de-DE',
  ];
  
  /// Idioma por defecto
  static const String defaultLanguage = 'es-ES';
  
  // ========================================
  // CONFIGURACIÓN DE ROLES
  // ========================================
  
  /// Roles disponibles en el sistema
  static const List<String> availableRoles = [
    'superadmin',
    'admin', 
    'operator',
    'viewer',
  ];
  
  // ========================================
  // CONFIGURACIÓN DE PANTALLAS
  // ========================================
  
  /// Pantallas principales de la aplicación
  static const List<String> mainScreens = [
    'login',
    'zone',
    'payment',
    'ticket',
    'settings',
    'accessibility',
    'admin',
  ];
  
  // ========================================
  // CONFIGURACIÓN DE ELEMENTOS UI
  // ========================================
  
  /// Elementos UI configurables
  static const List<String> configurableElements = [
    'button',
    'text',
    'icon',
    'input',
    'card',
    'dialog',
    'snackbar',
  ];
  
  // ========================================
  // CONFIGURACIÓN DE ERRORES
  // ========================================
  
  /// Códigos de error personalizados
  static const String errorNetworkConnection = 'NETWORK_CONNECTION_ERROR';
  static const String errorSupabaseConnection = 'SUPABASE_CONNECTION_ERROR';
  static const String errorAuthentication = 'AUTHENTICATION_ERROR';
  static const String errorPermissionDenied = 'PERMISSION_DENIED_ERROR';
  static const String errorDataNotFound = 'DATA_NOT_FOUND_ERROR';
  static const String errorInvalidData = 'INVALID_DATA_ERROR';
  static const String errorCacheError = 'CACHE_ERROR';
  static const String errorRealtimeError = 'REALTIME_ERROR';
  
  // ========================================
  // CONFIGURACIÓN DE LOGS
  // ========================================
  
  /// Niveles de log
  static const String logLevelDebug = 'DEBUG';
  static const String logLevelInfo = 'INFO';
  static const String logLevelWarning = 'WARNING';
  static const String logLevelError = 'ERROR';
  
  /// Habilitar logs detallados en desarrollo
  static const bool enableDetailedLogs = true;
  
  // ========================================
  // CONFIGURACIÓN DE DESARROLLO
  // ========================================
  
  /// Modo de desarrollo (deshabilitar en producción)
  static const bool isDevelopmentMode = true;
  
  /// Mostrar errores detallados en UI
  static const bool showDetailedErrors = true;
  
  /// Habilitar modo offline para testing
  static const bool enableOfflineMode = false;
  
  // ========================================
  // MÉTODOS DE UTILIDAD
  // ========================================
  
  /// Verificar si la configuración es válida
  static bool get isConfigValid {
    return supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty &&
           supabaseUrl.startsWith('https://') &&
           supabaseUrl.contains('.supabase.co');
  }
  
  /// Obtener configuración de caché para una tabla específica
  static Map<String, dynamic> getCacheConfig(String tableName) {
    return {
      'lifetime': cacheLifetimeSeconds,
      'maxSize': maxCacheSizeMB,
      'enabled': true,
      'table': tableName,
    };
  }
  
  /// Obtener configuración de Realtime para un canal
  static Map<String, dynamic> getRealtimeConfig(String channel) {
    return {
      'channel': channel,
      'heartbeat': heartbeatIntervalSeconds,
      'enabled': realtimeChannels.contains(channel),
    };
  }
  
  /// Validar idioma soportado
  static bool isLanguageSupported(String language) {
    return supportedLanguages.contains(language);
  }
  
  /// Validar rol válido
  static bool isValidRole(String role) {
    return availableRoles.contains(role);
  }
  
  /// Validar pantalla válida
  static bool isValidScreen(String screen) {
    return mainScreens.contains(screen);
  }
  
  /// Obtener configuración completa para logging
  static Map<String, dynamic> getLoggingConfig() {
    return {
      'enabled': enableDetailedLogs,
      'level': isDevelopmentMode ? logLevelDebug : logLevelInfo,
      'showInUI': showDetailedErrors,
      'developmentMode': isDevelopmentMode,
    };
  }
}
