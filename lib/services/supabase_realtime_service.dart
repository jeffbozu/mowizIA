/// Servicio de sincronización en tiempo real con Supabase
/// 
/// Este servicio maneja la sincronización automática de datos
/// usando Supabase Realtime, actualizando el AppState cuando
/// hay cambios en la base de datos.
/// 
/// IMPORTANTE: NUNCA hardcodear datos - todo debe venir de Supabase

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../data/models.dart';
import 'supabase_service.dart';

class SupabaseRealtimeService {
  static SupabaseRealtimeService? _instance;
  static SupabaseRealtimeService get instance => _instance ??= SupabaseRealtimeService._();
  
  SupabaseRealtimeService._();
  
  // ========================================
  // PROPIEDADES PRIVADAS
  // ========================================
  
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  bool _isInitialized = false;
  bool _isConnected = false;
  
  // Stream controllers para notificar cambios
  final StreamController<Map<String, dynamic>> _dataChangeController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  final StreamController<String> _connectionStatusController = 
      StreamController<String>.broadcast();
  
  // ========================================
  // INICIALIZACIÓN
  // ========================================
  
  /// Inicializar el servicio de Realtime
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Verificar que SupabaseService esté inicializado
      if (!SupabaseService.instance.isConnected) {
        await SupabaseService.instance.initialize();
      }
      
      _isInitialized = true;
      _isConnected = true;
      
      print('✅ SupabaseRealtimeService inicializado correctamente');
      
      // Configurar listeners de conexión
      _setupConnectionListeners();
      
    } catch (e) {
      print('❌ Error inicializando SupabaseRealtimeService: $e');
      _isConnected = false;
      rethrow;
    }
  }
  
  /// Configurar listeners de conexión
  void _setupConnectionListeners() {
    // TODO: Implementar listeners de conexión cuando esté disponible
    // Por ahora, verificamos la conexión manualmente
  }
  
  // ========================================
  // MÉTODOS DE CONEXIÓN
  // ========================================
  
  /// Verificar si está conectado
  bool get isConnected => _isConnected && _isInitialized;
  
  /// Obtener stream de cambios de datos
  Stream<Map<String, dynamic>> get dataChangeStream => _dataChangeController.stream;
  
  /// Obtener stream de estado de conexión
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;
  
  // ========================================
  // MÉTODOS DE SUSCRIPCIÓN
  // ========================================
  
  /// Suscribirse a cambios en una tabla
  Future<void> subscribeToTable(String tableName, {String? filter}) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final channelName = filter != null ? '${tableName}_$filter' : tableName;
      
      // Evitar suscripciones duplicadas
      if (_channels.containsKey(channelName)) {
        print('⚠️ Ya suscrito a $channelName');
        return;
      }
      
      // Crear canal de Realtime
      final channel = SupabaseService.instance.client
          .channel(channelName)
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: tableName,
            filter: filter != null ? PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'company_id',
              value: filter,
            ) : null,
            callback: (payload) => _handleTableChange(tableName, payload),
          );
      
      // Suscribirse al canal
      await channel.subscribe();
      
      _channels[channelName] = channel;
      
      print('📡 Suscrito a cambios en tabla: $tableName${filter != null ? ' (filtro: $filter)' : ''}');
      
    } catch (e) {
      print('❌ Error suscribiéndose a tabla $tableName: $e');
      rethrow;
    }
  }
  
  /// Desuscribirse de una tabla
  Future<void> unsubscribeFromTable(String tableName, {String? filter}) async {
    try {
      final channelName = filter != null ? '${tableName}_$filter' : tableName;
      
      if (_channels.containsKey(channelName)) {
        await _channels[channelName]!.unsubscribe();
        _channels.remove(channelName);
        
        print('📡 Desuscrito de tabla: $tableName${filter != null ? ' (filtro: $filter)' : ''}');
      }
      
    } catch (e) {
      print('❌ Error desuscribiéndose de tabla $tableName: $e');
    }
  }
  
  /// Suscribirse a todas las tablas principales
  Future<void> subscribeToAllTables({String? companyId}) async {
    try {
      for (final tableName in SupabaseConfig.realtimeChannels) {
        await subscribeToTable(tableName, filter: companyId);
      }
      
      print('📡 Suscrito a todas las tablas principales${companyId != null ? ' para empresa $companyId' : ''}');
      
    } catch (e) {
      print('❌ Error suscribiéndose a todas las tablas: $e');
      rethrow;
    }
  }
  
  /// Desuscribirse de todas las tablas
  Future<void> unsubscribeFromAllTables() async {
    try {
      for (final channelName in _channels.keys.toList()) {
        await _channels[channelName]!.unsubscribe();
      }
      
      _channels.clear();
      
      print('📡 Desuscrito de todas las tablas');
      
    } catch (e) {
      print('❌ Error desuscribiéndose de todas las tablas: $e');
    }
  }
  
  // ========================================
  // MANEJO DE CAMBIOS
  // ========================================
  
  /// Manejar cambios en una tabla
  void _handleTableChange(String tableName, PostgresChangePayload payload) {
    try {
      print('🔄 Cambio detectado en $tableName: ${payload.eventType}');
      
      final changeData = {
        'table': tableName,
        'eventType': payload.eventType.toString(),
        'oldRecord': payload.oldRecord,
        'newRecord': payload.newRecord,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Notificar cambio
      _dataChangeController.add(changeData);
      
      // Invalidar caché de la tabla
      SupabaseService.instance.invalidateTableCache(tableName);
      
      // Actualizar AppState según el tipo de cambio
      _updateAppStateFromChange(tableName, payload);
      
    } catch (e) {
      print('❌ Error manejando cambio en $tableName: $e');
    }
  }
  
  /// Actualizar AppState según el tipo de cambio
  void _updateAppStateFromChange(String tableName, PostgresChangePayload payload) {
    try {
      switch (tableName) {
        case 'companies':
          _handleCompanyChange(payload);
          break;
        case 'zones':
          _handleZoneChange(payload);
          break;
        case 'operators':
          _handleOperatorChange(payload);
          break;
        case 'payment_config':
          _handlePaymentConfigChange(payload);
          break;
        case 'accessibility_config':
          _handleAccessibilityConfigChange(payload);
          break;
        case 'kiosks':
          _handleKioskChange(payload);
          break;
        case 'active_sessions':
          _handleActiveSessionChange(payload);
          break;
        case 'ui_texts':
          _handleUiTextsChange(payload);
          break;
        case 'ui_elements_config':
          _handleUiElementsConfigChange(payload);
          break;
        default:
          print('⚠️ Tabla no manejada: $tableName');
      }
    } catch (e) {
      print('❌ Error actualizando AppState desde cambio en $tableName: $e');
    }
  }
  
  /// Manejar cambios en empresas
  void _handleCompanyChange(PostgresChangePayload payload) async {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
        case PostgresChangeEvent.update:
          final companyData = payload.newRecord;
          if (companyData != null) {
            final company = Company.fromJson(companyData);
            
            // TODO: Implementar manejo de empresas en AppState
            // Actualizar en AppState
            // if (AppState.companies.any((c) => c.id == company.id)) {
            //   AppState.companies.removeWhere((c) => c.id == company.id);
            // }
            // AppState.companies.add(company);
            
            // Si es la empresa actual, actualizar configuración
            if (AppState.currentCompany?.id == company.id) {
              AppState.currentCompany = company;
              await _loadCompanyCompleteConfig(company.id);
            }
            
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.delete:
          final companyId = payload.oldRecord?['id'];
          if (companyId != null) {
            // TODO: Implementar manejo de empresas en AppState
            // AppState.companies.removeWhere((c) => c.id == companyId);
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.all:
          // No hacer nada para eventos 'all'
          break;
      }
    } catch (e) {
      print('❌ Error manejando cambio de empresa: $e');
    }
  }
  
  /// Manejar cambios en zonas
  void _handleZoneChange(PostgresChangePayload payload) async {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
        case PostgresChangeEvent.update:
          final zoneData = payload.newRecord;
          if (zoneData != null) {
            final zone = Zone.fromJson(zoneData);
            
            // TODO: Implementar manejo de zonas en AppState
            // Actualizar en AppState
            // if (AppState.zones.any((z) => z.id == zone.id)) {
            //   AppState.zones.removeWhere((z) => z.id == zone.id);
            // }
            // AppState.zones.add(zone);
            
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.delete:
          final zoneId = payload.oldRecord?['id'];
          if (zoneId != null) {
            // TODO: Implementar manejo de zonas en AppState
            // AppState.zones.removeWhere((z) => z.id == zoneId);
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.all:
          // No hacer nada para eventos 'all'
          break;
      }
    } catch (e) {
      print('❌ Error manejando cambio de zona: $e');
    }
  }
  
  /// Manejar cambios en operadores
  void _handleOperatorChange(PostgresChangePayload payload) async {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
        case PostgresChangeEvent.update:
          final operatorData = payload.newRecord;
          if (operatorData != null) {
            final operator = Operator.fromJson(operatorData);
            
            // TODO: Implementar manejo de operadores en AppState
            // Actualizar en AppState
            // if (AppState.operators.any((o) => o.id == operator.id)) {
            //   AppState.operators.removeWhere((o) => o.id == operator.id);
            // }
            // AppState.operators.add(operator);
            
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.delete:
          final operatorId = payload.oldRecord?['id'];
          if (operatorId != null) {
            // TODO: Implementar manejo de operadores en AppState
            // AppState.operators.removeWhere((o) => o.id == operatorId);
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.all:
          // No hacer nada para eventos 'all'
          break;
      }
    } catch (e) {
      print('❌ Error manejando cambio de operador: $e');
    }
  }
  
  /// Manejar cambios en configuración de pagos
  void _handlePaymentConfigChange(PostgresChangePayload payload) async {
    try {
      if (payload.eventType == PostgresChangeEvent.insert || 
          payload.eventType == PostgresChangeEvent.update) {
        final configData = payload.newRecord;
        if (configData != null) {
          // Actualizar configuración de pagos en AppState
          AppState.acceptedCoins = List<double>.from(configData['accepted_coins'] ?? []);
          AppState.acceptedCards = List<String>.from(configData['accepted_cards'] ?? []);
          AppState.maxChangeAmount = (configData['max_change_amount'] ?? 10.0).toDouble();
          AppState.minPaymentAmount = (configData['min_payment_amount'] ?? 0.15).toDouble();
          AppState.currency = configData['currency'] ?? 'EUR';
          AppState.currencySymbol = configData['currency_symbol'] ?? '€';
          
          AppState.notifyListeners();
        }
      }
    } catch (e) {
      print('❌ Error manejando cambio de configuración de pagos: $e');
    }
  }
  
  /// Manejar cambios en configuración de accesibilidad
  void _handleAccessibilityConfigChange(PostgresChangePayload payload) async {
    try {
      if (payload.eventType == PostgresChangeEvent.insert || 
          payload.eventType == PostgresChangeEvent.update) {
        final configData = payload.newRecord;
        if (configData != null) {
          // Actualizar configuración de accesibilidad en AppState
          AppState.darkMode = configData['dark_mode'] ?? false;
          AppState.highContrast = configData['high_contrast'] ?? false;
          AppState.fontSize = configData['font_size'] ?? 'normal';
          AppState.reduceAnimations = configData['reduce_animations'] ?? false;
          // TODO: Implementar voiceGuide en AppState
          // AppState.voiceGuide = configData['voice_guide'] ?? false;
          AppState.voiceSpeed = (configData['voice_speed'] ?? 0.5).toDouble();
          AppState.voicePitch = (configData['voice_pitch'] ?? 1.0).toDouble();
          AppState.voiceVolume = (configData['voice_volume'] ?? 0.8).toDouble();
          AppState.adaptiveAI = configData['adaptive_ai'] ?? false;
          AppState.simplifiedMode = configData['simplified_mode'] ?? false;
          AppState.currentLanguage = configData['current_language'] ?? 'es-ES';
          
          AppState.notifyListeners();
        }
      }
    } catch (e) {
      print('❌ Error manejando cambio de configuración de accesibilidad: $e');
    }
  }
  
  /// Manejar cambios en kioscos
  void _handleKioskChange(PostgresChangePayload payload) async {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
        case PostgresChangeEvent.update:
          final kioskData = payload.newRecord;
          if (kioskData != null) {
            // TODO: Implementar KioscoStatus
            // final kiosk = KioscoStatus.fromJson(kioskData);
            
            // TODO: Implementar manejo de kioscos en AppState
            // Actualizar en AppState
            // if (AppState.kioscos.any((k) => k.id == kiosk.id)) {
            //   AppState.kioscos.removeWhere((k) => k.id == kiosk.id);
            // }
            // AppState.kioscos.add(kiosk);
            
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.delete:
          final kioskId = payload.oldRecord?['id'];
          if (kioskId != null) {
            // TODO: Implementar manejo de kioscos en AppState
            // AppState.kioscos.removeWhere((k) => k.id == kioskId);
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.all:
          // No hacer nada para eventos 'all'
          break;
      }
    } catch (e) {
      print('❌ Error manejando cambio de kiosco: $e');
    }
  }
  
  /// Manejar cambios en sesiones activas
  void _handleActiveSessionChange(PostgresChangePayload payload) async {
    try {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
        case PostgresChangeEvent.update:
          final sessionData = payload.newRecord;
          if (sessionData != null) {
            final session = ParkingSession.fromJson(sessionData);
            
            // Actualizar en AppState
            if (AppState.activeSessions.containsKey(session.plate)) {
              AppState.activeSessions[session.plate] = session;
            }
            
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.delete:
          final sessionId = payload.oldRecord?['id'];
          final plate = payload.oldRecord?['plate'];
          if (sessionId != null && plate != null) {
            AppState.activeSessions.remove(plate);
            AppState.notifyListeners();
          }
          break;
        case PostgresChangeEvent.all:
          // No hacer nada para eventos 'all'
          break;
      }
    } catch (e) {
      print('❌ Error manejando cambio de sesión activa: $e');
    }
  }
  
  /// Manejar cambios en textos UI
  void _handleUiTextsChange(PostgresChangePayload payload) async {
    try {
      // Invalidar caché de traducciones
      SupabaseService.instance.invalidateTableCache('ui_translations_cache');
      
      // Notificar que las traducciones han cambiado
      _dataChangeController.add({
        'type': 'ui_texts_changed',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      print('❌ Error manejando cambio de textos UI: $e');
    }
  }
  
  /// Manejar cambios en configuración de elementos UI
  void _handleUiElementsConfigChange(PostgresChangePayload payload) async {
    try {
      // Notificar que la configuración de elementos UI ha cambiado
      _dataChangeController.add({
        'type': 'ui_elements_config_changed',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      print('❌ Error manejando cambio de configuración de elementos UI: $e');
    }
  }
  
  // ========================================
  // MÉTODOS DE UTILIDAD
  // ========================================
  
  /// Cargar configuración completa de empresa
  Future<void> _loadCompanyCompleteConfig(String companyId) async {
    try {
      final config = await SupabaseService.instance.getCompanyCompleteConfig(companyId);
      if (config != null) {
        // Actualizar configuración de pagos
        if (config['accepted_coins'] != null) {
          AppState.acceptedCoins = List<double>.from(config['accepted_coins']);
        }
        if (config['accepted_cards'] != null) {
          AppState.acceptedCards = List<String>.from(config['accepted_cards']);
        }
        if (config['max_change_amount'] != null) {
          AppState.maxChangeAmount = (config['max_change_amount']).toDouble();
        }
        if (config['min_payment_amount'] != null) {
          AppState.minPaymentAmount = (config['min_payment_amount']).toDouble();
        }
        if (config['currency'] != null) {
          AppState.currency = config['currency'];
        }
        if (config['currency_symbol'] != null) {
          AppState.currencySymbol = config['currency_symbol'];
        }
        
        // Actualizar configuración de accesibilidad
        if (config['dark_mode'] != null) {
          AppState.darkMode = config['dark_mode'];
        }
        if (config['high_contrast'] != null) {
          AppState.highContrast = config['high_contrast'];
        }
        if (config['font_size'] != null) {
          AppState.fontSize = config['font_size'];
        }
        if (config['reduce_animations'] != null) {
          AppState.reduceAnimations = config['reduce_animations'];
        }
        if (config['voice_guide'] != null) {
          // TODO: Implementar voiceGuide en AppState
          // AppState.voiceGuide = config['voice_guide'];
        }
        if (config['voice_speed'] != null) {
          AppState.voiceSpeed = (config['voice_speed']).toDouble();
        }
        if (config['voice_pitch'] != null) {
          AppState.voicePitch = (config['voice_pitch']).toDouble();
        }
        if (config['voice_volume'] != null) {
          AppState.voiceVolume = (config['voice_volume']).toDouble();
        }
        if (config['adaptive_ai'] != null) {
          AppState.adaptiveAI = config['adaptive_ai'];
        }
        if (config['simplified_mode'] != null) {
          AppState.simplifiedMode = config['simplified_mode'];
        }
        if (config['current_language'] != null) {
          AppState.currentLanguage = config['current_language'];
        }
        
        AppState.notifyListeners();
      }
    } catch (e) {
      print('❌ Error cargando configuración completa de empresa: $e');
    }
  }
  
  /// Obtener estadísticas de conexión
  Map<String, dynamic> getConnectionStats() {
    return {
      'isConnected': _isConnected,
      'isInitialized': _isInitialized,
      'activeChannels': _channels.length,
      'channelNames': _channels.keys.toList(),
    };
  }
  
  /// Limpiar recursos
  Future<void> dispose() async {
    try {
      await unsubscribeFromAllTables();
      await _dataChangeController.close();
      await _connectionStatusController.close();
      
      _isInitialized = false;
      _isConnected = false;
      
      print('🧹 SupabaseRealtimeService limpiado');
      
    } catch (e) {
      print('❌ Error limpiando SupabaseRealtimeService: $e');
    }
  }
}
