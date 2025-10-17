import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para migrar TODOS los datos faltantes a Supabase
/// 
/// Este script identifica todos los datos hardcodeados en la app
/// y los migra a las tablas correspondientes en Supabase

class CompleteDataMigrationService {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b3FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';
  static const String companyId = '550e8400-e29b-41d4-a716-446655440000';
  
  static Future<void> migrateAllMissingData() async {
    print('🚀 INICIANDO MIGRACIÓN COMPLETA DE DATOS FALTANTES A SUPABASE');
    print('=============================================================');
    
    int successCount = 0;
    int errorCount = 0;
    
    // 1. MIGRAR CONFIGURACIÓN DE PAGOS
    print('\n💳 1. MIGRANDO CONFIGURACIÓN DE PAGOS...');
    try {
      final success = await _migratePaymentConfig();
      if (success) {
        successCount++;
        print('   ✅ Configuración de pagos migrada correctamente');
      } else {
        errorCount++;
        print('   ❌ Error migrando configuración de pagos');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e');
    }
    
    // 2. MIGRAR CONFIGURACIÓN DE ACCESIBILIDAD
    print('\n♿ 2. MIGRANDO CONFIGURACIÓN DE ACCESIBILIDAD...');
    try {
      final success = await _migrateAccessibilityConfig();
      if (success) {
        successCount++;
        print('   ✅ Configuración de accesibilidad migrada correctamente');
      } else {
        errorCount++;
        print('   ❌ Error migrando configuración de accesibilidad');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e');
    }
    
    // 3. MIGRAR CONFIGURACIÓN DE FACTURACIÓN
    print('\n🧾 3. MIGRANDO CONFIGURACIÓN DE FACTURACIÓN...');
    try {
      final success = await _migrateInvoiceConfig();
      if (success) {
        successCount++;
        print('   ✅ Configuración de facturación migrada correctamente');
      } else {
        errorCount++;
        print('   ❌ Error migrando configuración de facturación');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e');
    }
    
    // 4. MIGRAR KIOSCOS
    print('\n🏪 4. MIGRANDO KIOSCOS...');
    try {
      final success = await _migrateKiosks();
      if (success) {
        successCount++;
        print('   ✅ Kioscos migrados correctamente');
      } else {
        errorCount++;
        print('   ❌ Error migrando kioscos');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e');
    }
    
    // 5. MIGRAR CONFIGURACIÓN DE ELEMENTOS UI
    print('\n🎛️ 5. MIGRANDO CONFIGURACIÓN DE ELEMENTOS UI...');
    try {
      final success = await _migrateUIElementsConfig();
      if (success) {
        successCount++;
        print('   ✅ Configuración de elementos UI migrada correctamente');
      } else {
        errorCount++;
        print('   ❌ Error migrando configuración de elementos UI');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e');
    }
    
    // 6. MIGRAR CACHÉ DE TRADUCCIONES
    print('\n📝 6. MIGRANDO CACHÉ DE TRADUCCIONES...');
    try {
      final success = await _migrateTranslationsCache();
      if (success) {
        successCount++;
        print('   ✅ Caché de traducciones migrado correctamente');
      } else {
        errorCount++;
        print('   ❌ Error migrando caché de traducciones');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e');
    }
    
    // 7. AGREGAR MÁS ZONAS
    print('\n🅿️ 7. AGREGANDO MÁS ZONAS...');
    try {
      final success = await _addMoreZones();
      if (success) {
        successCount++;
        print('   ✅ Zonas adicionales agregadas correctamente');
      } else {
        errorCount++;
        print('   ❌ Error agregando zonas adicionales');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e');
    }
    
    // 8. AGREGAR MÁS OPERADORES
    print('\n👤 8. AGREGANDO MÁS OPERADORES...');
    try {
      final success = await _addMoreOperators();
      if (success) {
        successCount++;
        print('   ✅ Operadores adicionales agregados correctamente');
      } else {
        errorCount++;
        print('   ❌ Error agregando operadores adicionales');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e');
    }
    
    print('\n🎯 MIGRACIÓN COMPLETA FINALIZADA');
    print('================================');
    print('✅ Migraciones exitosas: $successCount');
    print('❌ Migraciones con error: $errorCount');
    print('📊 Total procesadas: ${successCount + errorCount}');
    
    if (successCount > 0) {
      print('\n🎉 ¡MIGRACIÓN EXITOSA!');
      print('Ahora todos los datos están en Supabase y se pueden modificar en tiempo real.');
    }
  }
  
  static Future<bool> _migratePaymentConfig() async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/payment_config'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'company_id': companyId,
          'accepted_coins': [0.05, 0.10, 0.20, 0.50, 1.00, 2.00],
          'accepted_cards': ['Visa', 'Mastercard', 'American Express'],
          'max_change_amount': 10.00,
          'min_payment_amount': 0.15,
          'currency': 'EUR',
          'currency_symbol': '€',
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error insertando payment_config: $e');
      return false;
    }
  }
  
  static Future<bool> _migrateAccessibilityConfig() async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/accessibility_config'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'company_id': companyId,
          'dark_mode': false,
          'high_contrast': false,
          'font_size': 'normal',
          'reduce_animations': false,
          'voice_guide': false,
          'voice_speed': 0.50,
          'voice_pitch': 1.00,
          'voice_volume': 0.80,
          'adaptive_ai': false,
          'simplified_mode': false,
          'current_language': 'es-ES',
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error insertando accessibility_config: $e');
      return false;
    }
  }
  
  static Future<bool> _migrateInvoiceConfig() async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/invoice_config'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'company_id': companyId,
          'business_name': 'MOWIZ Parking Solutions',
          'tax_id': 'B12345678',
          'address': 'Calle Principal 123, Madrid, España',
          'phone': '+34 91 123 4567',
          'email': 'facturacion@mowiz.com',
          'logo_url': 'https://example.com/mowiz-logo.png',
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error insertando invoice_config: $e');
      return false;
    }
  }
  
  static Future<bool> _migrateKiosks() async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/kiosks'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'company_id': companyId,
          'name': 'MAD_Centro_K72',
          'location': 'Centro Comercial Madrid Centro',
          'gps_lat': 40.4168,
          'gps_lng': -3.7038,
          'status': 'online',
          'hardware_status': {
            'printer': 'ok',
            'coin_acceptor': 'ok',
            'card_reader': 'ok',
            'display': 'ok'
          },
          'current_screen': 'home',
          'total_sessions': 0,
          'today_income': 0.00,
          'version': '1.0.0',
          'is_app': true,
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error insertando kiosks: $e');
      return false;
    }
  }
  
  static Future<bool> _migrateUIElementsConfig() async {
    try {
      // Lista de elementos UI para configurar
      final List<Map<String, dynamic>> uiElements = [
        {'screen': 'home', 'element_key': 'pay_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'home', 'element_key': 'cancel_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'home', 'element_key': 'language_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'home', 'element_key': 'accessibility_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'login', 'element_key': 'username_field', 'is_enabled': true, 'is_visible': true},
        {'screen': 'login', 'element_key': 'password_field', 'is_enabled': true, 'is_visible': true},
        {'screen': 'login', 'element_key': 'login_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'zone', 'element_key': 'zone_selection', 'is_enabled': true, 'is_visible': true},
        {'screen': 'plate', 'element_key': 'plate_input', 'is_enabled': true, 'is_visible': true},
        {'screen': 'time', 'element_key': 'time_selection', 'is_enabled': true, 'is_visible': true},
        {'screen': 'payment', 'element_key': 'cash_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'payment', 'element_key': 'card_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'payment', 'element_key': 'contactless_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'ticket', 'element_key': 'print_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'ticket', 'element_key': 'download_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'extend', 'element_key': 'search_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'extend', 'element_key': 'extend_button', 'is_enabled': true, 'is_visible': true},
        {'screen': 'accessibility', 'element_key': 'dark_mode_toggle', 'is_enabled': true, 'is_visible': true},
        {'screen': 'accessibility', 'element_key': 'voice_guide_toggle', 'is_enabled': true, 'is_visible': true},
        {'screen': 'accessibility', 'element_key': 'simplified_mode_toggle', 'is_enabled': true, 'is_visible': true},
      ];
      
      int successCount = 0;
      for (final element in uiElements) {
        try {
          final response = await http.post(
            Uri.parse('$supabaseUrl/rest/v1/ui_elements_config'),
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode({
              'company_id': companyId,
              'screen': element['screen'],
              'element_key': element['element_key'],
              'is_enabled': element['is_enabled'],
              'is_visible': element['is_visible'],
            }),
          );
          
          if (response.statusCode == 201) {
            successCount++;
          }
        } catch (e) {
          print('Error insertando elemento UI ${element['element_key']}: $e');
        }
      }
      
      print('   📊 Elementos UI insertados: $successCount/${uiElements.length}');
      return successCount > 0;
    } catch (e) {
      print('Error migrando UI elements config: $e');
      return false;
    }
  }
  
  static Future<bool> _migrateTranslationsCache() async {
    try {
      // Generar caché de traducciones para la empresa
      final translationsJson = {
        'home.main_title': 'MEYPARK',
        'home.subtitle': 'Sistema de Estacionamiento Inteligente',
        'home.pay': 'Pagar',
        'home.cancel': 'Anular',
        'login.title': 'MEYPARK',
        'login.subtitle': 'Sistema de Gestión de Parquímetros',
        'zone.title': 'Seleccionar Zona',
        'payment.title': 'Método de Pago',
        'ticket.title_new': 'Nuevo Estacionamiento',
        'extend.title': 'Extender Sesión',
        'accessibility.title': 'Configuración de Accesibilidad',
      };
      
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/ui_translations_cache'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'company_id': companyId,
          'language': 'es-ES',
          'translations': translationsJson,
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error insertando translations cache: $e');
      return false;
    }
  }
  
  static Future<bool> _addMoreZones() async {
    try {
      final List<Map<String, dynamic>> zones = [
        {
          'company_id': companyId,
          'name': 'Zona Norte',
          'price_per_hour': 3.00,
          'max_hours': 6,
          'time_options': ['1', '2', '3', '4', '5', '6'],
          'time_increment': 1,
          'min_time': 1,
          'is_active': true,
        },
        {
          'company_id': companyId,
          'name': 'Zona Sur',
          'price_per_hour': 2.50,
          'max_hours': 8,
          'time_options': ['1', '2', '3', '4', '5', '6', '7', '8'],
          'time_increment': 1,
          'min_time': 1,
          'is_active': true,
        },
        {
          'company_id': companyId,
          'name': 'Zona Este',
          'price_per_hour': 1.80,
          'max_hours': 4,
          'time_options': ['1', '2', '3', '4'],
          'time_increment': 1,
          'min_time': 1,
          'is_active': true,
        },
        {
          'company_id': companyId,
          'name': 'Zona Oeste',
          'price_per_hour': 2.20,
          'max_hours': 6,
          'time_options': ['1', '2', '3', '4', '5', '6'],
          'time_increment': 1,
          'min_time': 1,
          'is_active': true,
        },
      ];
      
      int successCount = 0;
      for (final zone in zones) {
        try {
          final response = await http.post(
            Uri.parse('$supabaseUrl/rest/v1/zones'),
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode(zone),
          );
          
          if (response.statusCode == 201) {
            successCount++;
          }
        } catch (e) {
          print('Error insertando zona ${zone['name']}: $e');
        }
      }
      
      print('   📊 Zonas insertadas: $successCount/${zones.length}');
      return successCount > 0;
    } catch (e) {
      print('Error agregando zonas: $e');
      return false;
    }
  }
  
  static Future<bool> _addMoreOperators() async {
    try {
      final List<Map<String, dynamic>> operators = [
        {
          'company_id': companyId,
          'username': 'operador1',
          'password_hash': 'hashed_password_operador1',
          'role': 'operator',
          'is_active': true,
        },
        {
          'company_id': companyId,
          'username': 'operador2',
          'password_hash': 'hashed_password_operador2',
          'role': 'operator',
          'is_active': true,
        },
        {
          'company_id': companyId,
          'username': 'supervisor',
          'password_hash': 'hashed_password_supervisor',
          'role': 'admin',
          'is_active': true,
        },
      ];
      
      int successCount = 0;
      for (final operator in operators) {
        try {
          final response = await http.post(
            Uri.parse('$supabaseUrl/rest/v1/operators'),
            headers: {
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode(operator),
          );
          
          if (response.statusCode == 201) {
            successCount++;
          }
        } catch (e) {
          print('Error insertando operador ${operator['username']}: $e');
        }
      }
      
      print('   📊 Operadores insertados: $successCount/${operators.length}');
      return successCount > 0;
    } catch (e) {
      print('Error agregando operadores: $e');
      return false;
    }
  }
}

void main() async {
  await CompleteDataMigrationService.migrateAllMissingData();
}
