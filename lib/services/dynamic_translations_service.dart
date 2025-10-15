/// Servicio de traducciones dinámicas desde Supabase
/// 
/// Este servicio maneja la carga y caché de traducciones desde Supabase,
/// permitiendo que cada empresa tenga sus propios textos personalizados
/// y soporte para múltiples idiomas.
/// 
/// IMPORTANTE: NUNCA hardcodear textos - todo debe venir de Supabase

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';

class DynamicTranslationsService {
  static DynamicTranslationsService? _instance;
  static DynamicTranslationsService get instance => _instance ??= DynamicTranslationsService._();
  
  DynamicTranslationsService._();
  
  // ========================================
  // PROPIEDADES PRIVADAS
  // ========================================
  
  final Map<String, Map<String, String>> _translations = {};
  final Map<String, Map<String, bool>> _elementStates = {};
  String _currentLanguage = SupabaseConfig.defaultLanguage;
  String? _currentCompanyId;
  
  // ========================================
  // INICIALIZACIÓN
  // ========================================
  
  /// Inicializar el servicio de traducciones
  Future<void> initialize({String? companyId, String? language}) async {
    try {
      _currentCompanyId = companyId;
      _currentLanguage = language ?? SupabaseConfig.defaultLanguage;
      
      // Cargar traducciones desde caché local
      await _loadFromLocalCache();
      
      // Cargar traducciones desde Supabase
      await _loadFromSupabase();
      
      print('✅ DynamicTranslationsService inicializado para empresa: $_currentCompanyId, idioma: $_currentLanguage');
      
    } catch (e) {
      print('❌ Error inicializando DynamicTranslationsService: $e');
      rethrow;
    }
  }
  
  /// Cargar traducciones desde caché local
  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar traducciones
      final translationsKey = 'translations_${_currentCompanyId}_$_currentLanguage';
      final translationsData = prefs.getString(translationsKey);
      if (translationsData != null) {
        final Map<String, dynamic> decoded = json.decode(translationsData);
        _translations[_currentLanguage] = Map<String, String>.from(decoded);
      }
      
      // Cargar estados de elementos
      final elementsKey = 'ui_elements_${_currentCompanyId}';
      final elementsData = prefs.getString(elementsKey);
      if (elementsData != null) {
        final Map<String, dynamic> decoded = json.decode(elementsData);
        _elementStates[_currentCompanyId ?? 'default'] = Map<String, bool>.from(decoded);
      }
      
      print('📦 Traducciones cargadas desde caché local: ${_translations[_currentLanguage]?.length ?? 0} elementos');
      
    } catch (e) {
      print('⚠️ Error cargando traducciones desde caché local: $e');
    }
  }
  
  /// Cargar traducciones desde Supabase
  Future<void> _loadFromSupabase() async {
    if (_currentCompanyId == null) return;
    
    try {
      // Intentar cargar desde caché de traducciones primero
      await _loadFromTranslationsCache();
      
      // Si no hay caché, cargar desde ui_texts
      if (_translations[_currentLanguage]?.isEmpty ?? true) {
        await _loadFromUiTexts();
      }
      
      // Cargar configuración de elementos UI
      await _loadUiElementsConfig();
      
      // Guardar en caché local
      await _saveToLocalCache();
      
      print('📡 Traducciones cargadas desde Supabase: ${_translations[_currentLanguage]?.length ?? 0} elementos');
      
    } catch (e) {
      print('❌ Error cargando traducciones desde Supabase: $e');
      
      // Si falla la carga desde Supabase, usar traducciones por defecto
      await _loadDefaultTranslations();
    }
  }
  
  /// Cargar desde caché de traducciones de Supabase
  Future<void> _loadFromTranslationsCache() async {
    try {
      final response = await SupabaseService.instance.client
          .from(SupabaseConfig.tableUiTranslationsCache)
          .select('translations_json')
          .eq('company_id', _currentCompanyId)
          .eq('language', _currentLanguage)
          .single();
      
      if (response != null && response['translations_json'] != null) {
        final translationsJson = response['translations_json'] as Map<String, dynamic>;
        _translations[_currentLanguage] = Map<String, String>.from(translationsJson);
        
        print('📦 Traducciones cargadas desde caché de Supabase');
      }
      
    } catch (e) {
      print('⚠️ No se pudo cargar desde caché de traducciones: $e');
    }
  }
  
  /// Cargar desde tabla ui_texts
  Future<void> _loadFromUiTexts() async {
    try {
      final response = await SupabaseService.instance.client
          .from(SupabaseConfig.tableUiTexts)
          .select('screen, element, text_value')
          .eq('company_id', _currentCompanyId)
          .eq('language', _currentLanguage)
          .eq('is_enabled', true);
      
      final translations = <String, String>{};
      
      for (final row in response) {
        final key = '${row['screen']}.${row['element']}';
        translations[key] = row['text_value'] as String;
      }
      
      _translations[_currentLanguage] = translations;
      
      // Regenerar caché de traducciones
      await _regenerateTranslationsCache();
      
      print('📝 Traducciones cargadas desde ui_texts: ${translations.length} elementos');
      
    } catch (e) {
      print('❌ Error cargando desde ui_texts: $e');
      rethrow;
    }
  }
  
  /// Cargar configuración de elementos UI
  Future<void> _loadUiElementsConfig() async {
    try {
      final response = await SupabaseService.instance.client
          .from(SupabaseConfig.tableUiElementsConfig)
          .select('screen, element_key, is_enabled')
          .eq('company_id', _currentCompanyId);
      
      final elementStates = <String, bool>{};
      
      for (final row in response) {
        final key = '${row['screen']}.${row['element_key']}';
        elementStates[key] = row['is_enabled'] as bool;
      }
      
      _elementStates[_currentCompanyId ?? 'default'] = elementStates;
      
      print('🎛️ Configuración de elementos UI cargada: ${elementStates.length} elementos');
      
    } catch (e) {
      print('❌ Error cargando configuración de elementos UI: $e');
    }
  }
  
  /// Regenerar caché de traducciones
  Future<void> _regenerateTranslationsCache() async {
    try {
      await SupabaseService.instance.client.rpc(
        'regenerate_translations_cache',
        params: {
          'p_company_id': _currentCompanyId,
          'p_language': _currentLanguage,
        },
      );
      
      print('🔄 Caché de traducciones regenerado');
      
    } catch (e) {
      print('⚠️ Error regenerando caché de traducciones: $e');
    }
  }
  
  /// Cargar traducciones por defecto
  Future<void> _loadDefaultTranslations() async {
    // Traducciones por defecto en español
    _translations[_currentLanguage] = {
      // Pantalla de login
      'login.title': 'Iniciar Sesión',
      'login.username': 'Usuario',
      'login.password': 'Contraseña',
      'login.button_login': 'Entrar',
      'login.error_invalid': 'Usuario o contraseña incorrectos',
      
      // Pantalla de zona
      'zone.title': 'Seleccionar Zona',
      'zone.coche': 'Coche',
      'zone.moto': 'Moto',
      'zone.azul': 'Zona Azul',
      'zone.verde': 'Zona Verde',
      'zone.button_continue': 'Continuar',
      'zone.button_back': 'Volver',
      
      // Pantalla de pago
      'payment.title': 'Pago',
      'payment.amount': 'Importe',
      'payment.time': 'Tiempo',
      'payment.button_pay': 'Pagar',
      'payment.button_cash': 'Efectivo',
      'payment.button_card': 'Tarjeta',
      'payment.button_back': 'Volver',
      
      // Pantalla de ticket
      'ticket.title': 'Ticket',
      'ticket.plate': 'Matrícula',
      'ticket.zone': 'Zona',
      'ticket.start_time': 'Hora inicio',
      'ticket.end_time': 'Hora fin',
      'ticket.button_print': 'Imprimir',
      'ticket.button_new': 'Nuevo',
      
      // Mensajes generales
      'common.loading': 'Cargando...',
      'common.error': 'Error',
      'common.success': 'Éxito',
      'common.cancel': 'Cancelar',
      'common.confirm': 'Confirmar',
      'common.back': 'Volver',
      'common.next': 'Siguiente',
      'common.finish': 'Finalizar',
    };
    
    print('📝 Traducciones por defecto cargadas: ${_translations[_currentLanguage]?.length ?? 0} elementos');
  }
  
  /// Guardar en caché local
  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar traducciones
      final translationsKey = 'translations_${_currentCompanyId}_$_currentLanguage';
      if (_translations[_currentLanguage] != null) {
        await prefs.setString(translationsKey, json.encode(_translations[_currentLanguage]));
      }
      
      // Guardar estados de elementos
      final elementsKey = 'ui_elements_${_currentCompanyId}';
      if (_elementStates[_currentCompanyId ?? 'default'] != null) {
        await prefs.setString(elementsKey, json.encode(_elementStates[_currentCompanyId ?? 'default']));
      }
      
    } catch (e) {
      print('⚠️ Error guardando en caché local: $e');
    }
  }
  
  // ========================================
  // MÉTODOS PÚBLICOS
  // ========================================
  
  /// Obtener texto traducido
  String t(String key, {String? defaultValue}) {
    try {
      // Buscar en traducciones actuales
      final translations = _translations[_currentLanguage];
      if (translations != null && translations.containsKey(key)) {
        return translations[key]!;
      }
      
      // Buscar en traducciones por defecto
      final defaultTranslations = _translations[SupabaseConfig.defaultLanguage];
      if (defaultTranslations != null && defaultTranslations.containsKey(key)) {
        return defaultTranslations[key]!;
      }
      
      // Usar valor por defecto proporcionado
      if (defaultValue != null) {
        return defaultValue;
      }
      
      // Usar la clave como fallback
      print('⚠️ Texto no encontrado: $key');
      return key;
      
    } catch (e) {
      print('❌ Error obteniendo traducción para $key: $e');
      return defaultValue ?? key;
    }
  }
  
  /// Verificar si un elemento UI está habilitado
  bool isElementEnabled(String screen, String element) {
    try {
      final key = '$screen.$element';
      final elementStates = _elementStates[_currentCompanyId ?? 'default'];
      
      if (elementStates != null && elementStates.containsKey(key)) {
        return elementStates[key]!;
      }
      
      // Por defecto, todos los elementos están habilitados
      return true;
      
    } catch (e) {
      print('❌ Error verificando estado de elemento $screen.$element: $e');
      return true;
    }
  }
  
  /// Cambiar idioma
  Future<void> changeLanguage(String language) async {
    if (!SupabaseConfig.isLanguageSupported(language)) {
      print('⚠️ Idioma no soportado: $language');
      return;
    }
    
    if (_currentLanguage == language) return;
    
    _currentLanguage = language;
    
    // Cargar traducciones para el nuevo idioma
    await _loadFromSupabase();
    
    print('🌐 Idioma cambiado a: $language');
  }
  
  /// Cambiar empresa
  Future<void> changeCompany(String companyId) async {
    if (_currentCompanyId == companyId) return;
    
    _currentCompanyId = companyId;
    
    // Cargar traducciones para la nueva empresa
    await _loadFromSupabase();
    
    print('🏢 Empresa cambiada a: $companyId');
  }
  
  /// Recargar traducciones
  Future<void> reload() async {
    try {
      // Limpiar caché
      _translations.clear();
      _elementStates.clear();
      
      // Recargar desde Supabase
      await _loadFromSupabase();
      
      print('🔄 Traducciones recargadas');
      
    } catch (e) {
      print('❌ Error recargando traducciones: $e');
    }
  }
  
  /// Invalidar caché
  void invalidateCache() {
    _translations.clear();
    _elementStates.clear();
    print('🗑️ Caché de traducciones invalidado');
  }
  
  // ========================================
  // MÉTODOS DE UTILIDAD
  // ========================================
  
  /// Obtener idioma actual
  String get currentLanguage => _currentLanguage;
  
  /// Obtener empresa actual
  String? get currentCompanyId => _currentCompanyId;
  
  /// Obtener estadísticas
  Map<String, dynamic> getStats() {
    return {
      'currentLanguage': _currentLanguage,
      'currentCompanyId': _currentCompanyId,
      'translationsCount': _translations[_currentLanguage]?.length ?? 0,
      'elementStatesCount': _elementStates[_currentCompanyId ?? 'default']?.length ?? 0,
      'supportedLanguages': _translations.keys.toList(),
    };
  }
  
  /// Obtener todas las traducciones para debugging
  Map<String, String> getAllTranslations() {
    return Map.from(_translations[_currentLanguage] ?? {});
  }
  
  /// Obtener todos los estados de elementos para debugging
  Map<String, bool> getAllElementStates() {
    return Map.from(_elementStates[_currentCompanyId ?? 'default'] ?? {});
  }
  
  /// Verificar si una clave existe
  bool hasTranslation(String key) {
    final translations = _translations[_currentLanguage];
    return translations?.containsKey(key) ?? false;
  }
  
  /// Obtener claves de traducción por pantalla
  List<String> getKeysForScreen(String screen) {
    final translations = _translations[_currentLanguage];
    if (translations == null) return [];
    
    return translations.keys
        .where((key) => key.startsWith('$screen.'))
        .toList();
  }
  
  /// Obtener pantallas disponibles
  List<String> getAvailableScreens() {
    final translations = _translations[_currentLanguage];
    if (translations == null) return [];
    
    final screens = <String>{};
    translations.keys.forEach((key) {
      final parts = key.split('.');
      if (parts.isNotEmpty) {
        screens.add(parts.first);
      }
    });
    
    return screens.toList()..sort();
  }
}
