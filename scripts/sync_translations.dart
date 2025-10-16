#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para sincronizar traducciones entre empresas
/// 
/// Este script permite copiar traducciones de una empresa a otra
/// y sincronizar el caché de traducciones.

class TranslationSync {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b2FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';

  static Future<void> main(List<String> args) async {
    print('🔄 INICIANDO SINCRONIZACIÓN DE TRADUCCIONES');
    print('=' * 50);
    
    final sync = TranslationSync();
    
    try {
      if (args.isEmpty) {
        print('Uso: dart run scripts/sync_translations.dart <comando>');
        print('');
        print('Comandos disponibles:');
        print('  copy <empresa_origen> <empresa_destino> - Copiar traducciones');
        print('  cache <empresa_id> - Regenerar caché de traducciones');
        print('  list - Listar todas las empresas');
        return;
      }
      
      final command = args[0];
      
      switch (command) {
        case 'copy':
          if (args.length < 3) {
            print('❌ Error: Se requieren empresa_origen y empresa_destino');
            return;
          }
          await sync.copyTranslations(args[1], args[2]);
          break;
          
        case 'cache':
          if (args.length < 2) {
            print('❌ Error: Se requiere empresa_id');
            return;
          }
          await sync.regenerateCache(args[1]);
          break;
          
        case 'list':
          await sync.listCompanies();
          break;
          
        default:
          print('❌ Comando no reconocido: $command');
      }
      
    } catch (e) {
      print('\n❌ ERROR EN SINCRONIZACIÓN: $e');
      exit(1);
    }
  }

  /// Copiar traducciones de una empresa a otra
  Future<void> copyTranslations(String sourceCompany, String targetCompany) async {
    print('📋 Copiando traducciones de $sourceCompany a $targetCompany');
    
    // Obtener traducciones de la empresa origen
    final sourceTranslations = await _getTranslations(sourceCompany);
    if (sourceTranslations.isEmpty) {
      print('❌ No se encontraron traducciones para $sourceCompany');
      return;
    }
    
    print('   📊 Encontradas ${sourceTranslations.length} traducciones');
    
    // Copiar traducciones a la empresa destino
    int copied = 0;
    for (final translation in sourceTranslations) {
      try {
        await _createTranslation(
          targetCompany,
          translation['screen'],
          translation['element'],
          translation['language'],
          translation['text_value'],
          translation['is_enabled'] ?? true,
        );
        copied++;
      } catch (e) {
        print('   ⚠️ Error copiando traducción: $e');
      }
    }
    
    print('   ✅ $copied traducciones copiadas exitosamente');
    
    // Regenerar caché para la empresa destino
    await regenerateCache(targetCompany);
  }

  /// Regenerar caché de traducciones para una empresa
  Future<void> regenerateCache(String companyId) async {
    print('🔄 Regenerando caché de traducciones para $companyId');
    
    // Obtener todas las traducciones de la empresa
    final translations = await _getTranslations(companyId);
    
    // Agrupar por idioma
    final Map<String, Map<String, String>> translationsByLanguage = {};
    
    for (final translation in translations) {
      final language = translation['language'] as String;
      final screen = translation['screen'] as String;
      final element = translation['element'] as String;
      final text = translation['text_value'] as String;
      
      if (!translationsByLanguage.containsKey(language)) {
        translationsByLanguage[language] = {};
      }
      
      translationsByLanguage[language]!['${screen}.${element}'] = text;
    }
    
    // Actualizar caché para cada idioma
    for (final entry in translationsByLanguage.entries) {
      final language = entry.key;
      final translationsJson = entry.value;
      
      try {
        await _updateCache(companyId, language, translationsJson);
        print('   ✅ Caché actualizado para idioma: $language');
      } catch (e) {
        print('   ❌ Error actualizando caché para $language: $e');
      }
    }
    
    print('   🎯 Caché regenerado para $companyId');
  }

  /// Listar todas las empresas
  Future<void> listCompanies() async {
    print('🏢 Listando todas las empresas:');
    
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/companies'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );
      
      if (response.statusCode == 200) {
        final companies = json.decode(response.body) as List;
        
        for (final company in companies) {
          final id = company['id'];
          final name = company['name'];
          final isActive = company['is_active'] ? '✅' : '❌';
          print('   $isActive $id - $name');
        }
      } else {
        print('   ❌ Error obteniendo empresas: ${response.statusCode}');
      }
    } catch (e) {
      print('   ❌ Error: $e');
    }
  }

  // Métodos auxiliares

  Future<List<Map<String, dynamic>>> _getTranslations(String companyId) async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/ui_texts?company_id=eq.$companyId'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error obteniendo traducciones: ${response.statusCode}');
    }
  }

  Future<void> _createTranslation(String companyId, String screen, String element, String language, String text, bool enabled) async {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/ui_texts'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'company_id': companyId,
        'screen': screen,
        'element': element,
        'language': language,
        'text_value': text,
        'is_enabled': enabled,
      }),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Error creando traducción: ${response.statusCode}');
    }
  }

  Future<void> _updateCache(String companyId, String language, Map<String, String> translations) async {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/ui_translations_cache'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'company_id': companyId,
        'language': language,
        'translations_json': translations,
        'last_updated': DateTime.now().toIso8601String(),
      }),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Error actualizando caché: ${response.statusCode}');
    }
  }
}
