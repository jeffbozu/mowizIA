#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para verificar las API keys de Supabase
void main(List<String> args) async {
  await ApiKeyVerifier.main(args);
}

class ApiKeyVerifier {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  
  // Keys originales proporcionadas por el usuario
  static const String originalAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b3FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';
  static const String originalServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b3FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDQ3OTUxNCwiZXhwIjoyMDc2MDU1NTE0fQ.CV7qGEl0GvReQJW8aWZ7U_0SWufzXBIW4QLhgsm9foY';

  static Future<void> main(List<String> args) async {
    print('🔑 VERIFICANDO API KEYS DE SUPABASE');
    print('=====================================');

    try {
      // Test 1: Verificar anon key
      print('\n🔍 TEST 1: Verificando anon key...');
      await testAnonKey();
      
      // Test 2: Verificar service key
      print('\n🔍 TEST 2: Verificando service key...');
      await testServiceKey();
      
      // Test 3: Verificar tablas
      print('\n🔍 TEST 3: Verificando tablas...');
      await testTables();
      
      print('\n✅ VERIFICACIÓN COMPLETADA');
      
    } catch (e) {
      print('\n❌ ERROR EN VERIFICACIÓN: $e');
      exit(1);
    }
  }

  static Future<void> testAnonKey() async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/companies?select=*'),
      headers: {
        'apikey': originalAnonKey,
        'Authorization': 'Bearer $originalAnonKey',
        'Content-Type': 'application/json',
      },
    );

    print('   📊 Status Code: ${response.statusCode}');
    print('   📊 Response: ${response.body}');

    if (response.statusCode == 200) {
      print('   ✅ Anon key funciona correctamente');
      final data = jsonDecode(response.body);
      print('   📋 Empresas encontradas: ${data.length}');
    } else {
      print('   ❌ Anon key no funciona');
    }
  }

  static Future<void> testServiceKey() async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/companies?select=*'),
      headers: {
        'apikey': originalServiceKey,
        'Authorization': 'Bearer $originalServiceKey',
        'Content-Type': 'application/json',
      },
    );

    print('   📊 Status Code: ${response.statusCode}');
    print('   📊 Response: ${response.body}');

    if (response.statusCode == 200) {
      print('   ✅ Service key funciona correctamente');
      final data = jsonDecode(response.body);
      print('   📋 Empresas encontradas: ${data.length}');
    } else {
      print('   ❌ Service key no funciona');
    }
  }

  static Future<void> testTables() async {
    final tables = [
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
    ];

    for (final table in tables) {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/$table?select=*&limit=1'),
        headers: {
          'apikey': originalAnonKey,
          'Authorization': 'Bearer $originalAnonKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('   ✅ Tabla $table: OK');
      } else {
        print('   ❌ Tabla $table: Error ${response.statusCode}');
      }
    }
  }
}
