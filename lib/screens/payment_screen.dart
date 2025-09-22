import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.dart';
import '../data/models.dart';
import '../data/mock_data.dart';
import '../widgets/top_bar.dart';
import '../services/websocket_service.dart';
import '../services/local_storage_service.dart';

class PaymentScreen extends StatefulWidget {
  final bool isExtend;
  final int minutes;
  final double price;
  final String zoneId;
  final String plate;

  const PaymentScreen({
    super.key,
    required this.isExtend,
    required this.minutes,
    required this.price,
    required this.zoneId,
    required this.plate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentMethod = 'cash';
  double _insertedAmount = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Inicializar contexto de pago
    AppState.currentPayment = PaymentContext(
      isExtend: widget.isExtend,
      plate: widget.plate,
      zoneId: widget.zoneId,
      minutes: widget.minutes,
      price: widget.price,
      insertedAmount: _insertedAmount,
      paymentMethod: _paymentMethod,
    );
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _paymentMethod = method;
      AppState.currentPayment = AppState.currentPayment?.copyWith(
        paymentMethod: method,
      );
    });
  }

  void _insertCoin(double amount) {
    setState(() {
      _insertedAmount += amount;
      AppState.currentPayment = AppState.currentPayment?.copyWith(
        insertedAmount: _insertedAmount,
      );
    });

    // Si se excedió el precio, simular devolución de cambio
    if (_insertedAmount > widget.price) {
      _simulateChangeReturn();
    }
  }

  void _simulateChangeReturn() {
    final change = _insertedAmount - widget.price;
    
    // Mostrar diálogo de devolución de cambio
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.green),
            const SizedBox(width: 8),
            Text('Devolución de Cambio'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Se ha insertado más dinero del necesario.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.money, color: Colors.green[800]),
                  const SizedBox(width: 8),
                  Text(
                    'Cambio: ${change.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'El cambio se devolverá automáticamente.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Ajustar el monto insertado al precio exacto
              setState(() {
                _insertedAmount = widget.price;
                AppState.currentPayment = AppState.currentPayment?.copyWith(
                  insertedAmount: _insertedAmount,
                );
              });
            },
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _payNow() {
    if (_canPay()) {
      setState(() {
        _isProcessing = true;
      });

      // Simular procesamiento de pago
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          // Crear sesión si no es extensión
          if (!widget.isExtend) {
            final session = Session(
              plate: widget.plate,
              zoneId: widget.zoneId,
              start: DateTime.now(),
              end: DateTime.now().add(Duration(minutes: widget.minutes)),
              totalPrice: widget.price,
              paymentMethod: _paymentMethod,
            );
            MockData.addSession(session);
            print('💾 Sesión guardada: ${session.plate} en zona ${session.zoneId}');
            print('📊 Total de sesiones activas: ${AppState.activeSessions.length}');
            
            // Guardar sesiones en almacenamiento local
            await LocalStorageService.saveSessions();
          }

          // Ir al ticket
          context.push('/ticket', extra: {
            'extend': widget.isExtend,
            'matricula': widget.plate,
            'zonaId': widget.zoneId,
            'minutos': widget.minutes,
            'precio': widget.price,
          });
        }
      });
    }
  }

  bool _canPay() {
    if (_paymentMethod == 'cash') {
      return _insertedAmount >= widget.price;
    } else {
      return true; // Chip+PIN y Contactless siempre pueden pagar
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

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: AppStrings.t('pay.title'),
            showBackButton: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Información del pago
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.isExtend
                              ? AppStrings.t('pay.extend_session')
                              : AppStrings.t('pay.new_parking'),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.t('pay.zone'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              zone?.name ?? '',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.t('pay.duration'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              _formatDuration(widget.minutes),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.t('pay.total'),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.price.toStringAsFixed(2)} €',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Métodos de pago
                  Text(
                    AppStrings.t('pay.select_method'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentMethodCard(
                          'cash',
                          Icons.monetization_on,
                          AppStrings.t('pay.method.cash'),
                          _paymentMethod == 'cash',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentMethodCard(
                          'chip',
                          Icons.credit_card,
                          AppStrings.t('pay.method.chip'),
                          _paymentMethod == 'chip',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentMethodCard(
                          'contactless',
                          Icons.tap_and_play,
                          AppStrings.t('pay.method.contactless'),
                          _paymentMethod == 'contactless',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Insertar monedas (solo para pago en efectivo)
                  if (_paymentMethod == 'cash') ...[
                    Text(
                      AppStrings.t('pay.insert_coins'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botones de monedas
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildCoinButton(0.10, '10c'),
                        _buildCoinButton(0.20, '20c'),
                        _buildCoinButton(0.50, '50c'),
                        _buildCoinButton(1.00, '1€'),
                        _buildCoinButton(2.00, '2€'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Cantidad insertada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _insertedAmount >= widget.price 
                            ? Colors.green[100]
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: _insertedAmount >= widget.price 
                              ? Colors.green
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.t('pay.inserted'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${_insertedAmount.toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _insertedAmount >= widget.price
                                  ? Colors.green[800]
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Información de estado
                    if (_insertedAmount < widget.price) ...[
                      Text(
                        AppStrings.t('pay.remaining') + ': ${(widget.price - _insertedAmount).toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ] else if (_insertedAmount == widget.price) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '¡Cantidad exacta! Puedes pagar ahora',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.monetization_on, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Cambio: ${(_insertedAmount - widget.price).toStringAsFixed(2)} €',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  const Spacer(),
                  // Botón de pago
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: FilledButton(
                      onPressed: _canPay() && !_isProcessing ? _payNow : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _canPay() 
                            ? (_insertedAmount == widget.price 
                                ? Colors.green 
                                : (_insertedAmount > widget.price 
                                    ? Colors.orange 
                                    : null))
                            : null,
                        foregroundColor: _canPay() 
                            ? Colors.white 
                            : null,
                      ),
                      child: _isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(AppStrings.t('pay.authorizing')),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_canPay()) ...[
                                  Icon(
                                    _insertedAmount == widget.price 
                                        ? Icons.check_circle
                                        : (_insertedAmount > widget.price 
                                            ? Icons.warning 
                                            : Icons.payment),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  _isProcessing 
                                      ? AppStrings.t('pay.authorizing')
                                      : (_insertedAmount == widget.price 
                                          ? AppStrings.t('pay.pay_exact')
                                          : (_insertedAmount > widget.price 
                                              ? AppStrings.t('pay.pay_change')
                                              : AppStrings.t('pay.pay_now'))),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón cancelar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(AppStrings.t('pay.cancel')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String method, IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectPaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinButton(double amount, String label) {
    // Deshabilitar botones cuando se alcance o supere el precio exacto
    // Una vez alcanzado el precio, no se pueden insertar más monedas
    final isDisabled = _insertedAmount >= widget.price;
    final isCloseToPrice = _insertedAmount >= widget.price - 0.50 && _insertedAmount < widget.price;
    
    return ElevatedButton(
      onPressed: isDisabled ? null : () => _insertCoin(amount),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(80, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: isDisabled 
            ? Colors.grey[300] 
            : (_insertedAmount >= widget.price ? Colors.green[100] : (isCloseToPrice ? Colors.orange[100] : Colors.blue[50])),
        foregroundColor: isDisabled 
            ? Colors.grey[600] 
            : (_insertedAmount >= widget.price ? Colors.green[800] : (isCloseToPrice ? Colors.orange[800] : Colors.blue[700])),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.grey[600] : null,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}€',
            style: TextStyle(
              fontSize: 12,
              color: isDisabled ? Colors.grey[600] : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}