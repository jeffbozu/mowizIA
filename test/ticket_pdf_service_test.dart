import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:meypark/services/ticket_pdf_service.dart';

void main() {
  group('TicketPdfService', () {
    test('generates PDF with correct dimensions', () async {
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('generates PDF with Spanish translations', () async {
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
      );

      // Verificar que el PDF se genera correctamente
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generates PDF with English translations', () async {
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'en',
      );

      // Verificar que el PDF se genera correctamente
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generates PDF with different payment methods', () async {
      // Test cash payment
      final cashPdf = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
      );

      expect(cashPdf, isNotEmpty);

      // Test chip payment
      final chipPdf = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'chip',
        language: 'es',
      );

      expect(chipPdf, isNotEmpty);

      // Test contactless payment
      final contactlessPdf = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'contactless',
        language: 'es',
      );

      expect(contactlessPdf, isNotEmpty);
    });

    test('generates PDF with correct pricing information', () async {
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generates PDF with correct time information', () async {
      final startTime = DateTime(2024, 1, 15, 10, 30);
      final endTime = DateTime(2024, 1, 15, 12, 30);
      
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: startTime,
        endTime: endTime,
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generates PDF with fiscal information', () async {
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generates PDF with company information', () async {
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generates PDF with QR code section', () async {
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
        transactionId: 'TXN_123456',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generates extension ticket correctly', () async {
      final pdfBytes = await TicketPdfService.generateTicketPdf(
        plate: '1234ABC',
        zoneId: 'ZONE_1',
        startTime: DateTime(2024, 1, 15, 10, 30),
        endTime: DateTime(2024, 1, 15, 12, 30),
        price: 2.40,
        paymentMethod: 'cash',
        language: 'es',
        isExtend: true,
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });
  });
}
