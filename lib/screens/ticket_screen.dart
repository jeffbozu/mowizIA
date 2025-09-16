import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../widgets/top_bar.dart';
import '../services/websocket_service.dart';

class TicketScreen extends StatefulWidget {
  final bool isExtend;
  final String plate;
  final String zoneId;
  final int minutes;
  final double price;

  const TicketScreen({
    super.key,
    required this.isExtend,
    required this.plate,
    required this.zoneId,
    required this.minutes,
    required this.price,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  @override
  void initState() {
    super.initState();
    // Crear o actualizar sesión en mock data
    if (widget.isExtend) {
      _extendSession();
    } else {
      _createNewSession();
    }
  }

  void _extendSession() {
    final existingSession = MockData.getSessionByPlate(widget.plate);
    if (existingSession != null) {
      final newEnd = existingSession.end.add(Duration(minutes: widget.minutes));
      final newSession = Session(
        plate: widget.plate,
        zoneId: widget.zoneId,
        start: existingSession.start,
        end: newEnd,
        totalPrice: existingSession.totalPrice + widget.price,
      );
      MockData.addSession(newSession);
    }
  }

  void _createNewSession() {
    final start = DateTime.now();
    final end = start.add(Duration(minutes: widget.minutes));
    final session = Session(
      plate: widget.plate,
      zoneId: widget.zoneId,
      start: start,
      end: end,
      totalPrice: widget.price,
    );
    MockData.addSession(session);
  }

  void _printTicket() {
    // Mock: mostrar mensaje de impresión
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.t('ticket.print')),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _ok() {
    context.go('/zona');
  }

  void _newParking() {
    context.go('/zona');
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
                  // Icono de éxito
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Título
                  Text(
                    AppStrings.t(widget.isExtend ? 'ticket.title.extend' : 'ticket.title.new'),
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
                          AppStrings.t('ticket.details'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(AppStrings.t('ticket.plate'), widget.plate),
                        _buildDetailRow(AppStrings.t('ticket.zone'), zone?.name ?? ''),
                        if (widget.isExtend && session != null) ...[
                          _buildDetailRow(
                            AppStrings.t('ticket.previous_end'),
                            '${session.end.hour.toString().padLeft(2, '0')}:${session.end.minute.toString().padLeft(2, '0')}',
                          ),
                          _buildDetailRow(
                            AppStrings.t('ticket.new_end'),
                            '${session.end.add(Duration(minutes: widget.minutes)).hour.toString().padLeft(2, '0')}:${session.end.add(Duration(minutes: widget.minutes)).minute.toString().padLeft(2, '0')}',
                          ),
                          _buildDetailRow(
                            AppStrings.t('ticket.extra_amount'),
                            '${widget.price.toStringAsFixed(2)} €',
                          ),
                        ] else ...[
                          _buildDetailRow(
                            AppStrings.t('ticket.start'),
                            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          ),
                          _buildDetailRow(
                            AppStrings.t('ticket.end'),
                            '${DateTime.now().add(Duration(minutes: widget.minutes)).hour.toString().padLeft(2, '0')}:${DateTime.now().add(Duration(minutes: widget.minutes)).minute.toString().padLeft(2, '0')}',
                          ),
                          _buildDetailRow(
                            AppStrings.t('ticket.amount'),
                            '${widget.price.toStringAsFixed(2)} €',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Botones
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _printTicket,
                          icon: const Icon(Icons.print),
                          label: Text(AppStrings.t('ticket.print')),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _ok,
                              child: Text(AppStrings.t('ticket.ok')),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: _newParking,
                              child: Text(AppStrings.t('ticket.new_parking')),
                            ),
                          ),
                        ],
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