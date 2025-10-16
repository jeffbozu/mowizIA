#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para crear tablas en Supabase usando la API REST
void main(List<String> args) async {
  await TableCreator.main(args);
}

class TableCreator {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b2FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImiYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.CV7qGEl0GvReQJW8aWZ7U_0SWufBBIW4QLHgsm9foY';

  static Future<void> main(List<String> args) async {
    print('🏗️  CREANDO TABLAS EN SUPABASE');
    print('=====================================');

    try {
      // Crear tablas principales
      await createCompaniesTable();
      await createOperatorsTable();
      await createZonesTable();
      await createPaymentConfigTable();
      await createAccessibilityConfigTable();
      await createKiosksTable();
      await createActiveSessionsTable();
      await createInvoiceConfigTable();
      await createUiTextsTable();
      await createUiTranslationsCacheTable();
      await createUiElementsConfigTable();

      print('\n✅ TODAS LAS TABLAS CREADAS EXITOSAMENTE');
      print('🎯 Ahora puedes ejecutar: dart run scripts/migrate_data.dart');

    } catch (e) {
      print('\n❌ ERROR CREANDO TABLAS: $e');
      exit(1);
    }
  }

  static Future<void> createCompaniesTable() async {
    print('📋 Creando tabla: companies');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS companies (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name TEXT NOT NULL,
            primary_color TEXT DEFAULT '#E62144',
            background_color TEXT DEFAULT '#FFFFFF',
            logo_url TEXT,
            contact_email TEXT,
            contact_phone TEXT,
            address TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            is_active BOOLEAN DEFAULT true
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla companies creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createOperatorsTable() async {
    print('📋 Creando tabla: operators');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS operators (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            username TEXT NOT NULL,
            password_hash TEXT NOT NULL,
            role TEXT DEFAULT 'operator',
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(company_id, username)
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla operators creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createZonesTable() async {
    print('📋 Creando tabla: zones');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS zones (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            price_per_hour DECIMAL(10,2) NOT NULL,
            max_hours INTEGER DEFAULT 8,
            time_options JSONB DEFAULT '["1", "2", "3", "4", "5", "6", "7", "8"]'::jsonb,
            time_increment INTEGER DEFAULT 1,
            min_time INTEGER DEFAULT 1,
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla zones creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createPaymentConfigTable() async {
    print('📋 Creando tabla: payment_config');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS payment_config (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            accepted_coins JSONB DEFAULT '["0.50", "1.00", "2.00", "5.00"]'::jsonb,
            min_payment DECIMAL(10,2) DEFAULT 0.50,
            max_payment DECIMAL(10,2) DEFAULT 100.00,
            payment_methods JSONB DEFAULT '["cash", "card"]'::jsonb,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla payment_config creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createAccessibilityConfigTable() async {
    print('📋 Creando tabla: accessibility_config');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS accessibility_config (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            dark_mode BOOLEAN DEFAULT false,
            high_contrast BOOLEAN DEFAULT false,
            font_size TEXT DEFAULT 'medium',
            voice_guide BOOLEAN DEFAULT true,
            adaptive_ai BOOLEAN DEFAULT false,
            simplified_mode BOOLEAN DEFAULT false,
            reduce_animations BOOLEAN DEFAULT false,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla accessibility_config creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createKiosksTable() async {
    print('📋 Creando tabla: kiosks');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS kiosks (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            location TEXT,
            status TEXT DEFAULT 'active',
            last_heartbeat TIMESTAMP WITH TIME ZONE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla kiosks creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createActiveSessionsTable() async {
    print('📋 Creando tabla: active_sessions');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS active_sessions (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
            plate TEXT NOT NULL,
            start_time TIMESTAMP WITH TIME ZONE NOT NULL,
            end_time TIMESTAMP WITH TIME ZONE,
            total_price DECIMAL(10,2),
            payment_method TEXT,
            status TEXT DEFAULT 'active',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla active_sessions creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createInvoiceConfigTable() async {
    print('📋 Creando tabla: invoice_config');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS invoice_config (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            business_name TEXT NOT NULL,
            tax_id TEXT,
            address TEXT,
            phone TEXT,
            email TEXT,
            logo_url TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla invoice_config creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createUiTextsTable() async {
    print('📋 Creando tabla: ui_texts');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS ui_texts (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            screen TEXT NOT NULL,
            element_key TEXT NOT NULL,
            text_value TEXT NOT NULL,
            language TEXT DEFAULT 'es-ES',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(company_id, screen, element_key, language)
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla ui_texts creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createUiTranslationsCacheTable() async {
    print('📋 Creando tabla: ui_translations_cache');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS ui_translations_cache (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            language TEXT NOT NULL,
            translations JSONB NOT NULL,
            last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(company_id, language)
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla ui_translations_cache creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createUiElementsConfigTable() async {
    print('📋 Creando tabla: ui_elements_config');
    
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'apikey': supabaseServiceKey,
        'Authorization': 'Bearer $supabaseServiceKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sql': '''
          CREATE TABLE IF NOT EXISTS ui_elements_config (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
            screen TEXT NOT NULL,
            element_key TEXT NOT NULL,
            is_enabled BOOLEAN DEFAULT true,
            is_visible BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(company_id, screen, element_key)
          );
        '''
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ Tabla ui_elements_config creada');
    } else {
      print('   ❌ Error: ${response.statusCode} - ${response.body}');
    }
  }
}
