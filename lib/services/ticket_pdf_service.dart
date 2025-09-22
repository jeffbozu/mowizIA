import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../data/models.dart';
import '../i18n/strings.dart';

class TicketPdfService {
  static const double _ticketWidth = 80.0; // 80mm width for thermal printer
  static const double _ticketHeight = 300.0; // Optimized height for complete ticket
  
  /// Genera un PDF del ticket de parquímetro
  static Future<Uint8List> generateTicketPdf({
    required String plate,
    required String zoneId,
    required DateTime startTime,
    required DateTime endTime,
    required double price,
    required String paymentMethod,
    required String language,
    String? transactionId,
    bool isExtend = false,
  }) async {
    final pdf = pw.Document();
    
    // Obtener traducciones según el idioma
    final strings = _getTicketStrings(language);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(_ticketWidth, _ticketHeight, marginAll: 2),
        build: (pw.Context context) {
          return pw.DefaultTextStyle(
            style: pw.TextStyle(
              font: pw.Font.helvetica(),
              fontSize: 7,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
              // Señal de recorte superior
              _buildCutLine(),
              pw.SizedBox(height: 1),
              
              // Header con logo y empresa
              _buildHeader(strings),
              pw.SizedBox(height: 2),
              
              // Línea separadora
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 2),
              
              // Información del ticket
              _buildTicketInfo(strings, plate, zoneId, startTime, endTime, price, paymentMethod, transactionId, isExtend),
              
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 2),
              
              // Información fiscal y legal
              _buildFiscalInfo(strings, price),
              
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 2),
              
              // QR Code para facturación
              _buildQRCode(transactionId ?? _generateTransactionId()),
              
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 2),
              
              // Footer
              _buildFooter(strings),
              
              pw.SizedBox(height: 1),
              // Señal de recorte inferior
              _buildCutLine(),
              ],
            ),
          );
        },
      ),
    );
    
    return pdf.save();
  }
  
  /// Descarga el PDF del ticket
  static Future<String> downloadTicketPdf({
    required String plate,
    required String zoneId,
    required DateTime startTime,
    required DateTime endTime,
    required double price,
    required String paymentMethod,
    required String language,
    String? transactionId,
    bool isExtend = false,
  }) async {
    final pdfBytes = await generateTicketPdf(
      plate: plate,
      zoneId: zoneId,
      startTime: startTime,
      endTime: endTime,
      price: price,
      paymentMethod: paymentMethod,
      language: language,
      transactionId: transactionId,
      isExtend: isExtend,
    );
    
    // Obtener directorio de descargas
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'ticket_${plate}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = path.join(directory.path, fileName);
    
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    
    return filePath;
  }
  
  /// Imprime el ticket (simulación)
  static Future<void> printTicket({
    required String plate,
    required String zoneId,
    required DateTime startTime,
    required DateTime endTime,
    required double price,
    required String paymentMethod,
    required String language,
    String? transactionId,
    bool isExtend = false,
  }) async {
    final pdfBytes = await generateTicketPdf(
      plate: plate,
      zoneId: zoneId,
      startTime: startTime,
      endTime: endTime,
      price: price,
      paymentMethod: paymentMethod,
      language: language,
      transactionId: transactionId,
      isExtend: isExtend,
    );
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
  
  /// Construye la señal de recorte
  static pw.Widget _buildCutLine() {
    return pw.Container(
      width: double.infinity,
      height: 4,
      child: pw.Row(
        children: List.generate(15, (index) => 
          pw.Container(
            width: 2,
            height: 1,
            color: PdfColors.black,
            margin: const pw.EdgeInsets.only(right: 2),
          )
        ),
      ),
    );
  }

  /// Construye el header del ticket
  static pw.Widget _buildHeader(Map<String, String> strings) {
    return pw.Column(
      children: [
        pw.Text(
          'MEYPARK',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          strings['company_name']!,
          style: pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          strings['company_address']!,
          style: pw.TextStyle(fontSize: 6),
        ),
        pw.Text(
          strings['company_tax_id']!,
          style: pw.TextStyle(fontSize: 6),
        ),
      ],
    );
  }
  
  /// Construye la información del ticket
  static pw.Widget _buildTicketInfo(
    Map<String, String> strings,
    String plate,
    String zoneId,
    DateTime startTime,
    DateTime endTime,
    double price,
    String paymentMethod,
    String? transactionId,
    bool isExtend,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título del ticket
        pw.Center(
          child: pw.Text(
            isExtend ? strings['ticket_extend']! : strings['ticket_new']!,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 2),
        
        // Información de la transacción
        _buildTransactionId(strings['transaction_id']!, transactionId ?? _generateTransactionId()),
        _buildInfoRow(strings['date']!, _formatDate(startTime, strings['date_format']!)),
        _buildInfoRow(strings['time']!, _formatTime(startTime)),
        pw.SizedBox(height: 1),
        
        // Información del vehículo
        _buildInfoRow(strings['license_plate']!, plate),
        _buildInfoRow(strings['zone']!, zoneId),
        pw.SizedBox(height: 1),
        
        // Información de tiempo
        _buildInfoRow(strings['start_time']!, _formatTime(startTime)),
        _buildInfoRow(strings['end_time']!, _formatTime(endTime)),
        _buildInfoRow(strings['duration']!, _formatDuration(startTime, endTime)),
        pw.SizedBox(height: 1),
        
        // Información de pago
        _buildInfoRow(strings['payment_method']!, _getPaymentMethodName(paymentMethod, strings)),
        pw.SizedBox(height: 1),
        
        // Desglose de precios compacto
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 1),
        
        // Precio base e IVA en una línea
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Base: ${(price / 1.21).toStringAsFixed(2)} EUR',
              style: pw.TextStyle(fontSize: 5),
            ),
            pw.Text(
              'IVA: ${(price - (price / 1.21)).toStringAsFixed(2)} EUR',
              style: pw.TextStyle(fontSize: 5),
            ),
          ],
        ),
        
        pw.Divider(thickness: 0.5),
        
        // Precio total
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              strings['total']!,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '${price.toStringAsFixed(2)} EUR',
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Construye la información fiscal compacta
  static pw.Widget _buildFiscalInfo(Map<String, String> strings, double price) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          strings['fiscal_text']!,
          style: pw.TextStyle(fontSize: 5),
        ),
      ],
    );
  }
  
  /// Construye el código QR compacto
  static pw.Widget _buildQRCode(String transactionId) {
    return pw.Column(
      children: [
        pw.Text(
          'QR Facturación',
          style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 1),
        pw.Container(
          width: 30,
          height: 30,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 1),
          ),
          child: pw.Center(
            child: pw.Text(
              'QR',
              style: pw.TextStyle(fontSize: 3),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          transactionId.length > 20 ? '${transactionId.substring(0, 20)}...' : transactionId,
          style: pw.TextStyle(fontSize: 3),
        ),
      ],
    );
  }
  
  /// Construye el footer compacto
  static pw.Widget _buildFooter(Map<String, String> strings) {
    return pw.Column(
      children: [
        pw.Text(
          strings['thank_you']!,
          style: pw.TextStyle(
            fontSize: 6,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          strings['keep_ticket']!,
          style: pw.TextStyle(fontSize: 4),
        ),
        pw.Text(
          strings['customer_service']!,
          style: pw.TextStyle(fontSize: 4),
        ),
        pw.Text(
          'www.meypark.com',
          style: pw.TextStyle(fontSize: 4),
        ),
      ],
    );
  }
  
  /// Construye una fila de información
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 6),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construye el ID de transacción en dos líneas si es muy largo
  static pw.Widget _buildTransactionId(String label, String transactionId) {
    if (transactionId.length <= 20) {
      return _buildInfoRow(label, transactionId);
    } else {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 0.3),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 6),
            ),
            pw.Text(
              transactionId,
              style: pw.TextStyle(
                fontSize: 5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }
  
  /// Obtiene las traducciones del ticket según el idioma
  static Map<String, String> _getTicketStrings(String language) {
    if (language == 'en') {
      return {
        'company_name': 'MEYPARK S.L.',
        'company_address': 'C/ Ejemplo 123, 28001 Madrid',
        'company_tax_id': 'B-12345678',
        'ticket_new': 'PARKING TICKET',
        'ticket_extend': 'PARKING EXTENSION',
        'transaction_id': 'Transaction ID:',
        'date': 'Date:',
        'time': 'Time:',
        'license_plate': 'License Plate:',
        'zone': 'Zone:',
        'start_time': 'Start:',
        'end_time': 'End:',
        'duration': 'Duration:',
        'payment_method': 'Payment:',
        'total': 'TOTAL',
        'fiscal_info': 'FISCAL INFORMATION',
        'fiscal_text': 'This ticket serves as proof of payment for parking services.',
        'iva_included': 'VAT included (21%)',
        'thank_you': 'Thank you for using MEYPARK!',
        'keep_ticket': 'Keep this ticket in your vehicle',
        'customer_service': 'Customer Service: 900 123 456',
        'date_format': 'dd/MM/yyyy',
      };
    } else {
      return {
        'company_name': 'MEYPARK S.L.',
        'company_address': 'C/ Ejemplo 123, 28001 Madrid',
        'company_tax_id': 'B-12345678',
        'ticket_new': 'TICKET DE APARCAMIENTO',
        'ticket_extend': 'EXTENSIÓN DE APARCAMIENTO',
        'transaction_id': 'ID Transacción:',
        'date': 'Fecha:',
        'time': 'Hora:',
        'license_plate': 'Matrícula:',
        'zone': 'Zona:',
        'start_time': 'Inicio:',
        'end_time': 'Fin:',
        'duration': 'Duración:',
        'payment_method': 'Pago:',
        'total': 'TOTAL',
        'fiscal_info': 'INFORMACIÓN FISCAL',
        'fiscal_text': 'Este ticket sirve como comprobante de pago del servicio de aparcamiento.',
        'iva_included': 'IVA incluido (21%)',
        'thank_you': '¡Gracias por usar MEYPARK!',
        'keep_ticket': 'Conserve este ticket en su vehículo',
        'customer_service': 'Atención al Cliente: 900 123 456',
        'date_format': 'dd/MM/yyyy',
      };
    }
  }
  
  /// Obtiene el nombre del método de pago traducido
  static String _getPaymentMethodName(String method, Map<String, String> strings) {
    switch (method) {
      case 'cash':
        return strings['payment_cash'] ?? 'Efectivo';
      case 'chip':
        return strings['payment_chip'] ?? 'Chip+PIN';
      case 'contactless':
        return strings['payment_contactless'] ?? 'Contactless';
      default:
        return method;
    }
  }
  
  /// Formatea la fecha
  static String _formatDate(DateTime date, String format) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Formatea la hora
  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  /// Formatea la duración
  static String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  /// Genera un ID de transacción único
  static String _generateTransactionId() {
    final now = DateTime.now();
    return 'TXN_${now.millisecondsSinceEpoch}_${(now.microsecond % 1000).toString().padLeft(3, '0')}';
  }
}
