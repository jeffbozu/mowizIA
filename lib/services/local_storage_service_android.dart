import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';

class LocalStorageService {
  static const String _configKey = 'app_config';
  static const String _sessionsKey = 'app_sessions';

  // Cargar configuración
  static Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);
      
      if (configJson != null) {
        final config = jsonDecode(configJson) as Map<String, dynamic>;
        
        // Cargar empresa actual
        if (config['currentCompany'] != null) {
          AppState.setCurrentCompany(Company.fromJson(config['currentCompany']));
        }
        
        // Cargar configuración de accesibilidad
        AppState.simplifiedMode = config['simplifiedMode'] ?? false;
        AppState.darkMode = config['darkMode'] ?? false;
        AppState.currentLanguage = config['currentLanguage'] ?? 'es-ES';
        
        print('Configuración cargada desde SharedPreferences');
      }
    } catch (e) {
      print('Error cargando configuración: $e');
    }
  }

  // Guardar configuración
  static Future<void> saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final config = {
        'currentCompany': AppState.currentCompany?.toJson(),
        'simplifiedMode': AppState.simplifiedMode,
        'darkMode': AppState.darkMode,
        'currentLanguage': AppState.currentLanguage,
        'savedAt': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_configKey, jsonEncode(config));
      print('Configuración guardada en SharedPreferences');
    } catch (e) {
      print('Error guardando configuración: $e');
    }
  }

  // Cargar sesiones
  static Future<void> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey);
      
      if (sessionsJson != null) {
        final sessionsData = jsonDecode(sessionsJson) as Map<String, dynamic>;
        AppState.activeSessions.clear();
        
        for (final entry in sessionsData.entries) {
          AppState.activeSessions[entry.key] = Session.fromJson(entry.value);
        }
        
        print('Sesiones cargadas: ${AppState.activeSessions.length}');
      }
    } catch (e) {
      print('Error cargando sesiones: $e');
    }
  }

  // Guardar sesiones
  static Future<void> saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsData = <String, dynamic>{};
      
      for (final entry in AppState.activeSessions.entries) {
        sessionsData[entry.key] = entry.value.toJson();
      }
      
      await prefs.setString(_sessionsKey, jsonEncode(sessionsData));
      print('Sesiones guardadas: ${AppState.activeSessions.length}');
    } catch (e) {
      print('Error guardando sesiones: $e');
    }
  }

  // Limpiar todos los datos
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_configKey);
      await prefs.remove(_sessionsKey);
      
      // Limpiar estado en memoria
      AppState.companies.clear();
      AppState.operators.clear();
      AppState.zones.clear();
      AppState.activeSessions.clear();
      AppState.currentCompany = null;
      AppState.currentOperatorId = null;
      
      print('Todos los datos locales eliminados');
    } catch (e) {
      print('Error al limpiar datos: $e');
    }
  }

  // Exportar configuración para backup
  static Future<Map<String, dynamic>> exportConfig() async {
    return {
      'currentCompany': AppState.currentCompany?.toJson(),
      'companies': AppState.companies.map((key, value) => MapEntry(key, value.toJson())),
      'operators': AppState.operators.map((key, value) => MapEntry(key, value.toJson())),
      'zones': AppState.zones.map((key, value) => MapEntry(key, value.toJson())),
      'activeSessions': AppState.activeSessions.map((key, value) => MapEntry(key, value.toJson())),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  // Importar configuración desde backup
  static Future<void> importConfig(Map<String, dynamic> config) async {
    try {
      // Limpiar datos actuales
      AppState.companies.clear();
      AppState.operators.clear();
      AppState.zones.clear();
      AppState.activeSessions.clear();
      
      // Importar empresa
      if (config['currentCompany'] != null) {
        AppState.setCurrentCompany(Company.fromJson(config['currentCompany']));
      }
      
      // Importar empresas
      if (config['companies'] != null) {
        final companiesMap = Map<String, dynamic>.from(config['companies']);
        for (final entry in companiesMap.entries) {
          AppState.addCompany(Company.fromJson(entry.value));
        }
      }
      
      // Importar operadores
      if (config['operators'] != null) {
        final operatorsMap = Map<String, dynamic>.from(config['operators']);
        for (final entry in operatorsMap.entries) {
          AppState.addOperator(Operator.fromJson(entry.value));
        }
      }
      
      // Importar zonas
      if (config['zones'] != null) {
        final zonesMap = Map<String, dynamic>.from(config['zones']);
        for (final entry in zonesMap.entries) {
          AppState.addZone(Zone.fromJson(entry.value));
        }
      }
      
      // Importar sesiones
      if (config['activeSessions'] != null) {
        final sessionsMap = Map<String, dynamic>.from(config['activeSessions']);
        for (final entry in sessionsMap.entries) {
          AppState.activeSessions[entry.key] = Session.fromJson(entry.value);
        }
      }
      
      // Guardar configuración importada
      await saveConfig();
      await saveSessions();
      
      print('Configuración importada exitosamente');
    } catch (e) {
      print('Error al importar configuración: $e');
    }
  }
}
