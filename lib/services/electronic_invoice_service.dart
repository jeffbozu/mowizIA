import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models.dart';
import '../config/supabase_config.dart';

class ElectronicInvoiceService {
  static final Map<String, ElectronicInvoiceTransaction> _transactions = {};
  
  /// Genera un ID único para la transacción
  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'TXN_${timestamp}_$random';
  }
  
  /// Crea una nueva transacción de facturación electrónica
  static Future<ElectronicInvoiceTransaction> createTransaction({
    required String plate,
    required String zoneId,
    required String zoneName,
    required String companyId,
    required double amount,
    required String paymentMethod,
    required String kioscoId,
    required bool isExtend,
    required int minutes,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final transaction = ElectronicInvoiceTransaction(
      id: _generateTransactionId(),
      plate: plate,
      zoneId: zoneId,
      timestamp: DateTime.now(),
      amount: amount,
      paymentMethod: paymentMethod,
      kioscoId: kioscoId,
      isExtend: isExtend,
      minutes: minutes,
    );
    
    // Guardar en memoria local
    _transactions[transaction.id] = transaction;
    
    // Registrar en Supabase
    try {
      await _registerTransactionInSupabase(
        transaction: transaction,
        zoneName: zoneName,
        companyId: companyId,
        startTime: startTime,
        endTime: endTime,
      );
      print('🧾 Transacción de facturación registrada en Supabase: ${transaction.id}');
    } catch (e) {
      print('⚠️ Error registrando transacción en Supabase: $e');
    }
    
    return transaction;
  }

  /// Registra la transacción en Supabase
  static Future<void> _registerTransactionInSupabase({
    required ElectronicInvoiceTransaction transaction,
    required String zoneName,
    required String companyId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final supabase = Supabase.instance.client;
    
    await supabase.from('invoices').insert({
      'ticket_id': transaction.id,
      'company_id': companyId,
      'zone_id': transaction.zoneId,
      'zone_name': zoneName,
      'plate': transaction.plate,
      'amount': transaction.amount,
      'payment_method': transaction.paymentMethod,
      'duration_minutes': transaction.minutes,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'kiosco_id': transaction.kioscoId,
      'is_extend': transaction.isExtend,
      'status': 'pending',
    });
  }
  
  /// Obtiene una transacción por ID
  static ElectronicInvoiceTransaction? getTransaction(String transactionId) {
    return _transactions[transactionId];
  }
  
  /// Valida si una transacción existe y es válida
  static bool validateTransaction(String transactionId) {
    final transaction = _transactions[transactionId];
    if (transaction == null) return false;
    
    // Verificar que no haya pasado más de 30 días
    final daysSinceTransaction = DateTime.now().difference(transaction.timestamp).inDays;
    return daysSinceTransaction <= 30;
  }
  
  /// Genera la URL del portal de facturación con el ID de transacción
  static String generateInvoicePortalUrl(String transactionId) {
    // URL de Vercel deployment
    return 'https://facturacion-fxjxw9214-jeffreys-projects-3d123ebc.vercel.app?transaction=$transactionId';
  }
  
  /// Genera un QR code data para la facturación
  static String generateQRData(String transactionId) {
    final url = generateInvoicePortalUrl(transactionId);
    return url;
  }
  
  /// Envía solicitud de factura (ahora solo actualiza estado en Supabase)
  static Future<InvoiceResponse> requestInvoice(InvoiceRequest request) async {
    try {
      print('🧾 Actualizando estado de factura para transacción: ${request.transactionId}');
      
      final supabase = Supabase.instance.client;
      
      final response = await supabase
        .from('invoices')
        .update({
          'status': 'pending',
          'fiscal_name': request.companyName,
          'fiscal_nif': request.nif,
          'fiscal_address': request.address,
          'fiscal_city': request.city,
          'fiscal_postal_code': request.postalCode,
          'fiscal_email': request.email,
          'fiscal_phone': request.phone,
        })
        .eq('ticket_id', request.transactionId);
      
      if (response.hasError) {
        return InvoiceResponse(
          success: false,
          errorMessage: 'Error al actualizar factura: ${response.error?.message}',
        );
      }
      
      return InvoiceResponse(
        success: true,
        invoiceId: request.transactionId,
      );
    } catch (e) {
      print('❌ Error al solicitar factura: $e');
      return InvoiceResponse(
        success: false,
        errorMessage: 'Error de conexión: $e',
      );
    }
  }
  
  /// Obtiene el estado de una factura desde Supabase
  static Future<InvoiceResponse> getInvoiceStatus(String transactionId) async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
        .from('invoices')
        .select('*')
        .eq('ticket_id', transactionId)
        .maybeSingle();
      
      if (response == null) {
        return InvoiceResponse(
          success: false,
          errorMessage: 'Factura no encontrada',
        );
      }
      
      final invoice = response;
      return InvoiceResponse(
        success: true,
        invoiceId: transactionId,
        invoiceUrl: invoice['invoice_pdf_url'],
      );
    } catch (e) {
      print('❌ Error al obtener estado de factura: $e');
      return InvoiceResponse(
        success: false,
        errorMessage: 'Error de conexión: $e',
      );
    }
  }
  
  /// Obtiene todas las transacciones (para debugging)
  static List<ElectronicInvoiceTransaction> getAllTransactions() {
    return _transactions.values.toList();
  }
  
  /// Limpia transacciones antiguas (más de 30 días)
  static void cleanOldTransactions() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _transactions.entries) {
      final daysSinceTransaction = now.difference(entry.value.timestamp).inDays;
      if (daysSinceTransaction > 30) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _transactions.remove(key);
    }
    
    if (keysToRemove.isNotEmpty) {
      print('🧹 Transacciones limpiadas: ${keysToRemove.length}');
    }
  }
  
  /// Obtiene estadísticas de facturación
  static Map<String, dynamic> getStatistics() {
    final totalTransactions = _transactions.length;
    final invoicedTransactions = _transactions.values
        .where((t) => t.invoiceId != null)
        .length;
    final totalAmount = _transactions.values
        .fold(0.0, (sum, t) => sum + t.amount);
    final invoicedAmount = _transactions.values
        .where((t) => t.invoiceId != null)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    return {
      'totalTransactions': totalTransactions,
      'invoicedTransactions': invoicedTransactions,
      'totalAmount': totalAmount,
      'invoicedAmount': invoicedAmount,
      'invoiceRate': totalTransactions > 0 ? (invoicedTransactions / totalTransactions) : 0.0,
    };
  }
}
