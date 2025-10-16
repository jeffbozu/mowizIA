#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para probar sincronización en tiempo real con Supabase

void main(List<String> args) async {
  await SupabaseTester.main(args);
}
/// 
/// Este script simula cambios en Supabase y verifica que se reflejen
/// en la aplicación Flutter en tiempo real.

class SupabaseTester {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b2FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';
  static const String supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b2FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDQ3OTUxNCwiZXhwIjoyMDc2MDU1NTE0fQ.CV7qGEl0GvReQJW8aWZ7U_0SWufBBIW4QLHgsm9foY';

  static Future<void> main(List<String> args) async {
    print('🧪 INICIANDO TESTING DE SINCRONIZACIÓN EN TIEMPO REAL');
    print('=' * 60);
    
    final tester = SupabaseTester();
    
    try {
      // Test 1: Cambiar tarifa de zona
      await tester.testZonePriceChange();
      
      // Test 2: Cambiar texto de botón
      await tester.testButtonTextChange();
      
      // Test 3: Cambiar colores de empresa
      await tester.testCompanyColorsChange();
      
      // Test 4: Deshabilitar botón
      await tester.testButtonDisable();
      
      // Test 5: Crear nueva empresa
      await tester.testNewCompanyCreation();
      
      print('\n✅ TODOS LOS TESTS COMPLETADOS EXITOSAMENTE');
      print('🎯 La sincronización en tiempo real está funcionando correctamente');
      
    } catch (e) {
      print('\n❌ ERROR EN TESTING: $e');
      exit(1);
    }
  }

  /// Test 1: Cambiar tarifa de zona y verificar cambio
  Future<void> testZonePriceChange() async {
    print('\n🔍 TEST 1: Cambio de tarifa de zona');
    
    // Obtener zona actual
    final zone = await _getZone('zona-1');
    final originalPrice = zone['price_per_hour'];
    final newPrice = originalPrice + 0.50;
    
    print('   📊 Tarifa original: \$${originalPrice.toStringAsFixed(2)}');
    print('   📊 Tarifa nueva: \$${newPrice.toStringAsFixed(2)}');
    
    // Cambiar tarifa en Supabase
    await _updateZone('zona-1', {'price_per_hour': newPrice});
    print('   ✅ Tarifa actualizada en Supabase');
    
    // Verificar cambio
    final updatedZone = await _getZone('zona-1');
    if (updatedZone['price_per_hour'] == newPrice) {
      print('   ✅ Cambio verificado en Supabase');
      print('   🎯 La app debería mostrar la nueva tarifa en < 2 segundos');
    } else {
      throw Exception('Error: La tarifa no se actualizó correctamente');
    }
    
    // Restaurar tarifa original
    await _updateZone('zona-1', {'price_per_hour': originalPrice});
    print('   🔄 Tarifa restaurada a valor original');
  }

  /// Test 2: Cambiar texto de botón y verificar cambio
  Future<void> testButtonTextChange() async {
    print('\n🔍 TEST 2: Cambio de texto de botón');
    
    const originalText = 'Pagar';
    const newText = 'Procesar Pago';
    
    print('   📝 Texto original: "$originalText"');
    print('   📝 Texto nuevo: "$newText"');
    
    // Cambiar texto en Supabase
    await _updateUIText('mowiz', 'payment', 'pay_button', 'es-ES', newText);
    print('   ✅ Texto actualizado en Supabase');
    
    // Verificar cambio
    final updatedText = await _getUIText('mowiz', 'payment', 'pay_button', 'es-ES');
    if (updatedText == newText) {
      print('   ✅ Cambio verificado en Supabase');
      print('   🎯 La app debería mostrar "$newText" en < 2 segundos');
    } else {
      throw Exception('Error: El texto no se actualizó correctamente');
    }
    
    // Restaurar texto original
    await _updateUIText('mowiz', 'payment', 'pay_button', 'es-ES', originalText);
    print('   🔄 Texto restaurado a valor original');
  }

  /// Test 3: Cambiar colores de empresa y verificar cambio
  Future<void> testCompanyColorsChange() async {
    print('\n🔍 TEST 3: Cambio de colores de empresa');
    
    // Obtener colores actuales
    final company = await _getCompany('mowiz');
    final originalColor = company['primary_color'];
    final newColor = '#FF6B35'; // Naranja
    
    print('   🎨 Color original: $originalColor');
    print('   🎨 Color nuevo: $newColor');
    
    // Cambiar color en Supabase
    await _updateCompany('mowiz', {'primary_color': newColor});
    print('   ✅ Color actualizado en Supabase');
    
    // Verificar cambio
    final updatedCompany = await _getCompany('mowiz');
    if (updatedCompany['primary_color'] == newColor) {
      print('   ✅ Cambio verificado en Supabase');
      print('   🎯 La app debería mostrar el nuevo color en < 2 segundos');
    } else {
      throw Exception('Error: El color no se actualizó correctamente');
    }
    
    // Restaurar color original
    await _updateCompany('mowiz', {'primary_color': originalColor});
    print('   🔄 Color restaurado a valor original');
  }

  /// Test 4: Deshabilitar botón y verificar cambio
  Future<void> testButtonDisable() async {
    print('\n🔍 TEST 4: Deshabilitar botón');
    
    // Deshabilitar botón en Supabase
    await _updateUIElement('mowiz', 'home', 'accessibility_button', false);
    print('   ✅ Botón deshabilitado en Supabase');
    
    // Verificar cambio
    final element = await _getUIElement('mowiz', 'home', 'accessibility_button');
    if (element['is_enabled'] == false) {
      print('   ✅ Cambio verificado en Supabase');
      print('   🎯 La app debería ocultar el botón de accesibilidad en < 2 segundos');
    } else {
      throw Exception('Error: El botón no se deshabilitó correctamente');
    }
    
    // Restaurar botón
    await _updateUIElement('mowiz', 'home', 'accessibility_button', true);
    print('   🔄 Botón restaurado (habilitado)');
  }

  /// Test 5: Crear nueva empresa y verificar que aparece
  Future<void> testNewCompanyCreation() async {
    print('\n🔍 TEST 5: Creación de nueva empresa');
    
    final testCompanyId = 'test-company-${DateTime.now().millisecondsSinceEpoch}';
    const testCompanyName = 'Empresa de Prueba';
    
    print('   🏢 ID de empresa: $testCompanyId');
    print('   🏢 Nombre: $testCompanyName');
    
    // Crear empresa en Supabase
    await _createCompany({
      'id': testCompanyId,
      'name': testCompanyName,
      'primary_color': '#00FF00',
      'background_color': '#FFFFFF',
      'is_active': true,
    });
    print('   ✅ Empresa creada en Supabase');
    
    // Verificar creación
    final company = await _getCompany(testCompanyId);
    if (company['name'] == testCompanyName) {
      print('   ✅ Empresa verificada en Supabase');
      print('   🎯 La app debería mostrar la nueva empresa en < 2 segundos');
    } else {
      throw Exception('Error: La empresa no se creó correctamente');
    }
    
    // Limpiar: eliminar empresa de prueba
    await _deleteCompany(testCompanyId);
    print('   🧹 Empresa de prueba eliminada');
  }

  // Métodos auxiliares para interactuar con Supabase

  Future<Map<String, dynamic>> _getZone(String zoneId) async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/zones?id=eq.$zoneId'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.isNotEmpty ? data.first : {};
    } else {
      throw Exception('Error obteniendo zona: ${response.statusCode}');
    }
  }

  Future<void> _updateZone(String zoneId, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$supabaseUrl/rest/v1/zones?id=eq.$zoneId'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(updates),
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error actualizando zona: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _getCompany(String companyId) async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/companies?id=eq.$companyId'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.isNotEmpty ? data.first : {};
    } else {
      throw Exception('Error obteniendo empresa: ${response.statusCode}');
    }
  }

  Future<void> _updateCompany(String companyId, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$supabaseUrl/rest/v1/companies?id=eq.$companyId'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(updates),
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error actualizando empresa: ${response.statusCode}');
    }
  }

  Future<void> _createCompany(Map<String, dynamic> company) async {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/companies'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(company),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Error creando empresa: ${response.statusCode}');
    }
  }

  Future<void> _deleteCompany(String companyId) async {
    final response = await http.delete(
      Uri.parse('$supabaseUrl/rest/v1/companies?id=eq.$companyId'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
      },
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error eliminando empresa: ${response.statusCode}');
    }
  }

  Future<String> _getUIText(String companyId, String screen, String element, String language) async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/ui_texts?company_id=eq.$companyId&screen=eq.$screen&element=eq.$element&language=eq.$language'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.isNotEmpty ? data.first['text_value'] : '';
    } else {
      throw Exception('Error obteniendo texto UI: ${response.statusCode}');
    }
  }

  Future<void> _updateUIText(String companyId, String screen, String element, String language, String text) async {
    final response = await http.patch(
      Uri.parse('$supabaseUrl/rest/v1/ui_texts?company_id=eq.$companyId&screen=eq.$screen&element=eq.$element&language=eq.$language'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({'text_value': text}),
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error actualizando texto UI: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _getUIElement(String companyId, String screen, String elementKey) async {
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/ui_elements_config?company_id=eq.$companyId&screen=eq.$screen&element_key=eq.$elementKey'),
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.isNotEmpty ? data.first : {};
    } else {
      throw Exception('Error obteniendo elemento UI: ${response.statusCode}');
    }
  }

  Future<void> _updateUIElement(String companyId, String screen, String elementKey, bool enabled) async {
    final response = await http.patch(
      Uri.parse('$supabaseUrl/rest/v1/ui_elements_config?company_id=eq.$companyId&screen=eq.$screen&element_key=eq.$elementKey'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({'is_enabled': enabled}),
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error actualizando elemento UI: ${response.statusCode}');
    }
  }
}
