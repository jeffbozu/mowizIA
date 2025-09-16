import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../data/models.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static String? _kioscoId;
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
  
  // Conectar dashboard al servidor WebSocket
  static Future<void> connectDashboard(String dashboardId, {String serverUrl = 'ws://localhost:8080'}) async {
    try {
      _channel = IOWebSocketChannel.connect('$serverUrl?type=dashboard&id=$dashboardId');
      _isConnected = true;
      AppState.isConnectedToDashboard = true;
      
      _connectionController.add(true);
      AppState.notifyWebSocketChange();
      
      print('Dashboard $dashboardId conectado al servidor WebSocket');
      
      // Escuchar mensajes
      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            _handleMessage(message);
          } catch (e) {
            print('Error al procesar mensaje: $e');
          }
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('Conexión WebSocket cerrada');
          _handleDisconnection();
        },
      );
      
    } catch (e) {
      print('Error al conectar WebSocket: $e');
      _scheduleReconnect();
    }
  }

  // Conectar kiosco al servidor WebSocket
  static Future<void> connectKiosco(String kioscoId, {String serverUrl = 'ws://localhost:8080'}) async {
    _kioscoId = kioscoId;
    AppState.kioscoId = kioscoId;
    
    try {
      _channel = IOWebSocketChannel.connect('$serverUrl?type=kiosco&id=$kioscoId');
      _isConnected = true;
      AppState.isConnectedToDashboard = true;
      
      _connectionController.add(true);
      AppState.notifyWebSocketChange();
      
      print('Kiosco $kioscoId conectado al servidor WebSocket');
      
      // Escuchar mensajes
      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            _handleMessage(message);
          } catch (e) {
            print('Error al procesar mensaje: $e');
          }
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          _handleDisconnection();
        },
        onDone: () {
          print('Conexión WebSocket cerrada');
          _handleDisconnection();
        },
      );
      
    } catch (e) {
      print('Error al conectar WebSocket: $e');
      _scheduleReconnect();
    }
  }
  
  // Manejar mensajes recibidos
  static void _handleMessage(Map<String, dynamic> message) {
    print('Mensaje recibido: $message');
    _messageController.add(message);
    
    switch (message['type']) {
      case 'update_company':
        _handleUpdateCompany(message['data']);
        break;
      case 'update_zone':
        _handleUpdateZone(message['data']);
        break;
      case 'update_operators':
        _handleUpdateOperators(message['data']);
        break;
      case 'update_zones':
        _handleUpdateZones(message['data']);
        break;
        case 'update_ui':
          _handleUpdateUI(message['data']);
          break;
      case 'operators_updated':
        _handleUpdateOperators(message['data']);
        break;
      case 'companies_updated':
        _handleUpdateCompanies(message['data']);
        break;
      case 'zones_updated':
        _handleUpdateZones(message['data']);
        break;
      case 'restart_app':
        _handleRestartApp();
        break;
      case 'ping':
        _sendPong();
        break;
    }
  }
  
  // Manejar actualización de empresa
  static void _handleUpdateCompany(Map<String, dynamic> data) {
    final company = Company.fromJson(data);
    AppState.setCurrentCompany(company);
    print('Empresa actualizada: ${company.name}');
  }
  
  // Manejar actualización de zona
  static void _handleUpdateZone(Map<String, dynamic> data) {
    final zone = Zone.fromJson(data);
    AppState.addZone(zone);
    print('Zona actualizada: ${zone.name}');
  }
  
  // Manejar actualización de operadores
  static void _handleUpdateOperators(List<dynamic> data) {
    // Limpiar operadores actuales
    AppState.operators.clear();
    
    // Agregar nuevos operadores
    for (final operatorData in data) {
      final operator = Operator.fromJson(operatorData);
      AppState.operators[operator.id] = operator;
    }
    
    print('Operadores actualizados: ${data.length}');
    print('Nuevos operadores:');
    for (var op in AppState.operators.values) {
      print('  ${op.username} / ${op.password}');
    }
  }
  
  // Manejar actualización de zonas
  static void _handleUpdateZones(List<dynamic> data) {
    for (final zoneData in data) {
      final zone = Zone.fromJson(zoneData);
      AppState.addZone(zone);
    }
    print('Zonas actualizadas: ${data.length}');
  }
  
  // Manejar actualización de empresas
  static void _handleUpdateCompanies(List<dynamic> data) {
    for (final companyData in data) {
      final company = Company.fromJson(companyData);
      AppState.addCompany(company);
    }
    print('Empresas actualizadas: ${data.length}');
  }
  
  // Manejar actualización de UI
  static void _handleUpdateUI(Map<String, dynamic> data) {
    if (data['darkMode'] != null) {
      AppState.darkMode = data['darkMode'];
    }
    if (data['highContrast'] != null) {
      AppState.highContrast = data['highContrast'];
    }
    if (data['fontSize'] != null) {
      AppState.fontSize = data['fontSize'];
    }
    if (data['reduceAnimations'] != null) {
      AppState.reduceAnimations = data['reduceAnimations'];
    }
    
    AppState.notifyAccessibilityChange();
    print('UI actualizada desde dashboard');
  }
  
  // Manejar reinicio de app
  static void _handleRestartApp() {
    print('Reiniciando aplicación...');
    // Aquí podrías implementar el reinicio real
    // Por ahora solo notificamos
  }
  
  // Enviar pong en respuesta a ping
  static void _sendPong() {
    sendMessage({
      'type': 'pong',
      'kioscoId': _kioscoId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  // Enviar mensaje al servidor
  static void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  // Enviar estado del kiosco
  static void sendKioscoStatus(Map<String, dynamic> status) {
    sendMessage({
      'type': 'kiosk_status',
      'kioscoId': _kioscoId,
      'status': status['status'] ?? 'online',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  // Enviar actualización de pantalla
  static void sendScreenUpdate(String screen, {
    String? user, 
    String? action, 
    String? selectedZone,
    String? zone,
    String? plate,
    int? selectedTime,
    String? total,
    String? method,
    String? time
  }) {
    sendMessage({
      'type': 'screen_update',
      'kioscoId': _kioscoId,
      'screen': screen,
      'user': user,
      'action': action,
      'selectedZone': selectedZone,
      'zone': zone,
      'plate': plate,
      'selectedTime': selectedTime,
      'total': total,
      'method': method,
      'time': time,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  // Enviar diagnósticos técnicos
  static void sendTechDiagnostics(Map<String, dynamic> diagnostics) {
    sendMessage({
      'type': 'diagnostics_update',
      'kioscoId': _kioscoId,
      'diagnostics': diagnostics,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  // Enviar sesión activa
  static void sendActiveSession(Session session) {
    sendMessage({
      'type': 'active_session',
      'kioscoId': _kioscoId,
      'session': session.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  // Manejar desconexión
  static void _handleDisconnection() {
    _isConnected = false;
    AppState.isConnectedToDashboard = false;
    _connectionController.add(false);
    AppState.notifyWebSocketChange();
    _scheduleReconnect();
  }
  
  // Programar reconexión
  static void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_kioscoId != null && !_isConnected) {
        print('Intentando reconectar...');
        connectKiosco(_kioscoId!);
      }
    });
  }
  
  // Desconectar
  static void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    AppState.isConnectedToDashboard = false;
    _connectionController.add(false);
    AppState.notifyWebSocketChange();
  }
  
  // Limpiar recursos
  static void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
