import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data/models.dart';

class LocalStorageService {
  static const String _configFileName = 'meypark_config.json';
  static const String _sessionsFileName = 'meypark_sessions.json';
  
  // Guardar configuración completa
  static Future<void> saveConfig() async {
    try {
      final config = {
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
        'kioscoId': AppState.kioscoId,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      final file = await _getConfigFile();
      await file.writeAsString(jsonEncode(config));
      print('Configuración guardada localmente');
    } catch (e) {
      print('Error al guardar configuración: $e');
    }
  }
  
  // Cargar configuración
  static Future<void> loadConfig() async {
    try {
      final file = await _getConfigFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final config = jsonDecode(content);
        
        // Cargar empresa actual
        if (config['currentCompany'] != null) {
          AppState.setCurrentCompany(Company.fromJson(config['currentCompany']));
        }
        
        // Cargar operadores
        if (config['operators'] != null) {
          final operatorsMap = Map<String, dynamic>.from(config['operators']);
          for (final entry in operatorsMap.entries) {
            AppState.addOperator(Operator.fromJson(entry.value));
          }
        }
        
        // Cargar zonas
        if (config['zones'] != null) {
          final zonesMap = Map<String, dynamic>.from(config['zones']);
          for (final entry in zonesMap.entries) {
            AppState.addZone(Zone.fromJson(entry.value));
          }
        }
        
        // Cargar configuración de accesibilidad
        AppState.darkMode = config['darkMode'] ?? false;
        AppState.highContrast = config['highContrast'] ?? false;
        AppState.currentLanguage = config['currentLanguage'] ?? 'es-ES';
        AppState.fontSize = config['fontSize'] ?? 'normal';
        AppState.reduceAnimations = config['reduceAnimations'] ?? false;
        AppState.kioscoId = config['kioscoId'];
        
        print('Configuración cargada desde almacenamiento local');
      }
    } catch (e) {
      print('Error al cargar configuración: $e');
    }
  }
  
  // Guardar sesiones activas
  static Future<void> saveSessions() async {
    try {
      final sessions = AppState.activeSessions.map((key, value) => 
          MapEntry(key, value.toJson()));
      
      final file = await _getSessionsFile();
      await file.writeAsString(jsonEncode(sessions));
      print('Sesiones guardadas localmente');
    } catch (e) {
      print('Error al guardar sesiones: $e');
    }
  }
  
  // Cargar sesiones activas
  static Future<void> loadSessions() async {
    try {
      final file = await _getSessionsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final sessionsMap = Map<String, dynamic>.from(jsonDecode(content));
        
        for (final entry in sessionsMap.entries) {
          AppState.activeSessions[entry.key] = Session.fromJson(entry.value);
        }
        
        print('Sesiones cargadas desde almacenamiento local');
      }
    } catch (e) {
      print('Error al cargar sesiones: $e');
    }
  }
  
  // Obtener archivo de configuración
  static Future<File> _getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_configFileName');
  }
  
  // Obtener archivo de sesiones
  static Future<File> _getSessionsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_sessionsFileName');
  }
  
  // Limpiar todos los datos
  static Future<void> clearAllData() async {
    try {
      final configFile = await _getConfigFile();
      final sessionsFile = await _getSessionsFile();
      
      if (await configFile.exists()) {
        await configFile.delete();
      }
      
      if (await sessionsFile.exists()) {
        await sessionsFile.delete();
      }
      
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
