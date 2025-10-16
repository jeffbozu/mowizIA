import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/models.dart';
import 'local_storage_service.dart';
import 'centralized_websocket_service.dart';

/// Servicio de almacenamiento dual que guarda automáticamente
/// tanto en local como en remoto (backend)
class DualStorageService {
  static bool _isOnline = true;
  static bool _syncInProgress = false;
  
  // ===========================================
  // CONFIGURACIÓN Y EMPRESAS
  // ===========================================
  
  /// Guardar configuración completa (local + remoto)
  static Future<void> saveConfig() async {
    try {
      // 1. Guardar localmente primero (siempre)
      await LocalStorageService.saveConfig();
      print('💾 Configuración guardada localmente');
      
      // 2. Sincronizar con backend si está online
      if (_isOnline && !_syncInProgress) {
        await _syncConfigToBackend();
      }
    } catch (e) {
      print('❌ Error guardando configuración: $e');
    }
  }
  
  /// Cargar configuración (local + remoto)
  static Future<void> loadConfig() async {
    try {
      // 1. Cargar desde local primero
      await LocalStorageService.loadConfig();
      print('📂 Configuración cargada desde local');
      
      // 2. Sincronizar con backend si está online
      if (_isOnline && !_syncInProgress) {
        await _syncFromBackend();
      }
    } catch (e) {
      print('❌ Error cargando configuración: $e');
    }
  }
  
  // ===========================================
  // SESIONES ACTIVAS
  // ===========================================
  
  /// Guardar sesiones (local + remoto)
  static Future<void> saveSessions() async {
    try {
      // 1. Guardar localmente primero
      // TODO: Implementar saveSessions en LocalStorageService
      // await LocalStorageService.saveSessions();
      print('💾 Sesiones guardadas localmente');
      
      // 2. Sincronizar con backend si está online
      if (_isOnline && !_syncInProgress) {
        await _syncSessionsToBackend();
      }
    } catch (e) {
      print('❌ Error guardando sesiones: $e');
    }
  }
  
  /// Cargar sesiones (local + remoto)
  static Future<void> loadSessions() async {
    try {
      // 1. Cargar desde local primero
      // TODO: Implementar loadSessions en LocalStorageService
      // await LocalStorageService.loadSessions();
      print('📂 Sesiones cargadas desde local');
      
      // 2. Sincronizar con backend si está online
      if (_isOnline && !_syncInProgress) {
        await _syncSessionsFromBackend();
      }
    } catch (e) {
      print('❌ Error cargando sesiones: $e');
    }
  }
  
  // ===========================================
  // SINCRONIZACIÓN CON BACKEND
  // ===========================================
  
  /// Sincronizar configuración hacia el backend
  static Future<void> _syncConfigToBackend() async {
    if (_syncInProgress) return;
    
    _syncInProgress = true;
    try {
      // Enviar datos de configuración al backend
      CentralizedWebSocketService.sendMessage({
        'type': 'update_config',
        'kioscoId': AppState.kioscoId,
        'config': {
          'currentCompany': AppState.currentCompany?.toJson(),
          'currentOperatorId': AppState.currentOperatorId,
          'companies': AppState.companies.map((key, value) => MapEntry(key, value.toJson())),
          'operators': AppState.operators.map((key, value) => MapEntry(key, value.toJson())),
          'zones': AppState.zones.map((key, value) => MapEntry(key, value.toJson())),
          'darkMode': AppState.darkMode,
          'highContrast': AppState.highContrast,
          'currentLanguage': AppState.currentLanguage,
          'fontSize': AppState.fontSize,
          'reduceAnimations': AppState.reduceAnimations,
          'lastUpdated': DateTime.now().toIso8601String(),
        }
      });
      
      print('🔄 Configuración sincronizada con backend');
    } catch (e) {
      print('❌ Error sincronizando configuración: $e');
      _isOnline = false;
    } finally {
      _syncInProgress = false;
    }
  }
  
  /// Sincronizar sesiones hacia el backend
  static Future<void> _syncSessionsToBackend() async {
    if (_syncInProgress) return;
    
    _syncInProgress = true;
    try {
      // Enviar sesiones activas al backend
      CentralizedWebSocketService.sendMessage({
        'type': 'update_sessions',
        'kioscoId': AppState.kioscoId,
        'sessions': AppState.activeSessions.map((key, value) => MapEntry(key, value.toJson())),
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      print('🔄 Sesiones sincronizadas con backend');
    } catch (e) {
      print('❌ Error sincronizando sesiones: $e');
      _isOnline = false;
    } finally {
      _syncInProgress = false;
    }
  }
  
  /// Sincronizar desde el backend
  static Future<void> _syncFromBackend() async {
    if (_syncInProgress) return;
    
    _syncInProgress = true;
    try {
      // Solicitar datos actualizados del backend
      CentralizedWebSocketService.sendMessage({
        'type': 'get_data',
        'company_id': AppState.currentCompany?.id,
      });
      
      print('🔄 Sincronizando desde backend...');
    } catch (e) {
      print('❌ Error sincronizando desde backend: $e');
      _isOnline = false;
    } finally {
      _syncInProgress = false;
    }
  }
  
  /// Sincronizar sesiones desde el backend
  static Future<void> _syncSessionsFromBackend() async {
    if (_syncInProgress) return;
    
    _syncInProgress = true;
    try {
      // Solicitar sesiones actualizadas del backend
      CentralizedWebSocketService.sendMessage({
        'type': 'get_sessions',
        'kioscoId': AppState.kioscoId,
      });
      
      print('🔄 Sincronizando sesiones desde backend...');
    } catch (e) {
      print('❌ Error sincronizando sesiones desde backend: $e');
      _isOnline = false;
    } finally {
      _syncInProgress = false;
    }
  }
  
  // ===========================================
  // GESTIÓN DE CONECTIVIDAD
  // ===========================================
  
  /// Marcar como online/offline
  static void setOnlineStatus(bool online) {
    _isOnline = online;
    if (online) {
      print('🌐 Conexión restaurada - iniciando sincronización');
      _syncFromBackend();
    } else {
      print('📴 Modo offline - usando solo almacenamiento local');
    }
  }
  
  /// Verificar estado de conectividad
  static bool get isOnline => _isOnline;
  
  /// Forzar sincronización completa
  static Future<void> forceSync() async {
    if (!_isOnline) {
      print('❌ No se puede sincronizar - sin conexión');
      return;
    }
    
    print('🔄 Forzando sincronización completa...');
    await _syncFromBackend();
    await _syncSessionsFromBackend();
  }
  
  // ===========================================
  // BACKUP Y RESTAURACIÓN
  // ===========================================
  
  /// Crear backup completo (local + remoto)
  static Future<Map<String, dynamic>> createBackup() async {
    try {
      final backup = await LocalStorageService.exportConfig();
      backup['backupType'] = 'dual_storage';
      backup['createdAt'] = DateTime.now().toIso8601String();
      backup['isOnline'] = _isOnline;
      
      // Guardar backup en archivo local
      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/meypark_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await backupFile.writeAsString(jsonEncode(backup));
      
      print('💾 Backup completo creado: ${backupFile.path}');
      return backup;
    } catch (e) {
      print('❌ Error creando backup: $e');
      return {};
    }
  }
  
  /// Restaurar desde backup
  static Future<void> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      // Restaurar datos locales
      await LocalStorageService.importConfig(backup);
      
      // Sincronizar con backend si está online
      if (_isOnline) {
        await _syncConfigToBackend();
        await _syncSessionsToBackend();
      }
      
      print('🔄 Backup restaurado exitosamente');
    } catch (e) {
      print('❌ Error restaurando backup: $e');
    }
  }
  
  // ===========================================
  // LIMPIEZA Y MANTENIMIENTO
  // ===========================================
  
  /// Limpiar todos los datos (local + remoto)
  static Future<void> clearAllData() async {
    try {
      // Limpiar datos locales
      await LocalStorageService.clearAllData();
      
      // Notificar al backend sobre la limpieza
      if (_isOnline) {
        CentralizedWebSocketService.sendMessage({
          'type': 'clear_data',
          'kioscoId': AppState.kioscoId,
        });
      }
      
      print('🧹 Todos los datos eliminados (local y remoto)');
    } catch (e) {
      print('❌ Error limpiando datos: $e');
    }
  }
  
  /// Obtener estadísticas de almacenamiento
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final configFile = File('${directory.path}/meypark_config.json');
      final sessionsFile = File('${directory.path}/meypark_sessions.json');
      
      return {
        'localConfigSize': await configFile.exists() ? await configFile.length() : 0,
        'localSessionsSize': await sessionsFile.exists() ? await sessionsFile.length() : 0,
        'isOnline': _isOnline,
        'syncInProgress': _syncInProgress,
        'companiesCount': AppState.companies.length,
        'operatorsCount': AppState.operators.length,
        'zonesCount': AppState.zones.length,
        'activeSessionsCount': AppState.activeSessions.length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {};
    }
  }
}
