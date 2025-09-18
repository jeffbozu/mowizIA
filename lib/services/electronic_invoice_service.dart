import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../data/models.dart';

class ElectronicInvoiceService {
  static const String _baseUrl = 'http://localhost:3002'; // URL del servidor demo
  static final Map<String, ElectronicInvoiceTransaction> _transactions = {};
  
  /// Genera un ID único para la transacción
  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'TXN_${timestamp}_$random';
  }
  
  /// Crea una nueva transacción de facturación electrónica
  static ElectronicInvoiceTransaction createTransaction({
    required String plate,
    required String zoneId,
    required double amount,
    required String paymentMethod,
    required String kioscoId,
    required bool isExtend,
    required int minutes,
  }) {
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
    
    // Guardar en memoria para la demo
    _transactions[transaction.id] = transaction;
    
    // Enviar al backend inmediatamente
    _sendTransactionToBackend(transaction);
    
    print('🧾 Transacción de facturación creada: ${transaction.id}');
    return transaction;
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
    return '$_baseUrl/facturacion.html?transactionId=$transactionId';
  }
  
  /// Genera un QR code data para la facturación
  static String generateQRData(String transactionId) {
    final url = generateInvoicePortalUrl(transactionId);
    return url;
  }
  
  /// Envía solicitud de factura al servidor backend
  static Future<InvoiceResponse> requestInvoice(InvoiceRequest request) async {
    try {
      print('🧾 Enviando solicitud de factura para transacción: ${request.transactionId}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate-invoice'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InvoiceResponse.fromJson(data);
      } else {
        return InvoiceResponse(
          success: false,
          errorMessage: 'Error del servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error al solicitar factura: $e');
      return InvoiceResponse(
        success: false,
        errorMessage: 'Error de conexión: $e',
      );
    }
  }
  
  /// Obtiene el estado de una factura
  static Future<InvoiceResponse> getInvoiceStatus(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/invoice-status/$transactionId'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InvoiceResponse.fromJson(data);
      } else {
        return InvoiceResponse(
          success: false,
          errorMessage: 'Error al obtener estado de la factura',
        );
      }
    } catch (e) {
      print('❌ Error al obtener estado de factura: $e');
      return InvoiceResponse(
        success: false,
        errorMessage: 'Error de conexión: $e',
      );
    }
  }
  
  /// Envía transacción al backend
  static Future<void> _sendTransactionToBackend(ElectronicInvoiceTransaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 200) {
        print('✅ Transacción ${transaction.id} enviada al backend correctamente');
      } else {
        print('❌ Error al enviar transacción ${transaction.id} al backend: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión al enviar transacción ${transaction.id} al backend: $e');
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
