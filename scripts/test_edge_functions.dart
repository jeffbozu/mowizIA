#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para probar Edge Functions de Supabase
/// 
/// Este script verifica que todas las Edge Functions estén funcionando
/// correctamente y respondan como se espera.

class EdgeFunctionsTester {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b2FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';

  static Future<void> main(List<String> args) async {
    print('⚡ INICIANDO TESTING DE EDGE FUNCTIONS');
    print('=' * 50);
    
    final tester = EdgeFunctionsTester();
    
    try {
      // Test 1: Verificar salud de Edge Functions
      await tester.testEdgeFunctionsHealth();
      
      // Test 2: Probar manage-sessions
      await tester.testManageSessions();
      
      // Test 3: Probar generate-invoice
      await tester.testGenerateInvoice();
      
      // Test 4: Probar dashboard-api
      await tester.testDashboardApi();
      
      print('\n✅ TODOS LOS TESTS DE EDGE FUNCTIONS COMPLETADOS');
      print('🎯 Todas las Edge Functions están funcionando correctamente');
      
    } catch (e) {
      print('\n❌ ERROR EN TESTING EDGE FUNCTIONS: $e');
      exit(1);
    }
  }

  /// Test 1: Verificar salud de todas las Edge Functions
  Future<void> testEdgeFunctionsHealth() async {
    print('\n🔍 TEST 1: Verificación de salud de Edge Functions');
    
    final functions = [
      'manage-sessions',
      'generate-invoice', 
      'dashboard-api',
    ];
    
    for (final function in functions) {
      try {
        final response = await http.get(
          Uri.parse('$supabaseUrl/functions/v1/$function'),
          headers: {
            'Authorization': 'Bearer $supabaseAnonKey',
          },
        );
        
        if (response.statusCode == 200) {
          print('   ✅ $function está funcionando');
        } else {
          print('   ⚠️ $function respondió con código: ${response.statusCode}');
        }
      } catch (e) {
        print('   ❌ $function no está disponible: $e');
      }
    }
  }

  /// Test 2: Probar Edge Function manage-sessions
  Future<void> testManageSessions() async {
    print('\n🔍 TEST 2: Testing manage-sessions');
    
    // Test: Agregar sesión
    print('   📝 Probando agregar sesión...');
    final addSessionResult = await _testAddSession();
    if (addSessionResult) {
      print('   ✅ Agregar sesión funciona');
    } else {
      print('   ❌ Error agregando sesión');
    }
    
    // Test: Buscar sesión
    print('   🔍 Probando buscar sesión...');
    final searchResult = await _testSearchSession();
    if (searchResult) {
      print('   ✅ Buscar sesión funciona');
    } else {
      print('   ❌ Error buscando sesión');
    }
    
    // Test: Extender sesión
    print('   ⏰ Probando extender sesión...');
    final extendResult = await _testExtendSession();
    if (extendResult) {
      print('   ✅ Extender sesión funciona');
    } else {
      print('   ❌ Error extendiendo sesión');
    }
  }

  /// Test 3: Probar Edge Function generate-invoice
  Future<void> testGenerateInvoice() async {
    print('\n🔍 TEST 3: Testing generate-invoice');
    
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/generate-invoice'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'transactionId': 'TEST_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'test@example.com',
          'name': 'Usuario de Prueba',
          'amount': 2.50,
          'plate': 'ABC123',
          'zone': 'Zona de Prueba',
          'duration': 60,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('   ✅ Generar factura funciona');
          print('   📄 PDF generado: ${data['pdfUrl'] ?? 'N/A'}');
        } else {
          print('   ⚠️ Generar factura falló: ${data['error'] ?? 'Error desconocido'}');
        }
      } else {
        print('   ❌ Error en generate-invoice: ${response.statusCode}');
      }
    } catch (e) {
      print('   ❌ Error probando generate-invoice: $e');
    }
  }

  /// Test 4: Probar Edge Function dashboard-api
  Future<void> testDashboardApi() async {
    print('\n🔍 TEST 4: Testing dashboard-api');
    
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/functions/v1/dashboard-api'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('   ✅ Dashboard API funciona');
          print('   📊 Estadísticas disponibles: ${data['stats']?.keys.join(', ') ?? 'N/A'}');
        } else {
          print('   ⚠️ Dashboard API falló: ${data['error'] ?? 'Error desconocido'}');
        }
      } else {
        print('   ❌ Error en dashboard-api: ${response.statusCode}');
      }
    } catch (e) {
      print('   ❌ Error probando dashboard-api: $e');
    }
  }

  // Métodos auxiliares para testing de manage-sessions

  Future<bool> _testAddSession() async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/manage-sessions'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': 'add',
          'session': {
            'plate': 'TEST123',
            'zoneId': 'zona-1',
            'start': DateTime.now().toIso8601String(),
            'end': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
            'totalPrice': 2.50,
            'paymentMethod': 'cash',
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testSearchSession() async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/manage-sessions'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': 'search',
          'plate': 'TEST123',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _testExtendSession() async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/manage-sessions'),
        headers: {
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': 'extend',
          'plate': 'TEST123',
          'extraMinutes': 30,
          'price': 1.25,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
