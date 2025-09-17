import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Servicio de almacenamiento compatible con Web y Desktop
class StorageService {
  static const String _preferencesKey = 'meypark_preferences';
  
  /// Guardar datos de forma compatible con Web y Desktop
  static Future<void> saveData(String key, Map<String, dynamic> data) async {
    try {
      if (kIsWeb) {
        // Para Web: usar localStorage
        final jsonString = jsonEncode(data);
        html.window.localStorage[key] = jsonString;
        print('💾 Datos guardados en localStorage: $key');
      } else {
        // Para Desktop: usar path_provider
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$key.json');
        await file.writeAsString(jsonEncode(data));
        print('💾 Datos guardados en archivo: ${file.path}');
      }
    } catch (e) {
      print('❌ Error guardando datos: $e');
    }
  }
  
  /// Cargar datos de forma compatible con Web y Desktop
  static Future<Map<String, dynamic>?> loadData(String key) async {
    try {
      if (kIsWeb) {
        // Para Web: usar localStorage
        final jsonString = html.window.localStorage[key];
        if (jsonString != null) {
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          print('📂 Datos cargados desde localStorage: $key');
          return data;
        }
      } else {
        // Para Desktop: usar path_provider
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$key.json');
        if (await file.exists()) {
          final jsonString = await file.readAsString();
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          print('📂 Datos cargados desde archivo: ${file.path}');
          return data;
        }
      }
    } catch (e) {
      print('❌ Error cargando datos: $e');
    }
    return null;
  }
  
  /// Guardar preferencias de accesibilidad
  static Future<void> saveAccessibilityPreferences(Map<String, dynamic> preferences) async {
    await saveData(_preferencesKey, preferences);
  }
  
  /// Cargar preferencias de accesibilidad
  static Future<Map<String, dynamic>?> loadAccessibilityPreferences() async {
    return await loadData(_preferencesKey);
  }
  
  /// Limpiar todos los datos
  static Future<void> clearAllData() async {
    try {
      if (kIsWeb) {
        // Para Web: limpiar localStorage
        html.window.localStorage.clear();
        print('🗑️ localStorage limpiado');
      } else {
        // Para Desktop: eliminar archivos
        final directory = await getApplicationDocumentsDirectory();
        final files = directory.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            await file.delete();
          }
        }
        print('🗑️ Archivos de datos eliminados');
      }
    } catch (e) {
      print('❌ Error limpiando datos: $e');
    }
  }
}

/// Detectar si estamos en Web - usar la función de Flutter
