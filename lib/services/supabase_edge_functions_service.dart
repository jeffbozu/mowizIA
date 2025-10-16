/// Servicio para interactuar con Supabase Edge Functions
/// 
/// Este servicio reemplaza la funcionalidad de los servidores Node.js
/// (mock_backend.js, facturacion_server.js, websocket_server.js)
/// usando Supabase Edge Functions.

import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../data/models.dart';

class SupabaseEdgeFunctionsService {
  static final SupabaseEdgeFunctionsService _instance = SupabaseEdgeFunctionsService._internal();
  factory SupabaseEdgeFunctionsService() => _instance;
  SupabaseEdgeFunctionsService._internal();

  late SupabaseClient _client;

  /// Inicializar el servicio
  void initialize() {
    _client = Supabase.instance.client;
  }

  // ========================================
  // GESTIÓN DE SESIONES (reemplaza mock_backend.js)
  // ========================================

  /// Obtener todos los datos de una empresa
  Future<Map<String, dynamic>?> getCompanyData(String companyId) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'get_data',
          'data': {'companyId': companyId}
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      } else {
        print('❌ Error obteniendo datos de empresa: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getCompanyData: $e');
      return null;
    }
  }

  /// Agregar nueva sesión
  Future<Map<String, dynamic>?> addSession(ParkingSession session) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'add_session',
          'data': {
            'sessionData': {
              'kioskId': 'default', // TODO: Obtener kioskId real
              'zoneId': session.zoneId,
              'plate': session.plate,
              'start': session.start.toIso8601String(),
              'end': session.end.toIso8601String(),
              'totalPrice': session.totalPrice,
              'paymentMethod': session.paymentMethod ?? 'cash',
            }
          }
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      } else {
        print('❌ Error agregando sesión: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en addSession: $e');
      return null;
    }
  }

  /// Actualizar sesión existente
  Future<Map<String, dynamic>?> updateSession(String sessionId, ParkingSession session) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'update_session',
          'data': {
            'sessionId': sessionId,
            'sessionData': {
              'zoneId': session.zoneId,
              'plate': session.plate,
              'start': session.start.toIso8601String(),
              'end': session.end.toIso8601String(),
              'totalPrice': session.totalPrice,
              'paymentMethod': session.paymentMethod ?? 'cash',
              'isExtend': false,
            }
          }
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      } else {
        print('❌ Error actualizando sesión: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en updateSession: $e');
      return null;
    }
  }

  /// Eliminar sesión
  Future<bool> removeSession(String plate) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'remove_session',
          'data': {'plate': plate}
        },
      );

      if (response.status == 200) {
        return true;
      } else {
        print('❌ Error eliminando sesión: ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Error en removeSession: $e');
      return false;
    }
  }

  /// Buscar sesión por matrícula
  Future<Map<String, dynamic>?> searchSession(String plate) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'search_session',
          'data': {'plate': plate}
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      } else {
        print('❌ Error buscando sesión: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en searchSession: $e');
      return null;
    }
  }

  /// Extender sesión existente
  Future<Map<String, dynamic>?> extendSession(String plate, int extraMinutes, double price) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'extend_session',
          'data': {
            'plate': plate,
            'extraMinutes': extraMinutes,
            'price': price,
          }
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      } else {
        print('❌ Error extendiendo sesión: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en extendSession: $e');
      return null;
    }
  }

  /// Actualizar operadores
  Future<List<Map<String, dynamic>>?> updateOperators(List<Operator> operators) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'update_operators',
          'data': {
            'operators': operators.map((op) => op.toJson()).toList()
          }
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['data'] as List);
      } else {
        print('❌ Error actualizando operadores: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en updateOperators: $e');
      return null;
    }
  }

  /// Actualizar zonas
  Future<List<Map<String, dynamic>>?> updateZones(List<Zone> zones) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'update_zones',
          'data': {
            'zones': zones.map((zone) => zone.toJson()).toList()
          }
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['data'] as List);
      } else {
        print('❌ Error actualizando zonas: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en updateZones: $e');
      return null;
    }
  }

  /// Actualizar empresas
  Future<List<Map<String, dynamic>>?> updateCompanies(List<Company> companies) async {
    try {
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'update_companies',
          'data': {
            'companies': companies.map((company) => company.toJson()).toList()
          }
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['data'] as List);
      } else {
        print('❌ Error actualizando empresas: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en updateCompanies: $e');
      return null;
    }
  }

  // ========================================
  // GENERACIÓN DE FACTURAS (reemplaza facturacion_server.js)
  // ========================================

  /// Generar factura electrónica
  Future<Map<String, dynamic>?> generateInvoice({
    required String transactionId,
    required String email,
    required String name,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'generate-invoice',
        body: {
          'transactionId': transactionId,
          'invoiceRequest': {
            'email': email,
            'name': name,
          }
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      } else {
        print('❌ Error generando factura: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en generateInvoice: $e');
      return null;
    }
  }

  // ========================================
  // DASHBOARD API (reemplaza websocket_server.js)
  // ========================================

  /// Obtener empresas para dashboard
  Future<List<Map<String, dynamic>>?> getCompanies() async {
    try {
      final response = await _client.functions.invoke(
        'dashboard-api',
        body: {
          'path': '/api/companies',
          'method': 'GET'
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['data'] as List);
      } else {
        print('❌ Error obteniendo empresas: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getCompanies: $e');
      return null;
    }
  }

  /// Obtener operadores para dashboard
  Future<List<Map<String, dynamic>>?> getOperators({String? companyId}) async {
    try {
      final response = await _client.functions.invoke(
        'dashboard-api',
        body: {
          'path': '/api/operators${companyId != null ? '?company_id=$companyId' : ''}',
          'method': 'GET'
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['data'] as List);
      } else {
        print('❌ Error obteniendo operadores: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getOperators: $e');
      return null;
    }
  }

  /// Obtener zonas para dashboard
  Future<List<Map<String, dynamic>>?> getZones({String? companyId}) async {
    try {
      final response = await _client.functions.invoke(
        'dashboard-api',
        body: {
          'path': '/api/zones${companyId != null ? '?company_id=$companyId' : ''}',
          'method': 'GET'
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['data'] as List);
      } else {
        print('❌ Error obteniendo zonas: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getZones: $e');
      return null;
    }
  }

  /// Obtener sesiones para dashboard
  Future<List<Map<String, dynamic>>?> getSessions({
    String? companyId,
    String? kioskId,
    String? status = 'active',
  }) async {
    try {
      final queryParams = <String>[];
      if (companyId != null) queryParams.add('company_id=$companyId');
      if (kioskId != null) queryParams.add('kiosk_id=$kioskId');
      if (status != null) queryParams.add('status=$status');
      
      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

      final response = await _client.functions.invoke(
        'dashboard-api',
        body: {
          'path': '/api/sessions$queryString',
          'method': 'GET'
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['data'] as List);
      } else {
        print('❌ Error obteniendo sesiones: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getSessions: $e');
      return null;
    }
  }

  /// Obtener estadísticas para dashboard
  Future<Map<String, dynamic>?> getStats({
    String? companyId,
    String period = 'today',
  }) async {
    try {
      final queryParams = <String>[];
      if (companyId != null) queryParams.add('company_id=$companyId');
      queryParams.add('period=$period');
      
      final queryString = '?${queryParams.join('&')}';

      final response = await _client.functions.invoke(
        'dashboard-api',
        body: {
          'path': '/api/stats$queryString',
          'method': 'GET'
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      } else {
        print('❌ Error obteniendo estadísticas: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getStats: $e');
      return null;
    }
  }

  /// Obtener facturas para dashboard
  Future<List<Map<String, dynamic>>?> getInvoices({String? companyId}) async {
    try {
      final response = await _client.functions.invoke(
        'dashboard-api',
        body: {
          'path': '/api/invoices${companyId != null ? '?company_id=$companyId' : ''}',
          'method': 'GET'
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['data'] as List);
      } else {
        print('❌ Error obteniendo facturas: ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getInvoices: $e');
      return null;
    }
  }

  // ========================================
  // MÉTODOS DE UTILIDAD
  // ========================================

  /// Verificar si las Edge Functions están disponibles
  Future<bool> checkEdgeFunctionsHealth() async {
    try {
      // Probar la función más simple
      final response = await _client.functions.invoke(
        'manage-sessions',
        body: {
          'method': 'get_data',
          'data': {'companyId': 'test'}
        },
      );

      return response.status == 200 || response.status == 404; // 404 es OK si no hay datos
    } catch (e) {
      print('❌ Edge Functions no disponibles: $e');
      return false;
    }
  }

  /// Obtener logs de Edge Functions (para debugging)
  Future<List<Map<String, dynamic>>?> getEdgeFunctionLogs(String functionName) async {
    try {
      // Nota: Esto requeriría configuración adicional en Supabase
      // Por ahora, solo retornamos null
      print('⚠️ getEdgeFunctionLogs no implementado aún');
      return null;
    } catch (e) {
      print('❌ Error obteniendo logs: $e');
      return null;
    }
  }
}
