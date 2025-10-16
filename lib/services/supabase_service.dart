/// Servicio principal de Supabase para MEYPARK
/// 
/// Este servicio maneja todas las operaciones CRUD con Supabase,
/// incluyendo caché local, manejo de errores y reconexión automática.
/// 
/// IMPORTANTE: NUNCA hardcodear datos - todo debe venir de Supabase

import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import '../data/models.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  // ========================================
  // PROPIEDADES PRIVADAS
  // ========================================
  
  late SupabaseClient _client;
  bool _isInitialized = false;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  
  // Caché local
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // ========================================
  // INICIALIZACIÓN
  // ========================================
  
  /// Inicializar el servicio de Supabase
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Verificar configuración
      if (!SupabaseConfig.isConfigValid) {
        throw Exception('Configuración de Supabase inválida');
      }
      
      // Inicializar cliente Supabase
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: SupabaseConfig.isDevelopmentMode,
      );
      
      _client = Supabase.instance.client;
      _isInitialized = true;
      _isConnected = true;
      
      print('✅ SupabaseService inicializado correctamente');
      
      // Configurar listeners de conexión
      _setupConnectionListeners();
      
      // Cargar caché local
      await _loadLocalCache();
      
    } catch (e) {
      print('❌ Error inicializando SupabaseService: $e');
      _isConnected = false;
      rethrow;
    }
  }
  
  /// Configurar listeners de conexión
  void _setupConnectionListeners() {
    // TODO: Implementar listeners de conexión cuando esté disponible en supabase_flutter
    // Por ahora, verificamos la conexión manualmente
  }
  
  /// Cargar caché local desde SharedPreferences
  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString('supabase_cache');
      if (cacheData != null) {
        final Map<String, dynamic> decoded = json.decode(cacheData);
        _cache.addAll(decoded);
        
        // Cargar timestamps
        final timestampsData = prefs.getString('supabase_cache_timestamps');
        if (timestampsData != null) {
          final Map<String, dynamic> timestamps = json.decode(timestampsData);
          timestamps.forEach((key, value) {
            _cacheTimestamps[key] = DateTime.parse(value);
          });
        }
        
        print('📦 Caché local cargado: ${_cache.length} elementos');
      }
    } catch (e) {
      print('⚠️ Error cargando caché local: $e');
    }
  }
  
  /// Guardar caché local en SharedPreferences
  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar caché
      await prefs.setString('supabase_cache', json.encode(_cache));
      
      // Guardar timestamps
      final timestampsMap = <String, String>{};
      _cacheTimestamps.forEach((key, value) {
        timestampsMap[key] = value.toIso8601String();
      });
      await prefs.setString('supabase_cache_timestamps', json.encode(timestampsMap));
      
    } catch (e) {
      print('⚠️ Error guardando caché local: $e');
    }
  }
  
  // ========================================
  // MÉTODOS DE CONEXIÓN
  // ========================================
  
  /// Verificar si está conectado
  bool get isConnected => _isConnected && _isInitialized;
  
  /// Verificar conexión con Supabase
  Future<bool> checkConnection() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Hacer una consulta simple para verificar conexión
      await _client.from('companies').select('id').limit(1);
      _isConnected = true;
      _reconnectAttempts = 0;
      return true;
      
    } catch (e) {
      print('❌ Error de conexión con Supabase: $e');
      _isConnected = false;
      return false;
    }
  }
  
  /// Reconectar automáticamente
  Future<bool> reconnect() async {
    if (_reconnectAttempts >= SupabaseConfig.maxReconnectAttempts) {
      print('❌ Máximo número de intentos de reconexión alcanzado');
      return false;
    }
    
    _reconnectAttempts++;
    print('🔄 Intentando reconectar... (intento $_reconnectAttempts)');
    
    await Future.delayed(Duration(seconds: SupabaseConfig.reconnectIntervalSeconds));
    
    return await checkConnection();
  }
  
  // ========================================
  // MÉTODOS DE CACHÉ
  // ========================================
  
  /// Obtener elemento del caché
  T? getFromCache<T>(String key) {
    if (!_cache.containsKey(key)) return null;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;
    
    // Verificar si el caché ha expirado
    final now = DateTime.now();
    final age = now.difference(timestamp).inSeconds;
    
    if (age > SupabaseConfig.cacheLifetimeSeconds) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    
    return _cache[key] as T?;
  }
  
  /// Guardar elemento en caché
  void setCache(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
    
    // Guardar en SharedPreferences de forma asíncrona
    _saveLocalCache();
  }
  
  /// Limpiar caché
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _saveLocalCache();
  }
  
  /// Invalidar caché de una tabla específica
  void invalidateTableCache(String tableName) {
    final keysToRemove = <String>[];
    _cache.keys.forEach((key) {
      if (key.startsWith('${tableName}_')) {
        keysToRemove.add(key);
      }
    });
    
    keysToRemove.forEach((key) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    });
    
    if (keysToRemove.isNotEmpty) {
      _saveLocalCache();
      print('🗑️ Caché invalidado para tabla: $tableName (${keysToRemove.length} elementos)');
    }
  }
  
  // ========================================
  // MÉTODOS CRUD GENÉRICOS
  // ========================================
  
  /// Obtener todos los registros de una tabla
  Future<List<Map<String, dynamic>>> getAll(String tableName, {String? where, List<dynamic>? params}) async {
    try {
      final cacheKey = '${tableName}_all_${where ?? 'default'}';
      
      // Verificar caché primero
      final cached = getFromCache<List<Map<String, dynamic>>>(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      // Consultar desde Supabase
      var query = _client.from(tableName).select();
      
      if (where != null) {
        query = query.eq(where, params?.first);
      }
      
      final response = await query;
      final data = List<Map<String, dynamic>>.from(response);
      
      // Guardar en caché
      setCache(cacheKey, data);
      
      return data;
      
    } catch (e) {
      print('❌ Error obteniendo datos de $tableName: $e');
      
      // Intentar obtener del caché como fallback
      final cacheKey = '${tableName}_all_${where ?? 'default'}';
      final cached = getFromCache<List<Map<String, dynamic>>>(cacheKey);
      if (cached != null) {
        print('📦 Usando datos del caché como fallback');
        return cached;
      }
      
      rethrow;
    }
  }
  
  /// Obtener un registro por ID
  Future<Map<String, dynamic>?> getById(String tableName, String id) async {
    try {
      final cacheKey = '${tableName}_$id';
      
      // Verificar caché primero
      final cached = getFromCache<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      // Consultar desde Supabase
      final response = await _client
          .from(tableName)
          .select()
          .eq('id', id)
          .single();
      
      final data = Map<String, dynamic>.from(response);
      
      // Guardar en caché
      setCache(cacheKey, data);
      
      return data;
      
    } catch (e) {
      print('❌ Error obteniendo $tableName con ID $id: $e');
      
      // Intentar obtener del caché como fallback
      final cacheKey = '${tableName}_$id';
      final cached = getFromCache<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        print('📦 Usando datos del caché como fallback');
        return cached;
      }
      
      return null;
    }
  }
  
  /// Insertar un nuevo registro
  Future<Map<String, dynamic>?> insert(String tableName, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from(tableName)
          .insert(data)
          .select()
          .single();
      
      final result = Map<String, dynamic>.from(response);
      
      // Invalidar caché de la tabla
      invalidateTableCache(tableName);
      
      print('✅ Registro insertado en $tableName: ${result['id']}');
      return result;
      
    } catch (e) {
      print('❌ Error insertando en $tableName: $e');
      rethrow;
    }
  }
  
  /// Actualizar un registro
  Future<Map<String, dynamic>?> update(String tableName, String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      
      final result = Map<String, dynamic>.from(response);
      
      // Invalidar caché de la tabla y del registro específico
      invalidateTableCache(tableName);
      _cache.remove('${tableName}_$id');
      _cacheTimestamps.remove('${tableName}_$id');
      
      print('✅ Registro actualizado en $tableName: $id');
      return result;
      
    } catch (e) {
      print('❌ Error actualizando $tableName con ID $id: $e');
      rethrow;
    }
  }
  
  /// Eliminar un registro
  Future<bool> delete(String tableName, String id) async {
    try {
      await _client
          .from(tableName)
          .delete()
          .eq('id', id);
      
      // Invalidar caché de la tabla y del registro específico
      invalidateTableCache(tableName);
      _cache.remove('${tableName}_$id');
      _cacheTimestamps.remove('${tableName}_$id');
      
      print('✅ Registro eliminado de $tableName: $id');
      return true;
      
    } catch (e) {
      print('❌ Error eliminando de $tableName con ID $id: $e');
      return false;
    }
  }
  
  // ========================================
  // MÉTODOS ESPECÍFICOS PARA MEYPARK
  // ========================================
  
  /// Obtener todas las empresas
  Future<List<Company>> getCompanies() async {
    try {
      final data = await getAll(SupabaseConfig.tableCompanies);
      return data.map((json) => Company.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo empresas: $e');
      return [];
    }
  }
  
  /// Obtener empresa por ID
  Future<Company?> getCompany(String id) async {
    try {
      final data = await getById(SupabaseConfig.tableCompanies, id);
      return data != null ? Company.fromJson(data) : null;
    } catch (e) {
      print('❌ Error obteniendo empresa $id: $e');
      return null;
    }
  }
  
  /// Obtener todas las zonas de una empresa
  Future<List<Zone>> getZonesByCompany(String companyId) async {
    try {
      final data = await getAll(SupabaseConfig.tableZones, where: 'company_id', params: [companyId]);
      return data.map((json) => Zone.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo zonas para empresa $companyId: $e');
      return [];
    }
  }
  
  /// Obtener operadores de una empresa
  Future<List<Operator>> getOperatorsByCompany(String companyId) async {
    try {
      final data = await getAll(SupabaseConfig.tableOperators, where: 'company_id', params: [companyId]);
      return data.map((json) => Operator.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo operadores para empresa $companyId: $e');
      return [];
    }
  }
  
  /// Obtener configuración completa de una empresa
  Future<Map<String, dynamic>?> getCompanyCompleteConfig(String companyId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.viewCompanyComplete)
          .select()
          .eq('id', companyId)
          .single();
      
      return Map<String, dynamic>.from(response);
      
    } catch (e) {
      print('❌ Error obteniendo configuración completa de empresa $companyId: $e');
      return null;
    }
  }
  
  /// Obtener sesiones activas
  Future<List<ParkingSession>> getActiveSessions() async {
    try {
      final data = await getAll(SupabaseConfig.tableActiveSessions);
      return data.map((json) => ParkingSession.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo sesiones activas: $e');
      return [];
    }
  }
  
  /// Crear nueva sesión
  Future<ParkingSession?> createSession(ParkingSession session) async {
    try {
      final data = await insert(SupabaseConfig.tableActiveSessions, session.toJson());
      return data != null ? ParkingSession.fromJson(data) : null;
    } catch (e) {
      print('❌ Error creando sesión: $e');
      return null;
    }
  }
  
  /// Actualizar sesión
  Future<Session?> updateSession(String sessionId, Map<String, dynamic> updates) async {
    try {
      final data = await update(SupabaseConfig.tableActiveSessions, sessionId, updates);
      return data != null ? Session.fromJson(data) : null;
    } catch (e) {
      print('❌ Error actualizando sesión $sessionId: $e');
      return null;
    }
  }
  
  // ========================================
  // MÉTODOS DE UTILIDAD
  // ========================================
  
  /// Obtener cliente Supabase
  SupabaseClient get client => _client;
  
  /// Obtener estadísticas del caché
  Map<String, dynamic> getCacheStats() {
    return {
      'totalItems': _cache.length,
      'totalSize': _cache.toString().length,
      'oldestItem': _cacheTimestamps.values.isNotEmpty 
          ? _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      'newestItem': _cacheTimestamps.values.isNotEmpty
          ? _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }
  
  /// Limpiar caché expirado
  void cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      final age = now.difference(timestamp).inSeconds;
      if (age > SupabaseConfig.cacheLifetimeSeconds) {
        expiredKeys.add(key);
      }
    });
    
    expiredKeys.forEach((key) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    });
    
    if (expiredKeys.isNotEmpty) {
      _saveLocalCache();
      print('🧹 Caché expirado limpiado: ${expiredKeys.length} elementos');
    }
  }
}
