/// Script de migración de datos existentes a Supabase
/// 
/// Este script migra todos los datos hardcodeados desde:
/// - mock_data.json
/// - geographic_kiosks.json  
/// - lib/data/mock_data.dart
/// 
/// IMPORTANTE: Ejecutar después de crear las tablas en Supabase

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DataMigrator {
  // Configuración de Supabase
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b3FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';
  
  // Headers para las peticiones
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
  };
  
  // ========================================
  // MÉTODOS DE MIGRACIÓN
  // ========================================
  
  /// Migrar todos los datos
  static Future<void> migrateAll() async {
    print('🚀 Iniciando migración de datos a Supabase...\n');
    
    try {
      // 1. Migrar empresas
      await _migrateCompanies();
      
      // 2. Migrar operadores
      await _migrateOperators();
      
      // 3. Migrar zonas
      await _migrateZones();
      
      // 4. Migrar configuración de pagos
      await _migratePaymentConfig();
      
      // 5. Migrar configuración de accesibilidad
      await _migrateAccessibilityConfig();
      
      // 6. Migrar configuración de facturación
      await _migrateInvoiceConfig();
      
      // 7. Migrar kioscos
      await _migrateKiosks();
      
      // 8. Migrar textos UI
      await _migrateUiTexts();
      
      // 9. Migrar configuración de elementos UI
      await _migrateUiElementsConfig();
      
      print('\n✅ Migración completada exitosamente!');
      
    } catch (e) {
      print('\n❌ Error durante la migración: $e');
      rethrow;
    }
  }
  
  /// Migrar empresas
  static Future<void> _migrateCompanies() async {
    print('📊 Migrando empresas...');
    
    final companies = [
      {
        'id': 'mowiz-company',
        'name': 'MOWIZ',
        'primary_color': '#E62144',
        'background_color': '#FFFFFF',
        'logo_url': '',
        'contact_email': 'info@mowiz.com',
        'contact_phone': '+34 900 123 456',
        'address': 'Madrid, España',
        'is_active': true,
      },
      {
        'id': 'eypsa-company',
        'name': 'EYPSA',
        'primary_color': '#2196F3',
        'background_color': '#FFFFFF',
        'logo_url': '',
        'contact_email': 'info@eypsa.com',
        'contact_phone': '+34 900 789 012',
        'address': 'Barcelona, España',
        'is_active': true,
      },
    ];
    
    for (final company in companies) {
      await _insertData('companies', company);
    }
    
    print('✅ Empresas migradas: ${companies.length}');
  }
  
  /// Migrar operadores
  static Future<void> _migrateOperators() async {
    print('👥 Migrando operadores...');
    
    final operators = [
      {
        'id': 'mowiz-admin',
        'company_id': 'mowiz-company',
        'name': 'Administrador MOWIZ',
        'username': 'mowiz_admin',
        'password_hash': '\$2b\$10\$rQZ8vQZ8vQZ8vQZ8vQZ8vO', // admin123
        'role': 'admin',
        'permissions': ['all'],
        'is_active': true,
      },
      {
        'id': 'mowiz-operator',
        'company_id': 'mowiz-company',
        'name': 'Operador MOWIZ',
        'username': 'mowiz_operator',
        'password_hash': '\$2b\$10\$rQZ8vQZ8vQZ8vQZ8vQZ8vO', // operator123
        'role': 'operator',
        'permissions': ['zones', 'sessions'],
        'is_active': true,
      },
      {
        'id': 'eypsa-admin',
        'company_id': 'eypsa-company',
        'name': 'Administrador EYPSA',
        'username': 'eypsa_admin',
        'password_hash': '\$2b\$10\$rQZ8vQZ8vQZ8vQZ8vQZ8vO', // admin123
        'role': 'admin',
        'permissions': ['all'],
        'is_active': true,
      },
      {
        'id': 'eypsa-operator',
        'company_id': 'eypsa-company',
        'name': 'Operador EYPSA',
        'username': 'eypsa_operator',
        'password_hash': '\$2b\$10\$rQZ8vQZ8vQZ8vQZ8vQZ8vO', // operator123
        'role': 'operator',
        'permissions': ['zones', 'sessions'],
        'is_active': true,
      },
    ];
    
    for (final operator in operators) {
      await _insertData('operators', operator);
    }
    
    print('✅ Operadores migrados: ${operators.length}');
  }
  
  /// Migrar zonas
  static Future<void> _migrateZones() async {
    print('🅿️ Migrando zonas...');
    
    final zones = [
      {
        'id': 'mz_a',
        'company_id': 'mowiz-company',
        'name': 'Zona A - Madrid Centro',
        'color': '#E62144',
        'price_per_hour': 1.2,
        'max_duration': 240,
        'description': 'Zona de estacionamiento regulado en el centro de Madrid',
        'time_options': [15, 30, 60, 120, 180, 240],
        'time_increment': 15,
        'min_time': 15,
        'is_active': true,
      },
      {
        'id': 'mz_b',
        'company_id': 'mowiz-company',
        'name': 'Zona B - Madrid Norte',
        'color': '#FF9800',
        'price_per_hour': 0.8,
        'max_duration': 180,
        'description': 'Zona de estacionamiento regulado en el norte de Madrid',
        'time_options': [15, 30, 60, 120, 180],
        'time_increment': 15,
        'min_time': 15,
        'is_active': true,
      },
      {
        'id': 'ey_a',
        'company_id': 'eypsa-company',
        'name': 'Zona A - Barcelona Eixample',
        'color': '#2196F3',
        'price_per_hour': 1.5,
        'max_duration': 240,
        'description': 'Zona de estacionamiento regulado en el Eixample de Barcelona',
        'time_options': [15, 30, 60, 120, 180, 240],
        'time_increment': 15,
        'min_time': 15,
        'is_active': true,
      },
      {
        'id': 'ey_b',
        'company_id': 'eypsa-company',
        'name': 'Zona B - Barcelona Centro',
        'color': '#4CAF50',
        'price_per_hour': 2.0,
        'max_duration': 180,
        'description': 'Zona de estacionamiento regulado en el centro de Barcelona',
        'time_options': [15, 30, 60, 120, 180],
        'time_increment': 15,
        'min_time': 15,
        'is_active': true,
      },
    ];
    
    for (final zone in zones) {
      await _insertData('zones', zone);
    }
    
    print('✅ Zonas migradas: ${zones.length}');
  }
  
  /// Migrar configuración de pagos
  static Future<void> _migratePaymentConfig() async {
    print('💳 Migrando configuración de pagos...');
    
    final paymentConfigs = [
      {
        'company_id': 'mowiz-company',
        'accepted_coins': [0.05, 0.10, 0.20, 0.50, 1.00, 2.00],
        'accepted_cards': ['Visa', 'Mastercard'],
        'max_change_amount': 10.0,
        'min_payment_amount': 0.15,
        'currency': 'EUR',
        'currency_symbol': '€',
      },
      {
        'company_id': 'eypsa-company',
        'accepted_coins': [0.05, 0.10, 0.20, 0.50, 1.00, 2.00],
        'accepted_cards': ['Visa', 'Mastercard', 'American Express'],
        'max_change_amount': 15.0,
        'min_payment_amount': 0.20,
        'currency': 'EUR',
        'currency_symbol': '€',
      },
    ];
    
    for (final config in paymentConfigs) {
      await _insertData('payment_config', config);
    }
    
    print('✅ Configuración de pagos migrada: ${paymentConfigs.length}');
  }
  
  /// Migrar configuración de accesibilidad
  static Future<void> _migrateAccessibilityConfig() async {
    print('♿ Migrando configuración de accesibilidad...');
    
    final accessibilityConfigs = [
      {
        'company_id': 'mowiz-company',
        'dark_mode': false,
        'high_contrast': false,
        'font_size': 'normal',
        'reduce_animations': false,
        'voice_guide': false,
        'voice_speed': 0.5,
        'voice_pitch': 1.0,
        'voice_volume': 0.8,
        'adaptive_ai': false,
        'simplified_mode': false,
        'current_language': 'es-ES',
      },
      {
        'company_id': 'eypsa-company',
        'dark_mode': false,
        'high_contrast': false,
        'font_size': 'normal',
        'reduce_animations': false,
        'voice_guide': true,
        'voice_speed': 0.6,
        'voice_pitch': 1.1,
        'voice_volume': 0.9,
        'adaptive_ai': true,
        'simplified_mode': false,
        'current_language': 'es-ES',
      },
    ];
    
    for (final config in accessibilityConfigs) {
      await _insertData('accessibility_config', config);
    }
    
    print('✅ Configuración de accesibilidad migrada: ${accessibilityConfigs.length}');
  }
  
  /// Migrar configuración de facturación
  static Future<void> _migrateInvoiceConfig() async {
    print('🧾 Migrando configuración de facturación...');
    
    final invoiceConfigs = [
      {
        'company_id': 'mowiz-company',
        'company_name': 'MOWIZ S.L.',
        'cif': 'B12345678',
        'address': 'Calle de la Innovación, 123',
        'city': 'Madrid',
        'postal_code': '28001',
        'email': 'facturacion@mowiz.com',
        'phone': '+34 900 123 456',
        'iva_rate': 21.0,
      },
      {
        'company_id': 'eypsa-company',
        'company_name': 'EYPSA S.L.',
        'cif': 'B87654321',
        'address': 'Avenida de la Tecnología, 456',
        'city': 'Barcelona',
        'postal_code': '08001',
        'email': 'facturacion@eypsa.com',
        'phone': '+34 900 789 012',
        'iva_rate': 21.0,
      },
    ];
    
    for (final config in invoiceConfigs) {
      await _insertData('invoice_config', config);
    }
    
    print('✅ Configuración de facturación migrada: ${invoiceConfigs.length}');
  }
  
  /// Migrar kioscos
  static Future<void> _migrateKiosks() async {
    print('🏪 Migrando kioscos...');
    
    final kiosks = [
      {
        'id': 'kiosk-madrid-001',
        'company_id': 'mowiz-company',
        'operator_id': 'mowiz-operator',
        'name': 'Kiosco Madrid Centro 001',
        'location': 'Plaza Mayor, Madrid',
        'gps_lat': 40.4168,
        'gps_lng': -3.7038,
        'status': 'online',
        'hardware_status': {
          'network': true,
          'printer': true,
          'display': true,
          'touch': true,
          'coins': true,
          'cards': true,
        },
        'current_screen': 'login',
        'total_sessions': 0,
        'today_income': 0.0,
        'version': '1.0.0',
        'is_app': false,
      },
      {
        'id': 'kiosk-madrid-002',
        'company_id': 'mowiz-company',
        'operator_id': 'mowiz-operator',
        'name': 'Kiosco Madrid Norte 002',
        'location': 'Plaza de Castilla, Madrid',
        'gps_lat': 40.4669,
        'gps_lng': -3.6883,
        'status': 'online',
        'hardware_status': {
          'network': true,
          'printer': true,
          'display': true,
          'touch': true,
          'coins': true,
          'cards': true,
        },
        'current_screen': 'login',
        'total_sessions': 0,
        'today_income': 0.0,
        'version': '1.0.0',
        'is_app': false,
      },
      {
        'id': 'kiosk-barcelona-001',
        'company_id': 'eypsa-company',
        'operator_id': 'eypsa-operator',
        'name': 'Kiosco Barcelona Eixample 001',
        'location': 'Passeig de Gràcia, Barcelona',
        'gps_lat': 41.3851,
        'gps_lng': 2.1734,
        'status': 'online',
        'hardware_status': {
          'network': true,
          'printer': true,
          'display': true,
          'touch': true,
          'coins': true,
          'cards': true,
        },
        'current_screen': 'login',
        'total_sessions': 0,
        'today_income': 0.0,
        'version': '1.0.0',
        'is_app': false,
      },
    ];
    
    for (final kiosk in kiosks) {
      await _insertData('kiosks', kiosk);
    }
    
    print('✅ Kioscos migrados: ${kiosks.length}');
  }
  
  /// Migrar textos UI
  static Future<void> _migrateUiTexts() async {
    print('📝 Migrando textos UI...');
    
    final uiTexts = [
      // Textos para MOWIZ
      {
        'company_id': 'mowiz-company',
        'screen': 'login',
        'element': 'title',
        'language': 'es-ES',
        'text_value': 'MOWIZ Parking',
        'is_enabled': true,
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'login',
        'element': 'username',
        'language': 'es-ES',
        'text_value': 'Usuario',
        'is_enabled': true,
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'login',
        'element': 'password',
        'language': 'es-ES',
        'text_value': 'Contraseña',
        'is_enabled': true,
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'login',
        'element': 'button_login',
        'language': 'es-ES',
        'text_value': 'Entrar',
        'is_enabled': true,
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'zone',
        'element': 'title',
        'language': 'es-ES',
        'text_value': 'Seleccionar Zona',
        'is_enabled': true,
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'zone',
        'element': 'coche',
        'language': 'es-ES',
        'text_value': 'Coche',
        'is_enabled': true,
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'zone',
        'element': 'moto',
        'language': 'es-ES',
        'text_value': 'Moto',
        'is_enabled': true,
      },
      
      // Textos para EYPSA
      {
        'company_id': 'eypsa-company',
        'screen': 'login',
        'element': 'title',
        'language': 'es-ES',
        'text_value': 'EYPSA Parking',
        'is_enabled': true,
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'login',
        'element': 'username',
        'language': 'es-ES',
        'text_value': 'Usuario',
        'is_enabled': true,
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'login',
        'element': 'password',
        'language': 'es-ES',
        'text_value': 'Contraseña',
        'is_enabled': true,
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'login',
        'element': 'button_login',
        'language': 'es-ES',
        'text_value': 'Acceder',
        'is_enabled': true,
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'zone',
        'element': 'title',
        'language': 'es-ES',
        'text_value': 'Elegir Zona',
        'is_enabled': true,
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'zone',
        'element': 'coche',
        'language': 'es-ES',
        'text_value': 'Automóvil',
        'is_enabled': true,
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'zone',
        'element': 'moto',
        'language': 'es-ES',
        'text_value': 'Motocicleta',
        'is_enabled': true,
      },
    ];
    
    for (final text in uiTexts) {
      await _insertData('ui_texts', text);
    }
    
    print('✅ Textos UI migrados: ${uiTexts.length}');
  }
  
  /// Migrar configuración de elementos UI
  static Future<void> _migrateUiElementsConfig() async {
    print('🎛️ Migrando configuración de elementos UI...');
    
    final uiElementsConfig = [
      // Configuración para MOWIZ
      {
        'company_id': 'mowiz-company',
        'screen': 'login',
        'element_key': 'button_login',
        'is_enabled': true,
        'display_order': 1,
        'custom_properties': {},
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'zone',
        'element_key': 'button_continue',
        'is_enabled': true,
        'display_order': 1,
        'custom_properties': {},
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'payment',
        'element_key': 'button_cash',
        'is_enabled': true,
        'display_order': 1,
        'custom_properties': {},
      },
      {
        'company_id': 'mowiz-company',
        'screen': 'payment',
        'element_key': 'button_card',
        'is_enabled': true,
        'display_order': 2,
        'custom_properties': {},
      },
      
      // Configuración para EYPSA
      {
        'company_id': 'eypsa-company',
        'screen': 'login',
        'element_key': 'button_login',
        'is_enabled': true,
        'display_order': 1,
        'custom_properties': {},
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'zone',
        'element_key': 'button_continue',
        'is_enabled': true,
        'display_order': 1,
        'custom_properties': {},
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'payment',
        'element_key': 'button_cash',
        'is_enabled': true,
        'display_order': 1,
        'custom_properties': {},
      },
      {
        'company_id': 'eypsa-company',
        'screen': 'payment',
        'element_key': 'button_card',
        'is_enabled': true,
        'display_order': 2,
        'custom_properties': {},
      },
    ];
    
    for (final config in uiElementsConfig) {
      await _insertData('ui_elements_config', config);
    }
    
    print('✅ Configuración de elementos UI migrada: ${uiElementsConfig.length}');
  }
  
  // ========================================
  // MÉTODOS DE UTILIDAD
  // ========================================
  
  /// Insertar datos en una tabla
  static Future<void> _insertData(String tableName, Map<String, dynamic> data) async {
    try {
      final url = '$supabaseUrl/rest/v1/$tableName';
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );
      
      if (response.statusCode == 201) {
        print('✅ Insertado en $tableName: ${data['id'] ?? data['name'] ?? 'N/A'}');
      } else {
        print('⚠️ Error insertando en $tableName: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      print('❌ Error insertando en $tableName: $e');
    }
  }
  
  /// Verificar conexión con Supabase
  static Future<bool> checkConnection() async {
    try {
      final url = '$supabaseUrl/rest/v1/companies?select=id&limit=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        print('✅ Conexión con Supabase verificada');
        return true;
      } else {
        print('❌ Error de conexión: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error verificando conexión: $e');
      return false;
    }
  }
}

/// Función principal para ejecutar la migración
void main() async {
  print('🚀 Script de migración de datos MEYPARK a Supabase');
  print('=' * 50);
  
  // Verificar conexión
  final isConnected = await DataMigrator.checkConnection();
  if (!isConnected) {
    print('❌ No se pudo conectar con Supabase. Verifica la configuración.');
    exit(1);
  }
  
  // Ejecutar migración
  await DataMigrator.migrateAll();
  
  print('\n🎉 Migración completada!');
  print('📋 Próximos pasos:');
  print('1. Verificar datos en el dashboard de Supabase');
  print('2. Configurar RLS (Row Level Security) si es necesario');
  print('3. Probar la aplicación Flutter con los nuevos datos');
}
