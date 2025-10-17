import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para migrar TODOS los textos hardcodeados a Supabase
/// 
/// Este script identifica todos los textos con defaultValue en la app
/// y los inserta en la tabla ui_texts de Supabase

class TextMigrationService {
  static const String supabaseUrl = 'https://thfmuoqcrkhxduxuygro.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoZm11b3FjcmtoeGR1eHV5Z3JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA0Nzk1MTQsImV4cCI6MjA3NjA1NTUxNH0.5n3YqmCV1t39aoDZDLfvKG432o9M79WkM6wQu9JTmFc';
  static const String companyId = '550e8400-e29b-41d4-a716-446655440000';
  
  // Lista completa de todos los textos hardcodeados encontrados
  static final List<Map<String, String>> allTexts = [
    // LOGIN SCREEN
    {'screen': 'login', 'element_key': 'title', 'text_value': 'MEYPARK'},
    {'screen': 'login', 'element_key': 'subtitle', 'text_value': 'Sistema de Gestión de Parquímetros'},
    {'screen': 'login', 'element_key': 'form_title', 'text_value': 'Iniciar Sesión'},
    {'screen': 'login', 'element_key': 'username', 'text_value': 'Usuario'},
    {'screen': 'login', 'element_key': 'password', 'text_value': 'Contraseña'},
    {'screen': 'login', 'element_key': 'login_button', 'text_value': 'Iniciar Sesión'},
    {'screen': 'login', 'element_key': 'error_invalid_credentials', 'text_value': 'Credenciales inválidas'},
    {'screen': 'login', 'element_key': 'error_empty_fields', 'text_value': 'Por favor, completa todos los campos'},
    
    // HOME SCREEN
    {'screen': 'home', 'element_key': 'subtitle', 'text_value': 'Sistema de Estacionamiento Inteligente'},
    {'screen': 'home', 'element_key': 'pay', 'text_value': 'Pagar'},
    {'screen': 'home', 'element_key': 'pay_subtitle', 'text_value': 'Nuevo estacionamiento'},
    {'screen': 'home', 'element_key': 'cancel', 'text_value': 'Anular'},
    {'screen': 'home', 'element_key': 'cancel_subtitle', 'text_value': 'Cancelar sesión activa'},
    {'screen': 'home', 'element_key': 'language', 'text_value': 'Idioma'},
    {'screen': 'home', 'element_key': 'accessibility', 'text_value': 'Accesibilidad'},
    {'screen': 'home', 'element_key': 'tech_access_hint', 'text_value': 'Mantén presionado para acceso técnico...'},
    
    // ZONE SCREEN
    {'screen': 'zone', 'element_key': 'title', 'text_value': 'Seleccionar Zona'},
    {'screen': 'zone', 'element_key': 'price_per_hour', 'text_value': 'Precio por hora'},
    {'screen': 'zone', 'element_key': 'max_hours', 'text_value': 'Horas máximas'},
    {'screen': 'zone', 'element_key': 'select_zone', 'text_value': 'Seleccionar Zona'},
    {'screen': 'zone', 'element_key': 'zone_info', 'text_value': 'Información de la zona'},
    
    // PLATE SCREEN
    {'screen': 'plate', 'element_key': 'title', 'text_value': 'Introducir Matrícula'},
    {'screen': 'plate', 'element_key': 'hint', 'text_value': '1234ABC'},
    {'screen': 'plate', 'element_key': 'continue_button', 'text_value': 'Continuar'},
    {'screen': 'plate', 'element_key': 'error_invalid_plate', 'text_value': 'Matrícula inválida'},
    {'screen': 'plate', 'element_key': 'error_empty_plate', 'text_value': 'Por favor, introduce una matrícula'},
    
    // TIME SCREEN
    {'screen': 'time', 'element_key': 'title', 'text_value': 'Seleccionar Tiempo'},
    {'screen': 'time', 'element_key': 'zone_info', 'text_value': 'Información de la zona'},
    {'screen': 'time', 'element_key': 'price_per_hour', 'text_value': 'Precio por hora'},
    {'screen': 'time', 'element_key': 'max_hours', 'text_value': 'Horas máximas'},
    {'screen': 'time', 'element_key': 'select_time', 'text_value': 'Seleccionar tiempo'},
    {'screen': 'time', 'element_key': 'minutes', 'text_value': 'Minutos'},
    {'screen': 'time', 'element_key': 'total_to_pay', 'text_value': 'Total a pagar'},
    {'screen': 'time', 'element_key': 'pay_button', 'text_value': 'Pagar'},
    
    // PAYMENT SCREEN
    {'screen': 'payment', 'element_key': 'title', 'text_value': 'Método de Pago'},
    {'screen': 'payment', 'element_key': 'payment_details', 'text_value': 'Detalles del pago'},
    {'screen': 'payment', 'element_key': 'zone', 'text_value': 'Zona'},
    {'screen': 'payment', 'element_key': 'time', 'text_value': 'Tiempo'},
    {'screen': 'payment', 'element_key': 'amount', 'text_value': 'Cantidad'},
    {'screen': 'payment', 'element_key': 'payment_method', 'text_value': 'Método de Pago'},
    {'screen': 'payment', 'element_key': 'cash', 'text_value': 'Efectivo'},
    {'screen': 'payment', 'element_key': 'chip', 'text_value': 'Chip+PIN'},
    {'screen': 'payment', 'element_key': 'contactless', 'text_value': 'Contactless'},
    {'screen': 'payment', 'element_key': 'insert_coins', 'text_value': 'Insertar monedas'},
    {'screen': 'payment', 'element_key': 'processing_payment', 'text_value': 'Procesando pago...'},
    {'screen': 'payment', 'element_key': 'payment_success', 'text_value': 'Pago realizado con éxito'},
    {'screen': 'payment', 'element_key': 'payment_error', 'text_value': 'Error en el pago'},
    
    // TICKET SCREEN
    {'screen': 'ticket', 'element_key': 'title_new', 'text_value': 'Nuevo Estacionamiento'},
    {'screen': 'ticket', 'element_key': 'title_extend', 'text_value': 'Sesión Extendida'},
    {'screen': 'ticket', 'element_key': 'details', 'text_value': 'Detalles del Ticket'},
    {'screen': 'ticket', 'element_key': 'plate', 'text_value': 'Matrícula'},
    {'screen': 'ticket', 'element_key': 'zone', 'text_value': 'Zona'},
    {'screen': 'ticket', 'element_key': 'payment_method', 'text_value': 'Método de Pago'},
    {'screen': 'ticket', 'element_key': 'start', 'text_value': 'Inicio'},
    {'screen': 'ticket', 'element_key': 'end', 'text_value': 'Fin'},
    {'screen': 'ticket', 'element_key': 'amount', 'text_value': 'Cantidad'},
    {'screen': 'ticket', 'element_key': 'previous_end', 'text_value': 'Fin Anterior'},
    {'screen': 'ticket', 'element_key': 'new_end', 'text_value': 'Nuevo Fin'},
    {'screen': 'ticket', 'element_key': 'extra_amount', 'text_value': 'Cantidad Extra'},
    {'screen': 'ticket', 'element_key': 'electronic_invoice', 'text_value': 'Facturación Electrónica'},
    {'screen': 'ticket', 'element_key': 'electronic_invoice_description', 'text_value': 'Accede a tu factura electrónica'},
    {'screen': 'ticket', 'element_key': 'click_here', 'text_value': 'Haz clic aquí'},
    {'screen': 'ticket', 'element_key': 'valid_for_days', 'text_value': 'Válido por 30 días'},
    {'screen': 'ticket', 'element_key': 'print_label', 'text_value': 'Imprimir ticket de estacionamiento'},
    {'screen': 'ticket', 'element_key': 'print', 'text_value': 'Imprimir'},
    {'screen': 'ticket', 'element_key': 'download_label', 'text_value': 'Descargar ticket en formato PDF'},
    {'screen': 'ticket', 'element_key': 'download_pdf', 'text_value': 'Descargar PDF'},
    {'screen': 'ticket', 'element_key': 'continue_label', 'text_value': 'Continuar - Volver a la pantalla de zonas'},
    {'screen': 'ticket', 'element_key': 'ok', 'text_value': 'Continuar'},
    {'screen': 'ticket', 'element_key': 'download_success', 'text_value': 'Ticket descargado correctamente'},
    {'screen': 'ticket', 'element_key': 'download_error', 'text_value': 'Error al descargar el ticket'},
    {'screen': 'ticket', 'element_key': 'print_success', 'text_value': 'Ticket enviado a impresión'},
    {'screen': 'ticket', 'element_key': 'print_error', 'text_value': 'Error al imprimir el ticket'},
    {'screen': 'ticket', 'element_key': 'view', 'text_value': 'Ver'},
    {'screen': 'ticket', 'element_key': 'operation_error', 'text_value': 'Error en la operación'},
    {'screen': 'ticket', 'element_key': 'cannot_open_link', 'text_value': 'No se pudo abrir el enlace'},
    {'screen': 'ticket', 'element_key': 'invoice_error', 'text_value': 'Error al abrir la facturación'},
    {'screen': 'ticket', 'element_key': 'payment_success', 'text_value': 'Pago realizado con éxito'},
    
    // EXTEND SCREEN
    {'screen': 'extend', 'element_key': 'title', 'text_value': 'Extender Sesión'},
    {'screen': 'extend', 'element_key': 'search', 'text_value': 'Buscar'},
    {'screen': 'extend', 'element_key': 'session_found', 'text_value': 'Sesión encontrada'},
    {'screen': 'extend', 'element_key': 'no_session', 'text_value': 'No se encontró sesión activa'},
    {'screen': 'extend', 'element_key': 'cannot_extend_more', 'text_value': 'No se puede extender más. Máximo de zona'},
    {'screen': 'extend', 'element_key': 'remaining', 'text_value': 'Quedan'},
    {'screen': 'extend', 'element_key': 'back_to_zones', 'text_value': 'Volver a Zonas'},
    {'screen': 'extend', 'element_key': 'start_new', 'text_value': 'Nuevo Estacionamiento'},
    {'screen': 'extend', 'element_key': 'enter_plate_to_search', 'text_value': 'Introduce la matrícula para buscar'},
    {'screen': 'extend', 'element_key': 'search_instructions', 'text_value': 'Busca tu sesión activa para extender el tiempo'},
    {'screen': 'extend', 'element_key': 'session_info', 'text_value': 'Información de la sesión'},
    {'screen': 'extend', 'element_key': 'current_time', 'text_value': 'Tiempo actual'},
    {'screen': 'extend', 'element_key': 'extend_time', 'text_value': 'Extender tiempo'},
    {'screen': 'extend', 'element_key': 'new_end_time', 'text_value': 'Nuevo tiempo de fin'},
    {'screen': 'extend', 'element_key': 'additional_cost', 'text_value': 'Costo adicional'},
    {'screen': 'extend', 'element_key': 'extend_button', 'text_value': 'Extender'},
    
    // ACCESSIBILITY SCREEN
    {'screen': 'accessibility', 'element_key': 'title', 'text_value': 'Configuración de Accesibilidad'},
    {'screen': 'accessibility', 'element_key': 'dark_mode', 'text_value': 'Modo Oscuro'},
    {'screen': 'accessibility', 'element_key': 'dark_mode_description', 'text_value': 'Activar tema oscuro para mejor visibilidad'},
    {'screen': 'accessibility', 'element_key': 'high_contrast', 'text_value': 'Alto Contraste'},
    {'screen': 'accessibility', 'element_key': 'high_contrast_description', 'text_value': 'Aumentar el contraste de colores'},
    {'screen': 'accessibility', 'element_key': 'font_size', 'text_value': 'Tamaño de Fuente'},
    {'screen': 'accessibility', 'element_key': 'font_size_description', 'text_value': 'Ajustar el tamaño de la fuente'},
    {'screen': 'accessibility', 'element_key': 'voice_guide', 'text_value': 'Guía por Voz'},
    {'screen': 'accessibility', 'element_key': 'voice_guide_description', 'text_value': 'Activar asistencia por voz'},
    {'screen': 'accessibility', 'element_key': 'adaptive_ai', 'text_value': 'IA Adaptativa'},
    {'screen': 'accessibility', 'element_key': 'adaptive_ai_description', 'text_value': 'Usar inteligencia artificial para adaptar la interfaz'},
    {'screen': 'accessibility', 'element_key': 'simplified_mode', 'text_value': 'Modo Simplificado'},
    {'screen': 'accessibility', 'element_key': 'simplified_mode_description', 'text_value': 'Simplificar la interfaz para facilitar el uso'},
    {'screen': 'accessibility', 'element_key': 'reduce_animations', 'text_value': 'Reducir Animaciones'},
    {'screen': 'accessibility', 'element_key': 'reduce_animations_description', 'text_value': 'Minimizar animaciones para reducir distracciones'},
    {'screen': 'accessibility', 'element_key': 'save_settings', 'text_value': 'Guardar Configuración'},
    {'screen': 'accessibility', 'element_key': 'reset_settings', 'text_value': 'Restablecer'},
    
    // COMMON TEXT
    {'screen': 'common', 'element_key': 'loading', 'text_value': 'Cargando...'},
    {'screen': 'common', 'element_key': 'error', 'text_value': 'Error'},
    {'screen': 'common', 'element_key': 'success', 'text_value': 'Éxito'},
    {'screen': 'common', 'element_key': 'cancel', 'text_value': 'Cancelar'},
    {'screen': 'common', 'element_key': 'confirm', 'text_value': 'Confirmar'},
    {'screen': 'common', 'element_key': 'back', 'text_value': 'Atrás'},
    {'screen': 'common', 'element_key': 'next', 'text_value': 'Siguiente'},
    {'screen': 'common', 'element_key': 'finish', 'text_value': 'Finalizar'},
    {'screen': 'common', 'element_key': 'retry', 'text_value': 'Reintentar'},
    {'screen': 'common', 'element_key': 'close', 'text_value': 'Cerrar'},
  ];
  
  static Future<void> migrateAllTexts() async {
    print('🚀 INICIANDO MIGRACIÓN DE TODOS LOS TEXTOS A SUPABASE');
    print('=====================================================');
    print('📊 Total de textos a migrar: ${allTexts.length}');
    
    int successCount = 0;
    int errorCount = 0;
    
    for (int i = 0; i < allTexts.length; i++) {
      final text = allTexts[i];
      final screen = text['screen']!;
      final elementKey = text['element_key']!;
      final textValue = text['text_value']!;
      
      print('\n📝 [${i + 1}/${allTexts.length}] Migrando: $screen.$elementKey');
      print('   Texto: "$textValue"');
      
      try {
        final success = await _insertTextToSupabase(screen, elementKey, textValue);
        if (success) {
          successCount++;
          print('   ✅ Migrado correctamente');
        } else {
          errorCount++;
          print('   ❌ Error en la migración');
        }
      } catch (e) {
        errorCount++;
        print('   ❌ Error: $e');
      }
      
      // Pequeña pausa para no sobrecargar la API
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    print('\n🎯 MIGRACIÓN COMPLETADA');
    print('=======================');
    print('✅ Textos migrados exitosamente: $successCount');
    print('❌ Textos con error: $errorCount');
    print('📊 Total procesados: ${allTexts.length}');
    
    if (successCount > 0) {
      print('\n🎉 ¡MIGRACIÓN EXITOSA!');
      print('Ahora todos los textos están en Supabase y se pueden modificar en tiempo real.');
    }
  }
  
  static Future<bool> _insertTextToSupabase(String screen, String elementKey, String textValue) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/ui_texts'),
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'company_id': companyId,
          'screen': screen,
          'element_key': elementKey,
          'text_value': textValue,
          'language': 'es-ES',
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error insertando texto: $e');
      return false;
    }
  }
}

void main() async {
  await TextMigrationService.migrateAllTexts();
}
