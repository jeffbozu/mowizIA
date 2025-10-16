#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Script para insertar datos básicos en Supabase
void main(List<String> args) async {
  await BasicDataInserter.main(args);
}

class BasicDataInserter {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b3FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';

  static Future<void> main(List<String> args) async {
    print('🚀 INSERTANDO DATOS BÁSICOS EN SUPABASE');
    print('=====================================');

    try {
      // Insertar empresa principal
      await insertCompany();
      
      // Insertar operador
      await insertOperator();
      
      // Insertar zona
      await insertZone();
      
      print('\n✅ DATOS BÁSICOS INSERTADOS EXITOSAMENTE');
      
    } catch (e) {
      print('\n❌ ERROR INSERTANDO DATOS: $e');
      exit(1);
    }
  }

  static Future<void> insertCompany() async {
    print('\n🏢 Insertando empresa...');
    
    final companyData = {
      'id': '550e8400-e29b-41d4-a716-446655440000', // UUID válido
      'name': 'MOWIZ',
      'primary_color': '#2196F3',
      'background_color': '#FFFFFF',
      'logo_url': 'https://example.com/logo.png',
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/companies'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: jsonEncode(companyData),
    );

    print('   📊 Status Code: ${response.statusCode}');
    if (response.statusCode == 201) {
      print('   ✅ Empresa insertada correctamente');
    } else {
      print('   ❌ Error: ${response.body}');
    }
  }

  static Future<void> insertOperator() async {
    print('\n👤 Insertando operador...');
    
    final operatorData = {
      'id': '550e8400-e29b-41d4-a716-446655440001', // UUID válido
      'username': 'admin',
      'password_hash': '\$2b\$10\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
      'role': 'admin',
      'company_id': '550e8400-e29b-41d4-a716-446655440000',
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/operators'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: jsonEncode(operatorData),
    );

    print('   📊 Status Code: ${response.statusCode}');
    if (response.statusCode == 201) {
      print('   ✅ Operador insertado correctamente');
    } else {
      print('   ❌ Error: ${response.body}');
    }
  }

  static Future<void> insertZone() async {
    print('\n🅿️ Insertando zona...');
    
    final zoneData = {
      'id': '550e8400-e29b-41d4-a716-446655440002', // UUID válido
      'name': 'Zona Centro',
      'price_per_hour': 1.20,
      'max_duration': 480, // 8 horas en minutos
      'time_increment': 15, // 15 minutos
      'min_time': 15, // 15 minutos
      'company_id': '550e8400-e29b-41d4-a716-446655440000',
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/zones'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal',
      },
      body: jsonEncode(zoneData),
    );

    print('   📊 Status Code: ${response.statusCode}');
    if (response.statusCode == 201) {
      print('   ✅ Zona insertada correctamente');
    } else {
      print('   ❌ Error: ${response.body}');
    }
  }
}
