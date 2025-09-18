import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../data/models.dart';

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
  static bool get isConnected => _isConnected;
  
  // Conectar al backend centralizado
  static Future<void> connect(String clientId, {String serverUrl = 'ws://localhost:8080'}) async {
    try {
      _clientId = clientId;
      _channel = IOWebSocketChannel.connect(serverUrl);
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
        _handleSessionAdded(message);
        break;
      case 'session_removed':
        _handleSessionRemoved(message);
        break;
      case 'tech_diagnostics':
        _handleTechDiagnostics(message);
        break;
      case 'stats_update':
        _handleStatsUpdate(message);
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
        AppState.activeSessions[key] = Session.fromJson(value);
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
      AppState.acceptedCoins = List<double>.from(data['paymentConfig']['acceptedCoins'] ?? []);
      AppState.acceptedCards = List<String>.from(data['paymentConfig']['acceptedCards'] ?? []);
      AppState.maxChangeAmount = (data['paymentConfig']['maxChangeAmount'] ?? 10.0).toDouble();
      AppState.minPaymentAmount = (data['paymentConfig']['minPaymentAmount'] ?? 0.15).toDouble();
      AppState.currency = data['paymentConfig']['currency'] ?? 'EUR';
      AppState.currencySymbol = data['paymentConfig']['symbol'] ?? '€';
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
      data['companies'].forEach((key, value) {
        AppState.companies[key] = Company.fromJson(value);
      });
    }
    
    // Sincronizar operadores
    if (data['operators'] != null) {
      AppState.operators.clear();
      data['operators'].forEach((key, value) {
        AppState.operators[key] = Operator.fromJson(value);
      });
    }
    
    // Sincronizar zonas
    if (data['zones'] != null) {
      AppState.zones.clear();
      data['zones'].forEach((key, value) {
        AppState.zones[key] = Zone.fromJson(value);
      });
    }
    
    // Sincronizar sesiones activas
    if (data['activeSessions'] != null) {
      AppState.activeSessions.clear();
      data['activeSessions'].forEach((key, value) {
        AppState.activeSessions[key] = Session.fromJson(value);
      });
    }
    
    // Sincronizar estadísticas
    if (data['stats'] != null) {
      final stats = data['stats'];
      AppState.totalIncome = (stats['totalIncome'] ?? 0.0).toDouble();
      AppState.todayIncome = (stats['todayIncome'] ?? 0.0).toDouble();
      AppState.activeSessionsCount = stats['activeSessions'] ?? 0;
    }
    
    // Sincronizar configuración de pagos
    if (data['paymentConfig'] != null) {
      final paymentConfig = data['paymentConfig'];
      AppState.acceptedCoins = List<double>.from(paymentConfig['acceptedCoins'] ?? [0.05, 0.10, 0.20, 0.50, 1.00, 2.00]);
      AppState.acceptedCards = List<String>.from(paymentConfig['acceptedCards'] ?? ['Visa', 'Mastercard']);
      AppState.maxChangeAmount = (paymentConfig['maxChangeAmount'] ?? 10.0).toDouble();
      AppState.minPaymentAmount = (paymentConfig['minPaymentAmount'] ?? 0.15).toDouble();
      AppState.currency = paymentConfig['currency'] ?? 'EUR';
      AppState.currencySymbol = paymentConfig['symbol'] ?? '€';
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
  static void _handleSessionAdded(Map<String, dynamic> message) {
    if (message['success'] == true && message['session'] != null) {
      final session = Session.fromJson(message['session']);
      AppState.activeSessions[session.plate] = session;
      AppState.notifyConfigChange();
      print('🅿️ Sesión agregada: ${session.plate}');
    }
  }
  
  // Manejar sesión removida
  static void _handleSessionRemoved(Map<String, dynamic> message) {
    if (message['success'] == true && message['sessionId'] != null) {
      AppState.activeSessions.remove(message['sessionId']);
      AppState.notifyConfigChange();
      print('🅿️ Sesión removida: ${message['sessionId']}');
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
  
  // Actualizar accesibilidad
  static void updateAccessibility(Map<String, dynamic> updates) {
    sendMessage({
      'type': 'update_accessibility',
      'updates': updates
    });
  }
  
  // Agregar sesión
  static void addSession(String sessionId, Map<String, dynamic> sessionData) {
    sendMessage({
      'type': 'add_session',
      'sessionId': sessionId,
      'sessionData': sessionData
    });
  }
  
  // Remover sesión
  static void removeSession(String sessionId) {
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
}

