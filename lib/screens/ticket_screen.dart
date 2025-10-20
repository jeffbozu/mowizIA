import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../widgets/top_bar.dart';
import '../services/websocket_service.dart';
import '../services/electronic_invoice_service.dart';
import '../services/ticket_pdf_service.dart';
import '../services/centralized_websocket_service.dart';
import '../services/dynamic_translations_service.dart';

enum PdfOperation { download, print }

class TicketScreen extends StatefulWidget {
  final bool isExtend;
  final String plate;
  final String zoneId;
  final String zoneName;
  final int minutes;
  final double price;
  final DateTime startTime;
  final DateTime endTime;

  const TicketScreen({
    super.key,
    required this.isExtend,
    required this.plate,
    required this.zoneId,
    required this.zoneName,
    required this.minutes,
    required this.price,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> with TickerProviderStateMixin {
  ElectronicInvoiceTransaction? _invoiceTransaction;
  String? _qrData;
  bool _isGeneratingPdf = false;
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;
  Timer? _autoReturnTimer;

  @override
  void initState() {
    super.initState();
    
    // Inicializar animaciones
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _successAnimation = CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    );
    
    // Crear o actualizar sesión en mock data
    if (widget.isExtend) {
      _extendSession();
    } else {
      _createNewSession();
    }
    
    // Crear transacción de facturación electrónica
    _createInvoiceTransaction().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    
    // Iniciar animación de éxito
    _successAnimationController.forward();
    
    // Iniciar timer de 30 segundos para volver automáticamente
    _startAutoReturnTimer();
  }

  @override
  void dispose() {
    _successAnimationController.dispose();
    _autoReturnTimer?.cancel();
    super.dispose();
  }

  void _startAutoReturnTimer() {
    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _returnToZones();
      }
    });
  }

  void _returnToZones() {
    // Limpiar estado y volver a zonas
    AppState.currentPayment = null;
    AppState.currentPlate = null;
    AppState.selectedZoneId = null;
    context.go('/zona');
  }

  Future<void> _extendSession() async {
    // Extender sesión en el backend
    final existingSession = AppState.activeSessions[widget.plate];
    if (existingSession != null) {
      final newEnd = existingSession.end.add(Duration(minutes: widget.minutes));
      final newSession = ParkingSession(
        plate: widget.plate,
        zoneId: widget.zoneId,
        start: existingSession.start,
        end: newEnd,
        totalPrice: existingSession.totalPrice + widget.price,
        paymentMethod: existingSession.paymentMethod,
      );
      
      // Actualizar sesión en el backend usando Edge Functions
      final sessionId = '${widget.plate}_${DateTime.now().millisecondsSinceEpoch}';
      final result = await CentralizedWebSocketService.updateSession(sessionId, newSession);
      if (result != null && result['success'] == true) {
        print('✅ Sesión actualizada exitosamente con Edge Functions');
      } else {
        print('❌ Error actualizando sesión con Edge Functions: ${result?['error'] ?? 'Error desconocido'}');
      }
      
      print('⏰ Sesión extendida en backend: ${widget.plate}');
    }
  }

  void _createNewSession() {
    // Crear nueva sesión en el backend
    final start = DateTime.now();
    final end = start.add(Duration(minutes: widget.minutes));
    final session = ParkingSession(
      plate: widget.plate,
      zoneId: widget.zoneId,
      start: start,
      end: end,
      totalPrice: widget.price,
      paymentMethod: AppState.currentPayment?.paymentMethod ?? 'cash',
    );
    
    // La sesión ya fue registrada en payment_screen.dart
    // No es necesario registrarla de nuevo aquí
    
    print('💾 Nueva sesión creada en backend: ${widget.plate}');
  }

  Future<void> _createInvoiceTransaction() async {
    _invoiceTransaction = await ElectronicInvoiceService.createTransaction(
      plate: widget.plate,
      zoneId: widget.zoneId,
      zoneName: widget.zoneName,
      companyId: AppState.currentCompany?.id ?? '550e8400-e29b-41d4-a716-446655440000',
      amount: widget.price,
      paymentMethod: AppState.currentPayment?.paymentMethod ?? 'cash',
      kioscoId: AppState.kioscoId ?? 'DEMO_KIOSCO',
      isExtend: widget.isExtend,
      minutes: widget.minutes,
      startTime: widget.startTime,
      endTime: widget.endTime,
    );
    
    _qrData = ElectronicInvoiceService.generateQRData(_invoiceTransaction!.id);
    
    print('🧾 Transacción de facturación creada: ${_invoiceTransaction!.id}');
  }

  Future<void> _handlePdfOperation(PdfOperation operation) async {
    if (_isGeneratingPdf) return;
    
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final session = MockData.getSessionByPlate(widget.plate);
      final startTime = session?.start ?? DateTime.now();
      final endTime = session?.end ?? DateTime.now().add(Duration(minutes: widget.minutes));
      
      String? filePath;
      String successMessage;
      String errorMessage;
      
      switch (operation) {
        case PdfOperation.download:
          filePath = await TicketPdfService.downloadTicketPdf(
            plate: widget.plate,
            zoneId: widget.zoneId,
            startTime: startTime,
            endTime: endTime,
            price: widget.price,
            paymentMethod: AppState.currentPayment?.paymentMethod ?? 'cash',
            language: AppState.currentLanguage,
            transactionId: _invoiceTransaction?.id,
            isExtend: widget.isExtend,
          );
          successMessage = DynamicTranslationsService.instance.t('ticket.download_success', defaultValue: 'Ticket descargado correctamente');
          errorMessage = DynamicTranslationsService.instance.t('ticket.download_error', defaultValue: 'Error al descargar el ticket');
          break;
        case PdfOperation.print:
          await TicketPdfService.printTicket(
            plate: widget.plate,
            zoneId: widget.zoneId,
            startTime: startTime,
            endTime: endTime,
            price: widget.price,
            paymentMethod: AppState.currentPayment?.paymentMethod ?? 'cash',
            language: AppState.currentLanguage,
            transactionId: _invoiceTransaction?.id,
            isExtend: widget.isExtend,
          );
          successMessage = DynamicTranslationsService.instance.t('ticket.print_success', defaultValue: 'Ticket enviado a impresión');
          errorMessage = DynamicTranslationsService.instance.t('ticket.print_error', defaultValue: 'Error al imprimir el ticket');
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            action: filePath != null ? SnackBarAction(
              label: DynamicTranslationsService.instance.t('ticket.view', defaultValue: 'Ver'),
              textColor: Colors.white,
              onPressed: () {
                print('PDF guardado en: $filePath');
              },
            ) : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${DynamicTranslationsService.instance.t('ticket.operation_error', defaultValue: 'Error en la operación')}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      print('Error en operación PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  Future<void> _printTicket() async {
    await _handlePdfOperation(PdfOperation.print);
  }

  Future<void> _downloadPdfTicket() async {
    await _handlePdfOperation(PdfOperation.download);
  }

  String _getPaymentMethodDisplay(String method) {
    switch (method) {
      case 'cash':
        return DynamicTranslationsService.instance.t('pay.payment_cash', defaultValue: 'Efectivo');
      case 'chip':
        return DynamicTranslationsService.instance.t('pay.payment_chip', defaultValue: 'Chip+PIN');
      case 'contactless':
        return DynamicTranslationsService.instance.t('pay.payment_contactless', defaultValue: 'Contactless');
      default:
        return method.toUpperCase();
    }
  }

  void _continue() {
    // Cancelar timer automático
    _autoReturnTimer?.cancel();
    // Volver a la pantalla de zona
    _returnToZones();
  }

  Future<void> _openElectronicInvoice() async {
    if (_invoiceTransaction?.id != null) {
      final url = 'http://localhost:3002/facturacion-fixed.html?transaction=${_invoiceTransaction!.id}';
      final uri = Uri.parse(url);
      
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${DynamicTranslationsService.instance.t('ticket.cannot_open_link', defaultValue: 'No se pudo abrir el enlace')}: $url'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${DynamicTranslationsService.instance.t('ticket.invoice_error', defaultValue: 'Error al abrir la facturación')}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: AppState.accessibilityStream,
      builder: (context, snapshot) {
        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    final zone = MockData.getZoneById(widget.zoneId);
    final session = MockData.getSessionByPlate(widget.plate);

    return Scaffold(
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Icono de éxito con animación
                  AnimatedBuilder(
                    animation: _successAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _successAnimation.value,
                        child: Semantics(
                          label: DynamicTranslationsService.instance.t('ticket.payment_success', defaultValue: 'Pago realizado con éxito'),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Título
                  Text(
                    DynamicTranslationsService.instance.t(widget.isExtend ? 'ticket.title.extend' : 'ticket.title.new', 
                      defaultValue: widget.isExtend ? 'Sesión Extendida' : 'Nuevo Estacionamiento'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Detalles del ticket
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DynamicTranslationsService.instance.t('ticket.details', defaultValue: 'Detalles del Ticket'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(DynamicTranslationsService.instance.t('ticket.plate', defaultValue: 'Matrícula'), widget.plate),
                        _buildDetailRow(DynamicTranslationsService.instance.t('ticket.zone', defaultValue: 'Zona'), zone?.name ?? ''),
                        _buildDetailRow(
                          DynamicTranslationsService.instance.t('ticket.payment_method', defaultValue: 'Método de Pago'), 
                          _getPaymentMethodDisplay(AppState.currentPayment?.paymentMethod ?? 'cash')
                        ),
                        if (widget.isExtend && session != null) ...[
                          _buildDetailRow(
                            DynamicTranslationsService.instance.t('ticket.previous_end', defaultValue: 'Fin Anterior'),
                            '${session.end.hour.toString().padLeft(2, '0')}:${session.end.minute.toString().padLeft(2, '0')}',
                          ),
                          _buildDetailRow(
                            DynamicTranslationsService.instance.t('ticket.new_end', defaultValue: 'Nuevo Fin'),
                            '${session.end.add(Duration(minutes: widget.minutes)).hour.toString().padLeft(2, '0')}:${session.end.add(Duration(minutes: widget.minutes)).minute.toString().padLeft(2, '0')}',
                          ),
                          _buildDetailRow(
                            DynamicTranslationsService.instance.t('ticket.extra_amount', defaultValue: 'Cantidad Extra'),
                            '${widget.price.toStringAsFixed(2)} €',
                          ),
                        ] else ...[
                          _buildDetailRow(
                            DynamicTranslationsService.instance.t('ticket.start', defaultValue: 'Inicio'),
                            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          ),
                          _buildDetailRow(
                            DynamicTranslationsService.instance.t('ticket.end', defaultValue: 'Fin'),
                            '${DateTime.now().add(Duration(minutes: widget.minutes)).hour.toString().padLeft(2, '0')}:${DateTime.now().add(Duration(minutes: widget.minutes)).minute.toString().padLeft(2, '0')}',
                          ),
                          _buildDetailRow(
                            DynamicTranslationsService.instance.t('ticket.amount', defaultValue: 'Cantidad'),
                            '${widget.price.toStringAsFixed(2)} €',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sección de facturación electrónica
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DynamicTranslationsService.instance.t('ticket.electronic_invoice', defaultValue: 'Facturación Electrónica'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          DynamicTranslationsService.instance.t('ticket.electronic_invoice_description', defaultValue: 'Accede a tu factura electrónica'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _openElectronicInvoice,
                          child: Text(
                            DynamicTranslationsService.instance.t('ticket.click_here', defaultValue: 'Haz clic aquí'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_qrData != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: QrImageView(
                              data: _qrData!,
                              version: QrVersions.auto,
                              size: 150.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ID: ${_invoiceTransaction?.id ?? ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ] else ...[
                          const CircularProgressIndicator(),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          DynamicTranslationsService.instance.t('ticket.valid_for_days', defaultValue: 'Válido por 30 días'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Botones
                  Column(
                    children: [
                      // Botones de PDF
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label: DynamicTranslationsService.instance.t('ticket.print_label', defaultValue: 'Imprimir ticket de estacionamiento'),
                              button: true,
                              enabled: !_isGeneratingPdf,
                              child: SizedBox(
                                height: 56,
                                child: FilledButton.icon(
                                  onPressed: _isGeneratingPdf ? null : _printTicket,
                                  icon: _isGeneratingPdf 
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.print, size: 24),
                                  label: Text(
                                    DynamicTranslationsService.instance.t('ticket.print', defaultValue: 'Imprimir'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Semantics(
                              label: DynamicTranslationsService.instance.t('ticket.download_label', defaultValue: 'Descargar ticket en formato PDF'),
                              button: true,
                              enabled: !_isGeneratingPdf,
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: _isGeneratingPdf ? null : _downloadPdfTicket,
                                  icon: _isGeneratingPdf 
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.download, size: 24),
                                  label: Text(
                                    DynamicTranslationsService.instance.t('ticket.download_pdf', defaultValue: 'Descargar PDF'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Botón de continuar
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Semantics(
                          label: DynamicTranslationsService.instance.t('ticket.continue_label', defaultValue: 'Continuar - Volver a la pantalla de zonas'),
                          button: true,
                          child: FilledButton(
                            onPressed: _continue,
                            child: Text(
                              DynamicTranslationsService.instance.t('ticket.ok', defaultValue: 'Continuar'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}