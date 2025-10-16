import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart';
import '../data/models.dart';
import 'supabase_edge_functions_service.dart';

class CentralizedWebSocketService {
  static WebSocketChannel? _channel;
  static String? _clientId;
  static bool _isConnected = false;
  static Timer? _reconnectTimer;
  
  // Streams para notificar cambios
  static final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();
  
  static Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  static Stream<bool> get connectionStream => _connectionController.stream;

  // Función auxiliar para conversión segura de tipos numéricos
  static double _safeToDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return defaultValue;
  }

  // Función auxiliar para conversión segura de listas de números
  static List<double> _safeToDoubleList(dynamic value, List<double> defaultValue) {
    if (value == null) return defaultValue;
    if (value is! List) return defaultValue;
    
    return value.map((e) => _safeToDouble(e, 0.0)).toList();
  }
  static bool get isConnected => _isConnected;
  
  // Instancia del servicio de Edge Functions
  static final SupabaseEdgeFunctionsService _edgeFunctions = SupabaseEdgeFunctionsService();
  
  // Conectar al backend centralizado
  static Future<void> connect(String clientId, {String serverUrl = 'ws://localhost:8082'}) async {
    try {
      _clientId = clientId;
      
      // Usar el WebSocket correcto según la plataforma
      if (kIsWeb) {
        _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      } else {
        _channel = IOWebSocketChannel.connect(serverUrl);
      }
      
      _isConnected = true;
      
      _connectionController.add(true);
      AppState.notifyWebSocketChange();
      
      print('🔌 $clientId conectado al backend centralizado');
      
      // Enviar ID de la app al backend para registro
      sendMessage({
        'type': 'register_app',
        'appId': clientId,
        'appInfo': {
          'name': 'MEYPARK App Flutter',
          'version': '1.0.0',
          'platform': 'linux',
          'location': 'Aplicación Móvil'
        }
      });
      
      // Escuchar mensajes
      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            _handleMessage(message);
          } catch (e) {
            print('❌ Error al procesar mensaje: $e');
          }
        },
        onError: (error) {
          print('❌ Error en WebSocket: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('🔌 Conexión WebSocket cerrada');
          _handleDisconnection();
        },
      );
      
    } catch (e) {
      print('❌ Error conectando al backend: $e');
      _scheduleReconnect();
    }
  }
  
  // Manejar mensajes del servidor
  static void _handleMessage(Map<String, dynamic> message) {
    print('📨 Mensaje recibido: $message');
    
    switch (message['type']) {
      case 'full_data':
        _handleFullData(message['data']);
        break;
      case 'initial_data':
        _handleInitialData(message['data']);
        break;
      case 'company_updated':
        _handleCompanyUpdated(message);
        break;
      case 'zone_updated':
        _handleZoneUpdated(message);
        break;
      case 'operator_updated':
        _handleOperatorUpdated(message);
        break;
      case 'accessibility_updated':
        _handleAccessibilityUpdated(message);
        break;
      case 'session_added':
        _handleParkingSessionAdded(message);
        break;
      case 'session_removed':
        _handleParkingSessionRemoved(message);
        break;
      case 'session_found':
        _handleParkingSessionFound(message);
        break;
      case 'tech_diagnostics':
        _handleTechDiagnostics(message);
        break;
      case 'stats_update':
        _handleStatsUpdate(message);
        break;
      case 'session_extended':
        _handleParkingSessionExtended(message);
        break;
      case 'session_found':
        _handleParkingSessionFound(message);
        break;
      default:
        print('❓ Tipo de mensaje no reconocido: ${message['type']}');
    }
    
    _messageController.add(message);
  }
  
  // Manejar datos iniciales del backend
  static void _handleInitialData(Map<String, dynamic> data) {
    print('📊 Recibiendo datos iniciales del backend');
    
    // Sincronizar empresas
    if (data['companies'] != null) {
      AppState.companies.clear();
      (data['companies'] as Map<String, dynamic>).forEach((key, value) {
        AppState.companies[key] = Company.fromJson(value);
      });
    }
    
    // Sincronizar operadores
    if (data['operators'] != null) {
      AppState.operators.clear();
      (data['operators'] as Map<String, dynamic>).forEach((key, value) {
        AppState.operators[key] = Operator.fromJson(value);
      });
    }
    
    // Sincronizar zonas
    if (data['zones'] != null) {
      AppState.zones.clear();
      (data['zones'] as Map<String, dynamic>).forEach((key, value) {
        AppState.zones[key] = Zone.fromJson(value);
      });
    }
    
    // Sincronizar sesiones activas
    if (data['activeSessions'] != null) {
      AppState.activeSessions.clear();
      (data['activeSessions'] as Map<String, dynamic>).forEach((key, value) {
        AppState.activeSessions[key] = ParkingSession.fromJson(value);
      });
    }
    
    // Sincronizar estadísticas
    if (data['stats'] != null) {
      AppState.totalIncome = (data['stats']['totalIncome'] ?? 0.0).toDouble();
      AppState.todayIncome = (data['stats']['todayIncome'] ?? 0.0).toDouble();
      AppState.activeSessionsCount = data['stats']['activeSessions'] ?? 0;
    }
    
    // Sincronizar configuración de accesibilidad
    if (data['accessibility'] != null) {
      AppState.darkMode = data['accessibility']['darkMode'] ?? false;
      AppState.highContrast = data['accessibility']['highContrast'] ?? false;
      AppState.fontSize = data['accessibility']['fontSize'] ?? 'normal';
      AppState.reduceAnimations = data['accessibility']['reduceAnimations'] ?? false;
      AppState.voiceGuideEnabled = data['accessibility']['voiceGuide'] ?? false;
      AppState.currentLanguage = data['accessibility']['currentLanguage'] ?? 'es-ES';
    }
    
    // Sincronizar configuración de pagos
    if (data['paymentConfig'] != null) {
      try {
        final paymentConfig = data['paymentConfig'];
        AppState.acceptedCoins = _safeToDoubleList(paymentConfig['acceptedCoins'], [0.05, 0.10, 0.20, 0.50, 1.00, 2.00]);
        AppState.acceptedCards = List<String>.from(paymentConfig['acceptedCards'] ?? ['Visa', 'Mastercard']);
        AppState.maxChangeAmount = _safeToDouble(paymentConfig['maxChangeAmount'], 10.0);
        AppState.minPaymentAmount = _safeToDouble(paymentConfig['minPaymentAmount'], 0.15);
        AppState.currency = paymentConfig['currency'] ?? 'EUR';
        AppState.currencySymbol = paymentConfig['symbol'] ?? '€';
        print('✅ Configuración de pagos sincronizada correctamente');
      } catch (e) {
        print('❌ Error sincronizando configuración de pagos: $e');
        // Valores por defecto en caso de error
        AppState.acceptedCoins = [0.05, 0.10, 0.20, 0.50, 1.00, 2.00];
        AppState.acceptedCards = ['Visa', 'Mastercard'];
        AppState.maxChangeAmount = 10.0;
        AppState.minPaymentAmount = 0.15;
        AppState.currency = 'EUR';
        AppState.currencySymbol = '€';
      }
    }
    
    print('✅ Datos iniciales sincronizados desde el backend');
    AppState.notifyConfigChange();
  }

  // Sincronizar datos completos
  static void _handleFullData(Map<String, dynamic> data) {
    print('📊 Sincronizando datos completos del backend');
    
    // Sincronizar empresas
    if (data['companies'] != null) {
      AppState.companies.clear();
      (data['companies'] as Map<String, dynamic>).forEach((key, value) {
        AppState.companies[key] = Company.fromJson(value);
      });
    }
    
    // Sincronizar operadores
    if (data['operators'] != null) {
      AppState.operators.clear();
      (data['operators'] as Map<String, dynamic>).forEach((key, value) {
        AppState.operators[key] = Operator.fromJson(value);
      });
    }
    
    // Sincronizar zonas
    if (data['zones'] != null) {
      AppState.zones.clear();
      (data['zones'] as Map<String, dynamic>).forEach((key, value) {
        AppState.zones[key] = Zone.fromJson(value);
      });
    }
    
    // Sincronizar sesiones activas
    if (data['activeSessions'] != null) {
      AppState.activeSessions.clear();
      (data['activeSessions'] as Map<String, dynamic>).forEach((key, value) {
        AppState.activeSessions[key] = ParkingSession.fromJson(value);
      });
    }
    
    // Sincronizar estadísticas
    if (data['stats'] != null) {
      try {
        final stats = data['stats'];
        AppState.totalIncome = _safeToDouble(stats['totalIncome'], 0.0);
        AppState.todayIncome = _safeToDouble(stats['todayIncome'], 0.0);
        AppState.activeSessionsCount = stats['activeSessions'] is int 
            ? stats['activeSessions'] as int
            : (stats['activeSessions'] is double 
                ? (stats['activeSessions'] as double).toInt()
                : 0);
        print('✅ Estadísticas sincronizadas correctamente');
      } catch (e) {
        print('❌ Error sincronizando estadísticas: $e');
        AppState.totalIncome = 0.0;
        AppState.todayIncome = 0.0;
        AppState.activeSessionsCount = 0;
      }
    }
    
    // Sincronizar configuración de pagos
    if (data['paymentConfig'] != null) {
      try {
        final paymentConfig = data['paymentConfig'];
        AppState.acceptedCoins = _safeToDoubleList(paymentConfig['acceptedCoins'], [0.05, 0.10, 0.20, 0.50, 1.00, 2.00]);
        AppState.acceptedCards = List<String>.from(paymentConfig['acceptedCards'] ?? ['Visa', 'Mastercard']);
        AppState.maxChangeAmount = _safeToDouble(paymentConfig['maxChangeAmount'], 10.0);
        AppState.minPaymentAmount = _safeToDouble(paymentConfig['minPaymentAmount'], 0.15);
        AppState.currency = paymentConfig['currency'] ?? 'EUR';
        AppState.currencySymbol = paymentConfig['symbol'] ?? '€';
        print('✅ Configuración de pagos sincronizada correctamente');
      } catch (e) {
        print('❌ Error sincronizando configuración de pagos: $e');
        // Valores por defecto en caso de error
        AppState.acceptedCoins = [0.05, 0.10, 0.20, 0.50, 1.00, 2.00];
        AppState.acceptedCards = ['Visa', 'Mastercard'];
        AppState.maxChangeAmount = 10.0;
        AppState.minPaymentAmount = 0.15;
        AppState.currency = 'EUR';
        AppState.currencySymbol = '€';
      }
    }
    
    // Sincronizar configuración del kiosco
    if (data['kioscoConfig'] != null) {
      final kioscoConfig = data['kioscoConfig'];
      AppState.kioscoLocation = kioscoConfig['location'] ?? 'Centro Comercial';
      AppState.timezone = kioscoConfig['timezone'] ?? 'Europe/Madrid';
      AppState.maintenanceMode = kioscoConfig['maintenanceMode'] ?? false;
    }
    
    // Sincronizar accesibilidad
    if (data['accessibility'] != null) {
      final acc = data['accessibility'];
      AppState.darkMode = acc['darkMode'] ?? false;
      AppState.highContrast = acc['highContrast'] ?? false;
      AppState.fontSize = acc['fontSize'] ?? 'normal';
      AppState.reduceAnimations = acc['reduceAnimations'] ?? false;
      AppState.voiceGuideEnabled = acc['voiceGuide'] ?? false;
      AppState.voiceSpeed = acc['voiceSpeed'] ?? 0.5;
      AppState.voicePitch = acc['voicePitch'] ?? 1.0;
      AppState.voiceVolume = acc['voiceVolume'] ?? 0.8;
      AppState.adaptiveAI = acc['adaptiveAI'] ?? false;
      AppState.simplifiedMode = acc['simplifiedMode'] ?? false;
    }
    
    AppState.notifyConfigChange();
    AppState.notifyAccessibilityChange();
  }
  
  // Manejar actualización de empresa
  static void _handleCompanyUpdated(Map<String, dynamic> message) {
    if (message['success'] == true && message['company'] != null) {
      final company = Company.fromJson(message['company']);
      AppState.companies[company.id] = company;
      AppState.notifyConfigChange();
      print('🏢 Empresa actualizada: ${company.name}');
    }
  }
  
  // Manejar actualización de zona
  static void _handleZoneUpdated(Map<String, dynamic> message) {
    if (message['success'] == true && message['zone'] != null) {
      final zone = Zone.fromJson(message['zone']);
      AppState.zones[zone.id] = zone;
      AppState.notifyConfigChange();
      print('📍 Zona actualizada: ${zone.name}');
    }
  }
  
  // Manejar actualización de operador
  static void _handleOperatorUpdated(Map<String, dynamic> message) {
    if (message['success'] == true && message['operator'] != null) {
      final operator = Operator.fromJson(message['operator']);
      AppState.operators[operator.id] = operator;
      AppState.notifyConfigChange();
      print('👤 Operador actualizado: ${operator.username}');
    }
  }
  
  // Manejar actualización de accesibilidad
  static void _handleAccessibilityUpdated(Map<String, dynamic> message) {
    if (message['success'] == true && message['accessibility'] != null) {
      final acc = message['accessibility'];
      AppState.darkMode = acc['darkMode'] ?? AppState.darkMode;
      AppState.highContrast = acc['highContrast'] ?? AppState.highContrast;
      AppState.fontSize = acc['fontSize'] ?? AppState.fontSize;
      AppState.reduceAnimations = acc['reduceAnimations'] ?? AppState.reduceAnimations;
      AppState.voiceGuideEnabled = acc['voiceGuide'] ?? AppState.voiceGuideEnabled;
      AppState.voiceSpeed = acc['voiceSpeed'] ?? AppState.voiceSpeed;
      AppState.voicePitch = acc['voicePitch'] ?? AppState.voicePitch;
      AppState.voiceVolume = acc['voiceVolume'] ?? AppState.voiceVolume;
      AppState.adaptiveAI = acc['adaptiveAI'] ?? AppState.adaptiveAI;
      AppState.simplifiedMode = acc['simplifiedMode'] ?? AppState.simplifiedMode;
      
      AppState.notifyAccessibilityChange();
      print('♿ Configuración de accesibilidad actualizada');
    }
  }
  
  // Manejar sesión agregada
  static void _handleParkingSessionAdded(Map<String, dynamic> message) {
    if (message['success'] == true && message['session'] != null) {
      final session = ParkingSession.fromJson(message['session']);
      // Usar plate como clave para búsqueda por matrícula
      AppState.activeSessions[session.plate] = session;
      AppState.notifyConfigChange();
      print('🅿️ Sesión agregada: ${session.plate} en zona ${session.zoneId}');
      print('📊 Total sesiones activas: ${AppState.activeSessions.length}');
    }
  }
  
  // Manejar sesión removida
  static void _handleParkingSessionRemoved(Map<String, dynamic> message) {
    if (message['success'] == true && message['sessionId'] != null) {
      AppState.activeSessions.remove(message['sessionId']);
      AppState.notifyConfigChange();
      print('🅿️ Sesión removida: ${message['sessionId']}');
    }
  }

  // Manejar sesión encontrada
  static void _handleParkingSessionFound(Map<String, dynamic> message) {
    if (message['success'] == true && message['session'] != null) {
      final session = ParkingSession.fromJson(message['session']);
      final plate = message['plate'] as String;
      
      // Agregar/actualizar sesión en el estado local
      AppState.activeSessions[plate] = session;
      AppState.notifyConfigChange();
      
      print('✅ Sesión encontrada: ${session.plate} en zona ${session.zoneId}');
      print('📊 Total de sesiones activas: ${AppState.activeSessions.length}');
    } else {
      final plate = message['plate'] as String?;
      print('❌ No se encontró sesión para matrícula: $plate');
    }
  }
  
  // Manejar diagnósticos técnicos
  static void _handleTechDiagnostics(Map<String, dynamic> message) {
    // Los diagnósticos se manejan en el dashboard
    print('🔧 Diagnósticos técnicos actualizados');
  }
  
  // Manejar actualización de estadísticas
  static void _handleStatsUpdate(Map<String, dynamic> message) {
    if (message['stats'] != null) {
      // Comentado hasta implementar en AppState
      // AppState.totalIncome = message['stats']['totalIncome'] ?? AppState.totalIncome;
      // AppState.todayIncome = message['stats']['todayIncome'] ?? AppState.todayIncome;
      AppState.notifyConfigChange();
      print('📊 Estadísticas actualizadas');
    }
  }
  
  // Enviar mensaje al servidor
  static void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
        print('📤 Mensaje enviado: $message');
      } catch (e) {
        print('❌ Error enviando mensaje: $e');
      }
    } else {
      print('⚠️ No conectado al servidor');
    }
  }
  
  // Solicitar datos completos
  static void requestFullData() {
    sendMessage({'type': 'get_data'});
  }
  
  // Actualizar empresa
  static void updateCompany(String companyId, Map<String, dynamic> updates) {
    sendMessage({
      'type': 'update_company',
      'companyId': companyId,
      'updates': updates
    });
  }
  
  // Actualizar zona
  static void updateZone(String zoneId, Map<String, dynamic> updates) {
    sendMessage({
      'type': 'update_zone',
      'zoneId': zoneId,
      'updates': updates
    });
  }
  
  // Actualizar operador
  static void updateOperator(String operatorId, Map<String, dynamic> updates) {
    sendMessage({
      'type': 'update_operator',
      'operatorId': operatorId,
      'updates': updates
    });
  }
  
  // Extender sesión
  static void extendParkingSession(String plate, int extraMinutes, double extraPrice) {
    sendMessage({
      'type': 'extend_session',
      'plate': plate,
      'extraMinutes': extraMinutes,
      'extraPrice': extraPrice,
      'timestamp': DateTime.now().toIso8601String()
    });
  }
  
  // Buscar sesión específica
  static void searchParkingSession(String plate) {
    sendMessage({
      'type': 'search_session',
      'plate': plate
    });
  }
  
  // Actualizar accesibilidad
  static void updateAccessibility(Map<String, dynamic> updates) {
    sendMessage({
      'type': 'update_accessibility',
      'updates': updates
    });
  }
  
  // Agregar sesión
  static void addParkingSession(String sessionId, Map<String, dynamic> sessionData) {
    sendMessage({
      'type': 'add_session',
      'sessionId': sessionId,
      'session': sessionData
    });
  }
  
  // Actualizar sesión existente
  static void updateParkingSession(String sessionId, Map<String, dynamic> sessionData) {
    sendMessage({
      'type': 'update_session',
      'sessionId': sessionId,
      'session': sessionData
    });
  }
  
  // Remover sesión
  static void removeParkingSession(String sessionId) {
    sendMessage({
      'type': 'remove_session',
      'sessionId': sessionId
    });
  }
  
  // Enviar diagnósticos técnicos
  static void sendTechDiagnostics(Map<String, dynamic> diagnostics) {
    sendMessage({
      'type': 'tech_diagnostics',
      'diagnostics': diagnostics
    });
  }
  
  // Enviar estadísticas
  static void sendStats(Map<String, dynamic> stats) {
    sendMessage({
      'type': 'stats_update',
      'stats': stats
    });
  }
  
  // Manejar desconexión
  static void _handleDisconnection() {
    _isConnected = false;
    _connectionController.add(false);
    AppState.notifyWebSocketChange();
    _scheduleReconnect();
  }
  
  // Programar reconexión
  static void _scheduleReconnect() {
    if (_reconnectTimer != null) return;
    
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      _reconnectTimer = null;
      if (_clientId != null) {
        print('🔄 Intentando reconectar...');
        connect(_clientId!);
      }
    });
  }
  
  // Desconectar
  static void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _isConnected = false;
    _connectionController.add(false);
    AppState.notifyWebSocketChange();
    print('🔌 Desconectado del backend centralizado');
  }
  
  // Limpiar recursos
  static void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
  
  // Manejar sesión extendida
  static void _handleParkingSessionExtended(Map<String, dynamic> message) {
    if (message['success'] == true && message['session'] != null) {
      final session = ParkingSession.fromJson(message['session']);
      AppState.activeSessions[session.plate] = session;
      AppState.notifyConfigChange();
      print('⏰ Sesión extendida: ${session.plate} - ${message['extraMinutes']} minutos adicionales');
    } else {
      print('❌ Error extendiendo sesión: ${message['error'] ?? 'Error desconocido'}');
    }
  }

  // ========================================
  // MÉTODOS QUE USAN EDGE FUNCTIONS (NUEVOS)
  // ========================================

  /// Agregar sesión usando Edge Functions
  static Future<Map<String, dynamic>?> addSession(ParkingSession session) async {
    try {
      return await _edgeFunctions.addSession(session);
    } catch (e) {
      print('❌ Error agregando sesión con Edge Functions: $e');
      return null;
    }
  }

  /// Buscar sesión usando Edge Functions
  static Future<Map<String, dynamic>?> searchSession(String plate) async {
    try {
      return await _edgeFunctions.searchSession(plate);
    } catch (e) {
      print('❌ Error buscando sesión con Edge Functions: $e');
      return null;
    }
  }

  /// Extender sesión usando Edge Functions
  static Future<Map<String, dynamic>?> extendSession(String plate, int extraMinutes, double price) async {
    try {
      return await _edgeFunctions.extendSession(plate, extraMinutes, price);
    } catch (e) {
      print('❌ Error extendiendo sesión con Edge Functions: $e');
      return null;
    }
  }

  /// Actualizar sesión usando Edge Functions
  static Future<Map<String, dynamic>?> updateSession(String sessionId, ParkingSession session) async {
    try {
      return await _edgeFunctions.updateSession(sessionId, session);
    } catch (e) {
      print('❌ Error actualizando sesión con Edge Functions: $e');
      return null;
    }
  }

  /// Eliminar sesión usando Edge Functions
  static Future<bool> removeSession(String plate) async {
    try {
      return await _edgeFunctions.removeSession(plate);
    } catch (e) {
      print('❌ Error eliminando sesión con Edge Functions: $e');
      return false;
    }
  }

  /// Obtener datos de empresa usando Edge Functions
  static Future<Map<String, dynamic>?> getCompanyData(String companyId) async {
    try {
      return await _edgeFunctions.getCompanyData(companyId);
    } catch (e) {
      print('❌ Error obteniendo datos de empresa con Edge Functions: $e');
      return null;
    }
  }

  /// Generar factura usando Edge Functions
  static Future<Map<String, dynamic>?> generateInvoice({
    required String transactionId,
    required String email,
    required String name,
  }) async {
    try {
      return await _edgeFunctions.generateInvoice(
        transactionId: transactionId,
        email: email,
        name: name,
      );
    } catch (e) {
      print('❌ Error generando factura con Edge Functions: $e');
      return null;
    }
  }

  /// Verificar salud de Edge Functions
  static Future<bool> checkEdgeFunctionsHealth() async {
    try {
      return await _edgeFunctions.checkEdgeFunctionsHealth();
    } catch (e) {
      print('❌ Error verificando salud de Edge Functions: $e');
      return false;
    }
  }
}

