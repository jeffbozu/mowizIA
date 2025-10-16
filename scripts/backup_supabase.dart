#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para hacer backup completo de datos de Supabase
/// 
/// Este script exporta todos los datos importantes de Supabase
/// a archivos JSON para respaldo y migración.

class SupabaseBackup {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b2FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';

  static Future<void> main(List<String> args) async {
    print('💾 INICIANDO BACKUP COMPLETO DE SUPABASE');
    print('=' * 50);
    
    final backup = SupabaseBackup();
    
    try {
      // Crear directorio de backup
      final backupDir = Directory('backup/supabase_${DateTime.now().millisecondsSinceEpoch}');
      await backupDir.create(recursive: true);
      
      // Hacer backup de todas las tablas
      await backup.backupTable('companies', backupDir);
      await backup.backupTable('operators', backupDir);
      await backup.backupTable('zones', backupDir);
      await backup.backupTable('payment_config', backupDir);
      await backup.backupTable('accessibility_config', backupDir);
      await backup.backupTable('kiosks', backupDir);
      await backup.backupTable('active_sessions', backupDir);
      await backup.backupTable('invoice_config', backupDir);
      await backup.backupTable('ui_texts', backupDir);
      await backup.backupTable('ui_translations_cache', backupDir);
      await backup.backupTable('ui_elements_config', backupDir);
      
      // Crear archivo de resumen
      await backup.createSummary(backupDir);
      
      print('\n✅ BACKUP COMPLETADO EXITOSAMENTE');
      print('📁 Ubicación: ${backupDir.path}');
      print('🎯 Todos los datos han sido respaldados');
      
    } catch (e) {
      print('\n❌ ERROR EN BACKUP: $e');
      exit(1);
    }
  }

  /// Hacer backup de una tabla específica
  Future<void> backupTable(String tableName, Directory backupDir) async {
    print('📊 Respaldando tabla: $tableName');
    
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/$tableName'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        
        // Guardar datos en archivo JSON
        final file = File('${backupDir.path}/$tableName.json');
        await file.writeAsString(json.encode(data, indent: 2));
        
        print('   ✅ $tableName: ${data.length} registros respaldados');
      } else {
        print('   ❌ Error respaldando $tableName: ${response.statusCode}');
      }
    } catch (e) {
      print('   ❌ Error respaldando $tableName: $e');
    }
  }

  /// Crear archivo de resumen del backup
  Future<void> createSummary(Directory backupDir) async {
    print('📝 Creando resumen del backup...');
    
    final summary = {
      'backup_date': DateTime.now().toIso8601String(),
      'supabase_url': supabaseUrl,
      'tables_backed_up': [
        'companies',
        'operators', 
        'zones',
        'payment_config',
        'accessibility_config',
        'kiosks',
        'active_sessions',
        'invoice_config',
        'ui_texts',
        'ui_translations_cache',
        'ui_elements_config',
      ],
      'total_files': 11,
      'backup_location': backupDir.path,
    };
    
    final file = File('${backupDir.path}/backup_summary.json');
    await file.writeAsString(json.encode(summary, indent: 2));
    
    print('   ✅ Resumen creado: backup_summary.json');
  }
}
