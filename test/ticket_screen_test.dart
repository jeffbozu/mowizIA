import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meypark/screens/ticket_screen.dart';
import 'package:meypark/data/mock_data.dart';
import 'package:meypark/data/models.dart';

void main() {
  group('TicketScreen', () {
    setUp(() {
      // Inicializar datos de prueba
      // MockData.initialize(); // Comentado temporalmente
      // AppState.currentLanguage = 'es'; // Comentado temporalmente
    });

    testWidgets('displays new parking ticket correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que se muestra el título correcto
      expect(find.text('Estacionamiento Registrado'), findsOneWidget);
      
      // Verificar que se muestran los detalles
      expect(find.text('Matrícula'), findsOneWidget);
      expect(find.text('1234ABC'), findsOneWidget);
      expect(find.text('Zona'), findsOneWidget);
      expect(find.text('2.40 €'), findsOneWidget);
    });

    testWidgets('displays extension ticket correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: true,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 60,
            price: 1.20,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que se muestra el título de extensión
      expect(find.text('Extensión Realizada'), findsOneWidget);
      
      // Verificar que se muestran los detalles de extensión
      expect(find.text('Importe adicional'), findsOneWidget);
      expect(find.text('1.20 €'), findsOneWidget);
    });

    testWidgets('displays PDF download and print buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que se muestran los botones de PDF
      expect(find.text('Descargar PDF'), findsOneWidget);
      expect(find.text('Imprimir PDF'), findsOneWidget);
      expect(find.text('Imprimir Ticket'), findsOneWidget);
    });

    testWidgets('displays electronic invoice section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que se muestra la sección de facturación electrónica
      expect(find.text('Facturación Electrónica'), findsOneWidget);
      expect(find.text('Escanea este código QR para obtener tu factura electrónica desde casa'), findsOneWidget);
      expect(find.text('Válido por 30 días'), findsOneWidget);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que se muestran los botones de acción
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Nuevo Estacionamiento'), findsOneWidget);
    });

    testWidgets('handles PDF download button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Buscar y tocar el botón de descarga PDF
      final downloadButton = find.text('Descargar PDF');
      expect(downloadButton, findsOneWidget);
      
      await tester.tap(downloadButton);
      await tester.pumpAndSettle();

      // Verificar que se muestra el indicador de carga o mensaje de éxito
      // (El comportamiento exacto depende de la implementación)
    });

    testWidgets('handles PDF print button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Buscar y tocar el botón de impresión PDF
      final printButton = find.text('Imprimir PDF');
      expect(printButton, findsOneWidget);
      
      await tester.tap(printButton);
      await tester.pumpAndSettle();

      // Verificar que se muestra el indicador de carga o mensaje de éxito
      // (El comportamiento exacto depende de la implementación)
    });

    testWidgets('handles OK button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Buscar y tocar el botón OK
      final okButton = find.text('OK');
      expect(okButton, findsOneWidget);
      
      await tester.tap(okButton);
      await tester.pumpAndSettle();

      // Verificar que se navega a la pantalla de zona
      // (El comportamiento exacto depende de la implementación de navegación)
    });

    testWidgets('handles new parking button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Buscar y tocar el botón de nuevo estacionamiento
      final newParkingButton = find.text('Nuevo Estacionamiento');
      expect(newParkingButton, findsOneWidget);
      
      await tester.tap(newParkingButton);
      await tester.pumpAndSettle();

      // Verificar que se navega a la pantalla de zona
      // (El comportamiento exacto depende de la implementación de navegación)
    });

    testWidgets('displays correct time information', (WidgetTester tester) async {
      final now = DateTime(2024, 1, 15, 14, 30);
      
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que se muestran las horas correctas
      expect(find.text('14:30'), findsOneWidget); // Start time
      expect(find.text('16:30'), findsOneWidget); // End time (14:30 + 120 min)
    });

    testWidgets('displays correct pricing information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TicketScreen(
            isExtend: false,
            plate: '1234ABC',
            zoneId: 'ZONE_1',
            minutes: 120,
            price: 2.40,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar que se muestra el precio correcto
      expect(find.text('2.40 €'), findsOneWidget);
    });
  });
}
